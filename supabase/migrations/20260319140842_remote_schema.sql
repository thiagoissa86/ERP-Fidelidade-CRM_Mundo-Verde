


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."usuario_tem_perfil"("perfil_buscado" "text") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.perfis_acesso
    WHERE id = auth.uid()
      AND perfil = perfil_buscado
  );
$$;


ALTER FUNCTION "public"."usuario_tem_perfil"("perfil_buscado" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."usuario_tem_um_dos_perfis"("perfis" "text"[]) RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.perfis_acesso
    WHERE id = auth.uid()
      AND perfil = ANY(perfis)
  );
$$;


ALTER FUNCTION "public"."usuario_tem_um_dos_perfis"("perfis" "text"[]) OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."campanhas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "usuario_id" "uuid",
    "nome" "text" NOT NULL,
    "tipo_campanha" "text",
    "canal" "text" DEFAULT 'whatsapp'::"text" NOT NULL,
    "objetivo" "text",
    "status" "text" DEFAULT 'rascunho'::"text" NOT NULL,
    "data_inicio" timestamp without time zone,
    "data_fim" timestamp without time zone,
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_campanhas_canal" CHECK (("canal" = ANY (ARRAY['whatsapp'::"text", 'instagram'::"text", 'email'::"text", 'interno'::"text"]))),
    CONSTRAINT "chk_campanhas_status" CHECK (("status" = ANY (ARRAY['rascunho'::"text", 'ativa'::"text", 'pausada'::"text", 'encerrada'::"text"])))
);


ALTER TABLE "public"."campanhas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."carteiras_fidelidade" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "cliente_id" "uuid" NOT NULL,
    "saldo_atual" numeric(10,2) DEFAULT 0 NOT NULL,
    "saldo_gerado_venda" numeric(10,2) DEFAULT 0 NOT NULL,
    "saldo_total_utilizado" numeric(10,2) DEFAULT 0 NOT NULL,
    "status" "text" DEFAULT 'ativa'::"text" NOT NULL,
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    "atualizado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    "saldo_total_gerado" numeric,
    "saldo_utilizado_venda" numeric,
    CONSTRAINT "chk_carteiras_status" CHECK (("status" = ANY (ARRAY['ativa'::"text", 'inativa'::"text", 'bloqueada'::"text"])))
);


ALTER TABLE "public"."carteiras_fidelidade" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."categorias_produtos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "descricao" "text",
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    "atualizado_em" timestamp without time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."categorias_produtos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."clientes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome_completo" "text" NOT NULL,
    "telefone" "text",
    "email" "text",
    "cpf" "text",
    "data_nascimento" "date",
    "canal_origem" "text",
    "aceita_whatsapp" boolean DEFAULT false NOT NULL,
    "aceita_marketing" boolean DEFAULT false NOT NULL,
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    "atualizado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_clientes_canal_origem" CHECK ((("canal_origem" IS NULL) OR ("canal_origem" = ANY (ARRAY['loja_fisica'::"text", 'whatsapp'::"text", 'instagram'::"text", 'outro'::"text"]))))
);


ALTER TABLE "public"."clientes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."envios_campanha" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "campanha_id" "uuid" NOT NULL,
    "cliente_id" "uuid" NOT NULL,
    "conteudo" "text",
    "status_envio" "text" DEFAULT 'pendente'::"text" NOT NULL,
    "status_resposta" "text" DEFAULT 'sem_resposta'::"text" NOT NULL,
    "status_conversao" "text" DEFAULT 'nao_convertido'::"text" NOT NULL,
    "enviado_em" timestamp without time zone,
    CONSTRAINT "chk_envios_status_conversao" CHECK (("status_conversao" = ANY (ARRAY['nao_convertido'::"text", 'convertido'::"text"]))),
    CONSTRAINT "chk_envios_status_envio" CHECK (("status_envio" = ANY (ARRAY['pendente'::"text", 'enviado'::"text", 'erro'::"text"]))),
    CONSTRAINT "chk_envios_status_resposta" CHECK (("status_resposta" = ANY (ARRAY['sem_resposta'::"text", 'respondido'::"text"])))
);


ALTER TABLE "public"."envios_campanha" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."indicacoes_clientes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "cliente_id" "uuid" NOT NULL,
    "profissional_id" "uuid" NOT NULL,
    "origem_indicacao" "text",
    "observacoes" "text",
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."indicacoes_clientes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."integration_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sistema_origem" "text" NOT NULL,
    "entidade" "text" NOT NULL,
    "referencia_id" "text",
    "status" "text" NOT NULL,
    "mensagem" "text",
    "processado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_integration_logs_status" CHECK (("status" = ANY (ARRAY['sucesso'::"text", 'erro'::"text", 'pendente'::"text"])))
);


