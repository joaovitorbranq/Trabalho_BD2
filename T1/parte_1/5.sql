-- Implemente uma solução através da programação em banco de dados para validar os
-- valores de uma coluna que represente uma situação (estado) garantindo que os seus
-- valores e suas transições atendam a especificação de um diagrama de transição de
-- estados (DTE). Quanto mais genérica e reutilizável for a solução melhor a pontuação
-- nessa questão. Junto da solução deverá ser entregue um cenário de teste
-- demonstrando o funcionamento da solução.


-- cria tabela de transicao de estados
CREATE TABLE transicoes (
    estado_atual TEXT NOT NULL,
    estado_proximo TEXT NOT NULL,
    CONSTRAINT pk_transicoes PRIMARY KEY (estado_atual, estado_proximo)
);

-- cria tabela da situacao atual dos estados
CREATE TABLE situacao (
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    estado_atual TEXT NOT NULL
);

-- cria function de validação da transição de estado
CREATE OR REPLACE FUNCTION validar_transicao_estado()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se a transição de estado é válida
    IF NOT EXISTS (
        SELECT 1
        FROM transicoes
        WHERE estado_atual = OLD.estado_atual
        AND estado_proximo = NEW.estado_atual
    ) THEN
        RAISE EXCEPTION 'Transição de estado inválida: % -> %', OLD.estado_atual, NEW.estado_atual;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- cria trigger de validação da transição de estado
CREATE TRIGGER trig_validar_estado
BEFORE UPDATE ON situacao
FOR EACH ROW
EXECUTE FUNCTION validar_transicao_estado();


-- popula as tabelas de transições com as transições válidas.
INSERT INTO transicoes (estado_atual, estado_proximo) VALUES
('Em andamento', 'Finalizado'),
('Em andamento', 'Cancelado'),
('Finalizado', 'Em andamento'),
('Cancelado', 'Cancelado');





-- cenário de teste:

INSERT INTO situacao (nome, estado_atual) VALUES ('Pedido 1', 'Em andamento'); -- estado inicial em andamento
UPDATE situacao SET estado_atual = 'Finalizado' WHERE id = 1; -- transição de andamento para finalizado - transição válida
UPDATE situacao SET estado_atual = 'Em andamento' WHERE id = 1; -- transição de finalizado para em andamento - transição inválida - deverá dar erro


