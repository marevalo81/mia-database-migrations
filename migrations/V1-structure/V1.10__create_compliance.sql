-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.10 — Estructura física: schema `compliance`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE compliance.compliance_requirements (
    requirement_id              UUID            NOT NULL,
    country_id                  UUID,
    requirement_code            VARCHAR(50)     NOT NULL,
    topic                       VARCHAR(50)     NOT NULL,
    description                 VARCHAR(500)    NOT NULL,
    version                     INTEGER         NOT NULL,
    legal_validation_status     VARCHAR(20)     NOT NULL,
    validated_at                TIMESTAMPTZ,
    valid_from                  TIMESTAMPTZ     NOT NULL,
    valid_to                    TIMESTAMPTZ,
    is_active                   BOOLEAN         NOT NULL,
    created_at                  TIMESTAMPTZ     NOT NULL,
    updated_at                  TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_compliance_requirements PRIMARY KEY (requirement_id),
    CONSTRAINT fk_compliance_requirements_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id),
    CONSTRAINT uq_compliance_requirements_code_country_version
        UNIQUE (requirement_code, country_id, version),
    CONSTRAINT ck_compliance_requirements_validation_status
        CHECK (legal_validation_status IN ('PENDIENTE','VALIDADO')),
    CONSTRAINT ck_compliance_requirements_active_requires_validated
        CHECK (is_active = FALSE OR legal_validation_status = 'VALIDADO')
);

CREATE TABLE compliance.compliance_checks (
    check_id           UUID            NOT NULL,
    requirement_id     UUID            NOT NULL,
    reference_type     VARCHAR(50)     NOT NULL,
    reference_id       UUID            NOT NULL,
    status             VARCHAR(30)     NOT NULL,
    result             VARCHAR(30),
    checked_at         TIMESTAMPTZ,
    notes              TEXT,
    created_at         TIMESTAMPTZ     NOT NULL,
    updated_at         TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_compliance_checks PRIMARY KEY (check_id),
    CONSTRAINT fk_compliance_checks_requirement FOREIGN KEY (requirement_id)
        REFERENCES compliance.compliance_requirements (requirement_id)
    -- reference_type/reference_id: sin FK física.
);
