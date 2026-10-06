create or replace NONEDITIONABLE PROCEDURE                "SP_VINCULAR_MULTIPLES_ARTISTAS" (
    P_ID_USUARIO IN NUMBER, 
    p_id_obra IN NUMBER,
    p_ids_artistas IN VARCHAR2  -- IDs separados por comas: '1,2,3'
) AS
    v_id_artista NUMBER;
    v_posicion NUMBER := 1;
    v_siguiente_coma NUMBER;
    v_ids_temp VARCHAR2(4000) := p_ids_artistas || ',';
    v_count NUMBER;
BEGIN
    SP_VALIDAR_PERMISO(P_ID_USUARIO, 'CREAR OBRA');
    -- Validar que la obra existe
    SELECT COUNT(*) INTO v_count
    FROM OBRAS
    WHERE ID_OBRA = p_id_obra;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20081, 'La obra con ID ' || p_id_obra || ' no existe');
    END IF;

    -- Procesar cada ID de artista
    WHILE v_posicion < LENGTH(v_ids_temp) LOOP
        v_siguiente_coma := INSTR(v_ids_temp, ',', v_posicion);

        IF v_siguiente_coma > 0 THEN
            v_id_artista := TO_NUMBER(TRIM(SUBSTR(v_ids_temp, v_posicion, v_siguiente_coma - v_posicion)));

            -- Vincular cada artista (usa el SP existente)
            BEGIN
                SP_VINCULAR_OBRA(v_id_artista, p_id_obra);
            EXCEPTION
                WHEN OTHERS THEN
                     RAISE;  -- Propagar el error original de vincular obra al artista 

            END;

            v_posicion := v_siguiente_coma + 1;
        ELSE
            EXIT;
        END IF;
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_VINCULAR_MULTIPLES_ARTISTAS;
/
