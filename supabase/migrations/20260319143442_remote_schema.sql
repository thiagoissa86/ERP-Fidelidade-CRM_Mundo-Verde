alter table "public"."clientes" add column "telefone_normalizado" text;

alter table "public"."produtos" add column "search_vector" tsvector;

CREATE INDEX idx_clientes_telefone_normalizado ON public.clientes USING btree (telefone_normalizado);

CREATE INDEX idx_produtos_search ON public.produtos USING gin (search_vector);

CREATE INDEX idx_produtos_search_vector ON public.produtos USING gin (search_vector);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.atualizar_search_vector_produtos()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.search_vector :=
    to_tsvector(
      'portuguese',
      coalesce(NEW.nome, '') || ' ' ||
      coalesce(NEW.marca, '') || ' ' ||
      coalesce(NEW.descricao_produto, '') || ' ' ||
      coalesce(NEW.beneficios, '') || ' ' ||
      coalesce(NEW.publico_indicado, '') || ' ' ||
      coalesce(NEW.objetivo_produto, '') || ' ' ||
      coalesce(array_to_string(NEW.palavras_chave, ' '), '')
    );
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.baixar_estoque()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE produtos
  SET estoque_atual = estoque_atual - NEW.quantidade
  WHERE id = NEW.produto_id;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.baixar_estoque_apos_item_venda()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE public.produtos
  SET estoque_atual = coalesce(estoque_atual, 0) - coalesce(NEW.quantidade, 0)
  WHERE id = NEW.produto_id;

  RETURN NEW;
END;
$function$
;

CREATE TRIGGER trg_baixa_estoque AFTER INSERT ON public.itens_venda FOR EACH ROW EXECUTE FUNCTION public.baixar_estoque();

CREATE TRIGGER trg_baixar_estoque_item_venda AFTER INSERT ON public.itens_venda FOR EACH ROW EXECUTE FUNCTION public.baixar_estoque_apos_item_venda();

CREATE TRIGGER trg_produtos_search_vector BEFORE INSERT OR UPDATE ON public.produtos FOR EACH ROW EXECUTE FUNCTION public.atualizar_search_vector_produtos();


