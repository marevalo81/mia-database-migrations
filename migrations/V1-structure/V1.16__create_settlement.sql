-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.16 — Estructura física: schema `settlement`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE settlement.settlement_batches (
    settlement_batch_id       UUID            NOT NULL,
    period_start              TIMESTAMPTZ     NOT NULL,
    period_end                TIMESTAMPTZ     NOT NULL,
    external_reference        VARCHAR(100),
    expected_total_amount     NUMERIC(19,4)   NOT NULL,
    reported_total_amount     NUMERIC(19,4)   NOT NULL,
    currency_id               UUID            NOT NULL,
    status                    VARCHAR(20)     NOT NULL,
    created_at                TIMESTAMPTZ     NOT NULL,
    updated_at                TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_settlement_batches PRIMARY KEY (settlement_batch_id),
    CONSTRAINT fk_settlement_batches_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id),
    CONSTRAINT ck_settlement_batches_period CHECK (period_end > period_start),
    CONSTRAINT ck_settlement_batches_expected_amount CHECK (expected_total_amount >= 0),
    CONSTRAINT ck_settlement_batches_reported_amount CHECK (reported_total_amount >= 0),
    CONSTRAINT ck_settlement_batches_status
        CHECK (status IN ('PENDING','PROCESSING','MATCHED','DISCREPANCY','CLOSED'))
);

CREATE TABLE settlement.settlement_items (
    settlement_item_id           UUID            NOT NULL,
    settlement_batch_id          UUID            NOT NULL,
    provider_transaction_id      UUID,
    reported_reference           VARCHAR(150)    NOT NULL,
    reported_amount              NUMERIC(19,4)   NOT NULL,
    reported_status              VARCHAR(30),
    fee_amount                   NUMERIC(19,4),
    net_amount                   NUMERIC(19,4),
    match_status                 VARCHAR(30)     NOT NULL,
    created_at                   TIMESTAMPTZ     NOT NULL,
    updated_at                   TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_settlement_items PRIMARY KEY (settlement_item_id),
    CONSTRAINT fk_settlement_items_batch FOREIGN KEY (settlement_batch_id)
        REFERENCES settlement.settlement_batches (settlement_batch_id),
    CONSTRAINT ck_settlement_items_reported_amount CHECK (reported_amount >= 0),
    CONSTRAINT ck_settlement_items_fee_amount CHECK (fee_amount IS NULL OR fee_amount >= 0),
    CONSTRAINT ck_settlement_items_net_amount CHECK (net_amount IS NULL OR net_amount >= 0),
    CONSTRAINT ck_settlement_items_match_status
        CHECK (match_status IN ('PENDING','MATCHED','UNMATCHED','AMOUNT_MISMATCH','DUPLICATE'))
    -- provider_transaction_id: referencia lógica, sin FK física.
);

CREATE TABLE settlement.settlement_discrepancies (
    settlement_discrepancy_id     UUID            NOT NULL,
    settlement_item_id            UUID            NOT NULL,
    discrepancy_type              VARCHAR(30)     NOT NULL,
    expected_amount               NUMERIC(19,4),
    reported_amount               NUMERIC(19,4),
    difference                    NUMERIC(19,4),
    resolution_status             VARCHAR(20)     NOT NULL,
    resolved_by                   UUID,
    resolved_at                   TIMESTAMPTZ,
    notes                         TEXT,
    created_at                    TIMESTAMPTZ     NOT NULL,
    updated_at                    TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_settlement_discrepancies PRIMARY KEY (settlement_discrepancy_id),
    CONSTRAINT fk_settlement_discrepancies_item FOREIGN KEY (settlement_item_id)
        REFERENCES settlement.settlement_items (settlement_item_id),
    CONSTRAINT ck_settlement_discrepancies_expected CHECK (expected_amount IS NULL OR expected_amount >= 0),
    CONSTRAINT ck_settlement_discrepancies_reported CHECK (reported_amount IS NULL OR reported_amount >= 0),
    CONSTRAINT ck_settlement_discrepancies_type
        CHECK (discrepancy_type IN ('MISSING_INTERNAL','MISSING_PROVIDER','AMOUNT_MISMATCH','DUPLICATE','OTHER')),
    CONSTRAINT ck_settlement_discrepancies_resolution_status
        CHECK (resolution_status IN ('OPEN','INVESTIGATING','RESOLVED')),
    CONSTRAINT ck_settlement_discrepancies_resolved_at_requires_status
        CHECK (resolution_status <> 'RESOLVED' OR resolved_at IS NOT NULL),
    CONSTRAINT ck_settlement_discrepancies_resolved_by_requires_at
        CHECK (resolved_at IS NULL OR resolved_by IS NOT NULL)
    -- resolved_by: referencia lógica, pendiente del modelo de identidad interna.
);
