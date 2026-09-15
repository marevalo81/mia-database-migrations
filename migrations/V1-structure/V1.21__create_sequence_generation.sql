-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.21 — Estructura física: schema `sequence_generation`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE sequence_generation.sequences (
    sequence_code      VARCHAR(50)     NOT NULL,
    current_value      BIGINT          NOT NULL,
    format_pattern     VARCHAR(100)    NOT NULL,
    reset_frequency    VARCHAR(20)     NOT NULL,
    last_reset_at      TIMESTAMPTZ,
    updated_at         TIMESTAMPTZ     NOT NULL,
    -- PK natural (sequence_code), NO UUID: así está definido explícitamente
    -- en el documento (6.5); no se sustituye una clave natural por UUID.
    CONSTRAINT pk_sequences PRIMARY KEY (sequence_code),
    CONSTRAINT ck_sequences_reset_frequency
        CHECK (reset_frequency IN ('NEVER','YEARLY','MONTHLY'))
);
