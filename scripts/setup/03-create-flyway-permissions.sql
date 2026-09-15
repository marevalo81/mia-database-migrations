-- =========================================================
-- 03-create-flyway-permissions.sql
-- MIA AVANZA CONTIGO - mia-database
--
-- Grants the permissions required by Flyway on database "mia".
-- =========================================================

GRANT CONNECT ON DATABASE mia TO flyway_mia;
GRANT CREATE ON DATABASE mia TO flyway_mia;

GRANT USAGE, CREATE ON SCHEMA public TO flyway_mia;