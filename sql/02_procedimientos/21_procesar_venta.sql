create or replace NONEDITIONABLE PROCEDURE PROCESAR_VENTA (
    P_ID_CLIENTE   IN NUMBER,
    P_TIPO_PEDIDO  IN VARCHAR2,  -- 'PRODUCTO' o 'OBRA'
    P_METODO_PAGO  IN VARCHAR2,
    P_PRODUCTOS    IN T_LISTA_PRODUCTOS DEFAULT NULL,
    P_ID_USUARIO IN NUMBER,
    P_MONTO_PAGADO IN NUMBER DEFAULT NULL  -- efectivo/monto entregado por el cliente (opcional)
)
AS
    V_ID_PEDIDO   NUMBER;
    V_TOTAL       NUMBER := 0;
    V_ID_FACTURA  NUMBER;
    V_PRECIO      NUMBER;
    V_STOCK       NUMBER;
    V_ESTADO      VARCHAR2(100);
    V_NOMBRE      VARCHAR2(200);
    V_CLIENTE_ACTIVO NUMBER;
    V_USUARIO_ACTIVO NUMBER;
    V_TOTAL_IVA   NUMBER;
    V_VUELTO      NUMBER := 0;
BEGIN
    ----------------------------------------------------------
    -- VALIDACIONES INICIALES
    ----------------------------------------------------------

    IF P_PRODUCTOS IS NULL OR P_PRODUCTOS.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Debe enviar al menos un ítem.');
    END IF;

    IF P_TIPO_PEDIDO NOT IN ('PRODUCTO', 'OBRA') THEN
        RAISE_APPLICATION_ERROR(-20011, 'Tipo de pedido inválido.');
    END IF;

 -- Validar que el cliente este activo
    BEGIN
        SELECT COUNT(*)
        INTO V_CLIENTE_ACTIVO
        FROM CLIENTES
        WHERE ID_CLIENTE = P_ID_CLIENTE AND ESTADO = 'ACTIVO';

        IF V_CLIENTE_ACTIVO = 0 THEN
            RAISE_APPLICATION_ERROR(-20022, 'El cliente esta inactivo');
        END IF;
    END;
    
     -- Validar que el usuario este activo
    BEGIN
        SELECT COUNT(*)
        INTO V_USUARIO_ACTIVO
        FROM USUARIOS
        WHERE ID_USUARIO = P_ID_USUARIO AND ESTADO = 'ACTIVO';

        IF V_USUARIO_ACTIVO = 0 THEN
            RAISE_APPLICATION_ERROR(-20022, 'El usuario esta inactivo');
        END IF;
    END;
    ----------------------------------------------------------
    -- VALIDAR STOCK / DISPONIBILIDAD ANTES DE CREAR PEDIDO
    ----------------------------------------------------------
    IF P_TIPO_PEDIDO = 'PRODUCTO' THEN
        SP_VALIDAR_PERMISO(P_ID_USUARIO, 'VENDER_PRODUCTO');
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
    END IF;

    IF P_TIPO_PEDIDO = 'OBRA' THEN
     SP_VALIDAR_PERMISO(P_ID_USUARIO, 'VENDER_OBRA');
        FOR I IN 1 .. P_PRODUCTOS.COUNT LOOP
            BEGIN
                SELECT ESTADO_OBRA
                INTO V_ESTADO
                FROM OBRAS
                WHERE ID_OBRA = P_PRODUCTOS(I).ID_PRODUCTO
                FOR UPDATE;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20013, 'Obra no existe.');
            END;

            IF V_ESTADO <> 'DISPONIBLE' THEN
                RAISE_APPLICATION_ERROR(-20002, 'La obra no está disponible.');
            END IF;
        END LOOP;
    END IF;

    ----------------------------------------------------------
    -- CREAR PEDIDO
    ----------------------------------------------------------
    INSERT INTO PEDIDOS (ID_CLIENTE, ESTADO_PEDIDO, TIPO_PEDIDO, METODO_PAGO, TOTAL)
    VALUES (P_ID_CLIENTE, 'PENDIENTE', P_TIPO_PEDIDO, P_METODO_PAGO, 0)
    RETURNING ID_PEDIDO INTO V_ID_PEDIDO;

    ----------------------------------------------------------
    -- PROCESAR PRODUCTOS
    ----------------------------------------------------------
    IF P_TIPO_PEDIDO = 'PRODUCTO' THEN
        FOR I IN 1 .. P_PRODUCTOS.COUNT LOOP
            SELECT PRECIO_VENTA
            INTO V_PRECIO
            FROM PRODUCTOS
            WHERE ID_PRODUCTO = P_PRODUCTOS(I).ID_PRODUCTO
            FOR UPDATE;

            INSERT INTO DETALLE_PEDIDO_PRODUCTO
                (ID_PEDIDO, ID_PRODUCTO, CANTIDAD, PRECIO_UNITARIO)
            VALUES
                (V_ID_PEDIDO, P_PRODUCTOS(I).ID_PRODUCTO,
                 P_PRODUCTOS(I).CANTIDAD, V_PRECIO);

            -- Actualizar inventario
            UPDATE PRODUCTOS
            SET CANTIDAD = CANTIDAD - P_PRODUCTOS(I).CANTIDAD
            WHERE ID_PRODUCTO = P_PRODUCTOS(I).ID_PRODUCTO;

            V_TOTAL := V_TOTAL + (V_PRECIO * P_PRODUCTOS(I).CANTIDAD);
        END LOOP;
    END IF;

    ----------------------------------------------------------
    -- PROCESAR OBRAS (SIEMPRE SON 1 UNIDAD)
    ----------------------------------------------------------
    IF P_TIPO_PEDIDO = 'OBRA' THEN
        FOR I IN 1 .. P_PRODUCTOS.COUNT LOOP
            SELECT PRECIO, ESTADO_OBRA
            INTO V_PRECIO, V_ESTADO
            FROM OBRAS
            WHERE ID_OBRA = P_PRODUCTOS(I).ID_PRODUCTO
            FOR UPDATE;

            -- Insertar detalle sin cantidad
            INSERT INTO DETALLE_PEDIDO
                (ID_PEDIDO, ID_OBRA, PRECIO_UNITARIO)
            VALUES
                (V_ID_PEDIDO, P_PRODUCTOS(I).ID_PRODUCTO, V_PRECIO);

            -- Movimiento de inventario
            INSERT INTO MOVIMIENTOS_INVENTARIO_OBRAS
                (ID_OBRA, TIPO_MOVIMIENTO)
            VALUES
                (P_PRODUCTOS(I).ID_PRODUCTO, 'SALIDA');

            -- Cambiar estado a vendida
            UPDATE OBRAS
            SET ESTADO_OBRA = 'VENDIDA'
            WHERE ID_OBRA = P_PRODUCTOS(I).ID_PRODUCTO;

            V_TOTAL := V_TOTAL + V_PRECIO;
        END LOOP;
    END IF;

    ----------------------------------------------------------
    -- FACTURA Y PAGO
    ----------------------------------------------------------
    V_TOTAL_IVA := ROUND(V_TOTAL * 1.13, 2);   -- IVA 13 %

    IF P_MONTO_PAGADO IS NOT NULL AND P_MONTO_PAGADO < V_TOTAL_IVA THEN
        RAISE_APPLICATION_ERROR(-20023,
            'Monto pagado insuficiente. Total con IVA (13%): ' || V_TOTAL_IVA);
    END IF;

    IF P_MONTO_PAGADO IS NOT NULL THEN
        V_VUELTO := P_MONTO_PAGADO - V_TOTAL_IVA;
    END IF;

    UPDATE PEDIDOS
    SET TOTAL = V_TOTAL,
        ESTADO_PEDIDO = 'PAGADO'
    WHERE ID_PEDIDO = V_ID_PEDIDO;

    INSERT INTO FACTURAS (ID_PEDIDO, ID_USUARIO,TOTAL_FACTURA)
    VALUES (V_ID_PEDIDO, SYS_CONTEXT('APP_CTX', 'USUARIO'),V_TOTAL)
    RETURNING ID_FACTURA INTO V_ID_FACTURA;

    INSERT INTO PAGOS
        (ID_FACTURA, MONTO_PAGADO, METODO_PAGO, ESTADO_PAGO)
    VALUES
        (V_ID_FACTURA, V_TOTAL_IVA, P_METODO_PAGO, 'COMPLETADO');

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Venta realizada. Pedido: ' || V_ID_PEDIDO ||
                         ' - Factura: ' || V_ID_FACTURA ||
                         ' - Total con IVA: ' || V_TOTAL_IVA ||
                         ' - Vuelto: ' || V_VUELTO);

EXCEPTION
       WHEN OTHERS THEN
        ROLLBACK; -- Primero hacer rollback
        RAISE; -- Re-lanzar el error
END;
/
