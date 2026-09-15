-- =========================================================
-- 02-flyway-setup.sql
-- MIA AVANZA CONTIGO - mia-database
--
-- Creates the technical PostgreSQL role used by Flyway.
-- Authentication is performed through Amazon RDS IAM.
-- =========================================================

CREATE ROLE flyway_mia
    LOGIN
    NOSUPERUSER
    NOCREATEDB
    CREATEROLE
    NOBYPASSRLS
    NOREPLICATION;

GRANT rds_iam TO flyway_mia;

SELECT
    rolname,
    rolcanlogin,
    rolsuper,
    rolcreatedb,
    rolcreaterole
FROM pg_roles
WHERE rolname = 'flyway_mia';

