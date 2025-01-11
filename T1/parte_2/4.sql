CREATE OR REPLACE FUNCTION atualizar_total_invoice()
RETURNS TRIGGER AS $$
BEGIN
    -- atualiza o total em invoice sendo a soma dos valores de unit_price * quantity
    UPDATE invoice
    SET total = (
        SELECT COALESCE(SUM(unit_price * quantity), 0)
        FROM invoice_line
        WHERE invoice_line.invoice_id = NEW.invoice_id
    )
    WHERE invoice.invoice_id = NEW.invoice_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_atualizar_total_invoice
AFTER INSERT OR UPDATE ON invoice_line
FOR EACH ROW
EXECUTE FUNCTION atualizar_total_invoice();





-- cenario de teste (levando em consideração o chinook-database e seus registros já existentes)

-- verificar o valor de total
SELECT invoice_id, total FROM invoice WHERE invoice_id = 1;

-- verificar a soma dos valores de unit_price * quantity (devem ser iguais ao total) para todos registros com invoice_id=1
SELECT * FROM invoice_line WHERE invoice_id = 1;

-- atualizar o valor de unit_price de um dos registros
UPDATE invoice_line
SET unit_price = 1.49
WHERE invoice_id = 1 AND invoice_line_id = 1;

-- verificar o total da invoice após a atualização (deve ser atualizado)
SELECT invoice_id, total FROM invoice WHERE invoice_id = 1;