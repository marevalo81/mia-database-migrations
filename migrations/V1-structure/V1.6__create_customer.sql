-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.6 — Estructura física: schema `customer`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE customer.customers (
    customer_id         UUID            NOT NULL,
    country_id          UUID            NOT NULL,
    first_name          VARCHAR(150)    NOT NULL,
    middle_name         VARCHAR(150),
    last_name           VARCHAR(150)    NOT NULL,
    second_last_name    VARCHAR(150),
    date_of_birth       DATE            NOT NULL,
    status               VARCHAR(30)     NOT NULL,
    created_at           TIMESTAMPTZ     NOT NULL,
    updated_at           TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT fk_customers_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id)
);

CREATE TABLE customer.customer_profiles (
    profile_id           UUID            NOT NULL,
    customer_id          UUID            NOT NULL,
    version              INTEGER         NOT NULL,
    occupation           VARCHAR(150),
    economic_activity    VARCHAR(150),
    employment_status    VARCHAR(50),
    monthly_income       NUMERIC(18,2),
    monthly_expenses     NUMERIC(18,2),
    effective_from       TIMESTAMPTZ     NOT NULL,
    effective_to         TIMESTAMPTZ,
    is_current           BOOLEAN         NOT NULL,
    created_at           TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_customer_profiles PRIMARY KEY (profile_id),
    CONSTRAINT fk_customer_profiles_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id),
    CONSTRAINT uq_customer_profiles_customer_version UNIQUE (customer_id, version)
);

CREATE TABLE customer.customer_identity_documents (
    identity_document_id    UUID            NOT NULL,
    customer_id             UUID            NOT NULL,
    document_type_id        UUID            NOT NULL,
    document_number         VARCHAR(50)     NOT NULL,
    issuing_country_id      UUID            NOT NULL,
    issue_date              DATE,
    expiration_date         DATE,
    document_status         VARCHAR(30)     NOT NULL,
    document_id             UUID            NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL,
    updated_at              TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_customer_identity_documents PRIMARY KEY (identity_document_id),
    CONSTRAINT fk_cust_id_docs_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id),
    CONSTRAINT fk_cust_id_docs_document_type FOREIGN KEY (document_type_id)
        REFERENCES reference_data.document_types (document_type_id),
    CONSTRAINT fk_cust_id_docs_issuing_country FOREIGN KEY (issuing_country_id)
        REFERENCES reference_data.countries (country_id),
    CONSTRAINT fk_cust_id_docs_document FOREIGN KEY (document_id)
        REFERENCES documents.documents (document_id)
);

CREATE TABLE customer.customer_contacts (
    contact_id       UUID            NOT NULL,
    customer_id      UUID            NOT NULL,
    contact_type     VARCHAR(30)     NOT NULL,
    contact_value    VARCHAR(255)    NOT NULL,
    is_primary       BOOLEAN         NOT NULL,
    status           VARCHAR(30)     NOT NULL,
    created_at       TIMESTAMPTZ     NOT NULL,
    updated_at       TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_customer_contacts PRIMARY KEY (contact_id),
    CONSTRAINT fk_customer_contacts_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id)
);

CREATE TABLE customer.customer_addresses (
    address_id       UUID            NOT NULL,
    customer_id      UUID            NOT NULL,
    address_type     VARCHAR(30)     NOT NULL,
    country_id       UUID            NOT NULL,
    state_code       VARCHAR(50),
    city_code        VARCHAR(50),
    address_line_1   VARCHAR(255)    NOT NULL,
    address_line_2   VARCHAR(255),
    postal_code      VARCHAR(30),
    is_primary       BOOLEAN         NOT NULL,
    valid_from       TIMESTAMPTZ     NOT NULL,
    valid_to         TIMESTAMPTZ,
    created_at       TIMESTAMPTZ     NOT NULL,
    updated_at       TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_customer_addresses PRIMARY KEY (address_id),
    CONSTRAINT fk_customer_addresses_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id),
    CONSTRAINT fk_customer_addresses_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id)
);

CREATE TABLE customer.customer_businesses (
    business_id          UUID            NOT NULL,
    customer_id          UUID            NOT NULL,
    business_name        VARCHAR(255)    NOT NULL,
    business_type        VARCHAR(50)     NOT NULL,
    economic_activity    VARCHAR(150),
    description          TEXT,
    status               VARCHAR(30)     NOT NULL,
    start_date           DATE,
    created_at           TIMESTAMPTZ     NOT NULL,
    updated_at           TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_customer_businesses PRIMARY KEY (business_id),
    CONSTRAINT fk_customer_businesses_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id)
);

