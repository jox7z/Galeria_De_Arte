-- Prueba de humo: ejecutar como GALERIAARTE después de @install.sql
SET SERVEROUTPUT ON
DECLARE
    V_ID NUMBER; V_ROL NUMBER; V_PROV NUMBER;
    V_PROD T_LISTA_PRODUCTOS := T_LISTA_PRODUCTOS();
BEGIN
    SP_LOGIN('admin', 'admin123', V_ID, V_ROL);
    DBMS_OUTPUT.PUT_LINE('Login OK -> usuario ' || V_ID || ', rol ' || V_ROL);

    SP_CREAR_PROVEEDOR(V_ID, 'Arte Global S.A.', 'María López', '8888-9999', 'San José', V_PROV);
    CREAR_PRODUCTO(V_ID, V_PROV, 'Pintura Acrílica', 'INSTRUMENTO', 3500, 5000, 20, 6);
    CREAR_CLIENTE(V_ID, 'Derek', 'Juanito', 'derek@correo.com', '22132132', 'San Sebastián', 'PERSONA', '123131232');

    V_PROD.EXTEND(1);
    V_PROD(1) := T_DETALLE_PRODUCTO(1, 10);      -- 10 unidades del producto 1
    PROCESAR_VENTA(
        P_ID_CLIENTE => 1, P_TIPO_PEDIDO => 'PRODUCTO', P_METODO_PAGO => 'EFECTIVO',
        P_PRODUCTOS => V_PROD, P_ID_USUARIO => V_ID,
        P_MONTO_PAGADO => 56500);                 -- 10 x 5000 + 13% IVA
END;
/
SELECT * FROM VW_PERMISOS_POR_ROL WHERE ROWNUM <= 5;
SELECT ID_PEDIDO, TIPO_PEDIDO, TOTAL, ESTADO_PEDIDO FROM PEDIDOS;
