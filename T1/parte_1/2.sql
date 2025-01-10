-- Criar usando a linguagem de programação do SGBD escolhido um procedimento que
-- remova todos os índices de uma tabela informada como parâmetro.

CREATE OR REPLACE PROCEDURE drop_all_indexes(table_name TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    index_name TEXT;
    constraint_record RECORD;
BEGIN
    -- Remover restrições da tabela
    FOR constraint_record IN 
        SELECT conname
        FROM pg_constraint
        WHERE conrelid = (SELECT oid FROM pg_class WHERE relname = table_name)
    LOOP
        EXECUTE 'ALTER TABLE ' || table_name || ' DROP CONSTRAINT ' || constraint_record.conname || ' CASCADE';
    END LOOP;

    -- Remover índices associados à tabela
    FOR index_name IN
        SELECT indexname
        FROM pg_indexes
        WHERE tablename = table_name
    LOOP
        EXECUTE 'DROP INDEX IF EXISTS ' || index_name;
    END LOOP;
END;
$$;



-- CALL drop_all_indexes('album');

