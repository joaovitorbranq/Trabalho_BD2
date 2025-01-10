-- Criar regras semânticas, que são regras que não podem ser garantidas pela estrutura
-- do modelo relacional, usando o esquema exemplo fornecido. As regras criadas também
-- devem ser descritas textualmente no trabalho a ser entregue.

-- Regra 1: Na tabela Invoice a coluna total deve ser exatamente a soma de (unit_price x quantity) da tabela de InvoiceLine pertencentes a Invoice
-- Regra 2: Validar que o total de uma Invoice não seja negativa
