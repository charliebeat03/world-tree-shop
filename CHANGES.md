# Historial de cambios

## 2026-11-22 · Experiencia de usuario, validación y SEO

### Catálogo público
- El encabezado muestra el subtotal del carrito en la tarifa seleccionada, además del número de artículos; el subtotal se recalcula al cambiar la tarifa.
- Se conserva la posición de scroll al añadir productos o combos al carrito.
- Se ocultan productos y combos ocultos, en consulta o sin precio disponible para la tarifa seleccionada.
- Los productos agotados continúan visibles, pero no pueden añadirse.
- Se iguala la estructura visual de las tarjetas: imágenes con proporción común, alturas de contenido consistentes y descripciones limitadas para evitar tarjetas desiguales.
- Se mejora la adaptación de cabecera, tarjetas, controles y botones a pantallas móviles.
- El footer incorpora copyright, todos los derechos reservados y la atribución de creación a Codexia Systems.

### Formularios
- El carnet cubano admite únicamente 11 dígitos y se comprueba que los seis primeros representen una fecha válida.
- El teléfono móvil del destinatario admite ocho dígitos y valida prefijo móvil 5 o 63.
- Los campos numéricos eliminan caracteres no numéricos y limitan la longitud.
- Se muestran mensajes de ayuda y validación junto a los campos.

### Panel administrativo
- Se sustituye el texto informal dirigido a la amiga de la propietaria por una descripción neutral de las funciones del panel.
- El acceso incluye control para mostrar u ocultar la contraseña.
- El selector de productos de combos se convierte en un buscador con lista limitada en altura, control de cantidades y resumen compacto de productos seleccionados.
- Solo se pueden añadir al combo productos disponibles con al menos un precio registrado.
- Se validan los formatos de precios y cantidades para evitar guardar valores no numéricos o negativos.
- Los buscadores del panel toleran tildes, mayúsculas y errores tipográficos pequeños.

### Búsqueda compartida
- Nuevo `src/search.ts`, utilizado por el catálogo y el panel.
- Normaliza acentos y mayúsculas, acepta coincidencias parciales y tolera pequeños errores de escritura y transposiciones de letras.

### SEO
- Se amplían título, descripción, canonical, Open Graph y datos estructurados en `index.html`.
- Se añaden `public/robots.txt` y `public/sitemap.xml`.
- La ruta administrativa establece `noindex, nofollow`.
- El sitemap incluye únicamente la página principal, ya que no existen rutas públicas individuales de producto.

### Documentación y mantenimiento
- Se elimina `src/data.ts`, un catálogo de demostración antiguo sin referencias en la aplicación.
- README, inventario y TODO actualizados para reflejar la estructura real del ZIP recibido.
- Se añade `.gitignore`.
- No se modificó el esquema ni los datos de Supabase.

## Cambios anteriores

Se mantienen las mejoras previas del panel de administración, la gestión de imágenes WebP, la verificación de referencias en Supabase Storage, los combos y las modalidades de precio Guyana y Western Union. Consulta el historial de Git para ver los cambios anteriores a esta entrega.
