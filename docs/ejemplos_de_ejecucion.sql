-------ejecutar sp venta -----------

DECLARE
  V_PROD T_LISTA_PRODUCTOS := T_LISTA_PRODUCTOS();
BEGIN
  V_PROD.EXTEND(2);
  V_PROD(1) := T_DETALLE_PRODUCTO(25, 4); -- 2 unidades del producto 1
  V_PROD(2) := T_DETALLE_PRODUCTO(21, 3); -- 1 unidad del producto 3

  PROCESAR_VENTA(1, 'PRODUCTO', 'EFECTIVO', V_PROD,SYS_CONTEXT('APP_CTX', 'USUARIO'));
END;
/

-------ejecutar sp mantenimiento-----------

--VENTA PRODUCTO
DECLARE
  V_PROD T_LISTA_PRODUCTOS := T_LISTA_PRODUCTOS();
BEGIN
  V_PROD.EXTEND(2);
  V_PROD(1) := T_DETALLE_PRODUCTO(25, 1); -- 5 unidades del producto 1
  V_PROD(2) := T_DETALLE_PRODUCTO(21, 4); -- 4 unidad del producto 21

  registrar_mantenimiento_obra(
        p_id_obra => 3,
        p_id_usuario => SYS_CONTEXT('APP_CTX', 'USUARIO'),
        p_estado_conservacion => 'En restauración',
        p_observaciones => 'Aplicación de limpiador y retoque de pintura',
        p_productos => V_PROD
    );
END;
/

--sp crear producto---
BEGIN
    CREAR_PRODUCTO(
        P_ID_USUARIO => SYS_CONTEXT('APP_CTX', 'USUARIO'),
        P_ID_PROVEEDOR     => 1,
        P_NOMBRE_PRODUCTO  => 'Pintura Acrílica',
        P_TIPO_PRODUCTO    => 'INSTRUMENTO',
        P_COSTO            => 3500,
        P_PRECIO_VENTA     => 5000,
        P_CANTIDAD         => 20,
        P_STOCK_MINIMO => 6
    );
END;
/


--sp cOMPRAR producto EXISTENTE---
BEGIN
    COMPRAR_PRODUCTO_EXISTENTE(
        P_ID_USUARIO => SYS_CONTEXT('APP_CTX', 'USUARIO'),
        P_ID_PRODUCTO     => 62,
        P_COSTO            => 4000,
        P_CANTIDAD         => 20
    );
END;
/


--sp CREAR CLIENTE---
BEGIN
    CREAR_CLIENTE(
        P_ID_USUARIO => SYS_CONTEXT('APP_CTX', 'USUARIO'),
        P_NOMBRE => 'derek',
        P_APELLIDO  => 'juanito',
        P_CORREO => 'aaaa@gmail.com',
        P_TELEFONO =>  '2213213',        
        P_DIRECCION => 'san sebas',
        P_TIPO_CLIENTE=>'PERSONA',
        P_IDENTIFICACION=>'123131232'
    );
END;



