-- ============================================================================
-- MIA AVANZA CONTIGO — V1-structure
-- V1.1 — Creación de todos los schemas PostgreSQL
-- Fuente: MIA-ModeloEntidadRelacion.pdf
-- ============================================================================
-- Los 22 schemas siguientes provienen de schema.sql (fuente física existente),
-- que a su vez traduce los 17 schemas transaccionales (4.1-4.17) y las
-- capacidades transversales con huella PostgreSQL (6) del ER.
CREATE SCHEMA reference_data;
CREATE SCHEMA auth;
CREATE SCHEMA customer;
CREATE SCHEMA providers;
CREATE SCHEMA kyc;
CREATE SCHEMA risk;
CREATE SCHEMA fraud;
CREATE SCHEMA compliance;
CREATE SCHEMA legal;
CREATE SCHEMA documents;
CREATE SCHEMA lending;
CREATE SCHEMA wallet;
CREATE SCHEMA payments;
CREATE SCHEMA ledger;
CREATE SCHEMA settlement;
CREATE SCHEMA collections;
CREATE SCHEMA treasury;
CREATE SCHEMA notifications;
CREATE SCHEMA outbox;
CREATE SCHEMA sequence_generation;
CREATE SCHEMA business_calendars;
CREATE SCHEMA audit;
CREATE SCHEMA reports;       
CREATE SCHEMA customer_support; 
