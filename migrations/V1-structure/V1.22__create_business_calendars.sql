-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.22 — Estructura física: schema `business_calendars`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE business_calendars.calendars (
    calendar_id     UUID            NOT NULL,
    country_id      UUID            NOT NULL,
    name            VARCHAR(100)    NOT NULL,
    is_active       BOOLEAN         NOT NULL,
    CONSTRAINT pk_calendars PRIMARY KEY (calendar_id),
    CONSTRAINT fk_calendars_country FOREIGN KEY (country_id)
        REFERENCES reference_data.countries (country_id)
    -- NOTA: el documento (6.6) no lista created_at/updated_at para esta
    -- tabla, a diferencia de la convención general del resto del modelo.
    -- No se agregan por fidelidad; se reporta como inconsistencia (Fase 4).
);

CREATE TABLE business_calendars.calendar_holidays (
    calendar_holiday_id     UUID            NOT NULL,
    calendar_id             UUID            NOT NULL,
    holiday_date            DATE            NOT NULL,
    description             VARCHAR(150),
    is_recurring            BOOLEAN         NOT NULL,
    CONSTRAINT pk_calendar_holidays PRIMARY KEY (calendar_holiday_id),
    CONSTRAINT fk_calendar_holidays_calendar FOREIGN KEY (calendar_id)
        REFERENCES business_calendars.calendars (calendar_id)
    -- Mismo caso: sin created_at/updated_at en el documento (6.6).
);
