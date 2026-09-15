-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.2 — Estructura física: schema `reference_data`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE reference_data.countries (
    country_id      UUID            NOT NULL,
    iso_code        CHAR(2)         NOT NULL,
    name            VARCHAR(100)    NOT NULL,
    is_active       BOOLEAN         NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL,
    updated_at      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_countries PRIMARY KEY (country_id),
    CONSTRAINT uq_countries_iso_code UNIQUE (iso_code)
);

CREATE TABLE reference_data.regions (
    region_id       UUID            NOT NULL,
    country_id      UUID            NOT NULL,
    code            VARCHAR(50)     NOT NULL,
    name            VARCHAR(150)    NOT NULL,
    is_active       BOOLEAN         NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL,
    updated_at      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_regions PRIMARY KEY (region_id),
    CONSTRAINT uq_regions_country_code UNIQUE (country_id, code),
    CONSTRAINT fk_regions_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id)
);

CREATE TABLE reference_data.currencies (
    currency_id     UUID            NOT NULL,
    iso_code        CHAR(3)         NOT NULL,
    name            VARCHAR(100)    NOT NULL,
    decimal_places  SMALLINT        NOT NULL,
    is_active       BOOLEAN         NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL,
    updated_at      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_currencies PRIMARY KEY (currency_id),
    CONSTRAINT uq_currencies_iso_code UNIQUE (iso_code),
    CONSTRAINT ck_currencies_decimal_places CHECK (decimal_places >= 0)
);

CREATE TABLE reference_data.products (
    product_id      UUID            NOT NULL,
    code            VARCHAR(50)     NOT NULL,
    name            VARCHAR(150)    NOT NULL,
    description     TEXT,
    is_active       BOOLEAN         NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL,
    updated_at      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY (product_id),
    CONSTRAINT uq_products_code UNIQUE (code)
);

CREATE TABLE reference_data.loan_profiles (
    loan_profile_id UUID            NOT NULL,
    code            VARCHAR(50)     NOT NULL,
    name            VARCHAR(100)    NOT NULL,
    description     TEXT,
    is_active       BOOLEAN         NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL,
    updated_at      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_loan_profiles PRIMARY KEY (loan_profile_id),
    CONSTRAINT uq_loan_profiles_code UNIQUE (code)
);

CREATE TABLE reference_data.product_parameters (
    parameter_id        UUID            NOT NULL,
    product_id          UUID            NOT NULL,
    country_id          UUID            NOT NULL,
    loan_profile_id     UUID            NOT NULL,
    term_value          SMALLINT,
    term_unit           VARCHAR(20),
    payment_frequency   VARCHAR(20),
    currency_id         UUID,
    effective_from      TIMESTAMPTZ     NOT NULL,
    effective_to        TIMESTAMPTZ,
    version_number      INTEGER         NOT NULL,
    is_current          BOOLEAN         NOT NULL,
    source_reference     VARCHAR(255),
    created_at          TIMESTAMPTZ     NOT NULL,
    updated_at          TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_product_parameters PRIMARY KEY (parameter_id),
    CONSTRAINT fk_product_parameters_product FOREIGN KEY (product_id)
        REFERENCES reference_data.products (product_id),
    CONSTRAINT fk_product_parameters_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id),
    CONSTRAINT fk_product_parameters_loan_profile FOREIGN KEY (loan_profile_id)
        REFERENCES reference_data.loan_profiles (loan_profile_id),
    CONSTRAINT fk_product_parameters_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id)
);

CREATE TABLE reference_data.limits (
    limit_id            UUID            NOT NULL,
    parameter_id        UUID            NOT NULL,
    limit_type          VARCHAR(50)     NOT NULL,
    amount              NUMERIC(19,4)   NOT NULL,
    effective_from      TIMESTAMPTZ     NOT NULL,
    effective_to        TIMESTAMPTZ,
    version_number      INTEGER         NOT NULL,
    created_at          TIMESTAMPTZ     NOT NULL,
    updated_at          TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_limits PRIMARY KEY (limit_id),
    CONSTRAINT fk_limits_parameter FOREIGN KEY (parameter_id)
        REFERENCES reference_data.product_parameters (parameter_id),
    CONSTRAINT ck_limits_amount CHECK (amount >= 0)
);

