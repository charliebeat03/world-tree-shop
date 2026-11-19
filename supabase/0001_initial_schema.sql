-- 0001_initial_schema.sql
-- World Tree v0.7 - Initial Schema
-- ============================================================
-- Catálogo comercial para tienda World Tree (Santiago de Cuba)
-- ============================================================

-- Extensiones
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla: categories
-- ============================================================

COMMENT ON TABLE public.categories IS 'Categorías del catálogo de productos. Ejemplos: Cárnicos, Productos lácteos, Granos, Confituras, Aseo, Otros.';

CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_categories_active ON public.categories(is_active, sort_order);

-- Tabla: products
-- ============================================================

COMMENT ON TABLE public.products IS 'Productos del catálogo. Estatus: available (disponible), check_availability (consultar disponibilidad), sold_out (agotado), hidden (oculto).';

COMMENT ON COLUMN public.products.status IS 'available: disponible, check_availability: consultar disponibilidad, sold_out: agotado, hidden: oculto';

CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(200) NOT NULL,
  slug VARCHAR(200) UNIQUE NOT NULL,
  description TEXT,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'check_availability',
  is_hidden BOOLEAN DEFAULT FALSE,
  image_main VARCHAR(500),
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category_id) WHERE category_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_products_status ON public.products(status);
CREATE INDEX IF NOT EXISTS idx_products_slug ON public.products(slug);
CREATE INDEX IF NOT EXISTS idx_products_hidden ON public.products(is_hidden) WHERE is_hidden = FALSE;

-- Tabla: product_images
-- ============================================================

COMMENT ON TABLE public.product_images IS 'Imágenes asociadas a productos. Una product puede tener múltiples imágenes.';

COMMENT ON COLUMN public.product_images.storage_path IS 'Ruta del archivo en el bucket world-tree-products de Supabase Storage.';

COMMENT ON COLUMN public.product_images.is_primary IS 'Indica si es la imagen principal del producto';

CREATE TABLE IF NOT EXISTS public.product_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  storage_path VARCHAR(500) NOT NULL,
  alt_text VARCHAR(200) NOT NULL DEFAULT '',
  sort_order INTEGER DEFAULT 0,
  is_primary BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_product_images_product ON public.product_images(product_id, is_primary);

-- Tabla: pricing_options
-- ============================================================

COMMENT ON TABLE public.pricing_options IS 'Opciones de tarifa/metodo de precio. Las 8 tarifas requeridas: Zelle, IBAN, Bizum, Posta, Reales, MXN, PDO, Rublos. Zelle, IBAN, Bizum y Posta son canales de pago, no monedas.';

INSERT INTO public.pricing_options (code, display_name, is_active, sort_order) VALUES
  ('Zelle', 'Zelle', TRUE, 1),
  ('IBAN', 'IBAN', TRUE, 2),
  ('Bizum', 'Bizum', TRUE, 3),
  ('Posta', 'Posta', TRUE, 4),
  ('Reales', 'Reales', TRUE, 5),
  ('MXN', 'MXN', TRUE, 6),
  ('PDO', 'PDO', TRUE, 7),
  ('Rublos', 'Rublos', TRUE, 8)
ON CONFLICT (code) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_pricing_options_active ON public.pricing_options(is_active, sort_order);

-- Tabla: product_prices
-- ============================================================

COMMENT ON TABLE public.product_prices IS 'Precios independientes por producto y tarifa. Los campos vacíos deben continuar vacíos. No se calculan precios de una tarifa a partir de otra.';

CREATE TABLE IF NOT EXISTS public.product_prices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  pricing_option_id UUID REFERENCES public.pricing_options(id) ON DELETE CASCADE,
  amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (product_id, pricing_option_id)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_product_prices_unique ON public.product_prices(product_id, pricing_option_id);
CREATE INDEX IF NOT EXISTS idx_product_prices_product ON public.product_prices(product_id);
CREATE INDEX IF NOT EXISTS idx_product_prices_option ON public.product_prices(pricing_option_id);

