 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/supabase/migrations/20260321_02_sincronizar_fidelidade.sql b/supabase/migrations/20260321_02_sincronizar_fidelidade.sql
index e69de29bb2d1d6434b8b29ae775ad8c2e48c5391..e019b5a0b98996494f3d957dbb8f55091f61813d 100644
--- a/supabase/migrations/20260321_02_sincronizar_fidelidade.sql
+++ b/supabase/migrations/20260321_02_sincronizar_fidelidade.sql
@@ -0,0 +1,200 @@
+-- Migration 02: sincronizar fidelidade a partir das movimentações
+-- Objetivos:
+-- 1) evitar divergência entre carteiras_fidelidade e movimentacoes_fidelidade
+-- 2) impedir movimentações que levem saldo abaixo de zero
+-- 3) manter compatibilidade com o modelo atual, sem criar novas tabelas
+
+begin;
+
+-- ---------------------------------------------------------------------------
+-- BLOCO 1: constraints mínimas para movimentações
+-- ---------------------------------------------------------------------------
+
+alter table public.movimentacoes_fidelidade
+  drop constraint if exists chk_movimentacoes_valor_nao_negativo;
+
+alter table public.movimentacoes_fidelidade
+  add constraint chk_movimentacoes_valor_nao_negativo
+  check (valor >= 0);
+
+-- ---------------------------------------------------------------------------
+-- BLOCO 2: funções auxiliares de recálculo da carteira
+-- ---------------------------------------------------------------------------
+
+create or replace function public.recalcular_carteira_fidelidade(p_carteira_id uuid)
+returns void
+language plpgsql
+as $function$
+declare
+  v_cliente_id uuid;
+  v_saldo_atual numeric(10,2);
+  v_total_credito_compra numeric(10,2);
+  v_total_bonus numeric(10,2);
+  v_total_ajuste numeric(10,2);
+  v_total_uso_credito numeric(10,2);
+  v_total_expiracao numeric(10,2);
+begin
+  select cliente_id
+    into v_cliente_id
+  from public.carteiras_fidelidade
+  where id = p_carteira_id;
+
+  if v_cliente_id is null then
+    raise exception 'Carteira de fidelidade não encontrada: %', p_carteira_id;
+  end if;
+
+  select
+    coalesce(sum(
+      case
+        when tipo_movimentacao in ('credito_compra', 'bonus', 'ajuste_manual') then valor
+        when tipo_movimentacao in ('uso_credito', 'expiracao') then -valor
+        else 0
+      end
+    ), 0),
+    coalesce(sum(case when tipo_movimentacao = 'credito_compra' then valor else 0 end), 0),
+    coalesce(sum(case when tipo_movimentacao = 'bonus' then valor else 0 end), 0),
+    coalesce(sum(case when tipo_movimentacao = 'ajuste_manual' then valor else 0 end), 0),
+    coalesce(sum(case when tipo_movimentacao = 'uso_credito' then valor else 0 end), 0),
+    coalesce(sum(case when tipo_movimentacao = 'expiracao' then valor else 0 end), 0)
+  into
+    v_saldo_atual,
+    v_total_credito_compra,
+    v_total_bonus,
+    v_total_ajuste,
+    v_total_uso_credito,
+    v_total_expiracao
+  from public.movimentacoes_fidelidade
+  where carteira_fidelidade_id = p_carteira_id;
+
+  update public.carteiras_fidelidade
+     set saldo_atual = v_saldo_atual,
+         saldo_gerado_venda = v_total_credito_compra,
+         saldo_total_gerado = (v_total_credito_compra + v_total_bonus + v_total_ajuste),
+         saldo_total_utilizado = (v_total_uso_credito + v_total_expiracao),
+         saldo_utilizado_venda = v_total_uso_credito
+   where id = p_carteira_id;
+end;
+$function$;
+
+comment on function public.recalcular_carteira_fidelidade(uuid) is
+'Recalcula campos materializados de carteiras_fidelidade com base no ledger de movimentacoes_fidelidade.';
+
+-- ---------------------------------------------------------------------------
+-- BLOCO 3: validação preventiva antes de gravar movimentações
+-- ---------------------------------------------------------------------------
+
+create or replace function public.validar_movimentacao_fidelidade()
+returns trigger
+language plpgsql
+as $function$
+declare
+  v_saldo_disponivel numeric(10,2);
+  v_delta_antigo numeric(10,2);
+begin
+  if new.valor is null or new.valor < 0 then
+    raise exception 'Valor da movimentação de fidelidade deve ser maior ou igual a zero.';
+  end if;
+
+  if not exists (
+    select 1
+    from public.carteiras_fidelidade cf
+    where cf.id = new.carteira_fidelidade_id
+      and cf.cliente_id = new.cliente_id
+  ) then
+    raise exception 'Carteira de fidelidade incompatível com o cliente informado.';
+  end if;
+
+  select saldo_atual
+    into v_saldo_disponivel
+  from public.carteiras_fidelidade
+  where id = new.carteira_fidelidade_id
+  for update;
+
+  if not found then
+    raise exception 'Carteira de fidelidade inexistente.';
+  end if;
+
+  if tg_op = 'UPDATE' then
+    v_delta_antigo := case
+      when old.tipo_movimentacao in ('credito_compra', 'bonus', 'ajuste_manual') then old.valor
+      when old.tipo_movimentacao in ('uso_credito', 'expiracao') then -old.valor
+      else 0
+    end;
+
+    v_saldo_disponivel := coalesce(v_saldo_disponivel, 0) - coalesce(v_delta_antigo, 0);
+  end if;
+
+  if new.tipo_movimentacao in ('uso_credito', 'expiracao') then
+    if coalesce(v_saldo_disponivel, 0) < coalesce(new.valor, 0) then
+      raise exception 'Saldo insuficiente na carteira de fidelidade.';
+    end if;
+  end if;
+
+  return new;
+end;
+$function$;
+
+comment on function public.validar_movimentacao_fidelidade() is
+'Impede movimentações de fidelidade inválidas e bloqueia débitos acima do saldo disponível.';
+
+-- ---------------------------------------------------------------------------
+-- BLOCO 4: sincronização automática da carteira após mudanças no ledger
+-- ---------------------------------------------------------------------------
+
+create or replace function public.sincronizar_carteira_fidelidade()
+returns trigger
+language plpgsql
+as $function$
+begin
+  if tg_op = 'DELETE' then
+    perform public.recalcular_carteira_fidelidade(old.carteira_fidelidade_id);
+    return old;
+  end if;
+
+  if tg_op = 'UPDATE' and old.carteira_fidelidade_id is distinct from new.carteira_fidelidade_id then
+    perform public.recalcular_carteira_fidelidade(old.carteira_fidelidade_id);
+  end if;
+
+  perform public.recalcular_carteira_fidelidade(new.carteira_fidelidade_id);
+  return new;
+end;
+$function$;
+
+comment on function public.sincronizar_carteira_fidelidade() is
+'Sincroniza os saldos materializados da carteira após insert/update/delete em movimentacoes_fidelidade.';
+
+-- ---------------------------------------------------------------------------
+-- BLOCO 5: triggers finais da fidelidade
+-- ---------------------------------------------------------------------------
+
+drop trigger if exists trg_validar_movimentacao_fidelidade on public.movimentacoes_fidelidade;
+drop trigger if exists trg_sincronizar_carteira_fidelidade on public.movimentacoes_fidelidade;
+
+create trigger trg_validar_movimentacao_fidelidade
+before insert or update on public.movimentacoes_fidelidade
+for each row
+execute function public.validar_movimentacao_fidelidade();
+
+create trigger trg_sincronizar_carteira_fidelidade
+after insert or update or delete on public.movimentacoes_fidelidade
+for each row
+execute function public.sincronizar_carteira_fidelidade();
+
+-- ---------------------------------------------------------------------------
+-- BLOCO 6: reconciliação inicial dos dados existentes
+-- ---------------------------------------------------------------------------
+
+do $$
+declare
+  r record;
+begin
+  for r in
+    select id
+    from public.carteiras_fidelidade
+  loop
+    perform public.recalcular_carteira_fidelidade(r.id);
+  end loop;
+end;
+$$;
+
+commit;
 
EOF
)