-- Regra 1: Evitar que sejam vendidas tracks com preço zero ou negativa

CREATE OR REPLACE FUNCTION validate_unit_price()
RETURNS TRIGGER AS $$
BEGIN
  -- Verifica se o preço da linha de fatura é zero ou negativo
  IF NEW.unit_price <= 0 THEN
    RAISE EXCEPTION 'Não é possível vender uma track com preço zerado ou negativo';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_zero_or_negative_price_sales
BEFORE INSERT OR UPDATE ON invoice_line
FOR EACH ROW
EXECUTE FUNCTION validate_unit_price();


-- Regra 2: Validar formato de email de clientes
CREATE OR REPLACE FUNCTION validate_email_format()
RETURNS TRIGGER AS $$
BEGIN
  -- Verifica se o e-mail tem o formato válido
  IF NOT NEW.email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
    RAISE EXCEPTION 'Formato do email do cliente está incorreto';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_email_format_trigger
BEFORE INSERT OR UPDATE ON customer
FOR EACH ROW
EXECUTE FUNCTION validate_email_format();
