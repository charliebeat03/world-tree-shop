-- 0002_security_hardening.sql
-- World Tree v0.7 - Security Hardening (RLS Policies)
-- ============================================================
-- Row Level Security policies for all tables

-- CATEGORIES

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anónimos pueden ver categorías activas" ON public.categories
  FOR SELECT USING (is_active = TRUE);

-- PRODUCTS

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Anónimos pueden ver productos disponibles (no ocultos y no sold_out)
CREATE POLICY "Anónimos pueden ver productos disponibles" ON public.products
  FOR SELECT USING (is_hidden = FALSE AND status != 'sold_out');

-- Anónimos pueden ver productos sold_out
CREATE POLICY "Anónimos pueden ver productos sold_out" ON public.products
  FOR SELECT USING (status = 'sold_out');

-- Administradores autorizados pueden gestionar productos
CREATE POLICY "Administradores pueden gestionar productos" ON public.products
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- PRICING_OPTIONS

ALTER TABLE public.pricing_options ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anónimos pueden ver opciones de precio activas" ON public.pricing_options
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Administradores pueden gestionar opciones de precio" ON public.pricing_options
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- PRODUCT_PRICES

ALTER TABLE public.product_prices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anónimos pueden ver precios de productos" ON public.product_prices
  FOR SELECT USING (TRUE);

CREATE POLICY "Administradores pueden gestionar precios de productos" ON public.product_prices
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- COMBOS

ALTER TABLE public.combos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anónimos pueden ver combos disponibles" ON public.combos
  FOR SELECT USING (is_hidden = FALSE);

CREATE POLICY "Administradores pueden gestionar combos" ON public.combos
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- COMBO_IMAGES

ALTER TABLE public.combo_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública de imágenes de combos" ON public.combo_images
  FOR SELECT USING (TRUE);

CREATE POLICY "Administradores pueden gestionar imágenes de combos" ON public.combo_images
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- COMBO_ITEMS

ALTER TABLE public.combo_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anónimos pueden ver items de combos" ON public.combo_items
  FOR SELECT USING (TRUE);

CREATE POLICY "Administradores pueden gestionar items de combos" ON public.combo_items
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- COMBO_PRICES

ALTER TABLE public.combo_prices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anónimos pueden ver precios de combos" ON public.combo_prices
  FOR SELECT USING (TRUE);

CREATE POLICY "Administradores pueden gestionar precios de combos" ON public.combo_prices
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- PROVINCES

ALTER TABLE public.provinces ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anónimos pueden ver provincias habilitadas" ON public.provinces
  FOR SELECT USING (is_enabled = TRUE);

CREATE POLICY "Administradores pueden gestionar provincias" ON public.provinces
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- MUNICIPALITIES

ALTER TABLE public.municipalities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anónimos pueden ver municipios de provincias habilitadas" ON public.municipalities
  FOR SELECT USING (is_enabled = TRUE AND province_id IN (
    SELECT id FROM public.provinces WHERE is_enabled = TRUE
  ));

CREATE POLICY "Administradores pueden gestionar municipios" ON public.municipalities
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid()::uuid
      AND is_active = TRUE
    )
  );

-- ADMIN_USERS

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver su propio registro de administrador" ON public.admin_users
  FOR SELECT USING (user_id = auth.uid()::uuid);

-- FUNCIÓN AUXILIAR

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE user_id = auth.uid()::uuid
    AND is_active = TRUE
    AND role = 'owner'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ============================================================
-- FIN DEL HARDENING DE SEGURIDAD
-- ============================================================
-- Nota: Las políticas RLS impiden que usuarios anónimos inserten, 
-- modifiquen o eliminen registros. Solo usuarios registrados en 
-- admin_users con rol owner/admin y sesión activa pueden realizar 
-- escrituras.