create or replace NONEDITIONABLE PROCEDURE                "SP_ACTUALIZAR_ARTISTA" (
    P_ID_USUARIO IN NUMBER,
    p_id_artista IN NUMBER,
    p_telefono IN VARCHAR2 DEFAULT NULL,
    p_direccion IN VARCHAR2 DEFAULT NULL,
    p_estado IN VARCHAR2 DEFAULT NULL
) AS
    v_count NUMBER;
BEGIN
--VALIDACIONES---
    SP_VALIDAR_PERMISO(P_ID_USUARIO, 'EDITAR_OBRA');
    -- Validar que el artista existe
    SELECT COUNT(*) INTO v_count 
    FROM ARTISTAS 
    WHERE ID_ARTISTA = p_id_artista;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20031, 'El artista con ID ' || p_id_artista || ' no existe');
    END IF;

    -- Validar estado si se proporciona
    IF p_estado IS NOT NULL AND p_estado NOT IN ('ACTIVO', 'INACTIVO') THEN
        RAISE_APPLICATION_ERROR(-20032, 'Estado invalido. Use: ACTIVO o INACTIVO');
    END IF;

    -- Actualizar solo campos proporcionados
    UPDATE ARTISTAS
    SET TELEFONO = NVL(p_telefono, TELEFONO),
        DIRECCION = NVL(p_direccion, DIRECCION),
        ESTADO = NVL(p_estado, ESTADO)
    WHERE ID_ARTISTA = p_id_artista;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20033, 'No se pudo actualizar el artista');
    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_ACTUALIZAR_ARTISTA;
/
