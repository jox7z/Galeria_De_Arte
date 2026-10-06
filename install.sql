-- Instalación (SQL*Plus / SQLcl). Conectado como GALERIAARTE, desde la raíz del repo:
--   sql galeriaarte/<clave>@//localhost:1521/FREEPDB1
--   SQL> @install.sql
-- Antes: ejecutar sql/00_setup/00_usuario_y_contexto.sql como SYSTEM.
SET DEFINE OFF
SET SERVEROUTPUT ON
@sql/01_esquema/00_fn_hash_clave.sql
@sql/01_esquema/01_esquema_completo.sql
@sql/02_procedimientos/01_sp_validar_permiso.sql
@sql/02_procedimientos/02_crear_rol.sql
@sql/02_procedimientos/03_editar_rol.sql
@sql/02_procedimientos/04_crear_usuario.sql
@sql/02_procedimientos/05_editar_usuario.sql
@sql/02_procedimientos/06_deshabilitar_usuario.sql
@sql/02_procedimientos/07_crear_cliente.sql
@sql/02_procedimientos/08_editar_cliente.sql
@sql/02_procedimientos/09_deshabilitar_cliente.sql
@sql/02_procedimientos/10_registrar_artista.sql
@sql/02_procedimientos/11_actualizar_artista.sql
@sql/02_procedimientos/12_registrar_obra.sql
@sql/02_procedimientos/13_actualizar_obra.sql
@sql/02_procedimientos/14_vincular_obra.sql
@sql/02_procedimientos/15_vincular_multiples_artistas.sql
@sql/02_procedimientos/16_desvincular_obra.sql
@sql/02_procedimientos/17_crear_producto.sql
@sql/02_procedimientos/18_comprar_producto_existente.sql
@sql/02_procedimientos/19_actualizar_producto.sql
@sql/02_procedimientos/20_registrar_mantenimiento_obra.sql
@sql/02_procedimientos/21_procesar_venta.sql
@sql/02_procedimientos/22_vista_permisos_por_rol.sql
@sql/02_procedimientos/23_sp_login.sql
@sql/02_procedimientos/24_habilitar_usuario.sql
@sql/02_procedimientos/25_habilitar_cliente.sql
@sql/02_procedimientos/26_sp_obra_habilitar.sql
@sql/02_procedimientos/27_sp_crear_proveedor.sql
@sql/02_procedimientos/28_sp_actualizar_proveedor.sql
@sql/03_datos/01_semilla.sql
-- Objetos inválidos (debe salir vacío):
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
-- Errores de compilación (debe salir vacío):
SELECT name, type, line, text FROM user_errors ORDER BY name, sequence;