CREATE TABLE customer.guarantors (
    guarantor_id         UUID            NOT NULL,
    customer_id          UUID            NOT NULL,
    country_id           UUID            NOT NULL,
    first_name           VARCHAR(150)    NOT NULL,
    middle_name          VARCHAR(150),
    last_name            VARCHAR(150)    NOT NULL,
    second_last_name     VARCHAR(150),
    date_of_birth        DATE            NOT NULL,
    relationship         VARCHAR(50)     NOT NULL,
    status               VARCHAR(30)     NOT NULL,
    created_at           TIMESTAMPTZ     NOT NULL,
    updated_at           TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_guarantors PRIMARY KEY (guarantor_id),
    CONSTRAINT fk_guarantors_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id),
    CONSTRAINT fk_guarantors_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id)
    -- NOTA: la Restricciones de 4.3.11 menciona "document_type_id referencia
    -- reference_data.document_types", pero no existe tal columna en esta
    -- tabla (pertenece a guarantor_identity_documents). Inconsistencia
    -- documental reportada en el informe; no se agrega columna inexistente.
);

CREATE TABLE customer.guarantor_identity_documents (
    identity_document_id    UUID            NOT NULL,
    guarantor_id            UUID            NOT NULL,
    document_type_id        UUID            NOT NULL,
    document_number         VARCHAR(50)     NOT NULL,
    issuing_country_id      UUID            NOT NULL,
    issue_date              DATE,
    expiration_date         DATE,
    document_status         VARCHAR(30)     NOT NULL,
    document_id             UUID            NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL,
    updated_at              TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_guarantor_identity_documents PRIMARY KEY (identity_document_id),
    CONSTRAINT fk_guar_id_docs_guarantor FOREIGN KEY (guarantor_id)
        REFERENCES customer.guarantors (guarantor_id),
    CONSTRAINT fk_guar_id_docs_document_type FOREIGN KEY (document_type_id)
        REFERENCES reference_data.document_types (document_type_id),
    CONSTRAINT fk_guar_id_docs_issuing_country FOREIGN KEY (issuing_country_id)
        REFERENCES reference_data.countries (country_id),
    CONSTRAINT fk_guar_id_docs_document FOREIGN KEY (document_id)
        REFERENCES documents.documents (document_id)
);

CREATE TABLE customer.guarantor_contacts (
    contact_id       UUID            NOT NULL,
    guarantor_id     UUID            NOT NULL,
    contact_type     VARCHAR(30)     NOT NULL,
    contact_value    VARCHAR(255)    NOT NULL,
    is_primary       BOOLEAN         NOT NULL,
    status           VARCHAR(30)     NOT NULL,
    created_at       TIMESTAMPTZ     NOT NULL,
    updated_at       TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_guarantor_contacts PRIMARY KEY (contact_id),
    CONSTRAINT fk_guarantor_contacts_guarantor FOREIGN KEY (guarantor_id)
        REFERENCES customer.guarantors (guarantor_id)
);

CREATE TABLE customer.guarantor_addresses (
    address_id       UUID            NOT NULL,
    guarantor_id     UUID            NOT NULL,
    address_type     VARCHAR(30)     NOT NULL,
    country_id       UUID            NOT NULL,
    state_code       VARCHAR(50),
    city_code        VARCHAR(50),
    address_line_1   VARCHAR(255)    NOT NULL,
    address_line_2   VARCHAR(255),
    postal_code      VARCHAR(30),
    is_primary       BOOLEAN         NOT NULL,
    valid_from       TIMESTAMPTZ     NOT NULL,
    valid_to         TIMESTAMPTZ,
    created_at       TIMESTAMPTZ     NOT NULL,
    updated_at       TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_guarantor_addresses PRIMARY KEY (address_id),
    CONSTRAINT fk_guarantor_addresses_guarantor FOREIGN KEY (guarantor_id)
        REFERENCES customer.guarantors (guarantor_id),
    CONSTRAINT fk_guarantor_addresses_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id)
);

CREATE TABLE customer.customer_bank_accounts (
    customer_bank_account_id    UUID            NOT NULL,
    customer_id                 UUID            NOT NULL,
    country_id                  UUID            NOT NULL,
    bank_name                   VARCHAR(150)    NOT NULL,
    account_holder_name         VARCHAR(200)    NOT NULL,
    account_number              VARCHAR(50)     NOT NULL,
    account_identifier_type     VARCHAR(30)     NOT NULL,
    account_type                VARCHAR(20)     NOT NULL,
    status                      VARCHAR(20)     NOT NULL,
    verified_at                 TIMESTAMPTZ,
    created_at                  TIMESTAMPTZ     NOT NULL,
    updated_at                  TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_customer_bank_accounts PRIMARY KEY (customer_bank_account_id),
    CONSTRAINT fk_customer_bank_accounts_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id),
    CONSTRAINT fk_customer_bank_accounts_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id)
);