ALTER TABLE "public"."integration_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."interacoes_clientes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "cliente_id" "uuid" NOT NULL,
    "usuario_id" "uuid",
    "canal" "text" NOT NULL,
    "tipo_interacao" "text",
    "resumo" "text",
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_interacoes_canal" CHECK (("canal" = ANY (ARRAY['whatsapp'::"text", 'instagram'::"text", 'loja'::"text", 'telefone'::"text", 'campanha'::"text", 'outro'::"text"])))
);


ALTER TABLE "public"."interacoes_clientes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."itens_venda" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "venda_id" "uuid" NOT NULL,
    "produto_id" "uuid" NOT NULL,
    "quantidade" numeric(10,3) DEFAULT 1 NOT NULL,
    "preco_unitario" numeric(10,2) DEFAULT 0 NOT NULL,
    "desconto" numeric(10,2) DEFAULT 0 NOT NULL,
    "valor_total" numeric(10,2) DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."itens_venda" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."mensagens_ia" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "cliente_id" "uuid" NOT NULL,
    "campanha_id" "uuid",
    "usuario_id" "uuid",
    "tipo_mensagem" "text" DEFAULT 'outro'::"text" NOT NULL,
    "mensagem" "text" NOT NULL,
    "origem" "text" DEFAULT 'ia'::"text" NOT NULL,
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_mensagens_origem" CHECK (("origem" = ANY (ARRAY['ia'::"text", 'manual'::"text", 'automatizacao'::"text"]))),
    CONSTRAINT "chk_mensagens_tipo" CHECK (("tipo_mensagem" = ANY (ARRAY['recomendacao'::"text", 'reativacao'::"text", 'aniversario'::"text", 'pos_venda'::"text", 'promocao'::"text", 'outro'::"text"])))
);


ALTER TABLE "public"."mensagens_ia" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."movimentacoes_fidelidade" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "carteira_fidelidade_id" "uuid" NOT NULL,
    "cliente_id" "uuid" NOT NULL,
    "venda_id" "uuid",
    "tipo_movimentacao" "text" NOT NULL,
    "valor" numeric(10,2) DEFAULT 0 NOT NULL,
    "descricao" "text",
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_movimentacoes_tipo" CHECK (("tipo_movimentacao" = ANY (ARRAY['credito_compra'::"text", 'uso_credito'::"text", 'ajuste_manual'::"text", 'expiracao'::"text", 'bonus'::"text"])))
);


ALTER TABLE "public"."movimentacoes_fidelidade" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."perfis_acesso" (
    "id" "uuid" NOT NULL,
    "perfil" "text" NOT NULL,
    "nome" "text",
    "criado_em" timestamp without time zone DEFAULT "now"(),
    CONSTRAINT "perfis_acesso_perfil_check" CHECK (("perfil" = ANY (ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text", 'marketing'::"text"])))
);


ALTER TABLE "public"."perfis_acesso" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pontuacoes_profissionais" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profissional_id" "uuid" NOT NULL,
    "cliente_id" "uuid" NOT NULL,
    "venda_id" "uuid",
    "tipo_pontuacao" "text",
    "valor_base_venda" numeric(10,2) DEFAULT 0 NOT NULL,
    "pontos_gerados" numeric(10,2) DEFAULT 0 NOT NULL,
    "saldo_gerado" numeric(10,2) DEFAULT 0 NOT NULL,
    "status" "text" DEFAULT 'pendente'::"text" NOT NULL,
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_pontuacoes_status" CHECK (("status" = ANY (ARRAY['pendente'::"text", 'aprovado'::"text", 'pago'::"text", 'cancelado'::"text"])))
);


ALTER TABLE "public"."pontuacoes_profissionais" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."produtos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "microvix_id" "text",
    "categoria_id" "uuid",
    "sku" "text",
    "codigo_barras" "text",
    "nome" "text" NOT NULL,
    "marca" "text",
    "preco_custo" numeric(10,2),
    "preco_venda" numeric(10,2),
    "estoque_atual" numeric DEFAULT 0 NOT NULL,
    "descricao_produto" "text",
    "beneficios" "text",
    "publico_indicado" "text",
    "objetivo_produto" "text",
    "palavras_chave" "text"[],
    "produtos_relacionados" "text"[],
    "ativo" boolean DEFAULT true NOT NULL,
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    "atualizado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    "site_oficial_marca" "text"
);


ALTER TABLE "public"."produtos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profissionais_indicadores" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "telefone" "text",
    "email" "text",
    "tipo_profissional" "text",
    "documento" "text",
    "chave_pix" "text",
    "ativo" boolean DEFAULT true NOT NULL,
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    "atualizado_em" timestamp without time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."profissionais_indicadores" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."recomendacoes_ia" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "cliente_id" "uuid" NOT NULL,
    "produto_id" "uuid",
    "tipo_recomendacao" "text" NOT NULL,
    "texto_recomendacao" "text",
    "confianca" numeric(5,2),
    "status" "text" DEFAULT 'pendente'::"text" NOT NULL,
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_recomendacoes_status" CHECK (("status" = ANY (ARRAY['pendente'::"text", 'utilizada'::"text", 'ignorada'::"text"]))),
    CONSTRAINT "chk_recomendacoes_tipo" CHECK (("tipo_recomendacao" = ANY (ARRAY['produto'::"text", 'recompra'::"text", 'upsell'::"text", 'cross_sell'::"text", 'acao_comercial'::"text"])))
);


