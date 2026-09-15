-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.9 — Estructura física: schema `fraud`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE fraud.fraud_cases (
    case_id              UUID            NOT NULL,
    reference_type       VARCHAR(50)     NOT NULL,
    reference_id         UUID            NOT NULL,
    status               VARCHAR(30)     NOT NULL,
    opened_at            TIMESTAMPTZ     NOT NULL,
    closed_at            TIMESTAMPTZ,
    resolution_notes     TEXT,
    created_at           TIMESTAMPTZ     NOT NULL,
    updated_at           TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_fraud_cases PRIMARY KEY (case_id)
);

CREATE TABLE fraud.fraud_signals (
    signal_id           UUID            NOT NULL,
    case_id             UUID,
    reference_type      VARCHAR(50)     NOT NULL,
    reference_id        UUID            NOT NULL,
    signal_type         VARCHAR(50)     NOT NULL,
    severity            VARCHAR(20)     NOT NULL,
    source              VARCHAR(50)     NOT NULL,
    status              VARCHAR(30)     NOT NULL,
    details             JSONB,
    detected_at         TIMESTAMPTZ     NOT NULL,
    created_at          TIMESTAMPTZ     NOT NULL,
    updated_at          TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_fraud_signals PRIMARY KEY (signal_id),
    CONSTRAINT fk_fraud_signals_case FOREIGN KEY (case_id)
        REFERENCES fraud.fraud_cases (case_id)
    -- reference_type/reference_id: Patrón C, sin FK física.
);

CREATE TABLE fraud.fraud_actions (
    action_id       UUID            NOT NULL,
    case_id         UUID            NOT NULL,
    action_type     VARCHAR(30)     NOT NULL,
    status          VARCHAR(30)     NOT NULL,
    applied_at      TIMESTAMPTZ,
    reverted_at     TIMESTAMPTZ,
    notes           TEXT,
    created_at      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_fraud_actions PRIMARY KEY (action_id),
    CONSTRAINT fk_fraud_actions_case FOREIGN KEY (case_id)
        REFERENCES fraud.fraud_cases (case_id)
);
