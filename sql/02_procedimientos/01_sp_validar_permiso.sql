CREATE OR REPLACE PROCEDURE SP_VALIDAR_PERMISO (
    P_ID_USUARIO IN NUMBER,
    P_NOMBRE_PERMISO IN VARCHAR2
)
AS
    V_TIENE_PERMISO NUMBER;
    V_NOMBRE_USUARIO VARCHAR2(100);
BEGIN
    -- Verificar si el usuario existe y está activo
    BEGIN
        SELECT NOMBRE_USUARIO INTO V_NOMBRE_USUARIO
        FROM USUARIOS
        WHERE ID_USUARIO = P_ID_USUARIO
          AND ESTADO = 'ACTIVO';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20100, 'Usuario no existe o está inactivo.');
    END;
    
    -- Verificar si tiene el permiso
    SELECT COUNT(*)
    INTO V_TIENE_PERMISO
    FROM USUARIOS u
    JOIN PERMISOS_ROLES pr ON u.ID_ROL = pr.ID_ROL
    JOIN PERMISOS p ON pr.ID_PERMISO = p.ID_PERMISO
    WHERE u.ID_USUARIO = P_ID_USUARIO
      AND p.NOMBRE_PERMISO = P_NOMBRE_PERMISO;
    
    -- Si no tiene el permiso, lanzar error
    IF V_TIENE_PERMISO = 0 THEN
        RAISE_APPLICATION_ERROR(-20101, 
            'Usuario "' || V_NOMBRE_USUARIO || '" no tiene permiso para: ' || P_NOMBRE_PERMISO);
    END IF;
END;
/
