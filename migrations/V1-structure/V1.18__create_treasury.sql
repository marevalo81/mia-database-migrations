-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.18 — Estructura física: schema `treasury`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE treasury.funding_sources (
    funding_source_id    UUID            NOT NULL,
    code                  VARCHAR(50)     NOT NULL,
    name                  VARCHAR(100)    NOT NULL,
    description           VARCHAR(255),
    is_active             BOOLEAN         NOT NULL,
    created_at            TIMESTAMPTZ     NOT NULL,
    updated_at            TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_funding_sources PRIMARY KEY (funding_source_id),
    CONSTRAINT uq_funding_sources_code UNIQUE (code)
);

CREATE TABLE treasury.capital_pools (
    capital_pool_id       UUID            NOT NULL,
    legal_entity_id       UUID            NOT NULL,
    funding_source_id     UUID            NOT NULL,
    currency_id           UUID            NOT NULL,
    available_amount      NUMERIC(19,4)   NOT NULL,
    committed_amount      NUMERIC(19,4)   NOT NULL,
    placed_amount         NUMERIC(19,4)   NOT NULL,
    recovered_amount      NUMERIC(19,4)   NOT NULL,
    created_at            TIMESTAMPTZ     NOT NULL,
    updated_at            TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_capital_pools PRIMARY KEY (capital_pool_id),
    CONSTRAINT fk_capital_pools_legal_entity FOREIGN KEY (legal_entity_id)
        REFERENCES reference_data.legal_entities (legal_entity_id),
    CONSTRAINT fk_capital_pools_funding_source FOREIGN KEY (funding_source_id)
        REFERENCES treasury.funding_sources (funding_source_id),
    CONSTRAINT fk_capital_pools_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id),
    CONSTRAINT uq_capital_pools_entity_source_currency
        UNIQUE (legal_entity_id, funding_source_id, currency_id),
    CONSTRAINT ck_capital_pools_available CHECK (available_amount >= 0),
    CONSTRAINT ck_capital_pools_committed CHECK (committed_amount >= 0),
    CONSTRAINT ck_capital_pools_placed CHECK (placed_amount >= 0),
    CONSTRAINT ck_capital_pools_recovered CHECK (recovered_amount >= 0)
);

CREATE TABLE treasury.capital_pool_restrictions (
    capital_pool_restriction_id     UUID            NOT NULL,
    capital_pool_id                 UUID            NOT NULL,
    restriction_type                VARCHAR(50)     NOT NULL,
    restriction_value               JSONB           NOT NULL,
    is_active                       BOOLEAN         NOT NULL,
    created_at                      TIMESTAMPTZ     NOT NULL,
    updated_at                      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_capital_pool_restrictions PRIMARY KEY (capital_pool_restriction_id),
    CONSTRAINT fk_capital_pool_restrictions_pool FOREIGN KEY (capital_pool_id)
        REFERENCES treasury.capital_pools (capital_pool_id)
);

CREATE TABLE treasury.capital_allocations (
    capital_allocation_id     UUID            NOT NULL,
    capital_pool_id           UUID            NOT NULL,
    loan_id                   UUID            NOT NULL,
    amount                    NUMERIC(19,4)   NOT NULL,
    status                    VARCHAR(20)     NOT NULL,
    committed_at              TIMESTAMPTZ     NOT NULL,
    placed_at                 TIMESTAMPTZ,
    recovered_at              TIMESTAMPTZ,
    created_at                TIMESTAMPTZ     NOT NULL,
    updated_at                TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_capital_allocations PRIMARY KEY (capital_allocation_id),
    CONSTRAINT fk_capital_allocations_pool FOREIGN KEY (capital_pool_id)
        REFERENCES treasury.capital_pools (capital_pool_id),
    CONSTRAINT fk_capital_allocations_loan FOREIGN KEY (loan_id)
        REFERENCES lending.loans (loan_id),
    CONSTRAINT uq_capital_allocations_loan UNIQUE (loan_id),
    CONSTRAINT ck_capital_allocations_amount CHECK (amount > 0),
    CONSTRAINT ck_capital_allocations_status
        CHECK (status IN ('COMMITTED','PLACED','RECOVERED','RELEASED'))
);
