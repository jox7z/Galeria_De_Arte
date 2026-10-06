create or replace NONEDITIONABLE PROCEDURE                "SP_REGISTRAR_ARTISTA" (
    P_ID_USUARIO IN NUMBER, 
    p_nombre IN VARCHAR2,
    p_apellido IN VARCHAR2,
    p_correo IN VARCHAR2,
    p_identificacion IN VARCHAR2,
    p_nombre_artistico IN VARCHAR2 DEFAULT NULL,
    p_telefono IN VARCHAR2 DEFAULT NULL,
    p_direccion IN VARCHAR2 DEFAULT NULL,
    p_especializacion IN VARCHAR2 DEFAULT 'OTRO',
    p_id_artista OUT NUMBER
) AS
BEGIN
    SP_VALIDAR_PERMISO(P_ID_USUARIO, 'CREAR_OBRA');
    -- Validar campos obligatorios
    IF p_nombre IS NULL OR p_correo IS NULL OR p_identificacion IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nombre, correo e identificacion son obligatorios');
    END IF;

    -- Validar apellido obligatorio
    IF p_apellido IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'El apellido es obligatorio');
    END IF;

    -- Validar formato de correo
    IF NOT REGEXP_LIKE(p_correo, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Formato de correo invalido');
    END IF;

    -- Validar especializacion
    IF p_especializacion NOT IN ('PINTURA','FOTOGRAFIA','ESCULTURA','GRABADO','DIBUJO','OTRO') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Especializacion no valida. Use: PINTURA, FOTOGRAFIA, ESCULTURA, GRABADO, DIBUJO u OTRO');
    END IF;

    -- Insertar artista
    INSERT INTO ARTISTAS (
        NOMBRE, APELLIDO, NOMBRE_ARTISTICO, CORREO_ELECTRONICO, 
        IDENTIFICACION, TELEFONO, DIRECCION, ESPECIALIZACION
    ) VALUES (
        TRIM(p_nombre), TRIM(p_apellido), TRIM(p_nombre_artistico), LOWER(TRIM(p_correo)),
        p_identificacion, p_telefono, p_direccion, p_especializacion
    ) RETURNING ID_ARTISTA INTO p_id_artista;

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20005, 'Ya existe un artista con ese correo o identificacion');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_REGISTRAR_ARTISTA;
/
