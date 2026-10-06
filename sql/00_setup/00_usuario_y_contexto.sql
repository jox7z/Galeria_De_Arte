-- ============================================================
-- 00 - Ejecutar como SYSTEM / SYS (o un usuario DBA)
--   * En Oracle XE/Free/19c multitenant: conectarse al PDB
--     (XEPDB1 / FREEPDB1 / ORCLPDB), NO al CDB$ROOT.
-- ============================================================
-- Cambia la contraseña antes de ejecutar:
CREATE USER GALERIAARTE IDENTIFIED BY "CambiaEstaClave_123"
  DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS;

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE,
      CREATE PROCEDURE, CREATE TRIGGER, CREATE TYPE TO GALERIAARTE;

-- El sistema usa SYS_CONTEXT('APP_CTX','USUARIO') para saber quién actúa.
-- El contexto solo lo puede crear un usuario con este privilegio:
GRANT CREATE ANY CONTEXT TO GALERIAARTE;
CREATE OR REPLACE CONTEXT APP_CTX USING GALERIAARTE.SET_CONTEXT_PKG;
