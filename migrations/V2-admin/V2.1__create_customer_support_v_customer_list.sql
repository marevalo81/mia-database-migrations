-- ============================================================
-- MIA AVANZA CONTIGO
-- ADR-018 - Proyección de listado de clientes
--
-- PROPÓSITO:
-- Proyección de solo lectura para Customer Support / Admin.
--
-- OWNERSHIP:
-- - customer: datos maestros del cliente
-- - reference_data: país
-- - kyc: verificación de identidad
--
-- NOTAS:
-- - No duplica información de dominio.
-- - La KYC mostrada es provisionalmente la más reciente por
--   started_at DESC, created_at DESC.
-- - Los contactos principales se seleccionan por is_primary.
-- ============================================================

CREATE OR REPLACE VIEW customer_support.v_customer_list AS

SELECT
    c.customer_id,

    trim(
        concat_ws(
            ' ',
            c.first_name,
            c.middle_name,
            c.last_name,
            c.second_last_name
        )
    ) AS full_name,

    co.iso_code AS country_code,
    co.name AS country_name,

    c.status AS customer_status,

    phone.contact_value AS primary_phone,
    email.contact_value AS primary_email,

    profile.occupation,
    profile.economic_activity,

    latest_kyc.status AS kyc_status,
    latest_kyc.result AS kyc_result,
    latest_kyc.verified_at AS kyc_verified_at,

    c.created_at

FROM customer.customers c

JOIN reference_data.countries co
    ON co.country_id = c.country_id

LEFT JOIN LATERAL (
    SELECT cc.contact_value
    FROM customer.customer_contacts cc
    WHERE cc.customer_id = c.customer_id
      AND upper(cc.contact_type) = 'PHONE'
      AND cc.is_primary = true
    ORDER BY cc.updated_at DESC, cc.created_at DESC
    LIMIT 1
) phone ON true

LEFT JOIN LATERAL (
    SELECT cc.contact_value
    FROM customer.customer_contacts cc
    WHERE cc.customer_id = c.customer_id
      AND upper(cc.contact_type) = 'EMAIL'
      AND cc.is_primary = true
    ORDER BY cc.updated_at DESC, cc.created_at DESC
    LIMIT 1
) email ON true

LEFT JOIN LATERAL (
    SELECT
        cp.occupation,
        cp.economic_activity
    FROM customer.customer_profiles cp
    WHERE cp.customer_id = c.customer_id
      AND cp.is_current = true
    ORDER BY cp.version DESC
    LIMIT 1
) profile ON true

LEFT JOIN LATERAL (
    SELECT
        kv.status,
        kv.result,
        kv.verified_at
    FROM kyc.kyc_verifications kv
    WHERE kv.customer_id = c.customer_id
    ORDER BY
        kv.started_at DESC,
        kv.created_at DESC
    LIMIT 1
) latest_kyc ON true;