-- Tabla: combos
-- ============================================================

COMMENT ON TABLE public.combos IS 'Combos y promociones. Estatus: available, check_availability, sold_out, hidden.';

COMMENT ON COLUMN public.combos.status IS 'available: disponible, check_availability: consultar disponibilidad, sold_out: agotado, hidden: oculto.';

COMMENT ON COLUMN public.combos.starts_at IS 'Fecha/hora de inicio de la promoción (opcional). Si es NULL, el combo está activo inmediatamente.';

COMMENT ON COLUMN public.combos.ends_at IS 'Fecha/hora de fin de la promoción (opcional). Si es NULL, el combo está activo indefinidamente.';

CREATE TABLE IF NOT EXISTS public.combos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(200) NOT NULL,
  slug VARCHAR(200) UNIQUE NOT NULL,
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'available',
  is_hidden BOOLEAN DEFAULT FALSE,
  starts_at TIMESTAMPTZ,
  ends_at TIMESTAMPTZ,
  image_main VARCHAR(500),
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_combos_status ON public.combos(status);
CREATE INDEX IF NOT EXISTS idx_combos_hidden ON public.combos(is_hidden) WHERE is_hidden = FALSE;
CREATE INDEX IF NOT EXISTS idx_combos_dates ON public.combos(starts_at, ends_at) WHERE starts_at IS NOT NULL OR ends_at IS NOT NULL;

-- Tabla: combo_images
-- ============================================================

COMMENT ON TABLE public.combo_images IS 'Imágenes asociadas a combos. Una combo puede tener múltiples imágenes.';

COMMENT ON COLUMN public.combo_images.storage_path IS 'Ruta del archivo en el bucket world-tree-products de Supabase Storage.';

CREATE TABLE IF NOT EXISTS public.combo_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  combo_id UUID REFERENCES public.combos(id) ON DELETE CASCADE,
  storage_path VARCHAR(500) NOT NULL,
  alt_text VARCHAR(200) NOT NULL DEFAULT '',
  sort_order INTEGER DEFAULT 0,
  is_primary BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_combo_images_combo ON public.combo_images(combo_id, is_primary);

-- Tabla: combo_items
-- ============================================================

COMMENT ON TABLE public.combo_items IS 'Productos incluidos en un combo. quantity >= 1. Si quantity es 0, el producto no debe incluirse (validación en aplicación).';

COMMENT ON COLUMN public.combo_items.quantity IS 'Cantidad del producto dentro del combo. Debe ser >= 1. Cantidad 0 significa que no debe incluirse.';

