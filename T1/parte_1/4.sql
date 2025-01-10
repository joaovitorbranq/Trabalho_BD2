-- Criar usando a linguagem de programação do SGBD escolhido um script que construa
-- de forma dinâmica a partir do catálogo os comandos create table das tabelas
-- existentes no esquema exemplo considerando pelo menos as informações sobre
-- colunas (nome, tipo e obrigatoriedade) e chaves primárias e estrangeiras.

DO $$ 
DECLARE
    table_rec RECORD;
    column_rec RECORD;
    pk_rec RECORD;
    fk_rec RECORD;
    create_table_sql TEXT := '';
    constraints_sql TEXT := '';
BEGIN
	-- percorre todas as tabelas
    FOR table_rec IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
    LOOP
        -- inicializa o comando CREATE TABLE
        create_table_sql := 'CREATE TABLE public.' || table_rec.tablename || ' (';

		-- para cada coluna:
        FOR column_rec IN
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = table_rec.tablename
            ORDER BY ordinal_position
        LOOP
            create_table_sql := create_table_sql || column_rec.column_name || ' ' || column_rec.data_type;

            -- verifica se a coluna é obrigatória (NOT NULL)
            IF column_rec.is_nullable = 'NO' THEN
                create_table_sql := create_table_sql || ' NOT NULL';
            END IF;

            create_table_sql := create_table_sql || ', ';
        END LOOP;

        -- adiciona pk's
        FOR pk_rec IN
            SELECT kcu.column_name
            FROM information_schema.key_column_usage kcu
            JOIN information_schema.table_constraints tc
                ON kcu.constraint_name = tc.constraint_name
            WHERE tc.constraint_type = 'PRIMARY KEY'
                AND kcu.table_name = table_rec.tablename
        LOOP
            constraints_sql := 'CONSTRAINT pk_' || table_rec.tablename || ' PRIMARY KEY (' || pk_rec.column_name || '), ';
        END LOOP;

        -- adiciona fk's
        FOR fk_rec IN
            SELECT 
                kcu.column_name, 
                ccu.table_name AS foreign_table_name, 
                ccu.column_name AS foreign_column_name
            FROM 
                information_schema.key_column_usage kcu
            JOIN 
                information_schema.table_constraints tc 
                ON kcu.constraint_name = tc.constraint_name
            JOIN 
                information_schema.constraint_column_usage ccu 
                ON ccu.constraint_name = tc.constraint_name
            WHERE tc.constraint_type = 'FOREIGN KEY'
                AND kcu.table_name = table_rec.tablename
        LOOP
            constraints_sql := constraints_sql || 'CONSTRAINT fk_' || table_rec.tablename || '_' || fk_rec.column_name ||
            ' FOREIGN KEY (' || fk_rec.column_name || ') REFERENCES ' || fk_rec.foreign_table_name || ' (' || fk_rec.foreign_column_name || '), ';
        END LOOP;

        create_table_sql := rtrim(create_table_sql, ', ') || ')';

        -- adiciona constraints
        create_table_sql := create_table_sql || ' ' || rtrim(constraints_sql, ', ') || ';';

        -- printa
        RAISE NOTICE '%', create_table_sql;

    END LOOP;
END $$;








-- retorno esperado:
-- NOTA:  CREATE TABLE public.artist (artist_id integer NOT NULL, name character varying) CONSTRAINT pk_artist PRIMARY KEY (artist_id);
-- NOTA:  CREATE TABLE public.album (album_id integer NOT NULL, title character varying NOT NULL, artist_id integer NOT NULL) CONSTRAINT pk_album PRIMARY KEY (album_id), CONSTRAINT fk_album_artist_id FOREIGN KEY (artist_id) REFERENCES artist (artist_id);
-- NOTA:  CREATE TABLE public.employee (employee_id integer NOT NULL, last_name character varying NOT NULL, first_name character varying NOT NULL, title character varying, reports_to integer, birth_date timestamp without time zone, hire_date timestamp without time zone, address character varying, city character varying, state character varying, country character varying, postal_code character varying, phone character varying, fax character varying, email character varying) CONSTRAINT pk_employee PRIMARY KEY (employee_id), CONSTRAINT fk_employee_reports_to FOREIGN KEY (reports_to) REFERENCES employee (employee_id);
-- NOTA:  CREATE TABLE public.customer (customer_id integer NOT NULL, first_name character varying NOT NULL, last_name character varying NOT NULL, company character varying, address character varying, city character varying, state character varying, country character varying, postal_code character varying, phone character varying, fax character varying, email character varying NOT NULL, support_rep_id integer) CONSTRAINT pk_customer PRIMARY KEY (customer_id), CONSTRAINT fk_customer_support_rep_id FOREIGN KEY (support_rep_id) REFERENCES employee (employee_id);
-- NOTA:  CREATE TABLE public.invoice (invoice_id integer NOT NULL, customer_id integer NOT NULL, invoice_date timestamp without time zone NOT NULL, billing_address character varying, billing_city character varying, billing_state character varying, billing_country character varying, billing_postal_code character varying, total numeric NOT NULL) CONSTRAINT pk_invoice PRIMARY KEY (invoice_id), CONSTRAINT fk_invoice_customer_id FOREIGN KEY (customer_id) REFERENCES customer (customer_id);
-- NOTA:  CREATE TABLE public.invoice_line (invoice_line_id integer NOT NULL, invoice_id integer NOT NULL, track_id integer NOT NULL, unit_price numeric NOT NULL, quantity integer NOT NULL) CONSTRAINT pk_invoice_line PRIMARY KEY (invoice_line_id), CONSTRAINT fk_invoice_line_invoice_id FOREIGN KEY (invoice_id) REFERENCES invoice (invoice_id), CONSTRAINT fk_invoice_line_track_id FOREIGN KEY (track_id) REFERENCES track (track_id);
-- NOTA:  CREATE TABLE public.track (track_id integer NOT NULL, name character varying NOT NULL, album_id integer, media_type_id integer NOT NULL, genre_id integer, composer character varying, milliseconds integer NOT NULL, bytes integer, unit_price numeric NOT NULL) CONSTRAINT pk_track PRIMARY KEY (track_id), CONSTRAINT fk_track_album_id FOREIGN KEY (album_id) REFERENCES album (album_id), CONSTRAINT fk_track_genre_id FOREIGN KEY (genre_id) REFERENCES genre (genre_id), CONSTRAINT fk_track_media_type_id FOREIGN KEY (media_type_id) REFERENCES media_type (media_type_id);
-- NOTA:  CREATE TABLE public.playlist (playlist_id integer NOT NULL, name character varying) CONSTRAINT pk_playlist PRIMARY KEY (playlist_id);
-- NOTA:  CREATE TABLE public.playlist_track (playlist_id integer NOT NULL, track_id integer NOT NULL) CONSTRAINT pk_playlist_track PRIMARY KEY (track_id), CONSTRAINT fk_playlist_track_playlist_id FOREIGN KEY (playlist_id) REFERENCES playlist (playlist_id), CONSTRAINT fk_playlist_track_track_id FOREIGN KEY (track_id) REFERENCES track (track_id);
-- NOTA:  CREATE TABLE public.genre (genre_id integer NOT NULL, name character varying) CONSTRAINT pk_genre PRIMARY KEY (genre_id);
-- NOTA:  CREATE TABLE public.media_type (media_type_id integer NOT NULL, name character varying) CONSTRAINT pk_media_type PRIMARY KEY (media_type_id);
