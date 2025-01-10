-- Consultar as tabelas de catálogo para listar todas as chaves estrangeiras existentes
-- informando as tabelas e colunas envolvidas.

SELECT 
    conname AS constraint_name,
    cl.relname AS table_name, -- cl é alias de pg_class
    att.attname AS column_name, -- att é alias de pg_attribute
    cl_ref.relname AS foreign_table_name, -- tabela referenciada pela fk
    att_ref.attname AS foreign_column_name -- coluna da tabela referenciada
FROM 
    pg_constraint AS con
JOIN 
    pg_attribute AS att ON att.attnum = ANY(con.conkey)
JOIN 
    pg_class AS cl ON cl.oid = con.conrelid
JOIN 
    pg_attribute AS att_ref ON att_ref.attnum = ANY(con.confkey)
JOIN 
    pg_class AS cl_ref ON cl_ref.oid = con.confrelid
WHERE 
    con.contype = 'f'  -- fk
ORDER BY 
    table_name, constraint_name;
