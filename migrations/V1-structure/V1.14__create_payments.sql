-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.14 — Estructura física: schema `payments`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE payments.payments (
    payment_id       UUID            NOT NULL,
    loan_id          UUID            NOT NULL,
    amount           NUMERIC(19,4)   NOT NULL,
    currency_id      UUID            NOT NULL,
    payment_date     TIMESTAMPTZ     NOT NULL,
    status           VARCHAR(20)     NOT NULL,
    created_at       TIMESTAMPTZ     NOT NULL,
    updated_at       TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_payments PRIMARY KEY (payment_id),
    CONSTRAINT fk_payments_loan FOREIGN KEY (loan_id)
        REFERENCES lending.loans (loan_id),
    CONSTRAINT fk_payments_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id),
    CONSTRAINT ck_payments_amount CHECK (amount > 0),
    CONSTRAINT ck_payments_status
        CHECK (status IN ('PENDING','CONFIRMED','FAILED','REVERSED'))
);

CREATE TABLE payments.payment_allocations (
    payment_allocation_id      UUID            NOT NULL,
    payment_id                 UUID            NOT NULL,
    loan_installment_id        UUID            NOT NULL,
    amount                     NUMERIC(19,4)   NOT NULL,
    interest_amount            NUMERIC(19,4)   NOT NULL,
    principal_amount           NUMERIC(19,4)   NOT NULL,
    created_at                 TIMESTAMPTZ     NOT NULL,
    updated_at                 TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_payment_allocations PRIMARY KEY (payment_allocation_id),
    CONSTRAINT fk_payment_allocations_payment FOREIGN KEY (payment_id)
        REFERENCES payments.payments (payment_id),
    CONSTRAINT fk_payment_allocations_installment FOREIGN KEY (loan_installment_id)
        REFERENCES lending.loan_installments (loan_installment_id),
    CONSTRAINT ck_payment_allocations_amount CHECK (amount > 0),
    CONSTRAINT ck_payment_allocations_interest CHECK (interest_amount >= 0),
    CONSTRAINT ck_payment_allocations_principal CHECK (principal_amount >= 0),
    CONSTRAINT ck_payment_allocations_sum
        CHECK (interest_amount + principal_amount = amount)
);
