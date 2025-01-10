-- Regra 1: Evitar que sejam vendidas tracks com preço zero ou negativa

CREATE OR REPLACE PROCEDURE insert_invoice_line(
  invoiceId INT,
  trackId INT,
  unitPrice DECIMAL,
  qtt INT
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Verifica se o preço da faixa é válido (maior que zero)
  IF unitPrice <= 0 THEN
    RAISE EXCEPTION 'Não é possível vender track com valor zerado ou negativo';
  END IF;

  -- Verifica se a quantidade é válida (maior que zero)
  IF qtt <= 0 THEN
    RAISE EXCEPTION 'Não é possível vender zero ou menos tracks';
  END IF;

  -- Insere a linha de fatura com preço e quantidade
  INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
  VALUES (invoiceId, trackId, unitPrice, qtt);
END;
$$;

REVOKE INSERT ON InvoiceLines FROM limited_user; -- Revogar permissões de inserção nas tabelas para o usuário
REVOKE INSERT ON Customers FROM limited_user; 
GRANT EXECUTE ON PROCEDURE insert_invoice_line TO postgres; -- verificar quais users vão ter permissão de usar essa procedure
