# World Tree v0.7 - Inventario del Proyecto

## 1. Estructura de Carpetas y Archivos

```
c:\Users\hkrey\Documents\world-tree-0.7\
├── index.html
├── package.json
├── tsconfig.json
├── tsconfig.app.json
├── vite.config.ts
├── .env.example
├── README.md
├── supabase/
│   ├── 0001_initial_schema.sql
│   └── 0002_security_hardening.sql
├── public/
│   └── brand/
│       └── world-tree-logo.jpg
└── src/
    ├── main.tsx
    ├── App.tsx
    ├── AdminApp.tsx
    ├── lib_supabase.ts
    ├── data.ts
    └── styles.css

## 2. Tecnologías y Dependencias

| Tecnología | Versión | Uso |
|------------|---------|-----|
| React | 19.1.1 | Framework de interfaz de usuario |
| React DOM | 19.1.1 | Renderizado en DOM |
| TypeScript | 5.9.2 | Tipado estático |
| Vite | 7.1.5 | Herramienta de construcción y desarrollo |
| @supabase/supabase-js | 2.57.4 | Cliente de Supabase para base de datos y autenticación |
| lucide-react | 0.468.0 | Iconografía |

## 3. Funcionalidades Existentes

### TIENDA PÚBLICA (`src/App.tsx`)
- Catálogo de productos con filtro por categoría y búsqueda
- Combos y promociones con productos incluidos y precios por tarifa
- Selección de tarifa (8 tarifas) persistida en localStorage
- Precio pendiente cuando no hay precio para una tarifa
- Estados de producto: available, check_availability, sold_out, hidden
- Carrito de compras: agregar, cambiar cantidades, eliminar líneas
- Formulario de pedido: comprador, destinatario, municipio, dirección, notas
- WhatsApp: prepara mensaje y abre para envío manual
- Mensaje formateado con todos los datos del pedido
- Advertencia de privacidad sobre carnet de identidad
- Diseño responsive mobile-first (breakpoints 800px, 480px)

### PANEL ADMINISTRATIVO (`src/AdminApp.tsx`)
- Autenticación con Supabase Auth (email/password)
- Gestión de productos: crear, editar, eliminar, cambiar estado/categoría, editar 8 precios
- Gestión de categorías: crear, renombrar, eliminar (sin productos asociados)
- Gestión de combos: crear, editar, eliminar, productos con cantidades, precios por tarifa, fechas
- Gestión de provincias/municipios: crear, activar/desactivar
- Subida de imágenes de producto y combo
- Mensajes de éxito/error en la interfaz

## 4. Base de Datos (`supabase/0001_initial_schema.sql`)

Tablas: categories, products, product_images, pricing_options (8 tarifas iniciales), product_prices, combos, combo_images, combo_items, combo_prices, provinces, municipalities, admin_users
Vistas: product_catalog, combo_catalog

## 5. Problemas Detectados

### Base de datos y seguridad
1. **`0002_security_hardening.sql` incompleto**: Solo tiene políticas RLS para categories, products y product_images. Faltan políticas para: pricing_options, product_prices, combos, combo_images, combo_items, combo_prices, provinces, municipalities, admin_users
2. **`0003_product_image_storage.sql` no existe**: Referenciado en README pero no implementado (bucket Storage, políticas de Storage)
3. **`0004_import_47_products.sql` no existe**: Referenciado en README pero no implementado (datos iniciales de los 47 productos)
4. **Falta función `is_admin()`**: Función SECURITY DEFINER no implementada
5. **No hay migración para Santiago de Cuba**: Los 9 municipios iniciales no están en las migraciones

### Código fuente
1. **`src/data.ts` usa datos demo**: Solo 6 productos estáticos, no conectados al catálogo real de Supabase
2. **`src/App.tsx` sin validación de permisos de administrador**
3. **`src/AdminApp.tsx` sin verificación completa de admin_users antes de mostrar contenido**

### Documentación
1. **README.md desactualizado**: Referencia migraciones que no existen (0003, 0004)
2. **Falta `.env.local`**: No existe archivo de entorno para desarrollo local
3. **Falta `.gitignore`**: No existe para excluir node_modules, dist, .env, secretos

## 6. Archivos Incompletos o Sin Uso Aparente

- `supabase/0002_security_hardening.sql`: Solo parcialmente implementado (políticas RLS incompletas)
- `src/data.ts`: Solo datos de demostración (6 productos), no usa el catálogo dinámico

## 7. Archivos Faltantes Requeridos

| Archivo | Propósito |
|---------|-----------|
| `.gitignore` | Excluir node_modules, dist, .env, secretos |
| `supabase/0003_product_image_storage.sql` | Configuración del bucket Storage y políticas |
| `supabase/0004_import_47_products.sql` | Importación de los 47 productos iniciales |