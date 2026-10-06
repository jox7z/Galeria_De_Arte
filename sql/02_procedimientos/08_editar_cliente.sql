CREATE OR REPLACE PROCEDURE EDITAR_CLIENTE(
P_ID_USUARIO IN NUMBER,
    P_ID_CLIENTE        IN NUMBER,
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
     V_ID_CLIENTE NUMBER;
BEGIN
--VALIDACIONES---
    SP_VALIDAR_PERMISO(P_ID_USUARIO, 'EDITAR_CLIENTE');
    
      BEGIN
        SELECT ID_CLIENTE INTO V_ID_CLIENTE
        FROM CLIENTES
        WHERE ID_CLIENTE = P_ID_CLIENTE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20015, 'El cliente no existe.');
    END;
    
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
    WHERE IDENTIFICACION = P_IDENTIFICACION AND ID_CLIENTE <> P_ID_CLIENTE;

    IF V_EXISTE_IDENTIFICACION > 0 THEN
        RAISE_APPLICATION_ERROR(-20043, 'La identificación ya está registrada en el sistema.');
    END IF;
    
    ---------------------------------------------------------------
    -- VALIDAR QUE EL CORREO SEA ÚNICO
    ---------------------------------------------------------------
    SELECT COUNT(*)
    INTO V_EXISTE_CORREO
    FROM CLIENTES
    WHERE CORREO_ELECTRONICO = P_CORREO AND ID_CLIENTE <>P_ID_CLIENTE;

    IF V_EXISTE_CORREO > 0 THEN
        RAISE_APPLICATION_ERROR(-20043, 'El correo ya está registrado en el sistema.');
    END IF;
    
    UPDATE CLIENTES
    SET
        NOMBRE = P_NOMBRE,
        APELLIDO = P_APELLIDO,
        CORREO_ELECTRONICO = P_CORREO,
        TELEFONO = P_TELEFONO,
        DIRECCION = P_DIRECCION,
        TIPO_CLIENTE = P_TIPO_CLIENTE,
        IDENTIFICACION = P_IDENTIFICACION
    WHERE ID_CLIENTE = P_ID_CLIENTE;

    EXCEPTION
       WHEN OTHERS THEN
        RAISE; -- Re-lanzar el error
END;
/
