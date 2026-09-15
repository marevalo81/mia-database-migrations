-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.20 — Estructura física: schema `outbox`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

-- El documento exige que outbox_events resida en la misma base transaccional
-- y esté "particionada por reference_type" (6.4), pero no define la
-- estrategia de particionamiento (LIST/HASH), el número de particiones, ni
-- si reference_type debe integrar la PK (requisito de particionamiento
-- declarativo de PostgreSQL). No se inventa esa estrategia: se crea como
-- tabla no particionada y se reporta la decisión pendiente (Fase 3).
CREATE TABLE outbox.outbox_events (
    outbox_event_id     UUID            NOT NULL,
    reference_type      VARCHAR(50)     NOT NULL,
    reference_id        UUID            NOT NULL,
    event_type          VARCHAR(50)     NOT NULL,
    payload             JSONB           NOT NULL,
    status               VARCHAR(20)     NOT NULL,
    published_at         TIMESTAMPTZ,
    created_at            TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_outbox_events PRIMARY KEY (outbox_event_id),
    CONSTRAINT ck_outbox_events_status CHECK (status IN ('PENDING','PUBLISHED','FAILED'))
);
