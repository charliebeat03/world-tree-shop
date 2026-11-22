# World Tree

Aplicación web de tienda construida con React, TypeScript, Vite y Supabase.

## Desarrollo local

Requisitos: Node.js LTS y pnpm.

```bash
pnpm install
cp .env.example .env.local
pnpm dev
```

Configura en `.env.local` las variables `VITE_SUPABASE_URL`, `VITE_SUPABASE_PUBLISHABLE_KEY` y `VITE_WHATSAPP_NUMBER`. Usa únicamente la clave pública/publishable de Supabase en el navegador. Nunca subas `.env.local`, `service_role` ni claves secretas.

La tienda se abre en `/` y el panel administrativo en `/admin`. El acceso al panel requiere un usuario autenticado autorizado en `public.admin_users`.

## Estructura importante

- `src/`: tienda y panel administrativo.
- `public/`: recursos estáticos y marca.
- `supabase/migrations/`: historial de migraciones SQL del proyecto.
- `supabase/seed/`: datos de importación inicial.

## Base de datos existente

Este repositorio contiene migraciones e importaciones históricas. **No ejecutes nuevamente las migraciones iniciales ni los scripts de seed sobre la base de datos de producción ya poblada.** Antes de aplicar cualquier SQL, comprueba qué migraciones ya se ejecutaron y realiza una copia de seguridad.

## Compilar

```bash
pnpm build
```