CREATE TABLE IF NOT EXISTS public.combo_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  combo_id UUID REFERENCES public.combos(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER DEFAULT 0,
  UNIQUE (combo_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_combo_items_combo ON public.combo_items(combo_id);
CREATE INDEX IF NOT EXISTS idx_combo_items_product ON public.combo_items(product_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_combo_items_unique ON public.combo_items(combo_id, product_id);

-- Tabla: combo_prices
-- ============================================================

COMMENT ON TABLE public.combo_prices IS 'Precios independientes para cada combo y tarifa. Los precios NO se calculan automáticamente sumando los precios de los productos incluidos.';

COMMENT ON COLUMN public.combo_prices.amount IS 'Precio independiente para esta combinación. No se deriva de la suma de precios de productos.';

CREATE TABLE IF NOT EXISTS public.combo_prices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  combo_id UUID REFERENCES public.combos(id) ON DELETE CASCADE,
  pricing_option_id UUID REFERENCES public.pricing_options(id) ON DELETE CASCADE,
  amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (combo_id, pricing_option_id)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_combo_prices_unique ON public.combo_prices(combo_id, pricing_option_id);
CREATE INDEX IF NOT EXISTS idx_combo_prices_combo ON public.combo_prices(combo_id);
CREATE INDEX IF NOT EXISTS idx_combo_prices_option ON public.combo_prices(pricing_option_id);

-- Tabla: provinces
-- ============================================================

COMMENT ON TABLE public.provinces IS 'Provincias para cobertura de entregas. Inicialmente solo Santiago de Cuba está habilitada. Otras provincias se añaden desde el panel y comienzan deshabilitadas.';

COMMENT ON COLUMN public.provinces.is_enabled IS 'TRUE = provincia disponible para entregas, FALSE = provincia deshabilitada (aún no se ofrecen entregas allí).';

CREATE TABLE IF NOT EXISTS public.provinces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  is_enabled BOOLEAN DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_provinces_enabled ON public.provinces(is_enabled, name);

-- Tabla: municipalities
-- ============================================================

COMMENT ON TABLE public.municipalities IS 'Municipios dentro de cada provincia. Solo se pueden seleccionar municipios de provincias habilitadas.';

COMMENT ON COLUMN public.municipalities.is_enabled IS 'TRUE = municipio disponible para entregas, FALSE = municipio deshabilitado. Al desactivar una provincia, sus municipios también se desactivan automáticamente.';

CREATE TABLE IF NOT EXISTS public.municipalities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  province_id UUID REFERENCES public.provinces(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  is_enabled BOOLEAN DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_municipalities_province ON public.municipalities(province_id, is_enabled);
CREATE INDEX IF NOT EXISTS idx_municipalities_enabled ON public.municipalities(is_enabled, name);

-- Tabla: admin_users
-- ============================================================

COMMENT ON TABLE public.admin_users IS 'Usuarios autorizados para acceder al panel administrativo. La cuenta del propietario se crea manualmente mediante Supabase Auth y registrando su user_id aquí.';

COMMENT ON COLUMN public.admin_users.user_id IS 'UUID de la cuenta de Supabase Auth del propietario o administrador.';

COMMENT ON COLUMN public.admin_users.role IS 'owner: propietaria del negocio, admin: administrador general, mantenimiento: personal de mantenimiento.';

CREATE TABLE IF NOT EXISTS public.admin_users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE,
  role VARCHAR(20) NOT NULL DEFAULT 'admin',
  is_active BOOLEAN DEFAULT TRUE,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT chk_admin_role CHECK (role IN ('owner', 'admin', 'maintenance'))
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_admin_users_user_id ON public.admin_users(user_id);
CREATE INDEX IF NOT EXISTS idx_admin_users_active ON public.admin_users(is_active, role);

-- Vistas para catálogo público
-- ============================================================

CREATE OR REPLACE VIEW public.product_catalog AS
SELECT 
  p.id,
  p.name,
  p.description,
  p.status,
  c.name AS category_name,
  pi.storage_path AS image_path,
  pp.amount AS price,
  pp.pricing_option_id AS pricing_option_id
FROM public.products p
LEFT JOIN public.categories c ON p.category_id = c.id
LEFT JOIN public.product_images pi ON p.id = pi.product_id AND pi.is_primary = TRUE
LEFT JOIN public.product_prices pp ON p.id = pp.product_id
WHERE p.is_hidden = FALSE;

COMMENT ON VIEW public.product_catalog IS 'Vista para el catálogo público. Solo productos no ocultos con sus precios e imágenes principales.';

CREATE OR REPLACE VIEW public.combo_catalog AS
SELECT 
  cb.id,
  cb.name,
  cb.description,
  cb.status,
  ci.quantity,
  p.name AS product_name,
  cp.amount AS price,
  cp.pricing_option_id AS pricing_option_id
FROM public.combos cb
LEFT JOIN public.combo_items ci ON cb.id = ci.combo_id
LEFT JOIN public.products p ON ci.product_id = p.id
LEFT JOIN public.combo_prices cp ON cb.id = cp.combo_id;

COMMENT ON VIEW public.combo_catalog IS 'Vista para el catálogo de combos. Incluye items y precios por tarifa.';

-- ============================================================
-- FIN DEL ESQUEMA INICIAL
-- ============================================================
-- Ejecutar en orden: 0001 -> 0002 -> 0003
-- ============================================================