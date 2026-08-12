-- Migration v5: Remove modalidad uniqueness constraint on TARJETAS
-- Allows multiple FISICA and/or VIRTUAL cards per account.
-- The rule is: money belongs to CUENTAS, not TARJETAS.
-- Cards are just access instruments; an account may have any number of them.

ALTER TABLE TARJETAS DROP CONSTRAINT uq_tarjeta_cuenta_modal;
