# World Tree · Starter 0.6

Tienda online en desarrollo. React + TypeScript + Vite + Supabase.

## Ejecutar
Requisitos: Node.js LTS y pnpm.

```bash
pnpm install
cp .env.example .env.local
pnpm dev
```

Abre `/` para la tienda y `/admin` para el acceso administrativo.

`.env.local`:
```env
VITE_SUPABASE_URL=https://TU-PROYECTO.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
VITE_WHATSAPP_NUMBER=5353526551
```
Usa exclusivamente una clave publishable/anon en el navegador. Nunca agregues `service_role`, claves secretas ni contraseñas al frontend o al repositorio.

## Migraciones Supabase
Aplica en orden desde SQL Editor o Supabase CLI en un proyecto de desarrollo:
1. `0001_initial_schema.sql`
2. `0002_security_hardening.sql`
3. `0003_product_image_storage.sql`

Revisa las migraciones antes de aplicarlas en producción. No se han ejecutado contra un proyecto Supabase real.

## Primer administrador
1. En Supabase Authentication, crea/invita la cuenta de la propietaria desde el panel de control. Desactiva los registros públicos si habilitaste esa opción.
2. Copia el UUID de esa cuenta.
3. En SQL Editor ejecuta, sustituyendo el UUID:
```sql
insert into public.admin_users(user_id, role, is_active)
values ('UUID-DE-LA-CUENTA', 'owner', true);
```
No crees una interfaz pública para esta operación. Para mantenimiento, un propietario autorizado puede insertar otro usuario con rol `maintenance` desde un procedimiento administrativo controlado.
4. Inicia sesión en `/admin`. La interfaz comprueba que exista una fila activa en `admin_users`; las políticas RLS también bloquean escrituras a quien no esté autorizado.

## Estado de funciones
- Interfaz pública: prototipo con productos de demostración en `src/data.ts`.
- `/admin`: login Supabase y primer módulo de alta/listado/cambio de estado de productos.
- SQL: categorías, productos, imágenes, tarifas, precios, combos, provincias, municipios y administradores.
- Storage: bucket de imágenes y políticas para lectura pública y escritura administrativa.
- WhatsApp: mensaje preparado desde el carrito, enviado únicamente cuando el comprador pulsa enviar en WhatsApp.

## Pendiente antes de producción
- Conectar el catálogo público a las tablas reales (actualmente usa datos demo).
- Terminar edición/borrado de productos, edición de categorías, carga de fotos desde el panel y edición de los ocho precios.
- Implementar administración de combos y provincias/municipios.
- Implementar detección de país/IP de forma confiable y con alternativa manual persistente.
- Importar y validar los 47 productos y sus 8 columnas de tarifa. Algunos importes originales parecen tener posibles errores de transcripción; no se deben corregir sin confirmación.
- Verificar qué representa exactamente cada modalidad (Zelle, IBAN, Bizum, Posta, Reales, MXN, PDO, Rublos) y sus símbolos/monedas antes de publicar precios.
- Confirmar el listado oficial de municipios y las reglas de entrega con la propietaria.
- Revisar legalidad, privacidad y manejo de carnet de identidad. El prototipo lo incluye en el texto de WhatsApp porque fue solicitado, pero no lo persiste en base de datos. Debe transmitirse solo si es necesario y con consentimiento claro.
- Pruebas automatizadas, auditoría RLS/Storage, responsive, accesibilidad, copias de seguridad y despliegue.

## Territorio inicial
Solo Santiago de Cuba y sus municipios habilitados. Las otras provincias quedan deshabilitadas. La administración territorial se gestionará desde tablas `provinces` y `municipalities`.

## Nota
Este paquete no está publicado, no tiene proyecto Supabase conectado y no tiene repositorio remoto. Es una versión de desarrollo, no una tienda lista para aceptar pedidos reales.


## Starter 0.4: catálogo administrable
- El catálogo no tiene un límite fijo de productos: la propietaria puede crear tantos registros como permita el proyecto/almacenamiento.
- Alta y edición de productos, categoría, slug, descripción y estado.
- Precios independientes para cada modalidad; los campos vacíos permanecen pendientes, sin conversión automática.
- Subida de imagen de producto al bucket `world-tree-products`.
- Creación de categorías.
- Alta de provincias y municipios, y activación/desactivación de cada zona.
- Eliminación de productos con confirmación; elimina primero archivos asociados y después el registro.

Aplicar también las migraciones `0001`, `0002` y `0003` en orden. El panel requiere que exista una cuenta Supabase Auth y que su UUID esté añadido en `public.admin_users` por un procedimiento seguro.

## Límites que siguen pendientes
- El catálogo público sigue usando datos de demostración y aún no consume las tablas Supabase.
- La edición de combos/promociones no está implementada.
- La carga de fotos requiere que las políticas de Storage de la migración 0003 estén aplicadas.
- El selector de tarifas por país/IP y el envío público deben conectarse a las opciones activas.
- No hay una función para crear cuentas de administrador desde el panel; se evita deliberadamente el alta pública.
- El formulario de pedido actual transmite datos por WhatsApp; no los almacena en la base de datos.
- Revisar las reglas de protección de datos del carnet de identidad antes de publicar.


