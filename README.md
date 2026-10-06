# Sistema de Galería de Arte — Oracle Database (PL/SQL)

Base de datos relacional para administrar una galería de arte: artistas, obras, clientes,
inventario de productos, mantenimiento de obras, ventas/facturación y visitantes.
Incluye control de acceso por **roles y permisos**, **bitácora de auditoría** mediante triggers,
alertas de stock bajo y vistas para reportes.

## Tecnologías
Oracle Database (PL/SQL) · SQL Developer · procedimientos almacenados · triggers · tipos de colección · vistas · `SYS_CONTEXT` / `DBMS_SESSION`

## Estructura
```
sql/00_setup/        Usuario GALERIAARTE y contexto APP_CTX (como SYSTEM)
sql/01_esquema/      Tipos, tablas, índices, vistas, triggers, paquete SET_CONTEXT_PKG
sql/02_procedimientos/  Procedimientos finales (reemplazan las versiones antiguas del esquema)
sql/03_datos/        Roles, permisos y usuarios de demostración
docs/                Manual de usuario (PDF) y ejemplos de ejecución
install.sql          Instala todo en orden
```

## Instalación
1. Como **SYSTEM** (en el PDB, p. ej. `FREEPDB1`/`XEPDB1`, no en el CDB raíz): ejecutar `sql/00_setup/00_usuario_y_contexto.sql` (cambia la clave antes).
2. Conectarse como `GALERIAARTE` y ejecutar `@install.sql` desde la raíz del repo (SQLcl / SQL*Plus).
   En SQL Developer: abrir cada script en el orden de `install.sql` y ejecutarlo con **F5** (Run Script).
3. Revisar las dos consultas finales de `install.sql`: objetos inválidos y errores de compilación deben salir vacíos.
4. Opcional: `docs/prueba_de_humo.sql` (login, proveedor, producto, cliente y una venta).

Requiere Oracle 12c o superior (columnas `IDENTITY` y `STANDARD_HASH`).

## Usuarios de demostración
| Usuario | Clave | Rol |
|---|---|---|
| admin | admin123 | ADMINISTRADOR |
| mgonzalez | gerente123 | GERENTE |
| cramirez | vendedor123 | VENDEDOR |
| lvargas | curador123 | CURADOR |

## Seguridad y diseño
- Las contraseñas se guardan con hash SHA-256 (`FN_HASH_CLAVE`, usuario como sal simple). Es suficiente para un proyecto académico; en producción se usaría PBKDF2/bcrypt desde la aplicación.
- Cada acción valida permisos por rol (`SP_VALIDAR_PERMISO`) y queda en bitácora vía triggers y `SYS_CONTEXT('APP_CTX','USUARIO')`.
- `PROCESAR_VENTA` aplica 13 % de IVA; si se envía `P_MONTO_PAGADO` debe cubrir el total con IVA (obras incluidas) y el procedimiento informa el vuelto.

## Notas
- `docs/Manual_de_Usuario.pdf` es el manual original (diciembre 2025). Cambios posteriores: `CREAR_CLIENTE`/`EDITAR_CLIENTE` ya no usan `PAIS` (la tabla no tiene esa columna) y `SP_REGISTRAR_USUARIO` (versión antigua) usa el mismo hash que `SP_CREAR_USUARIO`.
- Los ejemplos de venta de obra del manual deben pagar al menos precio × 1.13.
- Los scripts no se probaron en una instancia Oracle al preparar este repositorio; si encuentras un error de compilación, abre un issue.
