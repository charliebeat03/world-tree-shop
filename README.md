# World Tree Shop

Catálogo web mobile-first para World Tree Shop. La aplicación pública consulta el catálogo desde Supabase y prepara solicitudes de pedido para enviar manualmente por WhatsApp. El proyecto no procesa pagos dentro de la web.

## Producción

- Dominio: https://tienda.codexiasystems.dpdns.org/
- Hosting: Render
- Repositorio: https://github.com/charliebeat03/world-tree-shop
- Base de datos, autenticación y almacenamiento de imágenes: Supabase

## Tecnologías

- React 19 + TypeScript
- Vite 7
- Supabase JS 2
- Lucide React
- pnpm (lockfile incluido)

## Desarrollo local

Requisitos: Node.js LTS y pnpm.

```bash
pnpm install
cp .env.example .env.local
pnpm dev
```

Variables necesarias en `.env.local`:

```env
VITE_SUPABASE_URL=https://TU_PROYECTO.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=TU_CLAVE_PUBLISHABLE
VITE_WHATSAPP_NUMBER=535XXXXXXXX
```

Usa únicamente la clave pública/publishable de Supabase en el navegador. Nunca incluyas `service_role`, claves secretas ni `.env.local` en el repositorio.

La tienda se abre en `/` y el panel privado en `/admin`. El panel requiere una sesión de Supabase Auth cuyo usuario esté autorizado y activo en `public.admin_users`. No existe registro público desde la aplicación; las cuentas se crean y autorizan mediante un proceso administrativo de confianza.

## Funcionalidades

### Catálogo público
- Productos, categorías, combos y promociones cargados desde Supabase.
- Tarifas independientes: Zelle, IBAN, Bizum, Posta, Reales, MXN, PDO, Rublos, Guyana y Western Union.
- Los productos y combos sin precio para la tarifa seleccionada, en estado de consulta o con estado oculto no se muestran al público.
- Los productos agotados sí se muestran, pero no se pueden añadir al carrito.
- Búsqueda tolerante a tildes, mayúsculas, errores de una o dos letras y transposición de letras.
- Carrito con subtotal visible en el encabezado y detalle del pedido; el importe se recalcula al cambiar de tarifa.
- El catálogo conserva la posición de desplazamiento al añadir artículos.
- Pedido preparado para WhatsApp; el cliente revisa y envía el mensaje manualmente.
- Validación del carnet cubano (11 dígitos y fecha inicial válida) y del teléfono móvil del destinatario (8 dígitos, prefijo 5 o 63).
- Los datos personales del formulario no se guardan en Supabase ni en almacenamiento local de la aplicación.

### Panel administrativo
- Inicio de sesión con Supabase Auth y comprobación de `admin_users`.
- Botón para mostrar u ocultar la contraseña.
- CRUD de productos, precios, categorías, combos y zonas de entrega.
- Gestión de fotografías mediante Supabase Storage.
- Buscadores tolerantes a tildes, mayúsculas y errores tipográficos.
- Selector de productos para combos con búsqueda, cantidades, chips compactos y lista desplazable.
- El selector de combos solo ofrece productos disponibles con al menos un precio registrado.

## SEO e indexación

- `index.html`: título, descripción, canonical, Open Graph y datos estructurados básicos de `OnlineStore` y `WebSite`.
- `public/robots.txt`: permite el rastreo público e indica el sitemap.
- `public/sitemap.xml`: incluye la URL canónica de la página principal.
- `/admin`: configura `noindex, nofollow` desde `src/main.tsx`.

El sitemap solo incluye la página principal porque esta versión es una SPA sin URLs públicas individuales para cada producto o categoría. No se deben inventar rutas de producto. Si más adelante se crean páginas indexables con URL propia, habrá que generar sus etiquetas canonical, metadatos, datos estructurados y entradas del sitemap.

### Alta en Google Search Console
1. Añade la propiedad de prefijo de URL `https://tienda.codexiasystems.dpdns.org/`.
2. Completa el método de verificación que Google indique.
3. Envía `https://tienda.codexiasystems.dpdns.org/sitemap.xml`.
4. Usa Inspección de URL para solicitar rastreo de la página principal.
5. Revisa el informe de indexación después de que Google rastree el sitio.

La verificación y la solicitud de indexación no garantizan que Google incluya una página en sus resultados ni fijan un plazo.

## Compilar y comprobar

```bash
pnpm typecheck
pnpm build
pnpm preview
```

## Supabase y datos existentes

Este repositorio contiene migraciones históricas en `supabase/migrations/`, copias antiguas en `supabase/` y datos de seed. La aplicación ya consume las tablas existentes de Supabase.

**No ejecutes nuevamente las migraciones iniciales ni los scripts de seed sobre la base de datos de producción ya poblada.** Esta actualización de experiencia de usuario y SEO no requiere cambios de esquema ni migraciones SQL. Antes de aplicar cualquier SQL futuro, comprueba el historial de migraciones y realiza una copia de seguridad.

## Archivos principales

- `src/App.tsx`: catálogo público, carrito, formulario y pedido por WhatsApp.
- `src/AdminApp.tsx`: autenticación y panel de administración.
- `src/search.ts`: búsqueda tolerante a tildes y errores tipográficos.
- `src/lib_supabase.ts`: cliente Supabase.
- `src/styles.css`: sistema visual y estilos responsive.
- `index.html`: metadatos SEO y datos estructurados.
- `public/robots.txt` y `public/sitemap.xml`: rastreo e indexación.
- `supabase/migrations/`: migraciones SQL existentes.

### Sesión del panel administrativo

El panel consulta `admin_users` para comprobar que el usuario autenticado esté activo. Los errores temporales de red o consulta no se interpretan como falta de autorización: se reintenta la comprobación y, si continúa fallando, se conserva la sesión para evitar expulsiones falsas. Una cuenta sin registro activo sigue siendo rechazada.


### Mejoras recientes de experiencia de compra
El catálogo permite filtrar artículos disponibles, ordenar por nombre o precio y ver el número de resultados. Los botones de añadir al carrito siguen disponibles directamente desde cada tarjeta. La interfaz toma como referencia patrones de ecommerce observados en GoodCart, adaptados a una tienda de catálogo con pedidos coordinados por WhatsApp y sin checkout/pago integrado.
