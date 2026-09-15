-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.12 — Estructura física: schema `lending`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE lending.loan_application_statuses (
    loan_application_status_id     UUID            NOT NULL,
    code                            VARCHAR(50)     NOT NULL,
    name                            VARCHAR(100)    NOT NULL,
    description                     VARCHAR(255),
    is_active                       BOOLEAN         NOT NULL,
    created_at                      TIMESTAMPTZ     NOT NULL,
    updated_at                      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_loan_application_statuses PRIMARY KEY (loan_application_status_id),
    CONSTRAINT uq_loan_application_statuses_code UNIQUE (code)
);

CREATE TABLE lending.loan_statuses (
    loan_status_id      UUID            NOT NULL,
    code                 VARCHAR(50)     NOT NULL,
    name                 VARCHAR(100)    NOT NULL,
    description          VARCHAR(255),
    is_active            BOOLEAN         NOT NULL,
    created_at           TIMESTAMPTZ     NOT NULL,
    updated_at           TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_loan_statuses PRIMARY KEY (loan_status_id),
    CONSTRAINT uq_loan_statuses_code UNIQUE (code)
);

CREATE TABLE lending.loan_applications (
    loan_application_id             UUID            NOT NULL,
    customer_id                     UUID            NOT NULL,
    product_id                      UUID            NOT NULL,
    loan_application_status_id      UUID            NOT NULL,
    country_id                      UUID            NOT NULL,
    requested_amount                NUMERIC(19,4)   NOT NULL,
    created_at                      TIMESTAMPTZ     NOT NULL,
    updated_at                      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_loan_applications PRIMARY KEY (loan_application_id),
    CONSTRAINT fk_loan_applications_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id),
    CONSTRAINT fk_loan_applications_product FOREIGN KEY (product_id)
        REFERENCES reference_data.products (product_id),
    CONSTRAINT fk_loan_applications_status FOREIGN KEY (loan_application_status_id)
        REFERENCES lending.loan_application_statuses (loan_application_status_id),
    CONSTRAINT fk_loan_applications_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id)
);

CREATE TABLE lending.loan_application_steps (
    loan_application_step_id    UUID            NOT NULL,
    loan_application_id         UUID            NOT NULL,
    step_type                   VARCHAR(50)     NOT NULL,
    status                      VARCHAR(30)     NOT NULL,
    kyc_verification_id         UUID,
    risk_evaluation_id          UUID,
    verified_by                 UUID,
    notes                       VARCHAR(500),
    completed_at                TIMESTAMPTZ,
    created_at                  TIMESTAMPTZ     NOT NULL,
    updated_at                  TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_loan_application_steps PRIMARY KEY (loan_application_step_id),
    CONSTRAINT fk_loan_application_steps_application FOREIGN KEY (loan_application_id)
        REFERENCES lending.loan_applications (loan_application_id),
    CONSTRAINT fk_loan_application_steps_kyc_verification FOREIGN KEY (kyc_verification_id)
        REFERENCES kyc.kyc_verifications (verification_id),
    CONSTRAINT fk_loan_application_steps_risk_evaluation FOREIGN KEY (risk_evaluation_id)
        REFERENCES risk.risk_evaluations (risk_evaluation_id),
    CONSTRAINT uq_loan_application_steps_application_step UNIQUE (loan_application_id, step_type)
    -- verified_by: referencia lógica, pendiente del modelo de identidad interna.
);

CREATE TABLE lending.loan_application_decisions (
    loan_application_decision_id    UUID            NOT NULL,
    loan_application_id             UUID            NOT NULL,
    decision                        VARCHAR(30)     NOT NULL,
    approved_amount                 NUMERIC(19,4),
    customer_response               VARCHAR(20),
    customer_responded_at           TIMESTAMPTZ,
    decided_by                      UUID,
    decided_at                      TIMESTAMPTZ     NOT NULL,
    observations                    VARCHAR(500),
    rejection_reason                VARCHAR(255),
    created_at                      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_loan_application_decisions PRIMARY KEY (loan_application_decision_id),
    CONSTRAINT fk_loan_application_decisions_application FOREIGN KEY (loan_application_id)
        REFERENCES lending.loan_applications (loan_application_id),
    CONSTRAINT ck_loan_application_decisions_decision
        CHECK (decision IN ('APPROVED','REJECTED','COUNTER_OFFER')),
    CONSTRAINT ck_loan_application_decisions_customer_response
        CHECK (customer_response IS NULL OR customer_response IN ('ACCEPTED','REJECTED')),
    CONSTRAINT ck_loan_application_decisions_counter_offer_response
        CHECK (decision <> 'COUNTER_OFFER' OR customer_response IS NOT NULL)
    -- decided_by: referencia lógica, pendiente del modelo de identidad interna.
);

