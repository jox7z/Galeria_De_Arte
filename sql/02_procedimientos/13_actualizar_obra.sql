create or replace NONEDITIONABLE PROCEDURE                "SP_ACTUALIZAR_OBRA" (
    P_ID_USUARIO IN NUMBER,
    p_id_obra IN NUMBER,
    p_precio IN NUMBER DEFAULT NULL,
    p_estado IN VARCHAR2 DEFAULT NULL,
    p_descripcion IN VARCHAR2 DEFAULT NULL
) AS
    v_count NUMBER;
BEGIN
    SP_VALIDAR_PERMISO(P_ID_USUARIO, 'EDITAR_OBRA');
    -- Validar que la obra existe
    SELECT COUNT(*) INTO v_count 
    FROM OBRAS 
    WHERE ID_OBRA = p_id_obra;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20041, 'La obra con ID ' || p_id_obra || ' no existe');
    END IF;

    -- Validar estado si se proporciona
    IF p_estado IS NOT NULL AND p_estado NOT IN ('DISPONIBLE', 'RESERVADA', 'VENDIDA') THEN
        RAISE_APPLICATION_ERROR(-20042, 'Estado invalido. Use: DISPONIBLE, RESERVADA o VENDIDA');
    END IF;

    -- Validar precio
    IF p_precio IS NOT NULL AND p_precio < 0 THEN
        RAISE_APPLICATION_ERROR(-20043, 'El precio no puede ser negativo');
    END IF;

    -- Actualizar campos proporcionados
    UPDATE OBRAS
    SET PRECIO = NVL(p_precio, PRECIO),
        ESTADO_OBRA = NVL(p_estado, ESTADO_OBRA),
        DESCRIPCION = NVL(p_descripcion, DESCRIPCION)
    WHERE ID_OBRA = p_id_obra;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_ACTUALIZAR_OBRA;
/
