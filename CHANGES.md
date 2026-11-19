# Cambios de esta actualización

- `src/vite-env.d.ts`: añade las definiciones de tipos de Vite para que TypeScript reconozca `import.meta.env` y corrija el error TS2339 durante el build de Render.
- `src/AdminApp.tsx`: convierte los formularios de producto, combo, categorías y zonas de entrega en ventanas modales. Se accede desde botones directos en cada sección; editar producto o combo abre su formulario sin desplazarse por toda la página. Se mantienen los filtros y las operaciones existentes.
- `src/styles.css`: estilos adaptables para las ventanas modales, con desplazamiento interno y adaptación a móviles.

No se modificó la configuración de Supabase ni la base de datos.
- La ventana de zonas también permite renombrar y eliminar provincias o municipios. Al eliminar una provincia, Supabase elimina sus municipios asociados por la relación en cascada definida en el esquema.
- Se incluyen los `slug` obligatorios al crear provincias y municipios.
