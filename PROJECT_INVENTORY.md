# World Tree Shop · Inventario técnico actualizado

**Base de este inventario:** ZIP `world-tree-shop-main` proporcionado para la revisión del 22 de noviembre de 2026.

## 1. Estructura

```text
world-tree-shop-main/
├── .env.example
├── .gitignore
├── CHANGES.md
├── PROJECT_INVENTORY.md
├── README.md
├── TODO.md
├── index.html
├── package.json
├── pnpm-lock.yaml
├── public/
│   ├── robots.txt
│   ├── sitemap.xml
│   └── brand/
│       ├── README.md
│       └── world-tree-logo.jpg
├── src/
│   ├── AdminApp.tsx
│   ├── App.tsx
│   ├── lib_supabase.ts
│   ├── main.tsx
│   ├── search.ts
│   ├── styles.css
│   └── vite-env.d.ts
└── supabase/
    ├── 0001_initial_schema.sql
    ├── 0002_security_hardening.sql
    ├── 0003_product_image_storage.sql
    ├── migrations/
    │   ├── 0001_initial_schema.sql
    │   ├── 0002_security_hardening.sql
    │   ├── 0003_product_image_storage.sql
    │   ├── 0004_image_storage_repair.sql
    │   └── 0005_susana_combos.sql
    └── seed/
        └── 0004_import_47_products.sql
```

## 2. Tecnologías

| Tecnología | Versión declarada | Función |
|---|---:|---|
| React | 19.1.1 | Interfaz |
| React DOM | 19.1.1 | Renderizado |
| TypeScript | 5.9.2 | Tipado |
| Vite | 7.1.5 | Desarrollo y build |
| Supabase JS | 2.57.4 | Base de datos, Auth y Storage |
| Lucide React | 0.468.0 | Iconografía |

## 3. Responsabilidad de archivos

| Archivo | Responsabilidad |
|---|---|
| `src/App.tsx` | Catálogo, categorías, combos, carrito, validación del pedido y WhatsApp |
| `src/AdminApp.tsx` | Acceso privado y operaciones CRUD |
| `src/search.ts` | Normalización y búsqueda tolerante a errores |
| `src/lib_supabase.ts` | Inicialización del cliente Supabase |
| `src/styles.css` | Diseño visual, responsive y estados |
| `src/main.tsx` | Selección de ruta pública/admin y metadatos noindex del admin |
| `index.html` | Metadatos, canonical, Open Graph y JSON-LD |
| `public/robots.txt` | Instrucciones de rastreo |
| `public/sitemap.xml` | URL canónica pública |
| `supabase/migrations/` | Historial de esquema y políticas |
| `supabase/seed/` | Importación histórica de productos |

`src/data.ts` conserva datos de muestra históricos; el catálogo en producción se obtiene de Supabase.

## 4. Modelo funcional existente

La aplicación usa las tablas existentes para categorías, productos, imágenes, opciones de precio, precios por producto, combos, imágenes y composición de combos, provincias, municipios y usuarios administradores. Las migraciones SQL incluidas son documentación y código de evolución del esquema; su presencia en el ZIP no significa que deban volver a ejecutarse en producción.

## 5. Controles implementados en esta entrega

- Precio subtotal visible junto al carrito y recalculado al cambiar de tarifa.
- Protección de posición de desplazamiento al añadir un artículo.
- Filtro de visibilidad por estado y precio de la tarifa seleccionada.
- Validación local de carnet y teléfono móvil cubano del destinatario.
- Búsqueda tolerante a acentos, mayúsculas, errores pequeños y transposición.
- Selector compacto y buscable de productos para combos.
- Validación de formatos numéricos en precios y cantidades administrativas.
- Control de visibilidad de contraseña en el acceso administrativo.
- Tarjetas con estructura visual consistente y ajustes mobile-first.
- Footer con atribución y copyright.
- Metadatos SEO, robots, sitemap y noindex administrativo.

## 6. Límites conocidos de esta versión

- Es una SPA: no tiene URLs individuales para cada producto o categoría. El sitemap contiene solo la página principal.
- Los datos estructurados describen la tienda y el sitio, no inventan ofertas o precios de productos.
- El formato de teléfono destinatario se valida como móvil cubano de ocho dígitos iniciado en 5 o 63. Si la propietaria desea aceptar también teléfonos fijos, habrá que ampliar la regla.
- La validación del carnet comprueba longitud y fecha inicial, pero no pretende verificar la autenticidad del documento ni su dígito de control.
- La experiencia debe terminar de probarse en dispositivos reales y con el proyecto Supabase de producción; el ZIP no contiene credenciales ni permite validar datos privados.

## 7. Seguridad y precauciones

- No incluir `.env.local`, claves `service_role` ni secretos en el ZIP o Git.
- Mantener RLS y políticas existentes.
- No ejecutar migraciones iniciales ni seed contra la base de datos ya poblada.
- Las validaciones del navegador mejoran la experiencia, pero no sustituyen controles de seguridad en servidor.
