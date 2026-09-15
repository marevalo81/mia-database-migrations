-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.3 — Estructura física: schema `documents`
-- Fuente: schema.sql (§4.x correspondiente) — sin modificaciones de diseño.
-- ============================================================================
--  física HACIA documents.documents; documents nunca referencia hacia ellos)
-- ----------------------------------------------------------------------------

CREATE TABLE documents.documents (
    document_id             UUID            NOT NULL,
    document_category       VARCHAR(50)     NOT NULL,
    file_name               VARCHAR(255)    NOT NULL,
    mime_type               VARCHAR(100)    NOT NULL,
    storage_bucket          VARCHAR(100)    NOT NULL,
    storage_key             VARCHAR(500)    NOT NULL,
    status                  VARCHAR(30)     NOT NULL,
    replaces_document_id    UUID,
    uploader_type           VARCHAR(20)     NOT NULL,
    uploader_reference_id   UUID,
    retention_until         TIMESTAMPTZ,
    uploaded_at             TIMESTAMPTZ     NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL,
    updated_at              TIMESTAMPTZ     NOT NULL,
    CONSTRAINT pk_documents PRIMARY KEY (document_id),
    CONSTRAINT fk_documents_replaces FOREIGN KEY (replaces_document_id)
        REFERENCES documents.documents (document_id),
    CONSTRAINT ck_documents_uploader_type
        CHECK (uploader_type IN ('CUSTOMER','STAFF','SYSTEM'))
    -- uploader_reference_id es referencia lógica, sin FK física (explícito en el documento).
);