ALTER TABLE "public"."recomendacoes_ia" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."usuarios" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "email" "text" NOT NULL,
    "telefone" "text",
    "perfil" "text" NOT NULL,
    "ativo" boolean DEFAULT true NOT NULL,
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    "atualizado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_usuarios_perfil" CHECK (("perfil" = ANY (ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text", 'marketing'::"text"])))
);


ALTER TABLE "public"."usuarios" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vendas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "microvix_venda_id" "text",
    "cliente_id" "uuid",
    "canal_venda" "text" DEFAULT 'loja_fisica'::"text" NOT NULL,
    "data_venda" timestamp without time zone NOT NULL,
    "valor_bruto" numeric(10,2) DEFAULT 0 NOT NULL,
    "desconto" numeric(10,2) DEFAULT 0 NOT NULL,
    "valor_liquido" numeric(10,2) DEFAULT 0 NOT NULL,
    "forma_pagamento" "text",
    "cliente_identificado" boolean DEFAULT false NOT NULL,
    "criado_em" timestamp without time zone DEFAULT "now"() NOT NULL,
    "numero_cupom" "text",
    "imagem_cupom_url" "text",
    "origem_registro" "text",
    CONSTRAINT "chk_vendas_canal_venda" CHECK (("canal_venda" = ANY (ARRAY['loja_fisica'::"text", 'whatsapp'::"text", 'instagram'::"text"])))
);


ALTER TABLE "public"."vendas" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vw_clientes_indicados" AS
 SELECT "c"."id" AS "cliente_id",
    "c"."nome_completo" AS "cliente_nome",
    "p"."id" AS "profissional_id",
    "p"."nome" AS "profissional_nome",
    "p"."tipo_profissional",
    "ic"."origem_indicacao",
    "ic"."criado_em" AS "data_indicacao"
   FROM (("public"."indicacoes_clientes" "ic"
     JOIN "public"."clientes" "c" ON (("c"."id" = "ic"."cliente_id")))
     JOIN "public"."profissionais_indicadores" "p" ON (("p"."id" = "ic"."profissional_id")));


ALTER VIEW "public"."vw_clientes_indicados" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vw_resumo_fidelidade_clientes" AS
 SELECT "c"."id" AS "cliente_id",
    "c"."nome_completo",
    "c"."telefone",
    "cf"."saldo_atual",
    "cf"."saldo_gerado_venda" AS "saldo_total_gerado",
    "cf"."saldo_total_utilizado",
    "cf"."status"
   FROM ("public"."clientes" "c"
     LEFT JOIN "public"."carteiras_fidelidade" "cf" ON (("cf"."cliente_id" = "c"."id")));


ALTER VIEW "public"."vw_resumo_fidelidade_clientes" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vw_resumo_vendas_clientes" AS
 SELECT "c"."id" AS "cliente_id",
    "c"."nome_completo",
    "count"("v"."id") AS "total_vendas",
    COALESCE("sum"("v"."valor_liquido"), (0)::numeric) AS "valor_total_comprado",
    "max"("v"."data_venda") AS "ultima_compra"
   FROM ("public"."clientes" "c"
     LEFT JOIN "public"."vendas" "v" ON (("v"."cliente_id" = "c"."id")))
  GROUP BY "c"."id", "c"."nome_completo";


ALTER VIEW "public"."vw_resumo_vendas_clientes" OWNER TO "postgres";


ALTER TABLE ONLY "public"."campanhas"
    ADD CONSTRAINT "campanhas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."carteiras_fidelidade"
    ADD CONSTRAINT "carteiras_fidelidade_cliente_id_key" UNIQUE ("cliente_id");



ALTER TABLE ONLY "public"."carteiras_fidelidade"
    ADD CONSTRAINT "carteiras_fidelidade_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."categorias_produtos"
    ADD CONSTRAINT "categorias_produtos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."clientes"
    ADD CONSTRAINT "clientes_cpf_key" UNIQUE ("cpf");



ALTER TABLE ONLY "public"."clientes"
    ADD CONSTRAINT "clientes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."envios_campanha"
    ADD CONSTRAINT "envios_campanha_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."indicacoes_clientes"
    ADD CONSTRAINT "indicacoes_clientes_cliente_id_key" UNIQUE ("cliente_id");



ALTER TABLE ONLY "public"."indicacoes_clientes"
    ADD CONSTRAINT "indicacoes_clientes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."integration_logs"
    ADD CONSTRAINT "integration_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interacoes_clientes"
    ADD CONSTRAINT "interacoes_clientes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."itens_venda"
    ADD CONSTRAINT "itens_venda_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."mensagens_ia"
    ADD CONSTRAINT "mensagens_ia_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."movimentacoes_fidelidade"
    ADD CONSTRAINT "movimentacoes_fidelidade_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."perfis_acesso"
    ADD CONSTRAINT "perfis_acesso_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pontuacoes_profissionais"
    ADD CONSTRAINT "pontuacoes_profissionais_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."produtos"
    ADD CONSTRAINT "produtos_codigo_barras_key" UNIQUE ("codigo_barras");



ALTER TABLE ONLY "public"."produtos"
    ADD CONSTRAINT "produtos_microvix_id_key" UNIQUE ("microvix_id");



ALTER TABLE ONLY "public"."produtos"
    ADD CONSTRAINT "produtos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."produtos"
    ADD CONSTRAINT "produtos_sku_key" UNIQUE ("sku");



ALTER TABLE ONLY "public"."profissionais_indicadores"
    ADD CONSTRAINT "profissionais_indicadores_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."recomendacoes_ia"
    ADD CONSTRAINT "recomendacoes_ia_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."usuarios"
    ADD CONSTRAINT "usuarios_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."usuarios"
    ADD CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vendas"
    ADD CONSTRAINT "vendas_microvix_venda_id_key" UNIQUE ("microvix_venda_id");



ALTER TABLE ONLY "public"."vendas"
    ADD CONSTRAINT "vendas_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_campanhas_canal" ON "public"."campanhas" USING "btree" ("canal");



CREATE INDEX "idx_campanhas_nome" ON "public"."campanhas" USING "btree" ("nome");



CREATE INDEX "idx_campanhas_status" ON "public"."campanhas" USING "btree" ("status");



CREATE INDEX "idx_campanhas_usuario_id" ON "public"."campanhas" USING "btree" ("usuario_id");



CREATE INDEX "idx_carteiras_cliente_id" ON "public"."carteiras_fidelidade" USING "btree" ("cliente_id");



CREATE INDEX "idx_carteiras_status" ON "public"."carteiras_fidelidade" USING "btree" ("status");



CREATE UNIQUE INDEX "idx_categorias_nome" ON "public"."categorias_produtos" USING "btree" ("nome");



CREATE INDEX "idx_clientes_data_nascimento" ON "public"."clientes" USING "btree" ("data_nascimento");



CREATE INDEX "idx_clientes_email" ON "public"."clientes" USING "btree" ("email");



CREATE INDEX "idx_clientes_nome" ON "public"."clientes" USING "btree" ("nome_completo");



CREATE INDEX "idx_clientes_telefone" ON "public"."clientes" USING "btree" ("telefone");



CREATE INDEX "idx_envios_campanha_id" ON "public"."envios_campanha" USING "btree" ("campanha_id");



CREATE INDEX "idx_envios_cliente_id" ON "public"."envios_campanha" USING "btree" ("cliente_id");



CREATE INDEX "idx_envios_enviado_em" ON "public"."envios_campanha" USING "btree" ("enviado_em");



CREATE INDEX "idx_indicacoes_cliente_id" ON "public"."indicacoes_clientes" USING "btree" ("cliente_id");



CREATE INDEX "idx_indicacoes_profissional_id" ON "public"."indicacoes_clientes" USING "btree" ("profissional_id");



CREATE INDEX "idx_interacoes_canal" ON "public"."interacoes_clientes" USING "btree" ("canal");



CREATE INDEX "idx_interacoes_cliente_id" ON "public"."interacoes_clientes" USING "btree" ("cliente_id");



CREATE INDEX "idx_interacoes_criado_em" ON "public"."interacoes_clientes" USING "btree" ("criado_em");



CREATE INDEX "idx_interacoes_usuario_id" ON "public"."interacoes_clientes" USING "btree" ("usuario_id");



CREATE INDEX "idx_itens_venda_produto_id" ON "public"."itens_venda" USING "btree" ("produto_id");



CREATE INDEX "idx_itens_venda_venda_id" ON "public"."itens_venda" USING "btree" ("venda_id");



CREATE INDEX "idx_logs_entidade" ON "public"."integration_logs" USING "btree" ("entidade");



CREATE INDEX "idx_logs_processado_em" ON "public"."integration_logs" USING "btree" ("processado_em");



CREATE INDEX "idx_logs_sistema_origem" ON "public"."integration_logs" USING "btree" ("sistema_origem");



CREATE INDEX "idx_logs_status" ON "public"."integration_logs" USING "btree" ("status");



CREATE INDEX "idx_mensagens_campanha_id" ON "public"."mensagens_ia" USING "btree" ("campanha_id");



CREATE INDEX "idx_mensagens_cliente_id" ON "public"."mensagens_ia" USING "btree" ("cliente_id");



CREATE INDEX "idx_mensagens_tipo" ON "public"."mensagens_ia" USING "btree" ("tipo_mensagem");



CREATE INDEX "idx_mensagens_usuario_id" ON "public"."mensagens_ia" USING "btree" ("usuario_id");



CREATE INDEX "idx_movimentacoes_carteira_id" ON "public"."movimentacoes_fidelidade" USING "btree" ("carteira_fidelidade_id");



CREATE INDEX "idx_movimentacoes_cliente_id" ON "public"."movimentacoes_fidelidade" USING "btree" ("cliente_id");



CREATE INDEX "idx_movimentacoes_criado_em" ON "public"."movimentacoes_fidelidade" USING "btree" ("criado_em");



CREATE INDEX "idx_movimentacoes_tipo" ON "public"."movimentacoes_fidelidade" USING "btree" ("tipo_movimentacao");



CREATE INDEX "idx_movimentacoes_venda_id" ON "public"."movimentacoes_fidelidade" USING "btree" ("venda_id");



CREATE INDEX "idx_pontuacoes_cliente_id" ON "public"."pontuacoes_profissionais" USING "btree" ("cliente_id");



CREATE INDEX "idx_pontuacoes_profissional_id" ON "public"."pontuacoes_profissionais" USING "btree" ("profissional_id");



CREATE INDEX "idx_pontuacoes_status" ON "public"."pontuacoes_profissionais" USING "btree" ("status");



CREATE INDEX "idx_pontuacoes_venda_id" ON "public"."pontuacoes_profissionais" USING "btree" ("venda_id");



CREATE INDEX "idx_produtos_ativo" ON "public"."produtos" USING "btree" ("ativo");



CREATE INDEX "idx_produtos_categoria_id" ON "public"."produtos" USING "btree" ("categoria_id");



CREATE INDEX "idx_produtos_marca" ON "public"."produtos" USING "btree" ("marca");



CREATE INDEX "idx_produtos_nome" ON "public"."produtos" USING "btree" ("nome");



CREATE INDEX "idx_produtos_objetivo" ON "public"."produtos" USING "btree" ("objetivo_produto");



CREATE INDEX "idx_profissionais_ativo" ON "public"."profissionais_indicadores" USING "btree" ("ativo");



CREATE INDEX "idx_profissionais_nome" ON "public"."profissionais_indicadores" USING "btree" ("nome");



CREATE INDEX "idx_profissionais_tipo" ON "public"."profissionais_indicadores" USING "btree" ("tipo_profissional");



CREATE INDEX "idx_recomendacoes_cliente_id" ON "public"."recomendacoes_ia" USING "btree" ("cliente_id");



CREATE INDEX "idx_recomendacoes_produto_id" ON "public"."recomendacoes_ia" USING "btree" ("produto_id");



CREATE INDEX "idx_recomendacoes_status" ON "public"."recomendacoes_ia" USING "btree" ("status");



CREATE INDEX "idx_recomendacoes_tipo" ON "public"."recomendacoes_ia" USING "btree" ("tipo_recomendacao");



CREATE INDEX "idx_usuarios_ativo" ON "public"."usuarios" USING "btree" ("ativo");



CREATE INDEX "idx_usuarios_nome" ON "public"."usuarios" USING "btree" ("nome");



CREATE INDEX "idx_usuarios_perfil" ON "public"."usuarios" USING "btree" ("perfil");



CREATE INDEX "idx_vendas_canal_venda" ON "public"."vendas" USING "btree" ("canal_venda");



CREATE INDEX "idx_vendas_cliente_id" ON "public"."vendas" USING "btree" ("cliente_id");



CREATE INDEX "idx_vendas_cliente_identificado" ON "public"."vendas" USING "btree" ("cliente_identificado");



CREATE INDEX "idx_vendas_data_venda" ON "public"."vendas" USING "btree" ("data_venda");



CREATE OR REPLACE TRIGGER "trg_carteiras_updated_at" BEFORE UPDATE ON "public"."carteiras_fidelidade" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_categorias_updated_at" BEFORE UPDATE ON "public"."categorias_produtos" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_clientes_updated_at" BEFORE UPDATE ON "public"."clientes" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_produtos_updated_at" BEFORE UPDATE ON "public"."produtos" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_profissionais_updated_at" BEFORE UPDATE ON "public"."profissionais_indicadores" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_usuarios_updated_at" BEFORE UPDATE ON "public"."usuarios" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



ALTER TABLE ONLY "public"."campanhas"
    ADD CONSTRAINT "campanhas_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."carteiras_fidelidade"
    ADD CONSTRAINT "carteiras_fidelidade_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."envios_campanha"
    ADD CONSTRAINT "envios_campanha_campanha_id_fkey" FOREIGN KEY ("campanha_id") REFERENCES "public"."campanhas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."envios_campanha"
    ADD CONSTRAINT "envios_campanha_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."indicacoes_clientes"
    ADD CONSTRAINT "indicacoes_clientes_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."indicacoes_clientes"
    ADD CONSTRAINT "indicacoes_clientes_profissional_id_fkey" FOREIGN KEY ("profissional_id") REFERENCES "public"."profissionais_indicadores"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interacoes_clientes"
    ADD CONSTRAINT "interacoes_clientes_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interacoes_clientes"
    ADD CONSTRAINT "interacoes_clientes_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."itens_venda"
    ADD CONSTRAINT "itens_venda_produto_id_fkey" FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."itens_venda"
    ADD CONSTRAINT "itens_venda_venda_id_fkey" FOREIGN KEY ("venda_id") REFERENCES "public"."vendas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."mensagens_ia"
    ADD CONSTRAINT "mensagens_ia_campanha_id_fkey" FOREIGN KEY ("campanha_id") REFERENCES "public"."campanhas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."mensagens_ia"
    ADD CONSTRAINT "mensagens_ia_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."mensagens_ia"
    ADD CONSTRAINT "mensagens_ia_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."movimentacoes_fidelidade"
    ADD CONSTRAINT "movimentacoes_fidelidade_carteira_fidelidade_id_fkey" FOREIGN KEY ("carteira_fidelidade_id") REFERENCES "public"."carteiras_fidelidade"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."movimentacoes_fidelidade"
    ADD CONSTRAINT "movimentacoes_fidelidade_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."movimentacoes_fidelidade"
    ADD CONSTRAINT "movimentacoes_fidelidade_venda_id_fkey" FOREIGN KEY ("venda_id") REFERENCES "public"."vendas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."perfis_acesso"
    ADD CONSTRAINT "perfis_acesso_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pontuacoes_profissionais"
    ADD CONSTRAINT "pontuacoes_profissionais_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pontuacoes_profissionais"
    ADD CONSTRAINT "pontuacoes_profissionais_profissional_id_fkey" FOREIGN KEY ("profissional_id") REFERENCES "public"."profissionais_indicadores"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pontuacoes_profissionais"
    ADD CONSTRAINT "pontuacoes_profissionais_venda_id_fkey" FOREIGN KEY ("venda_id") REFERENCES "public"."vendas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."produtos"
    ADD CONSTRAINT "produtos_categoria_id_fkey" FOREIGN KEY ("categoria_id") REFERENCES "public"."categorias_produtos"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."recomendacoes_ia"
    ADD CONSTRAINT "recomendacoes_ia_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."recomendacoes_ia"
    ADD CONSTRAINT "recomendacoes_ia_produto_id_fkey" FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."vendas"
    ADD CONSTRAINT "vendas_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "public"."clientes"("id") ON DELETE SET NULL;



ALTER TABLE "public"."campanhas" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "campanhas_insert_marketing_gestor_admin" ON "public"."campanhas" FOR INSERT TO "authenticated" WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'marketing'::"text"]));



