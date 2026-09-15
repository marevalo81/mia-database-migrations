-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.13 — Estructura física: schema `legal`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================
--  lending.loan_applications)
-- ----------------------------------------------------------------------------

CREATE TABLE legal.legal_document_templates (
    template_id       UUID            NOT NULL,
    country_id        UUID,
    product_id        UUID,
    template_code     VARCHAR(50)     NOT NULL,
    template_type     VARCHAR(50)     NOT NULL,
    version           INTEGER         NOT NULL,
    upload_by         VARCHAR(50)     NOT NULL,
    document_id       UUID,
    valid_from        TIMESTAMPTZ     NOT NULL,
    valid_to          TIMESTAMPTZ,
    is_active         BOOLEAN         NOT NULL,
    created_at        TIMESTAMPTZ     NOT NULL,
    updated_at        TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_legal_document_templates PRIMARY KEY (template_id),
    CONSTRAINT fk_legal_doc_templates_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id),
    CONSTRAINT fk_legal_doc_templates_product FOREIGN KEY (product_id)
        REFERENCES reference_data.products (product_id),
    CONSTRAINT fk_legal_doc_templates_document FOREIGN KEY (document_id)
        REFERENCES documents.documents (document_id),
    CONSTRAINT uq_legal_doc_templates_code_country_product_version
        UNIQUE (template_code, country_id, product_id, version)
);

CREATE TABLE legal.legal_acceptances (
    acceptance_id           UUID            NOT NULL,
    loan_application_id     UUID            NOT NULL,
    template_id             UUID            NOT NULL,
    document_id             UUID,
    status                  VARCHAR(30)     NOT NULL,
    accepted_at             TIMESTAMPTZ,
    created_at              TIMESTAMPTZ     NOT NULL,
    updated_at              TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_legal_acceptances PRIMARY KEY (acceptance_id),
    CONSTRAINT fk_legal_acceptances_application FOREIGN KEY (loan_application_id)
        REFERENCES lending.loan_applications (loan_application_id),
    CONSTRAINT fk_legal_acceptances_template FOREIGN KEY (template_id)
        REFERENCES legal.legal_document_templates (template_id),
    CONSTRAINT fk_legal_acceptances_document FOREIGN KEY (document_id)
        REFERENCES documents.documents (document_id)
);

CREATE TABLE legal.legal_acceptance_signers (
    signer_id                UUID            NOT NULL,
    acceptance_id            UUID            NOT NULL,
    signer_type              VARCHAR(20)     NOT NULL,
    signer_reference_id      UUID            NOT NULL,
    signed_at                TIMESTAMPTZ,
    created_at               TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_legal_acceptance_signers PRIMARY KEY (signer_id),
    CONSTRAINT fk_legal_acceptance_signers_acceptance FOREIGN KEY (acceptance_id)
        REFERENCES legal.legal_acceptances (acceptance_id),
    CONSTRAINT ck_legal_acceptance_signers_type
        CHECK (signer_type IN ('CUSTOMER','GUARANTOR'))
    -- signer_reference_id: referencia lógica polimórfica, sin FK física.
);
