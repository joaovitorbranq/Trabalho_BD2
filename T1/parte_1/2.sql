-- Criar usando a linguagem de programação do SGBD escolhido um procedimento que
-- remova todos os índices de uma tabela informada como parâmetro.

-- Verificar sobre PKEYs e Cascade se são necessários, ou é isso mesmo que a questão quer

CREATE OR REPLACE PROCEDURE drop_all_indexes(table_name TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    index_name TEXT;
BEGIN
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