## Starter 0.5: catálogo público conectado
- La tienda pública consulta productos, categorías, precios, fotografías, combos y municipios habilitados directamente desde Supabase.
- Productos y combos se agregan al mismo carrito; los precios dependen de la tarifa elegida.
- La selección manual de tarifa se conserva en el navegador.
- El formulario de pedido recoge comprador, destinatario, carnet, teléfonos y dirección; esos datos solo se incorporan al mensaje de WhatsApp y no se persisten en Supabase.
- El catálogo no depende de una lista fija de productos. Cualquier producto creado por la propietaria aparece automáticamente si no está oculto.
- Si no hay conexión Supabase configurada, la web muestra un aviso en lugar de fingir datos reales.

### Nota sobre detección de país
La selección automática por país/IP no se ha activado todavía. No se debe inferir una modalidad financiera mediante idioma del navegador: el idioma no identifica de forma fiable el país ni el método que el comprador puede usar. Se conserva la selección manual hasta integrar y documentar un proveedor de geolocalización IP respetuoso con la privacidad.

### Requisitos de datos
El bucket `world-tree-products` debe existir y las migraciones 0001–0003 deben estar aplicadas. Las relaciones anidadas de Supabase usadas en el catálogo requieren las foreign keys de la migración inicial.


## Starter 0.6: administración ampliada
El panel privado permite a la propietaria:
- Crear, editar y eliminar productos, cambiar su categoría, descripción, estado y ocho precios.
- Añadir y editar fotografías. La eliminación de un producto elimina también sus imágenes asociadas; si un combo lo utiliza, la base de datos puede impedir el borrado hasta que se edite/elimine ese combo.
- Crear, renombrar y eliminar categorías. No permite borrar una categoría que todavía tenga productos asignados.
- Crear, editar y eliminar combos/promociones, seleccionar productos incluidos, indicar cantidades, cargar imagen y fijar un precio independiente por cada modalidad.
- Definir fecha y hora de inicio/fin de promoción (opcional).
- Añadir provincias/municipios y activar/desactivar su disponibilidad.

### Importar los 47 productos iniciales
Después de aplicar las migraciones `0001`, `0002` y `0003`, ejecutar:
`supabase/seed/0004_import_47_products.sql`
El script conserva los importes recibidos, omite las celdas vacías y deja todos los productos en **Consultar disponibilidad** para que la propietaria confirme existencias antes de publicarlos como disponibles. Es idempotente por slug, pero conviene hacer una copia de seguridad antes de repetirlo porque actualiza nombres/categorías/precios de esos slugs.

### Importante sobre la edición completa
La propietaria puede editar o eliminar cualquier producto desde el panel privado. No existe un límite fijo de cantidad impuesto por la aplicación. Los productos ocultos dejan de mostrarse al público; los agotados permanecen visibles sin poder añadirse al carrito. Los precios faltantes siguen como “Precio pendiente”.

### Pendientes y límites reales
- Aún no hay proyecto Supabase conectado ni despliegue. El panel no funcionará con datos reales hasta configurar `.env.local`, aplicar las migraciones y crear la cuenta propietaria.
- La compilación integral no se ha podido validar en este entorno por la instalación incompleta de dependencias. Ejecutar `npm install` y `npm run build` antes de publicar.
- La detección de país por IP sigue pendiente de seleccionar un proveedor. La tarifa manual continúa siendo la opción disponible y segura.
- El listado y los importes se cargan a partir de la lista facilitada; revisar manualmente los valores atípicos antes de poner productos como disponibles.


### Reglas de eliminación y fotografías
- Al reemplazar una fotografía de producto o combo, el panel elimina la referencia y el archivo anterior después de subir la nueva imagen.
- No se permite borrar un producto mientras forme parte de un combo. Primero hay que editar el combo y retirar ese producto; así no quedan combos incompletos.
- Las fotografías admitidas son JPG, PNG y WebP, con un máximo de 5 MB.
- Las políticas públicas de lectura no utilizan funciones `SECURITY DEFINER` expuestas. Las escrituras siguen reservadas a cuentas activas de administración.

### Revisión pendiente antes de producción
La base de datos debe probarse en un proyecto Supabase separado: crear cuenta Auth, registrar su `user_id` como `owner` en `admin_users` mediante SQL de confianza, aplicar migraciones en orden y verificar las políticas RLS desde una sesión anónima y otra propietaria. No se debe usar una clave `service_role` en el frontend.


### Reparación de permisos de imágenes

Si las fotos no se guardan o el catálogo no puede leerlas, ejecuta en Supabase SQL Editor, en este orden y solo si aún no están aplicadas, las migraciones `0001`, `0002`, `0003` y `0004_image_storage_repair.sql` de `supabase/migrations/`. La migración 0004 reestablece el bucket `world-tree-products` y sus políticas de lectura pública/escritura administrativa, además de los permisos RLS de `product_images` y `combo_images`. No ejecutes de nuevo las migraciones iniciales sobre una base de datos que ya tiene tablas; aplica únicamente la nueva migración 0004.
