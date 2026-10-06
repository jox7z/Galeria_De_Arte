create or replace NONEDITIONABLE PROCEDURE                "SP_VINCULAR_OBRA" (
    P_ID_USUARIO IN NUMBER,
    p_id_artista IN NUMBER,
    p_id_obra IN NUMBER
) AS
    v_count NUMBER;
    v_nombre_artista VARCHAR2(200);
    v_titulo_obra VARCHAR2(100);
BEGIN
    SP_VALIDAR_PERMISO(P_ID_USUARIO, 'VENDER_PRODUCTO');
    -- Validar parametros
    IF p_id_artista IS NULL OR p_id_obra IS NULL THEN
        RAISE_APPLICATION_ERROR(-20021, 'ID de artista y obra son obligatorios');
    END IF;

    -- Validar que artista existe y esta activo
    BEGIN
        SELECT COUNT(*), MAX(NOMBRE || ' ' || APELLIDO) 
        INTO v_count, v_nombre_artista
        FROM ARTISTAS 
        WHERE ID_ARTISTA = p_id_artista AND ESTADO = 'ACTIVO';

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20022, 'El artista con ID ' || p_id_artista || ' no existe o esta inactivo');
        END IF;
    END;

    -- Validar que obra existe y no esta vendida
    BEGIN
        SELECT COUNT(*), MAX(TITULO_OBRA) 
        INTO v_count, v_titulo_obra
        FROM OBRAS 
        WHERE ID_OBRA = p_id_obra;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20023, 'La obra con ID ' || p_id_obra || ' no existe');
        END IF;

        -- Verificar estado de la obra
        SELECT COUNT(*) INTO v_count
        FROM OBRAS
        WHERE ID_OBRA = p_id_obra AND ESTADO_OBRA = 'VENDIDA';

        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20024, 'No se puede vincular la obra "' || v_titulo_obra || '" porque ya fue vendida');
        END IF;
    END;

    -- Insertar vinculacion
    INSERT INTO OBRAS_ARTISTAS (ID_ARTISTA, ID_OBRA)
    VALUES (p_id_artista, p_id_obra);

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20025, 'La obra ya esta vinculada con este artista');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_VINCULAR_OBRA;
/