CREATE TABLE lending.loans (
    loan_id                  UUID            NOT NULL,
    loan_application_id      UUID            NOT NULL,
    customer_id              UUID            NOT NULL,
    product_id               UUID            NOT NULL,
    loan_status_id           UUID            NOT NULL,
    country_id               UUID            NOT NULL,
    created_at               TIMESTAMPTZ     NOT NULL,
    updated_at               TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_loans PRIMARY KEY (loan_id),
    CONSTRAINT fk_loans_application FOREIGN KEY (loan_application_id)
        REFERENCES lending.loan_applications (loan_application_id),
    CONSTRAINT fk_loans_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id),
    CONSTRAINT fk_loans_product FOREIGN KEY (product_id)
        REFERENCES reference_data.products (product_id),
    CONSTRAINT fk_loans_status FOREIGN KEY (loan_status_id)
        REFERENCES lending.loan_statuses (loan_status_id),
    CONSTRAINT fk_loans_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id),
    CONSTRAINT uq_loans_application UNIQUE (loan_application_id)
);

CREATE TABLE lending.loan_terms (
    loan_term_id          UUID            NOT NULL,
    loan_id               UUID            NOT NULL,
    principal_amount      NUMERIC(19,4)   NOT NULL,
    currency_id           UUID            NOT NULL,
    term_value            INTEGER         NOT NULL,
    term_unit             VARCHAR(20)     NOT NULL,
    interest_rate         NUMERIC(9,6)    NOT NULL,
    interest_rate_type    VARCHAR(20)     NOT NULL,
    interest_amount       NUMERIC(19,4)   NOT NULL,
    total_amount          NUMERIC(19,4)   NOT NULL,
    created_at            TIMESTAMPTZ     NOT NULL,
    updated_at            TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_loan_terms PRIMARY KEY (loan_term_id),
    CONSTRAINT fk_loan_terms_loan FOREIGN KEY (loan_id)
        REFERENCES lending.loans (loan_id),
    CONSTRAINT fk_loan_terms_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id),
    CONSTRAINT uq_loan_terms_loan UNIQUE (loan_id),
    CONSTRAINT ck_loan_terms_interest_rate_type
        CHECK (interest_rate_type IN ('FIXED','VARIABLE','INDEXED'))
);

CREATE TABLE lending.loan_schedules (
    loan_schedule_id      UUID            NOT NULL,
    loan_id               UUID            NOT NULL,
    total_installments    INTEGER         NOT NULL,
    frequency             VARCHAR(20)     NOT NULL,
    first_due_date        DATE            NOT NULL,
    last_due_date         DATE            NOT NULL,
    created_at            TIMESTAMPTZ     NOT NULL,
    updated_at            TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_loan_schedules PRIMARY KEY (loan_schedule_id),
    CONSTRAINT fk_loan_schedules_loan FOREIGN KEY (loan_id)
        REFERENCES lending.loans (loan_id),
    CONSTRAINT uq_loan_schedules_loan UNIQUE (loan_id),
    CONSTRAINT ck_loan_schedules_frequency
        CHECK (frequency IN ('DAILY','WEEKLY','BIWEEKLY','MONTHLY'))
);

