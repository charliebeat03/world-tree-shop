🌳 World Tree | Tienda Online

Tienda online de World Tree, desarrollada con React, TypeScript, Vite y Supabase. Permite consultar productos y combos, seleccionar modalidades de precios, preparar pedidos y gestionar el catálogo desde un panel administrativo privado.

🚀 Tecnologías

- React 19
- TypeScript 5.9
- Vite 7
- Supabase (Database, Authentication y Storage)
- pnpm
- Lucide React

📁 Estructura del proyecto

world-tree-shop/
├── public/
│   └── brand/
│       └── world-tree-logo.jpg
├── src/
│   ├── App.tsx
│   ├── AdminApp.tsx
│   ├── data.ts
│   ├── lib_supabase.ts
│   ├── main.tsx
│   ├── styles.css
│   └── vite-env.d.ts
├── supabase/
│   ├── 0001_initial_schema.sql
│   ├── 0002_security_hardening.sql
│   ├── 0003_product_image_storage.sql
│   ├── migrations/
│   └── seed/
│       └── 0004_import_47_products.sql
├── .env.example
├── index.html
├── package.json
├── pnpm-lock.yaml
├── tsconfig.json
├── tsconfig.app.json
└── vite.config.ts

🛍️ Tienda pública

La tienda permite:

- Consultar productos y categorías desde Supabase.
- Consultar combos y promociones.
- Buscar productos por nombre y descripción.
- Filtrar productos por categoría.
- Consultar fotografías, descripciones y disponibilidad.
- Seleccionar manualmente la modalidad de precio.
- Añadir productos y combos al carrito.
- Modificar cantidades y eliminar artículos.
- Calcular un subtotal estimado.
- Completar los datos del comprador y destinatario.
- Seleccionar el municipio de entrega habilitado.
- Preparar una solicitud de pedido mediante WhatsApp.

Modalidades de precios

La aplicación contempla ocho modalidades:

1. Zelle
2. IBAN
3. Bizum
4. Posta
5. Reales
6. MXN
7. PDO
8. Rublos

Cada modalidad tiene sus propios precios. No se realizan conversiones automáticas.

La selección de tarifa se conserva en el navegador.

Carrito y experiencia móvil

- Panel de carrito superpuesto a la tienda.
- Desplazamiento independiente dentro del carrito.
- Bloqueo del desplazamiento de la página de fondo mientras está abierto.
- Cabecera de la tienda detrás del carrito.
- Botón de cierre accesible.
- Cierre mediante la tecla Escape.
- Adaptación a pantallas móviles y áreas seguras del dispositivo.

Pedidos por WhatsApp

Los pedidos se preparan como mensajes de WhatsApp con los datos del comprador, destinatario, artículos, cantidades, tarifa y dirección de entrega.

Los datos del formulario no se guardan en la base de datos de la tienda. El comprador debe confirmar y enviar el mensaje desde WhatsApp.

Los importes son orientativos y están sujetos a confirmación.

🔐 Panel administrativo

El panel administrativo es privado y utiliza Supabase Authentication.

Ruta de acceso:

/admin

En producción:

https://world-tree-shop.onrender.com/admin

El panel permite:

Productos

- Crear productos.
- Editar productos existentes.
- Eliminar productos.
- Cambiar nombres, identificadores URL y descripciones.
- Asignar categorías.
- Cambiar estados de disponibilidad.
- Configurar precios independientes para las ocho modalidades.
- Subir y reemplazar fotografías.
- Buscar productos mediante filtros por nombre o identificador.

Combos y promociones

- Crear combos.
- Editar combos existentes.
- Eliminar combos.
- Seleccionar productos incluidos.
- Definir cantidades de cada producto.
- Configurar precios independientes por modalidad.
- Subir fotografías.
- Establecer fechas y horas de inicio y finalización de promociones.
- Cambiar el estado de disponibilidad.
- Buscar combos mediante filtros.

Categorías

- Crear categorías.
- Editar nombres.
- Eliminar categorías.
- Consultar las categorías existentes.

No se permite eliminar una categoría que todavía tenga productos asociados.

Zonas de entrega

- Crear provincias.
- Renombrar provincias.
- Eliminar provincias.
- Habilitar o deshabilitar provincias.
- Añadir municipios.
- Renombrar municipios.
- Eliminar municipios.
- Habilitar o deshabilitar municipios individualmente.

Las operaciones de creación y gestión se realizan mediante ventanas modales para evitar desplazamientos innecesarios por el panel.

⚙️ Instalación y desarrollo local

Requisitos

- Node.js compatible con Vite 7.
- pnpm.
- Proyecto Supabase configurado.

Instalar dependencias

pnpm install

Configurar variables de entorno

Crear un archivo ".env.local" en la raíz:

VITE_SUPABASE_URL=https://TU-PROYECTO.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=TU_CLAVE_PUBLISHABLE
VITE_WHATSAPP_NUMBER=5353526551

Utilizar exclusivamente una clave pública publishable o anon en el frontend.

Nunca incluir:

- Claves "service_role".
- Contraseñas de administración.
- Secretos privados.
- Credenciales sensibles.

