-- Consultar as tabelas de catálogo para listar todos os índices existentes acompanhados
-- das tabelas e colunas indexadas pelo mesmo.

SELECT 
    t.relname AS table_name,
    i.relname AS index_name,
    a.attname AS column_name
FROM 
    pg_class t
JOIN 
    pg_index ix ON t.oid = ix.indrelid
JOIN 
    pg_class i ON i.oid = ix.indexrelid
JOIN 
    pg_attribute a ON a.attnum = ANY(ix.indkey) AND a.attrelid = t.oid
WHERE 
    t.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY 
    t.relname, i.relname;