CREATE POLICY "campanhas_select_equipe" ON "public"."campanhas" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'marketing'::"text", 'vendedor'::"text"]));



CREATE POLICY "campanhas_update_marketing_gestor_admin" ON "public"."campanhas" FOR UPDATE TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'marketing'::"text"])) WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'marketing'::"text"]));



ALTER TABLE "public"."carteiras_fidelidade" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "carteiras_select_para_equipe" ON "public"."carteiras_fidelidade" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text"]));



ALTER TABLE "public"."categorias_produtos" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "categorias_select_para_equipe" ON "public"."categorias_produtos" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text", 'marketing'::"text"]));



ALTER TABLE "public"."clientes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "clientes_insert_para_equipe" ON "public"."clientes" FOR INSERT TO "authenticated" WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text"]));



CREATE POLICY "clientes_select_para_equipe" ON "public"."clientes" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text", 'marketing'::"text"]));



CREATE POLICY "clientes_update_para_equipe" ON "public"."clientes" FOR UPDATE TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text"])) WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text"]));



ALTER TABLE "public"."envios_campanha" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "envios_campanha_insert_marketing_gestor_admin" ON "public"."envios_campanha" FOR INSERT TO "authenticated" WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'marketing'::"text"]));



CREATE POLICY "envios_campanha_select_equipe" ON "public"."envios_campanha" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'marketing'::"text", 'vendedor'::"text"]));



