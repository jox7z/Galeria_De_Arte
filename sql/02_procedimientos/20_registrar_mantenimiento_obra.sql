create or replace NONEDITIONABLE PROCEDURE REGISTRAR_MANTENIMIENTO_OBRA (
    P_ID_OBRA            IN NUMBER,
    P_ID_USUARIO         IN NUMBER,
    P_ESTADO_CONSERVACION IN VARCHAR2,
    P_OBSERVACIONES      IN VARCHAR2,
    P_PRODUCTOS    IN T_LISTA_PRODUCTOS DEFAULT NULL
)
AS
    V_ID_MANTENIMIENTO   NUMBER;
    V_STOCK       NUMBER;
    V_ESTADO      VARCHAR2(100);
    V_NOMBRE      VARCHAR2(200);
BEGIN
    ----------------------------------------------------------
    -- VALIDACIONES INICIALES
    ----------------------------------------------------------
    SP_VALIDAR_PERMISO(P_ID_USUARIO, 'CREAR_MANTENIMIENTO');
    
    IF P_PRODUCTOS IS NULL OR P_PRODUCTOS.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Debe enviar al menos un ítem.');
    END IF;

    --STOCK PRODUCTOS
    FOR I IN 1 .. P_PRODUCTOS.COUNT LOOP
        BEGIN
            SELECT CANTIDAD, NOMBRE_PRODUCTO
            INTO V_STOCK, V_NOMBRE
            FROM PRODUCTOS
            WHERE ID_PRODUCTO = P_PRODUCTOS(I).ID_PRODUCTO
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20012, 'Producto no existe.');
        END;

        IF V_STOCK < P_PRODUCTOS(I).CANTIDAD THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Stock insuficiente para el producto: ' || V_NOMBRE
            );
        END IF;
    END LOOP;    

    --ESTADO OBRA
    BEGIN
        SELECT ESTADO_OBRA
        INTO V_ESTADO
        FROM OBRAS
        WHERE ID_OBRA = P_ID_OBRA
        FOR UPDATE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20013, 'Obra no existe.');
    END;

    IF V_ESTADO <> 'DISPONIBLE' THEN
        RAISE_APPLICATION_ERROR(-20002, 'La obra no está disponible.');
    END IF;

    ----------------------------------------------------------
    -- CREAR MANTENIMIENTO_OBRAS
    ----------------------------------------------------------
    INSERT INTO MANTENIMIENTO_OBRAS (ID_OBRA, ID_USUARIO, ESTADO_CONSERVACION, OBSERVACIONES)
    VALUES (P_ID_OBRA, P_ID_USUARIO, P_ESTADO_CONSERVACION, P_OBSERVACIONES)
    RETURNING ID_MANTENIMIENTO INTO V_ID_MANTENIMIENTO;

    ----------------------------------------------------------
    -- CREAR DETALLE DEL MANTENIMIENTO
    ----------------------------------------------------------
    FOR I IN 1 .. P_PRODUCTOS.COUNT LOOP
        INSERT INTO DETALLE_MANTENIMIENTO_OBRAS
            (ID_MANTENIMIENTO, ID_PRODUCTO, CANT_USADA)
        VALUES
            (V_ID_MANTENIMIENTO, P_PRODUCTOS(I).ID_PRODUCTO,
             P_PRODUCTOS(I).CANTIDAD);

        -- Registrar movimiento
        INSERT INTO MOVIMIENTOS_INVENTARIO
            (ID_PRODUCTO, TIPO_MOVIMIENTO, CANTIDAD)
        VALUES
            (P_PRODUCTOS(I).ID_PRODUCTO, 'SALIDA',
             P_PRODUCTOS(I).CANTIDAD);

        -- Actualizar inventario
        UPDATE PRODUCTOS
        SET CANTIDAD = CANTIDAD - P_PRODUCTOS(I).CANTIDAD
        WHERE ID_PRODUCTO = P_PRODUCTOS(I).ID_PRODUCTO;
    END LOOP;

    -- Actualizar estado de la obra (FUERA del loop)
    UPDATE OBRAS
    SET ESTADO_OBRA = 'EN MANTENIMIENTO'
    WHERE ID_OBRA = P_ID_OBRA;

    COMMIT; -- Confirmar la transacción

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Primero hacer rollback
        RAISE; -- Re-lanzar el error
END;
/
