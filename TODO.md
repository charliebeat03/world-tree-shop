# World Tree - TODO.md (Guía Maestra de Trabajo)

## FASE 1: Auditoría y Correcciones Estructurales

| # | Tarea | Estado | Archivos | Dependencias | Criterio de Finalización |
|---|-------|--------|----------|--------------|--------------------------|
| 1.1 | Crear `.gitignore` | completado | `.gitignore` | Ninguno | Archivo creado con exclusiones de node_modules, dist, .env, .env.local |
| 1.2 | Crear `supabase/0003_product_image_storage.sql` | completado | `supabase/0003_product_image_storage.sql` | 0001, 0002 | Bucket Storage definido con políticas de lectura pública y escritura de admin |
| 1.3 | Crear `supabase/0004_import_47_products.sql` | completado | `supabase/seed/0004_import_47_products.sql` | 0001, 0002, 0003 | Ya existía con 47 productos originales y 8 tarifas |
| 1.4 | Completar `supabase/0002_security_hardening.sql` con todas las políticas RLS | completado | `supabase/0002_security_hardening.sql` | 0001 | Todas las tablas tienen RLS habilitado con políticas para anónimos y admin |
| 1.5 | Corregir `src/App.tsx` - eliminar símbolos monetarios inventados | completado | `src/App.tsx` | Ninguno | Símbolos eliminados, se muestra importe + nombre de tarifa |
| 1.6 | Corregir `src/AdminApp.tsx` - eliminar import no usado `Save` | completado | `src/AdminApp.tsx` | Ninguno | Import limpio, sin variables no usadas |

## FASE 2: Base de Datos y Seguridad

| # | Tarea | Estado | Archivos | Dependencias | Criterio de Finalización |
|---|-------|--------|----------|--------------|--------------------------|
| 2.1 | Agregar función `is_admin()` SECURITY DEFINER | completado | `supabase/0002_security_hardening.sql` | 0001 | Función existe y retorna correctamente |
| 2.2 | Agregar políticas RLS para pricing_options | completado | `supabase/0002_security_hardening.sql` | 0001 | Lectura pública habilitada |
| 2.3 | Agregar políticas RLS para product_prices | completado | `supabase/0002_security_hardening.sql` | 0001 | Lectura pública habilitada, escritura solo admin |
| 2.4 | Agregar políticas RLS para combos | completado | `supabase/0002_security_hardening.sql` | 0001 | Lectura pública para no ocultos |
| 2.5 | Agregar políticas RLS para combo_images | completado | `supabase/0002_security_hardening.sql` | 0001 | Lectura pública, escritura solo admin |
| 2.6 | Agregar políticas RLS para combo_items y combo_prices | completado | `supabase/0002_security_hardening.sql` | 0001 | Lectura pública |
| 2.7 | Agregar políticas RLS para provinces y municipalities | completado | `supabase/0002_security_hardening.sql` | 0001 | Lectura para habilitados, escritura solo admin |
| 2.8 | Agregar políticas RLS para admin_users | completado | `supabase/0002_security_hardening.sql` | 0001 | Usuario puede ver su propio registro |

## FASE 3: Catálogo Público

| # | Tarea | Estado | Archivos | Dependencias | Criterio de Finalización |
|---|-------|--------|----------|--------------|--------------------------|
| 3.1 | Conectar catálogo a tablas reales de Supabase | pendiente | `src/App.tsx` | 0001, 0002 | Productos cargan desde base de datos |
| 3.2 | Implementar selección de tarifa con localStorage | completado | `src/App.tsx` | Ninguno | Ya implementado |
| 3.3 | Implementar filtro por categoría y búsqueda | completado | `src/App.tsx` | Ninguno | Ya implementado |
| 3.4 | Mostrar "Precio pendiente" para tarifas sin precio | completado | `src/App.tsx` | Ninguno | Ya implementado |
| 3.5 | Implementar estados de producto (agotado, oculto, consultar) | completado | `src/App.tsx` | Ninguno | Ya implementado |
| 3.6 | Implementar carrito con productos y combos | completado | `src/App.tsx` | Ninguno | Ya implementado |
| 3.7 | Implementar combos con precios independientes por tarifa | completado | `src/App.tsx` | Ninguno | Ya implementado |

## FASE 4: Proceso de Pedido y WhatsApp

| # | Tarea | Estado | Archivos | Dependencias | Criterio de Finalización |
|---|-------|--------|----------|--------------|--------------------------|
| 4.1 | Formulario de comprador y destinatario | completado | `src/App.tsx` | Ninguno | Ya implementado |
| 4.2 | Mensaje de WhatsApp correctamente formateado | completado | `src/App.tsx` | Ninguno | Ya implementado |
| 4.3 | Advertencia de privacidad sobre carnet de identidad | completado | `src/App.tsx` | Ninguno | Ya implementado |
| 4.4 | No persistir datos personales en Supabase | completado | `src/App.tsx` | Ninguno | Ya implementado (solo local) |
| 4.5 | Número de WhatsApp configurado por variable de entorno | completado | `src/App.tsx` | VITE_WHATSAPP_NUMBER | Usa variable de entorno con fallback |

