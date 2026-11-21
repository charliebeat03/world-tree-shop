# Cambios recientes

## Panel de administración
- Se agregó una barra de acceso rápido antes de la sección Productos con enlaces directos a Combos y promociones, Categorías y Zonas de entrega.
- Se añadieron destinos de navegación estables a las secciones de categorías y zonas de entrega.
- Se mejoró el contraste del título y subtítulo del panel y de los encabezados de las tarjetas para facilitar su lectura.
- Se eliminó el campo duplicado de búsqueda de productos; se conserva un único filtro con el botón de actualización.


## Corrección de gestión de imágenes (2026-11-21)
- El panel carga y muestra la fotografía actualmente vinculada a cada producto y combo.
- Se incorpora vista previa de la nueva imagen y opción de retirar la imagen existente.
- Se comprimen/redimensionan imágenes en el navegador y se convierten a WebP antes de subirlas.
- El guardado de productos espera la subida a Storage, inserta la referencia en `product_images` y vuelve a leerla para verificar que quedó persistida antes de informar éxito.
- Los errores distinguen entre fallo de Storage y fallo de escritura/verificación en la base de datos.
- Se agrega filtro de productos sin fotografía.
- Se incorpora migración `0004_image_storage_repair.sql` para reestablecer las políticas de Storage y de las tablas de imágenes.