CREATE POLICY "envios_campanha_update_marketing_gestor_admin" ON "public"."envios_campanha" FOR UPDATE TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'marketing'::"text"])) WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'marketing'::"text"]));



ALTER TABLE "public"."indicacoes_clientes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "indicacoes_insert_equipe" ON "public"."indicacoes_clientes" FOR INSERT TO "authenticated" WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text"]));



CREATE POLICY "indicacoes_select_equipe" ON "public"."indicacoes_clientes" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text"]));



ALTER TABLE "public"."integration_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."interacoes_clientes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "interacoes_insert_equipe" ON "public"."interacoes_clientes" FOR INSERT TO "authenticated" WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text", 'marketing'::"text"]));



CREATE POLICY "interacoes_select_equipe" ON "public"."interacoes_clientes" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text", 'marketing'::"text"]));



CREATE POLICY "interacoes_update_equipe" ON "public"."interacoes_clientes" FOR UPDATE TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text", 'marketing'::"text"])) WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text", 'marketing'::"text"]));



ALTER TABLE "public"."itens_venda" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "itens_venda_select_para_equipe" ON "public"."itens_venda" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text"]));



CREATE POLICY "logs_select_admin_gestor" ON "public"."integration_logs" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text"]));



ALTER TABLE "public"."mensagens_ia" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "mensagens_ia_select_equipe" ON "public"."mensagens_ia" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text", 'marketing'::"text"]));



