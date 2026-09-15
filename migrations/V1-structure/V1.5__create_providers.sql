-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.5 — Estructura física: schema `providers`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE providers.providers (
    provider_id     UUID            NOT NULL,
    code            VARCHAR(50)     NOT NULL,
    name            VARCHAR(100)    NOT NULL,
    is_active       BOOLEAN         NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL,
    updated_at      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_providers PRIMARY KEY (provider_id),
    CONSTRAINT uq_providers_code UNIQUE (code)
);

CREATE TABLE providers.provider_accounts (
    provider_account_id     UUID            NOT NULL,
    provider_id             UUID            NOT NULL,
    code                    VARCHAR(50)     NOT NULL,
    jurisdiction_code       VARCHAR(20)     NOT NULL,
    currency_id             UUID            NOT NULL,
    secret_reference        VARCHAR(255),
    is_active               BOOLEAN         NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL,
    updated_at              TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_provider_accounts PRIMARY KEY (provider_account_id),
    CONSTRAINT fk_provider_accounts_provider FOREIGN KEY (provider_id)
        REFERENCES providers.providers (provider_id),
    CONSTRAINT fk_provider_accounts_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id),
    CONSTRAINT uq_provider_accounts_provider_code UNIQUE (provider_id, code)
);

CREATE TABLE providers.provider_transactions (
    provider_transaction_id     UUID            NOT NULL,
    provider_account_id         UUID,
    reference_type               VARCHAR(50)     NOT NULL,
    reference_id                 UUID            NOT NULL,
    external_reference           VARCHAR(100),
    transaction_type             VARCHAR(30)     NOT NULL,
    amount                       NUMERIC(19,4),
    currency_id                  UUID,
    status                       VARCHAR(30)     NOT NULL,
    created_at                   TIMESTAMPTZ     NOT NULL,
    updated_at                   TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_provider_transactions PRIMARY KEY (provider_transaction_id),
    CONSTRAINT fk_provider_transactions_account FOREIGN KEY (provider_account_id)
        REFERENCES providers.provider_accounts (provider_account_id),
    CONSTRAINT fk_provider_transactions_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id),
    CONSTRAINT ck_provider_transactions_amount CHECK (amount IS NULL OR amount > 0)
    -- reference_type/reference_id: Patrón C, sin FK física (explícito, 4.4.7).
);
