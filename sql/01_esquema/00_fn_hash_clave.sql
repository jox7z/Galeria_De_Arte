-- Hash SHA-256 de la contraseña, con el nombre de usuario como "sal" simple.
-- Requiere Oracle 12c o superior (STANDARD_HASH). Para un sistema real usar PBKDF2/bcrypt desde la aplicación.
CREATE OR REPLACE FUNCTION FN_HASH_CLAVE (
    P_NOMBRE_USUARIO IN VARCHAR2,
    P_CLAVE          IN VARCHAR2
) RETURN VARCHAR2 DETERMINISTIC
IS
    V_HASH VARCHAR2(64);
BEGIN
    SELECT RAWTOHEX(STANDARD_HASH(LOWER(P_NOMBRE_USUARIO) || ':' || P_CLAVE, 'SHA256'))
      INTO V_HASH FROM DUAL;
    RETURN V_HASH;
END;
/