ALTER TABLE "public"."movimentacoes_fidelidade" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "movimentacoes_select_admin_gestor" ON "public"."movimentacoes_fidelidade" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text"]));



ALTER TABLE "public"."perfis_acesso" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "perfis_acesso_insert_own" ON "public"."perfis_acesso" FOR INSERT TO "authenticated" WITH CHECK (("id" = "auth"."uid"()));



CREATE POLICY "perfis_acesso_select_own" ON "public"."perfis_acesso" FOR SELECT TO "authenticated" USING (("id" = "auth"."uid"()));



CREATE POLICY "perfis_acesso_update_own" ON "public"."perfis_acesso" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));



ALTER TABLE "public"."pontuacoes_profissionais" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "pontuacoes_profissionais_select_admin_gestor" ON "public"."pontuacoes_profissionais" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text"]));



ALTER TABLE "public"."produtos" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "produtos_insert_admin_gestor" ON "public"."produtos" FOR INSERT TO "authenticated" WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text"]));



CREATE POLICY "produtos_select_para_equipe" ON "public"."produtos" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text", 'marketing'::"text"]));



CREATE POLICY "produtos_update_admin_gestor" ON "public"."produtos" FOR UPDATE TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text"])) WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text"]));



ALTER TABLE "public"."profissionais_indicadores" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "profissionais_select_equipe" ON "public"."profissionais_indicadores" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text", 'marketing'::"text"]));



