-- 0003_product_image_storage.sql
-- World Tree v0.7 - Configuración de Storage para imágenes de productos
-- ============================================================
-- Bucket: world-tree-products
-- Lectura pública: imágenes del catálogo
-- Escritura: solo administradores autorizados
-- Formatos: JPG, PNG, WebP
-- Tamaño máximo: 5 MB
-- ============================================================

-- Nota: Este archivo contiene instrucciones SQL para configurar el bucket
-- de Storage de Supabase. Algunos buckets se crean desde el panel de control
-- de Supabase o mediante la CLI de Supabase, ya que el SQL puro no puede
-- crear buckets directamente en todas las versiones.

-- ============================================================
-- POLÍTICAS DE STORAGE PARA world-tree-products
-- ============================================================

-- Estas políticas se aplican al bucket world-tree-products en Supabase Storage.
-- Deben configurarse desde el panel de Supabase (Storage > Buckets > world-tree-products > Policies)

-- Política: Lectura pública de todas las imágenes
-- Permite que cualquier usuario (incluidos anónimos) descargue imágenes del catálogo
CREATE POLICY "Lectura pública de imágenes de productos" ON storage.objects
  FOR SELECT
  USING (bucket_id = 'world-tree-products');

-- Política: Subida de imágenes solo para administradores autenticados
-- Requiere que el usuario esté en la tabla admin_users con is_active = TRUE
CREATE POLICY "Subida de imágenes solo para administradores" ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'world-tree-products'
    AND auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- Política: Actualización de imágenes solo para administradores
CREATE POLICY "Actualización de imágenes solo para administradores" ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'world-tree-products'
    AND auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- Política: Eliminación de imágenes solo para administradores
CREATE POLICY "Eliminación de imágenes solo para administradores" ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'world-tree-products'
    AND auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- ============================================================
-- NOTAS DE CONFIGURACIÓN
-- ============================================================
-- 1. Crear el bucket 'world-tree-products' desde el panel de Supabase o CLI:
--    supabase storage create world-tree-products --public
-- 2. Configurar tipos MIME permitidos: image/jpeg, image/png, image/webp
-- 3. Configurar tamaño máximo de archivo: 5 MB
-- 4. Aplicar las políticas de Storage listadas arriba
-- 5. Nunca usar la clave service_role en el frontend
-- ============================================================