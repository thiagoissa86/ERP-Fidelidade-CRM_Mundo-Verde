 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/supabase/migrations/20260321_01_corrigir_estoque_itens_venda.sql b/supabase/migrations/20260321_01_corrigir_estoque_itens_venda.sql
index e69de29bb2d1d6434b8b29ae775ad8c2e48c5391..d5a8da0fbaef910765478693652bcc7d5920f7a8 100644
--- a/supabase/migrations/20260321_01_corrigir_estoque_itens_venda.sql
+++ b/supabase/migrations/20260321_01_corrigir_estoque_itens_venda.sql
@@ -0,0 +1,162 @@
+-- Migration 01: corrigir estoque em itens de venda
+-- Objetivos:
+-- 1) remover duplicidade de triggers de estoque
+-- 2) impedir venda com produto inexistente, inativo ou sem estoque suficiente
+-- 3) centralizar sincronização de estoque em um único trigger
+-- 4) adicionar validações mínimas e seguras em itens_venda
+
+begin;
+
+-- ---------------------------------------------------------------------------
+-- BLOCO 1: limpeza do comportamento antigo de estoque
+-- ---------------------------------------------------------------------------
+
+drop trigger if exists trg_baixa_estoque on public.itens_venda;
+drop trigger if exists trg_baixar_estoque_item_venda on public.itens_venda;
+drop trigger if exists trg_validar_item_venda_estoque on public.itens_venda;
+drop trigger if exists trg_sincronizar_estoque_item_venda on public.itens_venda;
+
+drop function if exists public.baixar_estoque();
+drop function if exists public.baixar_estoque_apos_item_venda();
+drop function if exists public.validar_item_venda_estoque();
+drop function if exists public.sincronizar_estoque_item_venda();
+
+-- ---------------------------------------------------------------------------
+-- BLOCO 2: constraints mínimas de integridade para itens_venda
+-- ---------------------------------------------------------------------------
+
+alter table public.itens_venda
+  drop constraint if exists chk_itens_venda_quantidade_positiva;
+
+alter table public.itens_venda
+  add constraint chk_itens_venda_quantidade_positiva
+  check (quantidade > 0);
+
+alter table public.itens_venda
+  drop constraint if exists chk_itens_venda_preco_unitario_nao_negativo;
+
+alter table public.itens_venda
+  add constraint chk_itens_venda_preco_unitario_nao_negativo
+  check (preco_unitario >= 0);
+
+alter table public.itens_venda
+  drop constraint if exists chk_itens_venda_desconto_nao_negativo;
+
+alter table public.itens_venda
+  add constraint chk_itens_venda_desconto_nao_negativo
+  check (desconto >= 0);
+
+alter table public.itens_venda
+  drop constraint if exists chk_itens_venda_valor_total_nao_negativo;
+
+alter table public.itens_venda
+  add constraint chk_itens_venda_valor_total_nao_negativo
+  check (valor_total >= 0);
+
+-- ---------------------------------------------------------------------------
+-- BLOCO 3: validação prévia de produto e estoque
+-- ---------------------------------------------------------------------------
+
+create or replace function public.validar_item_venda_estoque()
+returns trigger
+language plpgsql
+as $function$
+declare
+  v_estoque_atual numeric;
+  v_produto_ativo boolean;
+begin
+  if new.quantidade is null or new.quantidade <= 0 then
+    raise exception 'Quantidade do item deve ser maior que zero.';
+  end if;
+
+  select p.estoque_atual, p.ativo
+    into v_estoque_atual, v_produto_ativo
+  from public.produtos p
+  where p.id = new.produto_id
+  for update;
+
+  if not found then
+    raise exception 'Produto inexistente para o item da venda.';
+  end if;
+
+  if coalesce(v_produto_ativo, false) = false then
+    raise exception 'Produto inativo e indisponível para venda.';
+  end if;
+
+  if tg_op = 'UPDATE' then
+    if old.produto_id = new.produto_id then
+      v_estoque_atual := v_estoque_atual + coalesce(old.quantidade, 0);
+    else
+      perform 1
+      from public.produtos p_old
+      where p_old.id = old.produto_id
+      for update;
+    end if;
+  end if;
+
+  if coalesce(v_estoque_atual, 0) < coalesce(new.quantidade, 0) then
+    raise exception 'Estoque insuficiente para o produto %.', new.produto_id;
+  end if;
+
+  return new;
+end;
+$function$;
+
+comment on function public.validar_item_venda_estoque() is
+'Valida produto, status e estoque disponível antes de inserir/atualizar itens_venda.';
+
+-- ---------------------------------------------------------------------------
+-- BLOCO 4: sincronização única de estoque para insert/update/delete
+-- ---------------------------------------------------------------------------
+
+create or replace function public.sincronizar_estoque_item_venda()
+returns trigger
+language plpgsql
+as $function$
+begin
+  if tg_op = 'INSERT' then
+    update public.produtos
+       set estoque_atual = coalesce(estoque_atual, 0) - coalesce(new.quantidade, 0)
+     where id = new.produto_id;
+
+    return new;
+  elsif tg_op = 'UPDATE' then
+    update public.produtos
+       set estoque_atual = coalesce(estoque_atual, 0) + coalesce(old.quantidade, 0)
+     where id = old.produto_id;
+
+    update public.produtos
+       set estoque_atual = coalesce(estoque_atual, 0) - coalesce(new.quantidade, 0)
+     where id = new.produto_id;
+
+    return new;
+  elsif tg_op = 'DELETE' then
+    update public.produtos
+       set estoque_atual = coalesce(estoque_atual, 0) + coalesce(old.quantidade, 0)
+     where id = old.produto_id;
+
+    return old;
+  end if;
+
+  return null;
+end;
+$function$;
+
+comment on function public.sincronizar_estoque_item_venda() is
+'Sincroniza estoque de produtos a partir de insert/update/delete em itens_venda, sem duplicidade de baixa.';
+
+-- ---------------------------------------------------------------------------
+-- BLOCO 5: triggers finais
+-- ---------------------------------------------------------------------------
+
+create trigger trg_validar_item_venda_estoque
+before insert or update on public.itens_venda
+for each row
+execute function public.validar_item_venda_estoque();
+
+create trigger trg_sincronizar_estoque_item_venda
+after insert or update or delete on public.itens_venda
+for each row
+execute function public.sincronizar_estoque_item_venda();
+
+commit;
 
EOF
)