CREATE TABLE lending.loan_installments (
    loan_installment_id       UUID            NOT NULL,
    loan_schedule_id          UUID            NOT NULL,
    installment_number        INTEGER         NOT NULL,
    due_date                  DATE            NOT NULL,
    principal_amount          NUMERIC(19,4)   NOT NULL,
    interest_amount           NUMERIC(19,4)   NOT NULL,
    total_amount              NUMERIC(19,4)   NOT NULL,
    paid_amount               NUMERIC(19,4)   NOT NULL DEFAULT 0,
    status                    VARCHAR(30)     NOT NULL,
    grace_period_ends_at      TIMESTAMPTZ,
    became_late_at            TIMESTAMPTZ,
    created_at                TIMESTAMPTZ     NOT NULL,
    updated_at                TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_loan_installments PRIMARY KEY (loan_installment_id),
    CONSTRAINT fk_loan_installments_schedule FOREIGN KEY (loan_schedule_id)
        REFERENCES lending.loan_schedules (loan_schedule_id),
    CONSTRAINT uq_loan_installments_schedule_number UNIQUE (loan_schedule_id, installment_number),
    CONSTRAINT ck_loan_installments_status
        CHECK (status IN ('PENDING','PARTIALLY_PAID','PAID','LATE'))
);

CREATE TABLE lending.guarantees (
    guarantee_id             UUID            NOT NULL,
    loan_application_id      UUID            NOT NULL,
    guarantor_id             UUID            NOT NULL,
    created_at               TIMESTAMPTZ     NOT NULL,
    updated_at               TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_guarantees PRIMARY KEY (guarantee_id),
    CONSTRAINT fk_guarantees_application FOREIGN KEY (loan_application_id)
        REFERENCES lending.loan_applications (loan_application_id),
    CONSTRAINT fk_guarantees_guarantor FOREIGN KEY (guarantor_id)
        REFERENCES customer.guarantors (guarantor_id)
    -- Sin UNIQUE(loan_application_id, guarantor_id): cantidad mínima/máxima
    -- de avales y reglas de sustitución permanecen pendientes (4.11.14).
);

CREATE TABLE lending.disbursements (
    disbursement_id       UUID            NOT NULL,
    loan_id               UUID            NOT NULL,
    wallet_account_id     UUID            NOT NULL,
    status                VARCHAR(30)     NOT NULL,
    amount                NUMERIC(19,4)   NOT NULL,
    currency_id           UUID            NOT NULL,
    created_at            TIMESTAMPTZ     NOT NULL,
    updated_at            TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_disbursements PRIMARY KEY (disbursement_id),
    CONSTRAINT fk_disbursements_loan FOREIGN KEY (loan_id)
        REFERENCES lending.loans (loan_id),
    CONSTRAINT fk_disbursements_wallet_account FOREIGN KEY (wallet_account_id)
        REFERENCES wallet.wallet_accounts (wallet_account_id),
    CONSTRAINT fk_disbursements_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id),
    CONSTRAINT ck_disbursements_status
        CHECK (status IN ('PENDING_DISBURSEMENT','VALIDATED','EXECUTED'))
    -- Sin UNIQUE(loan_id): un crédito puede tener más de un desembolso (4.11.15).
);

CREATE TABLE lending.loan_charges (
    loan_charge_id       UUID            NOT NULL,
    loan_term_id         UUID            NOT NULL,
    charge_type          VARCHAR(30)     NOT NULL,
    charge_code          VARCHAR(50)     NOT NULL,
    base_amount          NUMERIC(19,4)   NOT NULL,
    tax_code             VARCHAR(30),
    tax_rate             NUMERIC(9,6),
    tax_amount           NUMERIC(19,4),
    total_amount         NUMERIC(19,4)   NOT NULL,
    currency_id          UUID            NOT NULL,
    fee_schedule_id      UUID            NOT NULL,
    created_at           TIMESTAMPTZ     NOT NULL,
    updated_at           TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_loan_charges PRIMARY KEY (loan_charge_id),
    CONSTRAINT fk_loan_charges_loan_term FOREIGN KEY (loan_term_id)
        REFERENCES lending.loan_terms (loan_term_id),
    CONSTRAINT fk_loan_charges_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id),
    CONSTRAINT fk_loan_charges_fee_schedule FOREIGN KEY (fee_schedule_id)
        REFERENCES reference_data.fee_schedules (fee_schedule_id),
    CONSTRAINT ck_loan_charges_total_amount
        CHECK (total_amount = base_amount + COALESCE(tax_amount, 0))
);
