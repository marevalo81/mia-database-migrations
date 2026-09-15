-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.8 — Estructura física: schema `risk`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE risk.risk_evaluations (
    risk_evaluation_id       UUID            NOT NULL,
    customer_id              UUID            NOT NULL,
    status                   VARCHAR(30)     NOT NULL,
    result                   VARCHAR(30),
    score                    NUMERIC(10,4),
    estimated_max_amount     NUMERIC(19,4),
    currency_id              UUID,
    evaluated_at             TIMESTAMPTZ,
    created_at               TIMESTAMPTZ     NOT NULL,
    updated_at               TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_risk_evaluations PRIMARY KEY (risk_evaluation_id),
    -- customer_id es FK física explícita (4.6.5 Restricciones), pese a que el
    -- diagrama de 4.6.8 la etiqueta como "referencia lógica". Se implementa
    -- como FK física por ser la definición más específica y explícita; la
    -- contradicción se reporta en el informe (Fase 4).
    CONSTRAINT fk_risk_evaluations_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id),
    CONSTRAINT fk_risk_evaluations_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id)
    -- Sin loan_application_id: relación lógica en dirección inversa (4.6.8).
);

CREATE TABLE risk.risk_evaluation_factors (
    factor_id             UUID            NOT NULL,
    risk_evaluation_id    UUID            NOT NULL,
    factor_type           VARCHAR(50)     NOT NULL,
    factor_name           VARCHAR(100)    NOT NULL,
    factor_value          JSONB,
    source                VARCHAR(50),
    created_at            TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_risk_evaluation_factors PRIMARY KEY (factor_id),
    CONSTRAINT fk_risk_evaluation_factors_evaluation FOREIGN KEY (risk_evaluation_id)
        REFERENCES risk.risk_evaluations (risk_evaluation_id)
);
