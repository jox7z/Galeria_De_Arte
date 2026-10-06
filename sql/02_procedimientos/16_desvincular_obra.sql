create or replace NONEDITIONABLE PROCEDURE                "SP_DESVINCULAR_OBRA" (
    P_ID_USUARIO IN NUMBER,
    p_id_artista IN NUMBER,
    p_id_obra IN NUMBER
) AS
    v_count NUMBER;
BEGIN
    SP_VALIDAR_PERMISO(P_ID_USUARIO, 'ELIMINAR_OBRA');
    -- Verificar que existe la vinculacion
    
    SELECT COUNT(*) INTO v_count
    FROM OBRAS_ARTISTAS
    WHERE ID_ARTISTA = p_id_artista AND ID_OBRA = p_id_obra;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20051, 'No existe vinculacion entre el artista ' || p_id_artista || ' y la obra ' || p_id_obra);
    END IF;

    -- Eliminar vinculacion
    DELETE FROM OBRAS_ARTISTAS
    WHERE ID_ARTISTA = p_id_artista AND ID_OBRA = p_id_obra;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_DESVINCULAR_OBRA;
/
