-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.7 — Estructura física: schema `kyc`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE kyc.kyc_requirements (
    requirement_id       UUID            NOT NULL,
    country_id           UUID            NOT NULL,
    document_type_id     UUID,
    requirement_type     VARCHAR(50)     NOT NULL,
    version              INTEGER         NOT NULL,
    description          VARCHAR(500)    NOT NULL,
    is_required          BOOLEAN         NOT NULL,
    valid_from           TIMESTAMPTZ     NOT NULL,
    valid_to             TIMESTAMPTZ,
    is_active            BOOLEAN         NOT NULL,
    created_at           TIMESTAMPTZ     NOT NULL,
    updated_at           TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_kyc_requirements PRIMARY KEY (requirement_id),
    CONSTRAINT fk_kyc_requirements_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id),
    CONSTRAINT fk_kyc_requirements_document_type FOREIGN KEY (document_type_id)
        REFERENCES reference_data.document_types (document_type_id),
    CONSTRAINT uq_kyc_requirements_type_country_doctype_version
        UNIQUE (requirement_type, country_id, document_type_id, version)
);

CREATE TABLE kyc.kyc_verifications (
    verification_id     UUID            NOT NULL,
    customer_id         UUID            NOT NULL,
    status              VARCHAR(30)     NOT NULL,
    result              VARCHAR(30),
    started_at          TIMESTAMPTZ     NOT NULL,
    completed_at        TIMESTAMPTZ,
    verified_at         TIMESTAMPTZ,
    expires_at          TIMESTAMPTZ,
    review_notes        TEXT,
    created_at          TIMESTAMPTZ     NOT NULL,
    updated_at          TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_kyc_verifications PRIMARY KEY (verification_id),
    CONSTRAINT fk_kyc_verifications_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id)
    -- Sin loan_application_id: la relación con Lending es lógica y en
    -- dirección inversa (4.5.10). No se agrega columna inexistente.
);

CREATE TABLE kyc.kyc_checks (
    check_id             UUID            NOT NULL,
    verification_id      UUID            NOT NULL,
    requirement_id       UUID            NOT NULL,
    check_type           VARCHAR(50)     NOT NULL,
    execution_type       VARCHAR(30)     NOT NULL,
    status               VARCHAR(30)     NOT NULL,
    result               VARCHAR(30),
    is_required          BOOLEAN         NOT NULL,
    review_notes         TEXT,
    completed_at         TIMESTAMPTZ,
    created_at           TIMESTAMPTZ     NOT NULL,
    updated_at           TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_kyc_checks PRIMARY KEY (check_id),
    CONSTRAINT fk_kyc_checks_verification FOREIGN KEY (verification_id)
        REFERENCES kyc.kyc_verifications (verification_id),
    CONSTRAINT fk_kyc_checks_requirement FOREIGN KEY (requirement_id)
        REFERENCES kyc.kyc_requirements (requirement_id)
);

CREATE TABLE kyc.kyc_evidences (
    evidence_id                       UUID            NOT NULL,
    verification_id                   UUID            NOT NULL,
    check_id                          UUID,
    evidence_type                     VARCHAR(50)     NOT NULL,
    customer_identity_document_id     UUID,
    document_id                       UUID,
    provider_transaction_id           UUID,
    created_at                        TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_kyc_evidences PRIMARY KEY (evidence_id),
    CONSTRAINT fk_kyc_evidences_verification FOREIGN KEY (verification_id)
        REFERENCES kyc.kyc_verifications (verification_id),
    CONSTRAINT fk_kyc_evidences_check FOREIGN KEY (check_id)
        REFERENCES kyc.kyc_checks (check_id),
    CONSTRAINT fk_kyc_evidences_identity_document FOREIGN KEY (customer_identity_document_id)
        REFERENCES customer.customer_identity_documents (identity_document_id),
    CONSTRAINT fk_kyc_evidences_document FOREIGN KEY (document_id)
        REFERENCES documents.documents (document_id)
    -- provider_transaction_id: referencia lógica, sin FK física (explícito, 4.5.8).
);
