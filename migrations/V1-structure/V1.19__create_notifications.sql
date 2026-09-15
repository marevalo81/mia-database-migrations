-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.19 — Estructura física: schema `notifications`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE notifications.notification_templates (
    notification_template_id     UUID            NOT NULL,
    country_id                   UUID,
    notification_type            VARCHAR(50)     NOT NULL,
    channel                      VARCHAR(20)     NOT NULL,
    version                      INTEGER         NOT NULL,
    content_template             TEXT            NOT NULL,
    is_active                    BOOLEAN         NOT NULL,
    created_at                   TIMESTAMPTZ     NOT NULL,
    updated_at                   TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_notification_templates PRIMARY KEY (notification_template_id),
    CONSTRAINT fk_notification_templates_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id),
    CONSTRAINT ck_notification_templates_channel
        CHECK (channel IN ('EMAIL','SMS','PUSH','WHATSAPP'))
);
-- notifications.notifications (envíos) es DynamoDB (sección 6.1) — no se crea aquí.
