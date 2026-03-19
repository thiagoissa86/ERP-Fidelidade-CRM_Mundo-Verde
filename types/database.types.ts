export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.4"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      campanhas: {
        Row: {
          canal: string
          criado_em: string
          data_fim: string | null
          data_inicio: string | null
          id: string
          nome: string
          objetivo: string | null
          status: string
          tipo_campanha: string | null
          usuario_id: string | null
        }
        Insert: {
          canal?: string
          criado_em?: string
          data_fim?: string | null
          data_inicio?: string | null
          id?: string
          nome: string
          objetivo?: string | null
          status?: string
          tipo_campanha?: string | null
          usuario_id?: string | null
        }
        Update: {
          canal?: string
          criado_em?: string
          data_fim?: string | null
          data_inicio?: string | null
          id?: string
          nome?: string
          objetivo?: string | null
          status?: string
          tipo_campanha?: string | null
          usuario_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "campanhas_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "usuarios"
            referencedColumns: ["id"]
          },
        ]
      }
      carteiras_fidelidade: {
        Row: {
          atualizado_em: string
          cliente_id: string
          criado_em: string
          id: string
          saldo_atual: number
          saldo_gerado_venda: number
          saldo_total_gerado: number | null
          saldo_total_utilizado: number
          saldo_utilizado_venda: number | null
          status: string
        }
        Insert: {
          atualizado_em?: string
          cliente_id: string
          criado_em?: string
          id?: string
          saldo_atual?: number
          saldo_gerado_venda?: number
          saldo_total_gerado?: number | null
          saldo_total_utilizado?: number
          saldo_utilizado_venda?: number | null
          status?: string
        }
        Update: {
          atualizado_em?: string
          cliente_id?: string
          criado_em?: string
          id?: string
          saldo_atual?: number
          saldo_gerado_venda?: number
          saldo_total_gerado?: number | null
          saldo_total_utilizado?: number
          saldo_utilizado_venda?: number | null
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "carteiras_fidelidade_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: true
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "carteiras_fidelidade_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: true
            referencedRelation: "vw_clientes_indicados"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "carteiras_fidelidade_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: true
            referencedRelation: "vw_resumo_fidelidade_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "carteiras_fidelidade_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: true
            referencedRelation: "vw_resumo_vendas_clientes"
            referencedColumns: ["cliente_id"]
          },
        ]
      }
      categorias_produtos: {
        Row: {
          atualizado_em: string
          criado_em: string
          descricao: string | null
          id: string
          nome: string
        }
        Insert: {
          atualizado_em?: string
          criado_em?: string
          descricao?: string | null
          id?: string
          nome: string
        }
        Update: {
          atualizado_em?: string
          criado_em?: string
          descricao?: string | null
          id?: string
          nome?: string
        }
        Relationships: []
      }
      clientes: {
        Row: {
          aceita_marketing: boolean
          aceita_whatsapp: boolean
          atualizado_em: string
          canal_origem: string | null
          cpf: string | null
          criado_em: string
          data_nascimento: string | null
          email: string | null
          id: string
          nome_completo: string
          telefone: string | null
        }
        Insert: {
          aceita_marketing?: boolean
          aceita_whatsapp?: boolean
          atualizado_em?: string
          canal_origem?: string | null
          cpf?: string | null
          criado_em?: string
          data_nascimento?: string | null
          email?: string | null
          id?: string
          nome_completo: string
          telefone?: string | null
        }
        Update: {
          aceita_marketing?: boolean
          aceita_whatsapp?: boolean
          atualizado_em?: string
          canal_origem?: string | null
          cpf?: string | null
          criado_em?: string
          data_nascimento?: string | null
          email?: string | null
          id?: string
          nome_completo?: string
          telefone?: string | null
        }
        Relationships: []
      }
      envios_campanha: {
        Row: {
          campanha_id: string
          cliente_id: string
          conteudo: string | null
          enviado_em: string | null
          id: string
          status_conversao: string
          status_envio: string
          status_resposta: string
        }
        Insert: {
          campanha_id: string
          cliente_id: string
          conteudo?: string | null
          enviado_em?: string | null
          id?: string
          status_conversao?: string
          status_envio?: string
          status_resposta?: string
        }
        Update: {
          campanha_id?: string
          cliente_id?: string
          conteudo?: string | null
          enviado_em?: string | null
          id?: string
          status_conversao?: string
          status_envio?: string
          status_resposta?: string
        }
        Relationships: [
          {
            foreignKeyName: "envios_campanha_campanha_id_fkey"
            columns: ["campanha_id"]
            isOneToOne: false
            referencedRelation: "campanhas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "envios_campanha_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "envios_campanha_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_clientes_indicados"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "envios_campanha_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_fidelidade_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "envios_campanha_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_vendas_clientes"
            referencedColumns: ["cliente_id"]
          },
        ]
      }
      indicacoes_clientes: {
        Row: {
          cliente_id: string
          criado_em: string
          id: string
          observacoes: string | null
          origem_indicacao: string | null
          profissional_id: string
        }
        Insert: {
          cliente_id: string
          criado_em?: string
          id?: string
          observacoes?: string | null
          origem_indicacao?: string | null
          profissional_id: string
        }
        Update: {
          cliente_id?: string
          criado_em?: string
          id?: string
          observacoes?: string | null
          origem_indicacao?: string | null
          profissional_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "indicacoes_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: true
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "indicacoes_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: true
            referencedRelation: "vw_clientes_indicados"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "indicacoes_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: true
            referencedRelation: "vw_resumo_fidelidade_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "indicacoes_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: true
            referencedRelation: "vw_resumo_vendas_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "indicacoes_clientes_profissional_id_fkey"
            columns: ["profissional_id"]
            isOneToOne: false
            referencedRelation: "profissionais_indicadores"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "indicacoes_clientes_profissional_id_fkey"
            columns: ["profissional_id"]
            isOneToOne: false
            referencedRelation: "vw_clientes_indicados"
            referencedColumns: ["profissional_id"]
          },
        ]
      }
      integration_logs: {
        Row: {
          entidade: string
          id: string
          mensagem: string | null
          processado_em: string
          referencia_id: string | null
          sistema_origem: string
          status: string
        }
        Insert: {
          entidade: string
          id?: string
          mensagem?: string | null
          processado_em?: string
          referencia_id?: string | null
          sistema_origem: string
          status: string
        }
        Update: {
          entidade?: string
          id?: string
          mensagem?: string | null
          processado_em?: string
          referencia_id?: string | null
          sistema_origem?: string
          status?: string
        }
        Relationships: []
      }
      interacoes_clientes: {
        Row: {
          canal: string
          cliente_id: string
          criado_em: string
          id: string
          resumo: string | null
          tipo_interacao: string | null
          usuario_id: string | null
        }
        Insert: {
          canal: string
          cliente_id: string
          criado_em?: string
          id?: string
          resumo?: string | null
          tipo_interacao?: string | null
          usuario_id?: string | null
        }
        Update: {
          canal?: string
          cliente_id?: string
          criado_em?: string
          id?: string
          resumo?: string | null
          tipo_interacao?: string | null
          usuario_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "interacoes_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "interacoes_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_clientes_indicados"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "interacoes_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_fidelidade_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "interacoes_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_vendas_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "interacoes_clientes_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "usuarios"
            referencedColumns: ["id"]
          },
        ]
      }
      itens_venda: {
        Row: {
          desconto: number
          id: string
          preco_unitario: number
          produto_id: string
          quantidade: number
          valor_total: number
          venda_id: string
        }
        Insert: {
          desconto?: number
          id?: string
          preco_unitario?: number
          produto_id: string
          quantidade?: number
          valor_total?: number
          venda_id: string
        }
        Update: {
          desconto?: number
          id?: string
          preco_unitario?: number
          produto_id?: string
          quantidade?: number
          valor_total?: number
          venda_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "itens_venda_produto_id_fkey"
            columns: ["produto_id"]
            isOneToOne: false
            referencedRelation: "produtos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "itens_venda_venda_id_fkey"
            columns: ["venda_id"]
            isOneToOne: false
            referencedRelation: "vendas"
            referencedColumns: ["id"]
          },
        ]
      }
      mensagens_ia: {
        Row: {
          campanha_id: string | null
          cliente_id: string
          criado_em: string
          id: string
          mensagem: string
          origem: string
          tipo_mensagem: string
          usuario_id: string | null
        }
        Insert: {
          campanha_id?: string | null
          cliente_id: string
          criado_em?: string
          id?: string
          mensagem: string
          origem?: string
          tipo_mensagem?: string
          usuario_id?: string | null
        }
        Update: {
          campanha_id?: string | null
          cliente_id?: string
          criado_em?: string
          id?: string
          mensagem?: string
          origem?: string
          tipo_mensagem?: string
          usuario_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "mensagens_ia_campanha_id_fkey"
            columns: ["campanha_id"]
            isOneToOne: false
            referencedRelation: "campanhas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "mensagens_ia_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "mensagens_ia_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_clientes_indicados"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "mensagens_ia_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_fidelidade_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "mensagens_ia_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_vendas_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "mensagens_ia_usuario_id_fkey"
            columns: ["usuario_id"]
            isOneToOne: false
            referencedRelation: "usuarios"
            referencedColumns: ["id"]
          },
        ]
      }
      movimentacoes_fidelidade: {
        Row: {
          carteira_fidelidade_id: string
          cliente_id: string
          criado_em: string
          descricao: string | null
          id: string
          tipo_movimentacao: string
          valor: number
          venda_id: string | null
        }
        Insert: {
          carteira_fidelidade_id: string
          cliente_id: string
          criado_em?: string
          descricao?: string | null
          id?: string
          tipo_movimentacao: string
          valor?: number
          venda_id?: string | null
        }
        Update: {
          carteira_fidelidade_id?: string
          cliente_id?: string
          criado_em?: string
          descricao?: string | null
          id?: string
          tipo_movimentacao?: string
          valor?: number
          venda_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "movimentacoes_fidelidade_carteira_fidelidade_id_fkey"
            columns: ["carteira_fidelidade_id"]
            isOneToOne: false
            referencedRelation: "carteiras_fidelidade"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "movimentacoes_fidelidade_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "movimentacoes_fidelidade_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_clientes_indicados"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "movimentacoes_fidelidade_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_fidelidade_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "movimentacoes_fidelidade_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_vendas_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "movimentacoes_fidelidade_venda_id_fkey"
            columns: ["venda_id"]
            isOneToOne: false
            referencedRelation: "vendas"
            referencedColumns: ["id"]
          },
        ]
      }
      perfis_acesso: {
        Row: {
          criado_em: string | null
          id: string
          nome: string | null
          perfil: string
        }
        Insert: {
          criado_em?: string | null
          id: string
          nome?: string | null
          perfil: string
        }
        Update: {
          criado_em?: string | null
          id?: string
          nome?: string | null
          perfil?: string
        }
        Relationships: []
      }
      pontuacoes_profissionais: {
        Row: {
          cliente_id: string
          criado_em: string
          id: string
          pontos_gerados: number
          profissional_id: string
          saldo_gerado: number
          status: string
          tipo_pontuacao: string | null
          valor_base_venda: number
          venda_id: string | null
        }
        Insert: {
          cliente_id: string
          criado_em?: string
          id?: string
          pontos_gerados?: number
          profissional_id: string
          saldo_gerado?: number
          status?: string
          tipo_pontuacao?: string | null
          valor_base_venda?: number
          venda_id?: string | null
        }
        Update: {
          cliente_id?: string
          criado_em?: string
          id?: string
          pontos_gerados?: number
          profissional_id?: string
          saldo_gerado?: number
          status?: string
          tipo_pontuacao?: string | null
          valor_base_venda?: number
          venda_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "pontuacoes_profissionais_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pontuacoes_profissionais_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_clientes_indicados"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "pontuacoes_profissionais_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_fidelidade_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "pontuacoes_profissionais_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_vendas_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "pontuacoes_profissionais_profissional_id_fkey"
            columns: ["profissional_id"]
            isOneToOne: false
            referencedRelation: "profissionais_indicadores"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pontuacoes_profissionais_profissional_id_fkey"
            columns: ["profissional_id"]
            isOneToOne: false
            referencedRelation: "vw_clientes_indicados"
            referencedColumns: ["profissional_id"]
          },
          {
            foreignKeyName: "pontuacoes_profissionais_venda_id_fkey"
            columns: ["venda_id"]
            isOneToOne: false
            referencedRelation: "vendas"
            referencedColumns: ["id"]
          },
        ]
      }
      produtos: {
        Row: {
          ativo: boolean
          atualizado_em: string
          beneficios: string | null
          categoria_id: string | null
          codigo_barras: string | null
          criado_em: string
          descricao_produto: string | null
          estoque_atual: number
          id: string
          marca: string | null
          microvix_id: string | null
          nome: string
          objetivo_produto: string | null
          palavras_chave: string[] | null
          preco_custo: number | null
          preco_venda: number | null
          produtos_relacionados: string[] | null
          publico_indicado: string | null
          site_oficial_marca: string | null
          sku: string | null
        }
        Insert: {
          ativo?: boolean
          atualizado_em?: string
          beneficios?: string | null
          categoria_id?: string | null
          codigo_barras?: string | null
          criado_em?: string
          descricao_produto?: string | null
          estoque_atual?: number
          id?: string
          marca?: string | null
          microvix_id?: string | null
          nome: string
          objetivo_produto?: string | null
          palavras_chave?: string[] | null
          preco_custo?: number | null
          preco_venda?: number | null
          produtos_relacionados?: string[] | null
          publico_indicado?: string | null
          site_oficial_marca?: string | null
          sku?: string | null
        }
        Update: {
          ativo?: boolean
          atualizado_em?: string
          beneficios?: string | null
          categoria_id?: string | null
          codigo_barras?: string | null
          criado_em?: string
          descricao_produto?: string | null
          estoque_atual?: number
          id?: string
          marca?: string | null
          microvix_id?: string | null
          nome?: string
          objetivo_produto?: string | null
          palavras_chave?: string[] | null
          preco_custo?: number | null
          preco_venda?: number | null
          produtos_relacionados?: string[] | null
          publico_indicado?: string | null
          site_oficial_marca?: string | null
          sku?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "produtos_categoria_id_fkey"
            columns: ["categoria_id"]
            isOneToOne: false
            referencedRelation: "categorias_produtos"
            referencedColumns: ["id"]
          },
        ]
      }
      profissionais_indicadores: {
        Row: {
          ativo: boolean
          atualizado_em: string
          chave_pix: string | null
          criado_em: string
          documento: string | null
          email: string | null
          id: string
          nome: string
          telefone: string | null
          tipo_profissional: string | null
        }
        Insert: {
          ativo?: boolean
          atualizado_em?: string
          chave_pix?: string | null
          criado_em?: string
          documento?: string | null
          email?: string | null
          id?: string
          nome: string
          telefone?: string | null
          tipo_profissional?: string | null
        }
        Update: {
          ativo?: boolean
          atualizado_em?: string
          chave_pix?: string | null
          criado_em?: string
          documento?: string | null
          email?: string | null
          id?: string
          nome?: string
          telefone?: string | null
          tipo_profissional?: string | null
        }
        Relationships: []
      }
      recomendacoes_ia: {
        Row: {
          cliente_id: string
          confianca: number | null
          criado_em: string
          id: string
          produto_id: string | null
          status: string
          texto_recomendacao: string | null
          tipo_recomendacao: string
        }
        Insert: {
          cliente_id: string
          confianca?: number | null
          criado_em?: string
          id?: string
          produto_id?: string | null
          status?: string
          texto_recomendacao?: string | null
          tipo_recomendacao: string
        }
        Update: {
          cliente_id?: string
          confianca?: number | null
          criado_em?: string
          id?: string
          produto_id?: string | null
          status?: string
          texto_recomendacao?: string | null
          tipo_recomendacao?: string
        }
        Relationships: [
          {
            foreignKeyName: "recomendacoes_ia_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recomendacoes_ia_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_clientes_indicados"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "recomendacoes_ia_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_fidelidade_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "recomendacoes_ia_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_vendas_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "recomendacoes_ia_produto_id_fkey"
            columns: ["produto_id"]
            isOneToOne: false
            referencedRelation: "produtos"
            referencedColumns: ["id"]
          },
        ]
      }
      usuarios: {
        Row: {
          ativo: boolean
          atualizado_em: string
          criado_em: string
          email: string
          id: string
          nome: string
          perfil: string
          telefone: string | null
        }
        Insert: {
          ativo?: boolean
          atualizado_em?: string
          criado_em?: string
          email: string
          id?: string
          nome: string
          perfil: string
          telefone?: string | null
        }
        Update: {
          ativo?: boolean
          atualizado_em?: string
          criado_em?: string
          email?: string
          id?: string
          nome?: string
          perfil?: string
          telefone?: string | null
        }
        Relationships: []
      }
      vendas: {
        Row: {
          canal_venda: string
          cliente_id: string | null
          cliente_identificado: boolean
          criado_em: string
          data_venda: string
          desconto: number
          forma_pagamento: string | null
          id: string
          imagem_cupom_url: string | null
          microvix_venda_id: string | null
          numero_cupom: string | null
          origem_registro: string | null
          valor_bruto: number
          valor_liquido: number
        }
        Insert: {
          canal_venda?: string
          cliente_id?: string | null
          cliente_identificado?: boolean
          criado_em?: string
          data_venda: string
          desconto?: number
          forma_pagamento?: string | null
          id?: string
          imagem_cupom_url?: string | null
          microvix_venda_id?: string | null
          numero_cupom?: string | null
          origem_registro?: string | null
          valor_bruto?: number
          valor_liquido?: number
        }
        Update: {
          canal_venda?: string
          cliente_id?: string | null
          cliente_identificado?: boolean
          criado_em?: string
          data_venda?: string
          desconto?: number
          forma_pagamento?: string | null
          id?: string
          imagem_cupom_url?: string | null
          microvix_venda_id?: string | null
          numero_cupom?: string | null
          origem_registro?: string | null
          valor_bruto?: number
          valor_liquido?: number
        }
        Relationships: [
          {
            foreignKeyName: "vendas_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vendas_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_clientes_indicados"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "vendas_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_fidelidade_clientes"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "vendas_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_resumo_vendas_clientes"
            referencedColumns: ["cliente_id"]
          },
        ]
      }
    }
    Views: {
      vw_clientes_indicados: {
        Row: {
          cliente_id: string | null
          cliente_nome: string | null
          data_indicacao: string | null
          origem_indicacao: string | null
          profissional_id: string | null
          profissional_nome: string | null
          tipo_profissional: string | null
        }
        Relationships: []
      }
      vw_resumo_fidelidade_clientes: {
        Row: {
          cliente_id: string | null
          nome_completo: string | null
          saldo_atual: number | null
          saldo_total_gerado: number | null
          saldo_total_utilizado: number | null
          status: string | null
          telefone: string | null
        }
        Relationships: []
      }
      vw_resumo_vendas_clientes: {
        Row: {
          cliente_id: string | null
          nome_completo: string | null
          total_vendas: number | null
          ultima_compra: string | null
          valor_total_comprado: number | null
        }
        Relationships: []
      }
    }
    Functions: {
      usuario_tem_perfil: { Args: { perfil_buscado: string }; Returns: boolean }
      usuario_tem_um_dos_perfis: {
        Args: { perfis: string[] }
        Returns: boolean
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const
