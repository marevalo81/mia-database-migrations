-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.4 — Estructura física: schema `auth`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE auth.authentication_events (
    event_id            UUID            NOT NULL,
    cognito_user_id     VARCHAR(255),
    customer_id         UUID,
    event_type          VARCHAR(50)     NOT NULL,
    occurred_at         TIMESTAMPTZ     NOT NULL,
    result              VARCHAR(30)     NOT NULL,
    ip_address          INET,
    device_info         TEXT,
    user_agent          TEXT,
    created_at          TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_authentication_events PRIMARY KEY (event_id)
    -- customer_id y cognito_user_id son referencias lógicas, explícitamente
    -- sin FK física (4.2.5): Cognito es externo y Auth no adquiere ownership
    -- sobre Customer.
);
