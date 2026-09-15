-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.17 — Estructura física: schema `collections`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE collections.collection_cases (
    collection_case_id     UUID            NOT NULL,
    loan_id                UUID            NOT NULL,
    loan_installment_id    UUID,
    status                 VARCHAR(30)     NOT NULL,
    assigned_to            UUID,
    opened_at              TIMESTAMPTZ     NOT NULL,
    closed_at              TIMESTAMPTZ,
    created_at             TIMESTAMPTZ     NOT NULL,
    updated_at             TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_collection_cases PRIMARY KEY (collection_case_id),
    CONSTRAINT fk_collection_cases_loan FOREIGN KEY (loan_id)
        REFERENCES lending.loans (loan_id),
    CONSTRAINT fk_collection_cases_installment FOREIGN KEY (loan_installment_id)
        REFERENCES lending.loan_installments (loan_installment_id)
    -- assigned_to: referencia lógica, pendiente del modelo de identidad interna.
);

CREATE TABLE collections.collection_actions (
    collection_action_id     UUID            NOT NULL,
    collection_case_id       UUID            NOT NULL,
    action_type               VARCHAR(50)     NOT NULL,
    status                    VARCHAR(20)     NOT NULL,
    performed_by               UUID,
    performed_at               TIMESTAMPTZ,
    notes                      VARCHAR(500),
    created_at                 TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_collection_actions PRIMARY KEY (collection_action_id),
    CONSTRAINT fk_collection_actions_case FOREIGN KEY (collection_case_id)
        REFERENCES collections.collection_cases (collection_case_id),
    CONSTRAINT ck_collection_actions_status CHECK (status IN ('PENDING','COMPLETED'))
    -- performed_by: referencia lógica, pendiente del modelo de identidad interna.
);

CREATE TABLE collections.payment_promises (
    payment_promise_id      UUID            NOT NULL,
    collection_case_id      UUID            NOT NULL,
    promised_amount          NUMERIC(19,4)   NOT NULL,
    promised_date            DATE            NOT NULL,
    status                   VARCHAR(20)     NOT NULL,
    created_at               TIMESTAMPTZ     NOT NULL,
    updated_at               TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_payment_promises PRIMARY KEY (payment_promise_id),
    CONSTRAINT fk_payment_promises_case FOREIGN KEY (collection_case_id)
        REFERENCES collections.collection_cases (collection_case_id),
    CONSTRAINT ck_payment_promises_amount CHECK (promised_amount > 0),
    CONSTRAINT ck_payment_promises_status CHECK (status IN ('PENDING','FULFILLED','BROKEN'))
);