CREATE TABLE reference_data.amount_progressions (
    progression_id      UUID            NOT NULL,
    parameter_id        UUID            NOT NULL,
    cycle_number        SMALLINT        NOT NULL,
    amount              NUMERIC(19,4)   NOT NULL,
    increment_amount    NUMERIC(19,4),
    created_at          TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_amount_progressions PRIMARY KEY (progression_id),
    CONSTRAINT fk_amount_progressions_parameter FOREIGN KEY (parameter_id)
        REFERENCES reference_data.product_parameters (parameter_id),
    CONSTRAINT uq_amount_progressions_parameter_cycle UNIQUE (parameter_id, cycle_number),
    CONSTRAINT ck_amount_progressions_amount CHECK (amount >= 0)
);

CREATE TABLE reference_data.rates (
    rate_id             UUID            NOT NULL,
    parameter_id        UUID            NOT NULL,
    rate_type           VARCHAR(50)     NOT NULL,
    rate_value          NUMERIC(12,8)   NOT NULL,
    rate_unit           VARCHAR(30)     NOT NULL,
    effective_from      TIMESTAMPTZ     NOT NULL,
    effective_to        TIMESTAMPTZ,
    version_number      INTEGER         NOT NULL,
    created_at          TIMESTAMPTZ     NOT NULL,
    updated_at          TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_rates PRIMARY KEY (rate_id),
    CONSTRAINT fk_rates_parameter FOREIGN KEY (parameter_id)
        REFERENCES reference_data.product_parameters (parameter_id)
);

CREATE TABLE reference_data.document_types (
    document_type_id   UUID            NOT NULL,
    code                VARCHAR(50)     NOT NULL,
    name                VARCHAR(100)    NOT NULL,
    description         TEXT,
    country_id          UUID,
    is_active           BOOLEAN         NOT NULL,
    created_at          TIMESTAMPTZ     NOT NULL,
    updated_at          TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_document_types PRIMARY KEY (document_type_id),
    CONSTRAINT uq_document_types_code UNIQUE (code),
    CONSTRAINT fk_document_types_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id)
);

CREATE TABLE reference_data.legal_entities (
    legal_entity_id     UUID            NOT NULL,
    country_id          UUID            NOT NULL,
    code                VARCHAR(50)     NOT NULL,
    legal_name          VARCHAR(200)    NOT NULL,
    tax_id              VARCHAR(50),
    is_active           BOOLEAN         NOT NULL,
    created_at          TIMESTAMPTZ     NOT NULL,
    updated_at          TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_legal_entities PRIMARY KEY (legal_entity_id),
    CONSTRAINT uq_legal_entities_code UNIQUE (code),
    CONSTRAINT fk_legal_entities_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id)
);

CREATE TABLE reference_data.fee_schedules (
    fee_schedule_id     UUID            NOT NULL,
    country_id          UUID            NOT NULL,
    product_id          UUID            NOT NULL,
    charge_code         VARCHAR(50)     NOT NULL,
    calculation_type    VARCHAR(20)     NOT NULL,
    calculation_base    VARCHAR(30),
    value               NUMERIC(12,6)   NOT NULL,
    currency_id         UUID,
    effective_from      TIMESTAMPTZ     NOT NULL,
    effective_to        TIMESTAMPTZ,
    version_number      INTEGER         NOT NULL,
    is_active           BOOLEAN         NOT NULL,
    source_reference     VARCHAR(255),
    created_at          TIMESTAMPTZ     NOT NULL,
    updated_at          TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_fee_schedules PRIMARY KEY (fee_schedule_id),
    CONSTRAINT fk_fee_schedules_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id),
    CONSTRAINT fk_fee_schedules_product FOREIGN KEY (product_id)
        REFERENCES reference_data.products (product_id),
    CONSTRAINT fk_fee_schedules_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id),
    CONSTRAINT uq_fee_schedules_country_product_charge_version
        UNIQUE (country_id, product_id, charge_code, version_number),
    CONSTRAINT ck_fee_schedules_calculation_type
        CHECK (calculation_type IN ('PERCENTAGE','FIXED_AMOUNT')),
    CONSTRAINT ck_fee_schedules_currency_required_if_fixed
        CHECK (calculation_type <> 'FIXED_AMOUNT' OR currency_id IS NOT NULL),
    CONSTRAINT ck_fee_schedules_base_required_if_percentage
        CHECK (calculation_type <> 'PERCENTAGE' OR calculation_base IS NOT NULL)
    -- PENDIENTE (no implementado): no-solapamiento de vigencias entre versiones
    -- de una misma combinación country_id+product_id+charge_code. El documento
    -- (4.1.16) deja explícitamente pendiente el mecanismo (EXCLUDE con
    -- btree_gist vs. validación en aplicación). No se inventa aquí.
);
