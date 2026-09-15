-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.15 — Estructura física: schema `ledger`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================

CREATE TABLE ledger.ledger_accounts (
    ledger_account_id    UUID            NOT NULL,
    code                 VARCHAR(50)     NOT NULL,
    name                 VARCHAR(100)    NOT NULL,
    account_type         VARCHAR(20)     NOT NULL,
    currency_id          UUID            NOT NULL,
    legal_entity_id      UUID            NOT NULL,
    description          VARCHAR(255),
    is_active            BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at           TIMESTAMPTZ     NOT NULL,
    updated_at           TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_ledger_accounts PRIMARY KEY (ledger_account_id),
    CONSTRAINT fk_ledger_accounts_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id),
    CONSTRAINT fk_ledger_accounts_legal_entity FOREIGN KEY (legal_entity_id)
        REFERENCES reference_data.legal_entities (legal_entity_id),
    CONSTRAINT uq_ledger_accounts_code UNIQUE (code),
    CONSTRAINT ck_ledger_accounts_type
        CHECK (account_type IN ('ASSET','LIABILITY','EQUITY','INCOME','EXPENSE'))
    -- NOTA: 4.14.9 y 4.14.5-Restricciones mencionan una columna country_id en
    -- esta tabla que NO existe en el listado de Campos (4.14.5). No se agrega
    -- una columna no definida en el listado de Campos; inconsistencia
    -- reportada en el informe (Fase 4).
);

CREATE TABLE ledger.journal_entries (
    journal_entry_id     UUID            NOT NULL,
    entry_date           TIMESTAMPTZ     NOT NULL,
    reference_type       VARCHAR(50),
    reference_id         UUID,
    currency_id          UUID            NOT NULL,
    description          VARCHAR(255),
    created_at           TIMESTAMPTZ     NOT NULL,
    updated_at           TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_journal_entries PRIMARY KEY (journal_entry_id),
    CONSTRAINT fk_journal_entries_currency FOREIGN KEY (currency_id)
        REFERENCES reference_data.currencies (currency_id)
    -- reference_type/reference_id: Patrón C, sin FK física.
);

CREATE TABLE ledger.journal_entry_lines (
    journal_entry_line_id     UUID            NOT NULL,
    journal_entry_id          UUID            NOT NULL,
    ledger_account_id         UUID            NOT NULL,
    entry_type                VARCHAR(10)     NOT NULL,
    amount                    NUMERIC(19,4)   NOT NULL,
    created_at                TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_journal_entry_lines PRIMARY KEY (journal_entry_line_id),
    CONSTRAINT fk_journal_entry_lines_entry FOREIGN KEY (journal_entry_id)
        REFERENCES ledger.journal_entries (journal_entry_id),
    CONSTRAINT fk_journal_entry_lines_account FOREIGN KEY (ledger_account_id)
        REFERENCES ledger.ledger_accounts (ledger_account_id),
    CONSTRAINT ck_journal_entry_lines_entry_type CHECK (entry_type IN ('DEBIT','CREDIT')),
    CONSTRAINT ck_journal_entry_lines_amount CHECK (amount > 0)
    -- SUM(DEBIT)=SUM(CREDIT) por asiento es una regla de conjunto (multi-fila);
    -- no se implementa como CHECK de una sola fila ni se inventa un trigger no
    -- solicitado. Reportado como RECOMENDACIÓN — NO IMPLEMENTADA.
);