## FASE 5: Panel Administrativo

| # | Tarea | Estado | Archivos | Dependencias | Criterio de Finalización |
|---|-------|--------|----------|--------------|--------------------------|
| 5.1 | Autenticación admin con verificación de admin_users | pendiente | `src/AdminApp.tsx` | 0001, 0002 | Solo usuarios en admin_users pueden acceder |
| 5.2 | CRUD de productos completo | completado | `src/AdminApp.tsx` | 0001, 0002 | Ya implementado |
| 5.3 | CRUD de categorías con validación de dependencias | completado | `src/AdminApp.tsx` | 0001, 0002 | Ya implementado |
| 5.4 | CRUD de combos con productos, cantidades y precios | completado | `src/AdminApp.tsx` | 0001, 0002 | Ya implementado |
| 5.5 | Gestión de provincias y municipios | completado | `src/AdminApp.tsx` | 0001, 0002 | Ya implementado |
| 5.6 | Subida y gestión de imágenes | completado | `src/AdminApp.tsx` | 0003 | Pendiente de 0003 |
| 5.7 | Mensajes de éxito/error y estados de carga | completado | `src/AdminApp.tsx` | Ninguno | Ya implementado |

## FASE 6: Provincias y Municipios

| # | Tarea | Estado | Archivos | Dependencias | Criterio de Finalización |
|---|-------|--------|----------|--------------|--------------------------|
| 6.1 | Santiago de Cuba con 9 municipios en seed | pendiente | `supabase/0004_import_47_products.sql` | 0001 | 9 municipios creados en la provincia Santiago de Cuba |
| 6.2 | Activar/desactivar provincias y municipios | completado | `src/AdminApp.tsx` | 0001, 0002 | Ya implementado |
| 6.3 | No permitir seleccionar municipios de provincias desactivadas | pendiente | `src/App.tsx`, `src/AdminApp.tsx` | 0001 | Validación en formularios |

## FASE 7: Gestión de Imágenes

| # | Tarea | Estado | Archivos | Dependencias | Criterio de Finalización |
|---|-------|--------|----------|--------------|--------------------------|
| 7.1 | Bucket `world-tree-products` con lectura pública | pendiente | `supabase/0003_product_image_storage.sql` | 0001 | Bucket existe con políticas correctas |
| 7.2 | Escritura exclusiva de administradores | pendiente | `supabase/0003_product_image_storage.sql` | 0001 | Solo admin puede subir/eliminar |
| 7.3 | Validación de archivos (JPG, PNG, WebP, max 5 MB) | pendiente | `supabase/0003_product_image_storage.sql` | 0001 | Validación en Storage y frontend |
| 7.4 | No usar service_role en frontend | completado | `src/lib_supabase.ts` | Ninguno | Solo clave publishable en frontend |

## FASE 8: Diseño y Responsive

| # | Tarea | Estado | Archivos | Dependencias | Criterio de Finalización |
|---|-------|--------|----------|--------------|--------------------------|
| 8.1 | Revisar diseño mobile-first | pendiente | `src/styles.css` | Ninguno | Diseño se adapta a móviles |
| 8.2 | Corregir problemas en tablets y móviles | pendiente | `src/styles.css` | Ninguno | Sin problemas visuales en breakpoints |
| 8.3 | Estados visuales para productos agotados y pendientes | completado | `src/styles.css`, `src/App.tsx` | Ninguno | Ya implementado |
| 8.4 | Logotipo de World Tree en header y footer | completado | `src/App.tsx` | Ninguno | Ya implementado |

## FASE 9: QA, Pruebas y Documentación

| # | Tarea | Estado | Archivos | Dependencias | Criterio de Finalización |
|---|-------|--------|----------|--------------|--------------------------|
| 9.1 | Instalación de dependencias (pnpm/npm) | pendiente | `package.json` | Ninguno | `pnpm install` o `npm install` funciona |
| 9.2 | Compilación TypeScript | pendiente | `tsconfig.app.json` | Ninguno | `tsc --noEmit` pasa sin errores |
| 9.3 | Compilación de producción | pendiente | `vite.config.ts` | Ninguno | `vite build` genera dist exitosamente |
| 9.4 | Actualizar README.md | pendiente | `README.md` | Todas las fases | README explica instalación, migraciones, importación, admin |
| 9.5 | Documentar configuraciones externas pendientes | pendiente | `README.md` | Todas las fases | Supabase, bucket Storage, cuenta admin documentados |
| 9.6 | Crear ZIP final del proyecto | pendiente | Todos | Todas las fases | ZIP completo, sin node_modules, dist, .env, secretos |

## Leyenda de Estados

- **pendiente**: No iniciado
- **en progreso**: Actualmente en desarrollo
- **completado**: Implementado y verificado
- **bloqueada**: Esperando dependencia externa o credencial
- **no aplicable**: No requerida para esta versión