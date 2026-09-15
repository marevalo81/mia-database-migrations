-- ============================================================
-- MIA AVANZA CONTIGO
-- ADR-019 - Proyección de listado de solicitudes
--
-- PROPÓSITO:
-- Proyección de solo lectura para el listado administrativo
-- de solicitudes de crédito.
--
-- OWNERSHIP:
-- - lending: solicitud y estado
-- - customer: datos maestros del cliente
-- - reference_data: producto y país
--
-- REGLAS:
-- - Solicitud, crédito y desembolso se mantienen separados.
-- - No se inventan estados ni etapas.
-- - Los estados provienen de lending.loan_application_statuses.
-- - La moneda no se infiere desde el país ni se hardcodea.
-- ============================================================

CREATE OR REPLACE VIEW customer_support.v_loan_application_list AS
SELECT
    la.loan_application_id,

    la.customer_id,

    trim(
        concat_ws(
            ' ',
            c.first_name,
            c.middle_name,
            c.last_name,
            c.second_last_name
        )
    ) AS customer_name,

    la.product_id,
    p.code AS product_code,
    p.name AS product_name,

    la.country_id,
    country.iso_code AS country_code,
    country.name AS country_name,

    la.requested_amount,

    la.loan_application_status_id,
    status.code AS application_status_code,
    status.name AS application_status_name,

    la.created_at,
    la.updated_at

FROM lending.loan_applications la

JOIN customer.customers c
    ON c.customer_id = la.customer_id

JOIN reference_data.products p
    ON p.product_id = la.product_id

JOIN reference_data.countries country
    ON country.country_id = la.country_id

JOIN lending.loan_application_statuses status
    ON status.loan_application_status_id =
       la.loan_application_status_id;
