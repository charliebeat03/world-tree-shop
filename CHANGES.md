# Cambios de esta actualización

- `src/vite-env.d.ts`: añade las definiciones de tipos de Vite para que TypeScript reconozca `import.meta.env` y corrija el error TS2339 durante el build de Render.
- `src/AdminApp.tsx`: convierte los formularios de producto, combo, categorías y zonas de entrega en ventanas modales. Se accede desde botones directos en cada sección; editar producto o combo abre su formulario sin desplazarse por toda la página. Se mantienen los filtros y las operaciones existentes.
- `src/styles.css`: estilos adaptables para las ventanas modales, con desplazamiento interno y adaptación a móviles.

No se modificó la configuración de Supabase ni la base de datos.
- La ventana de zonas también permite renombrar y eliminar provincias o municipios. Al eliminar una provincia, Supabase elimina sus municipios asociados por la relación en cascada definida en el esquema.
- Se incluyen los `slug` obligatorios al crear provincias y municipios.

## Corrección del carrito móvil (19-11-2026)

- `src/App.tsx`: el carrito ahora bloquea el desplazamiento de la página que queda detrás mientras está abierto y se puede cerrar con la tecla Escape. Se añadieron atributos accesibles de diálogo (`role`, `aria-modal` y `aria-labelledby`).
- `src/styles.css`: el panel del carrito y su fondo ahora se dibujan por encima de la cabecera fija; el panel ocupa la altura visible del dispositivo, gestiona el desplazamiento internamente y respeta las áreas seguras de móviles. También se ajusta el tamaño de las imágenes de producto para evitar desbordamientos.