CREATE POLICY "profissionais_update_admin_gestor" ON "public"."profissionais_indicadores" TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text"])) WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text"]));



ALTER TABLE "public"."recomendacoes_ia" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "recomendacoes_select_equipe" ON "public"."recomendacoes_ia" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text"]));



ALTER TABLE "public"."usuarios" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "usuarios_insert_admin" ON "public"."usuarios" FOR INSERT TO "authenticated" WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text"]));



CREATE POLICY "usuarios_select_admin_gestor" ON "public"."usuarios" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text"]));



CREATE POLICY "usuarios_update_admin" ON "public"."usuarios" FOR UPDATE TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text"])) WITH CHECK ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text"]));



ALTER TABLE "public"."vendas" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "vendas_select_para_equipe" ON "public"."vendas" FOR SELECT TO "authenticated" USING ("public"."usuario_tem_um_dos_perfis"(ARRAY['administrador'::"text", 'gestor'::"text", 'vendedor'::"text"]));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."usuario_tem_perfil"("perfil_buscado" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."usuario_tem_perfil"("perfil_buscado" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."usuario_tem_perfil"("perfil_buscado" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."usuario_tem_um_dos_perfis"("perfis" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."usuario_tem_um_dos_perfis"("perfis" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."usuario_tem_um_dos_perfis"("perfis" "text"[]) TO "service_role";


















GRANT ALL ON TABLE "public"."campanhas" TO "anon";
GRANT ALL ON TABLE "public"."campanhas" TO "authenticated";
GRANT ALL ON TABLE "public"."campanhas" TO "service_role";



GRANT ALL ON TABLE "public"."carteiras_fidelidade" TO "anon";
GRANT ALL ON TABLE "public"."carteiras_fidelidade" TO "authenticated";
GRANT ALL ON TABLE "public"."carteiras_fidelidade" TO "service_role";



GRANT ALL ON TABLE "public"."categorias_produtos" TO "anon";
GRANT ALL ON TABLE "public"."categorias_produtos" TO "authenticated";
GRANT ALL ON TABLE "public"."categorias_produtos" TO "service_role";



GRANT ALL ON TABLE "public"."clientes" TO "anon";
GRANT ALL ON TABLE "public"."clientes" TO "authenticated";
GRANT ALL ON TABLE "public"."clientes" TO "service_role";



GRANT ALL ON TABLE "public"."envios_campanha" TO "anon";
GRANT ALL ON TABLE "public"."envios_campanha" TO "authenticated";
GRANT ALL ON TABLE "public"."envios_campanha" TO "service_role";



GRANT ALL ON TABLE "public"."indicacoes_clientes" TO "anon";
GRANT ALL ON TABLE "public"."indicacoes_clientes" TO "authenticated";
GRANT ALL ON TABLE "public"."indicacoes_clientes" TO "service_role";



GRANT ALL ON TABLE "public"."integration_logs" TO "anon";
GRANT ALL ON TABLE "public"."integration_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."integration_logs" TO "service_role";



GRANT ALL ON TABLE "public"."interacoes_clientes" TO "anon";
GRANT ALL ON TABLE "public"."interacoes_clientes" TO "authenticated";
GRANT ALL ON TABLE "public"."interacoes_clientes" TO "service_role";



GRANT ALL ON TABLE "public"."itens_venda" TO "anon";
GRANT ALL ON TABLE "public"."itens_venda" TO "authenticated";
GRANT ALL ON TABLE "public"."itens_venda" TO "service_role";



GRANT ALL ON TABLE "public"."mensagens_ia" TO "anon";
GRANT ALL ON TABLE "public"."mensagens_ia" TO "authenticated";
GRANT ALL ON TABLE "public"."mensagens_ia" TO "service_role";



GRANT ALL ON TABLE "public"."movimentacoes_fidelidade" TO "anon";
GRANT ALL ON TABLE "public"."movimentacoes_fidelidade" TO "authenticated";
GRANT ALL ON TABLE "public"."movimentacoes_fidelidade" TO "service_role";



GRANT ALL ON TABLE "public"."perfis_acesso" TO "anon";
GRANT ALL ON TABLE "public"."perfis_acesso" TO "authenticated";
GRANT ALL ON TABLE "public"."perfis_acesso" TO "service_role";



GRANT ALL ON TABLE "public"."pontuacoes_profissionais" TO "anon";
GRANT ALL ON TABLE "public"."pontuacoes_profissionais" TO "authenticated";
GRANT ALL ON TABLE "public"."pontuacoes_profissionais" TO "service_role";



GRANT ALL ON TABLE "public"."produtos" TO "anon";
GRANT ALL ON TABLE "public"."produtos" TO "authenticated";
GRANT ALL ON TABLE "public"."produtos" TO "service_role";



GRANT ALL ON TABLE "public"."profissionais_indicadores" TO "anon";
GRANT ALL ON TABLE "public"."profissionais_indicadores" TO "authenticated";
GRANT ALL ON TABLE "public"."profissionais_indicadores" TO "service_role";



GRANT ALL ON TABLE "public"."recomendacoes_ia" TO "anon";
GRANT ALL ON TABLE "public"."recomendacoes_ia" TO "authenticated";
GRANT ALL ON TABLE "public"."recomendacoes_ia" TO "service_role";



GRANT ALL ON TABLE "public"."usuarios" TO "anon";
GRANT ALL ON TABLE "public"."usuarios" TO "authenticated";
GRANT ALL ON TABLE "public"."usuarios" TO "service_role";



GRANT ALL ON TABLE "public"."vendas" TO "anon";
GRANT ALL ON TABLE "public"."vendas" TO "authenticated";
GRANT ALL ON TABLE "public"."vendas" TO "service_role";



GRANT ALL ON TABLE "public"."vw_clientes_indicados" TO "anon";
GRANT ALL ON TABLE "public"."vw_clientes_indicados" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_clientes_indicados" TO "service_role";



GRANT ALL ON TABLE "public"."vw_resumo_fidelidade_clientes" TO "anon";
GRANT ALL ON TABLE "public"."vw_resumo_fidelidade_clientes" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_resumo_fidelidade_clientes" TO "service_role";



GRANT ALL ON TABLE "public"."vw_resumo_vendas_clientes" TO "anon";
GRANT ALL ON TABLE "public"."vw_resumo_vendas_clientes" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_resumo_vendas_clientes" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































drop extension if exists "pg_net";


