CREATE OR REPLACE PROCEDURE CREAR_CLIENTE(
    P_ID_USUARIO IN NUMBER,
    P_NOMBRE            IN VARCHAR2,
    P_APELLIDO          IN VARCHAR2,
    P_CORREO            IN VARCHAR2,
    P_TELEFONO          IN VARCHAR2,
    P_DIRECCION         IN VARCHAR2,
    P_TIPO_CLIENTE      IN VARCHAR2,
    P_IDENTIFICACION    IN VARCHAR2
)
AS
    V_EXISTE_IDENTIFICACION NUMBER;
     V_EXISTE_CORREO NUMBER;
BEGIN
    --VALIDACIONES---
    SP_VALIDAR_PERMISO(P_ID_USUARIO, 'CREAR_CLIENTE');
    
    -- Validar tipo cliente si se proporciona
    IF P_TIPO_CLIENTE IS NOT NULL AND P_TIPO_CLIENTE NOT IN ('PERSONA','EMPRESA') THEN
        RAISE_APPLICATION_ERROR(-20042, 'Tipo de cliente invalido. Use: PERSONA o CLIENTE');
    END IF;
    
    ---------------------------------------------------------------
    -- VALIDAR QUE LA IDENTIFICACIÓN SEA ÚNICA
    ---------------------------------------------------------------
    SELECT COUNT(*)
    INTO V_EXISTE_IDENTIFICACION
    FROM CLIENTES
    WHERE IDENTIFICACION = P_IDENTIFICACION;

    IF V_EXISTE_IDENTIFICACION > 0 THEN
        RAISE_APPLICATION_ERROR(-20043, 'La identificación ya está registrada en el sistema.');
    END IF;
    
    ---------------------------------------------------------------
    -- VALIDAR QUE EL CORREO SEA ÚNICO
    ---------------------------------------------------------------
    SELECT COUNT(*)
    INTO V_EXISTE_CORREO
    FROM CLIENTES
    WHERE CORREO_ELECTRONICO = P_CORREO;

    IF V_EXISTE_CORREO > 0 THEN
        RAISE_APPLICATION_ERROR(-20043, 'El correo ya está registrado en el sistema.');
    END IF;
    
    
    
    INSERT INTO CLIENTES(
        NOMBRE, APELLIDO, CORREO_ELECTRONICO,
        TELEFONO, DIRECCION,
        TIPO_CLIENTE, ESTADO, IDENTIFICACION
    )
    VALUES(
        P_NOMBRE, P_APELLIDO, P_CORREO,
        P_TELEFONO, P_DIRECCION,
        P_TIPO_CLIENTE, 'ACTIVO', P_IDENTIFICACION
    );
    EXCEPTION
       WHEN OTHERS THEN
        RAISE; -- Re-lanzar el error
END;
/
