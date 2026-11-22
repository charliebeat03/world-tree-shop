# World Tree Shop · Lista de verificación posterior a la mejora

## Implementado en la entrega 2026-11-22

- [x] Mostrar subtotal del carrito en la cabecera y recalcularlo al cambiar de tarifa.
- [x] Mantener la posición de scroll al añadir artículos.
- [x] Ocultar productos sin precio para la tarifa activa y estados distintos de Disponible/Agotado.
- [x] Mantener agotados visibles y bloquear su adición.
- [x] Igualar proporciones y alturas visuales de las tarjetas.
- [x] Mejorar disposición mobile-first.
- [x] Selector de productos para combos con buscador.
- [x] Filtrar selector de combos a productos disponibles con precio.
- [x] Mostrar selección de combos de forma compacta y editar cantidades.
- [x] Validar longitud y fecha inicial del carnet cubano.
- [x] Validar teléfono móvil destinatario cubano de ocho dígitos.
- [x] Añadir botón de mostrar/ocultar contraseña.
- [x] Retirar texto informal sobre la amiga de la propietaria en el encabezado admin.
- [x] Añadir copyright y atribución a Codexia Systems.
- [x] Búsqueda tolerante a acentos, mayúsculas y errores tipográficos pequeños.
- [x] Metadatos SEO, canonical y datos estructurados básicos.
- [x] Añadir robots.txt y sitemap.xml.
- [x] Marcar la ruta /admin como noindex.
- [x] Actualizar README, inventario, cambios y TODO.

## Pendiente de verificación en el entorno real

- [ ] Ejecutar `pnpm install`, `pnpm typecheck` y `pnpm build`.
- [ ] Probar el catálogo en Android a 320, 360, 390 y 430 px.
- [ ] Probar la suma del carrito con cantidades, combos y cambio de tarifa.
- [ ] Comprobar que añadir productos desde el final del catálogo conserva la posición.
- [ ] Verificar la visibilidad de productos con precio ausente, estado de consulta, agotado y disponible.
- [ ] Probar carnet de 11 dígitos con fechas válidas, inválidas y longitud excedida.
- [ ] Confirmar con la propietaria que la validación móvil 5/63 es la regla deseada y que no necesita admitir teléfonos fijos.
- [ ] Probar el selector de combos con un catálogo grande y al editar combos existentes.
- [ ] Probar los permisos reales de Supabase Auth, RLS y Storage con la cuenta administradora.
- [ ] Revisar el mensaje de pedido generado y los datos enviados a WhatsApp.
- [ ] Verificar en producción que `robots.txt` y `sitemap.xml` responden correctamente.
- [ ] Añadir la propiedad en Google Search Console, verificarla y enviar el sitemap.
- [ ] Usar Inspección de URL para comprobar cómo Google renderiza el contenido.
- [ ] Revisar los informes de indexación después del rastreo.

## Mejoras futuras, no incluidas en esta entrega

- Crear páginas públicas con URL propia para categorías y productos si el catálogo y la estrategia SEO lo justifican.
- Generar sitemap dinámico y datos estructurados `Product` únicamente cuando existan páginas individuales y datos verificables de precio/disponibilidad.
- Añadir filtros/ordenación adicionales si el tamaño del catálogo lo requiere.
- Incorporar pruebas automatizadas de validación, carrito, búsqueda y formularios.

## Importante

Esta actualización no modifica el esquema de Supabase. No ejecutar de nuevo migraciones iniciales ni scripts seed en la base de datos de producción.
