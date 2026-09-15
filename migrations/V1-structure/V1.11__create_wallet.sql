-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.11 — Estructura física: schema `wallet`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================
--  wallet.wallet_accounts)
-- ----------------------------------------------------------------------------

CREATE TABLE wallet.wallets (
    wallet_id       UUID            NOT NULL,
    customer_id     UUID            NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL,
    updated_at      TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_wallets PRIMARY KEY (wallet_id),
    CONSTRAINT fk_wallets_customer FOREIGN KEY (customer_id)
        REFERENCES customer.customers (customer_id),
    CONSTRAINT uq_wallets_customer UNIQUE (customer_id)
);

CREATE TABLE wallet.wallet_accounts (
    wallet_account_id       UUID            NOT NULL,
    wallet_id               UUID            NOT NULL,
    account_type            VARCHAR(20)     NOT NULL,
    external_account_id     UUID,
    created_at               TIMESTAMPTZ     NOT NULL,
    updated_at               TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_wallet_accounts PRIMARY KEY (wallet_account_id),
    CONSTRAINT fk_wallet_accounts_wallet FOREIGN KEY (wallet_id)
        REFERENCES wallet.wallets (wallet_id),
    CONSTRAINT fk_wallet_accounts_external_account FOREIGN KEY (external_account_id)
        REFERENCES customer.customer_bank_accounts (customer_bank_account_id),
    -- CHECK deliberado y temporal: solo EXTERNAL habilitado (4.12.6). Habilitar
    -- INTERNAL requiere decisión expresa de Dirección General + migración.
    CONSTRAINT ck_wallet_accounts_type_external_only CHECK (account_type = 'EXTERNAL'),
    CONSTRAINT ck_wallet_accounts_external_account_required
        CHECK (account_type <> 'EXTERNAL' OR external_account_id IS NOT NULL)
);