Iniciar desarrollo

pnpm dev

Compilar para producción

pnpm run build

Vista previa de producción

pnpm run preview

La compilación genera los archivos de producción en:

dist/

El archivo "src/vite-env.d.ts" contiene las definiciones de tipos de Vite necesarias para reconocer "import.meta.env" durante la compilación de TypeScript.

🗄️ Configuración de Supabase

La aplicación utiliza Supabase para almacenar y gestionar:

- Categorías.
- Productos.
- Precios de productos.
- Fotografías.
- Combos.
- Precios de combos.
- Productos incluidos en combos.
- Provincias.
- Municipios.
- Usuarios administradores.

Migraciones

Aplicar las migraciones en este orden:

1. "supabase/0001_initial_schema.sql"
2. "supabase/0002_security_hardening.sql"
3. "supabase/0003_product_image_storage.sql"

Se pueden aplicar mediante Supabase SQL Editor o Supabase CLI.

Revisar las migraciones y realizar una copia de seguridad antes de aplicarlas en producción.

Almacenamiento de imágenes

El bucket utilizado es:

world-tree-products

Admite fotografías JPG, PNG y WebP, con un máximo de 5 MB por imagen.

Las políticas de Storage deben estar configuradas mediante la migración correspondiente.

Crear el primer administrador

1. Entrar en Supabase Authentication.
2. Crear o invitar la cuenta de la propietaria.
3. Obtener el UUID del usuario.
4. Abrir SQL Editor.
5. Ejecutar la siguiente consulta sustituyendo el UUID:

INSERT INTO public.admin_users (user_id, role, is_active)
VALUES ('UUID-DE-LA-CUENTA', 'owner', true);

La cuenta debe existir previamente en Supabase Authentication.

El panel comprueba que el usuario tenga un registro administrativo activo antes de permitir la gestión.

No habilitar registros públicos de administradores.

📦 Importación de productos iniciales

El proyecto incluye un archivo para importar los 47 productos iniciales:

supabase/seed/0004_import_47_products.sql

Ejecutarlo después de aplicar las tres migraciones iniciales.

El script conserva los importes recibidos y deja los productos en estado de consulta de disponibilidad para que la propietaria pueda confirmar existencias.

Antes de repetir la importación, realizar una copia de seguridad: el script actualiza los registros que coinciden por slug.

🌐 Despliegue en Render

La aplicación se despliega como una aplicación web de Vite.

Configuración de compilación

Build Command:

pnpm install --frozen-lockfile && pnpm run build

Publish Directory:

dist

Configuración de rutas SPA

Para que la ruta administrativa "/admin" funcione al acceder directamente desde el navegador, configurar una regla Rewrite en Render.

En el apartado:

Settings → Redirects/Rewrites

Crear la siguiente regla:

Campo| Valor
Source| "/*"
Destination| "/index.html"
Action| Rewrite

Esta regla permite que Render entregue "index.html" para las rutas de la aplicación y que React cargue el componente correspondiente.

Direcciones de producción

Tienda pública:

https://world-tree-shop.onrender.com/

Panel administrativo:

https://world-tree-shop.onrender.com/admin

🔒 Seguridad y buenas prácticas

- Mantener el panel administrativo protegido mediante Supabase Authentication.
- No compartir las credenciales de administración.
- No utilizar claves privadas en el frontend.
- Mantener las políticas RLS activas.
- Restringir las operaciones de escritura a administradores autorizados.
- Realizar copias de seguridad antes de modificar la base de datos.
- Revisar las políticas de Storage.
- No almacenar datos personales del pedido innecesariamente.

El formulario solicita datos del comprador y del destinatario, incluido el carnet de identidad. Estos datos se incorporan al mensaje de WhatsApp y no se persisten en la base de datos de la tienda.

📌 Estados de productos y combos

Estado| Comportamiento
Disponible| Se muestra y puede añadirse al carrito si tiene precio.
Consultar disponibilidad| Se muestra, pero requiere confirmación.
Agotado| Se muestra, pero no permite añadirlo al carrito.
Oculto| No aparece en el catálogo público.

Los precios que todavía no estén registrados se muestran como pendientes y no se convierten automáticamente.

📝 Notas del proyecto

- La tienda utiliza datos reales de Supabase cuando está correctamente configurada.
- La selección automática de tarifa por país/IP todavía no está implementada.
- La tarifa se selecciona manualmente.
- La disponibilidad de las zonas depende de su configuración en Supabase.
- El territorio inicial es Santiago de Cuba y sus municipios habilitados.
- Los pedidos se gestionan mediante WhatsApp y requieren confirmación.
- Las imágenes de productos y combos se sirven desde Supabase Storage.

🛠️ Mantenimiento

Para actualizar la aplicación:

1. Modificar los archivos necesarios.
2. Comprobar que la aplicación compile:

pnpm run build

3. Subir los cambios al repositorio de GitHub.
4. Esperar el despliegue automático de Render o iniciar un despliegue manual.
5. Comprobar la tienda pública y el panel administrativo.

---

World Tree | Tienda Online

Proyecto desarrollado con React, TypeScript, Vite y Supabase.
