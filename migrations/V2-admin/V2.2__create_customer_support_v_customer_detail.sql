-- ============================================================
-- MIA AVANZA CONTIGO
-- ADR-018 - Proyección de detalle de cliente
--
-- PROPÓSITO:
-- Proyección de solo lectura para el detalle administrativo
-- de un cliente.
--
-- OWNERSHIP:
-- - customer: datos maestros, perfil, contactos e identidad
-- - reference_data: país y tipos de documento
-- - documents: metadata documental
-- - kyc: verificaciones y checks
--
-- REGLAS CONFIRMADAS:
-- - Se muestran todos los contactos.
-- - Se muestran todos los documentos de identidad.
-- - Customer Support no determina el documento principal.
-- - Se muestra todo el historial KYC.
-- - El historial KYC se presenta por started_at DESC,
--   created_at DESC.
-- ============================================================

CREATE OR REPLACE VIEW customer_support.v_customer_detail AS
SELECT
    c.customer_id,

    c.first_name,
    c.middle_name,
    c.last_name,
    c.second_last_name,

    trim(
        concat_ws(
            ' ',
            c.first_name,
            c.middle_name,
            c.last_name,
            c.second_last_name
        )
    ) AS full_name,

    c.date_of_birth,
    c.status AS customer_status,

    co.country_id,
    co.iso_code AS country_code,
    co.name AS country_name,

    profile.profile_id,
    profile.version AS profile_version,
    profile.occupation,
    profile.economic_activity,
    profile.employment_status,
    profile.monthly_income,
    profile.monthly_expenses,

    COALESCE(
        contacts.contacts,
        '[]'::jsonb
    ) AS contacts,

    COALESCE(
        identity_documents.identity_documents,
        '[]'::jsonb
    ) AS identity_documents,

    COALESCE(
        kyc_history.kyc_verifications,
        '[]'::jsonb
    ) AS kyc_verifications,

    c.created_at,
    c.updated_at

FROM customer.customers c

JOIN reference_data.countries co
    ON co.country_id = c.country_id

LEFT JOIN LATERAL (
    SELECT
        cp.profile_id,
        cp.version,
        cp.occupation,
        cp.economic_activity,
        cp.employment_status,
        cp.monthly_income,
        cp.monthly_expenses
    FROM customer.customer_profiles cp
    WHERE cp.customer_id = c.customer_id
      AND cp.is_current = true
    ORDER BY cp.version DESC
    LIMIT 1
) profile ON true

LEFT JOIN LATERAL (
    SELECT
        jsonb_agg(
            jsonb_build_object(
                'contact_id', cc.contact_id,
                'contact_type', cc.contact_type,
                'contact_value', cc.contact_value,
                'is_primary', cc.is_primary,
                'status', cc.status,
                'created_at', cc.created_at,
                'updated_at', cc.updated_at
            )
            ORDER BY
                cc.is_primary DESC,
                cc.updated_at DESC,
                cc.created_at DESC
        ) AS contacts
    FROM customer.customer_contacts cc
    WHERE cc.customer_id = c.customer_id
) contacts ON true

LEFT JOIN LATERAL (
    SELECT
        jsonb_agg(
            jsonb_build_object(
                'identity_document_id', cid.identity_document_id,
                'document_type_id', cid.document_type_id,
                'document_type_code', dt.code,
                'document_type_name', dt.name,
                'document_number', cid.document_number,
                'issuing_country_id', cid.issuing_country_id,
                'issuing_country_code', issuing_country.iso_code,
                'issuing_country_name', issuing_country.name,
                'issue_date', cid.issue_date,
                'expiration_date', cid.expiration_date,
                'document_status', cid.document_status,
                'document_id', cid.document_id,
                'file_name', d.file_name,
                'mime_type', d.mime_type,
                'file_status', d.status,
                'uploaded_at', d.uploaded_at,
                'created_at', cid.created_at,
                'updated_at', cid.updated_at
            )
            ORDER BY cid.created_at DESC
        ) AS identity_documents
    FROM customer.customer_identity_documents cid

    JOIN reference_data.document_types dt
        ON dt.document_type_id = cid.document_type_id

    JOIN reference_data.countries issuing_country
        ON issuing_country.country_id = cid.issuing_country_id

    JOIN documents.documents d
        ON d.document_id = cid.document_id

    WHERE cid.customer_id = c.customer_id
) identity_documents ON true

LEFT JOIN LATERAL (
    SELECT
        jsonb_agg(
            jsonb_build_object(
                'verification_id', kv.verification_id,
                'status', kv.status,
                'result', kv.result,
                'started_at', kv.started_at,
                'completed_at', kv.completed_at,
                'verified_at', kv.verified_at,
                'expires_at', kv.expires_at,
                'review_notes', kv.review_notes,
                'checks', COALESCE(
                    (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'check_id', kc.check_id,
                                'requirement_id', kc.requirement_id,
                                'check_type', kc.check_type,
                                'execution_type', kc.execution_type,
                                'status', kc.status,
                                'result', kc.result,
                                'is_required', kc.is_required,
                                'review_notes', kc.review_notes,
                                'completed_at', kc.completed_at
                            )
                            ORDER BY kc.created_at
                        )
                        FROM kyc.kyc_checks kc
                        WHERE kc.verification_id = kv.verification_id
                    ),
                    '[]'::jsonb
                )
            )
            ORDER BY
                kv.started_at DESC,
                kv.created_at DESC
        ) AS kyc_verifications
    FROM kyc.kyc_verifications kv
    WHERE kv.customer_id = c.customer_id
) kyc_history ON true;
