create or replace NONEDITIONABLE PROCEDURE                "SP_REGISTRAR_OBRA" (
    P_ID_USUARIO IN NUMBER,
    p_titulo IN VARCHAR2,
    p_tipo IN VARCHAR2,
    p_anio IN NUMBER,
    p_precio IN NUMBER,
    p_descripcion IN VARCHAR2 DEFAULT NULL,
    p_id_obra OUT NUMBER
) AS
BEGIN
    SP_VALIDAR_PERMISO(P_ID_USUARIO, 'CREAR_OBRA');
    -- Validar campos obligatorios
    IF p_titulo IS NULL THEN
        RAISE_APPLICATION_ERROR(-20011, 'El titulo de la obra es obligatorio');
    END IF;

    IF p_tipo IS NULL THEN
        RAISE_APPLICATION_ERROR(-20012, 'El tipo de obra es obligatorio');
    END IF;

    -- Validar tipo de obra
    IF p_tipo NOT IN ('PINTURA','FOTOGRAFIA','ESCULTURA','GRABADO','DIBUJO','OTRO') THEN
        RAISE_APPLICATION_ERROR(-20013, 'Tipo de obra no valido. Use: PINTURA, FOTOGRAFIA, ESCULTURA, GRABADO, DIBUJO u OTRO');
    END IF;

    -- Validar año
    IF p_anio IS NOT NULL AND (p_anio < 1000 OR p_anio > 9999) THEN
        RAISE_APPLICATION_ERROR(-20014, 'El año debe estar entre 1000 y 9999');
    END IF;

    -- Validar precio
    IF p_precio IS NOT NULL AND p_precio < 0 THEN
        RAISE_APPLICATION_ERROR(-20015, 'El precio no puede ser negativo');
    END IF;

    -- Insertar obra
    INSERT INTO OBRAS (
        TITULO_OBRA, TIPO_OBRA, ANIO_CREACION, 
        PRECIO, DESCRIPCION, ESTADO_OBRA
    ) VALUES (
        TRIM(p_titulo), p_tipo, p_anio,
        NVL(p_precio, 0), p_descripcion, 'DISPONIBLE'
    ) RETURNING ID_OBRA INTO p_id_obra;

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20016, 'Ya existe una obra con ese titulo');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_REGISTRAR_OBRA;
/
