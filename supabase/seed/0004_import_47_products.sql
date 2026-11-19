-- ============================================================
-- WORLD TREE - IMPORTACIÓN DE PRODUCTOS (VERSIÓN SIMPLE)
-- ============================================================

-- ------------------------------------------------------------
-- 1. CATEGORÍAS
-- ------------------------------------------------------------

INSERT INTO public.categories (name, slug, description, is_active, sort_order) VALUES
  ('Cárnicos', 'carnicos', 'Productos de carne y embutidos', TRUE, 1),
  ('Productos lácteos', 'productos-lacteos', 'Leche, quesos, yogures y derivados lácteos', TRUE, 2),
  ('Granos', 'granos', 'Arroz, frijoles, lentejas y otros granos', TRUE, 3),
  ('Confituras', 'confituras', 'Mermeladas, jaleas y conservas de fruta', TRUE, 4),
  ('Aseo', 'aseo', 'Productos de limpieza e higiene personal', TRUE, 5),
  ('Otros', 'otros', 'Productos varios no clasificados en otras categorías', TRUE, 6)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  updated_at = now();

-- ------------------------------------------------------------
-- 2. PROVINCIA Y MUNICIPIOS
-- ------------------------------------------------------------

INSERT INTO public.provinces (name, slug, is_enabled, sort_order) VALUES
  ('Santiago de Cuba', 'santiago-de-cuba', TRUE, 1)
ON CONFLICT (slug) DO UPDATE SET updated_at = now();

INSERT INTO public.municipalities (province_id, name, slug, is_enabled, sort_order)
SELECT p.id, m.name, m.slug, m.is_enabled, m.sort_order
FROM public.provinces p
CROSS JOIN (
  VALUES
    ('Santiago de Cuba', 'santiago-de-cuba', TRUE, 1),
    ('Contramaestre', 'contramaestre', TRUE, 2),
    ('Palma Soriano', 'palma-soriano', TRUE, 3),
    ('San Luis', 'san-luis', TRUE, 4),
    ('Songo-La Maya', 'songo-la-maya', TRUE, 5),
    ('Segundo Frente', 'segundo-frente', TRUE, 6),
    ('Tercer Frente', 'tercer-frente', TRUE, 7),
    ('Guamá', 'guama', TRUE, 8),
    ('Mella', 'mella', TRUE, 9)
) AS m(name, slug, is_enabled, sort_order)
WHERE p.slug = 'santiago-de-cuba'
ON CONFLICT (slug) DO UPDATE SET updated_at = now();

-- ------------------------------------------------------------
-- 3. PRODUCTOS Y PRECIOS
-- ------------------------------------------------------------

-- Función auxiliar para obtener ID de categoría
DO $$
DECLARE
  v_carnicos UUID := (SELECT id FROM public.categories WHERE slug = 'carnicos');
  v_lacteos UUID := (SELECT id FROM public.categories WHERE slug = 'productos-lacteos');
  v_granos UUID := (SELECT id FROM public.categories WHERE slug = 'granos');
  v_confituras UUID := (SELECT id FROM public.categories WHERE slug = 'confituras');
  v_aseo UUID := (SELECT id FROM public.categories WHERE slug = 'aseo');
  v_otros UUID := (SELECT id FROM public.categories WHERE slug = 'otros');
  
  v_zelle UUID := (SELECT id FROM public.pricing_options WHERE code = 'Zelle');
  v_iban UUID := (SELECT id FROM public.pricing_options WHERE code = 'IBAN');
  v_bizum UUID := (SELECT id FROM public.pricing_options WHERE code = 'Bizum');
  v_posta UUID := (SELECT id FROM public.pricing_options WHERE code = 'Posta');
  v_reales UUID := (SELECT id FROM public.pricing_options WHERE code = 'Reales');
  v_mxn UUID := (SELECT id FROM public.pricing_options WHERE code = 'MXN');
  v_pdo UUID := (SELECT id FROM public.pricing_options WHERE code = 'PDO');
  v_rublos UUID := (SELECT id FROM public.pricing_options WHERE code = 'Rublos');
  
  v_pid UUID;
BEGIN

  -- CÁRNICOS (6 productos)
  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_carnicos, 'PAQUETE DE POLLO 10LB', 'paquete-de-pollo-10lb', 'Paquete familiar. Consulta disponibilidad antes de confirmar.', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 14.70), (v_pid, v_iban, 14.50), (v_pid, v_bizum, 14.63), (v_pid, v_posta, 14.63),
    (v_pid, v_reales, 84.87), (v_pid, v_mxn, 297.45), (v_pid, v_pdo, 1500), (v_pid, v_rublos, 1630)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_carnicos, 'CARNE DE CERDO DESHUESADO 5lb', 'carne-de-cerdo-deshuesado-5lb', 'Presentación de 5 libras.', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 21.65), (v_pid, v_iban, 20.90), (v_pid, v_bizum, 21.49), (v_pid, v_posta, 21.54),
    (v_pid, v_reales, 125), (v_pid, v_mxn, 48.2), (v_pid, v_pdo, 2031.25), (v_pid, v_rublos, 2400)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_carnicos, 'CARNE DE RES 5 Lb', 'carne-de-res-5lb', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 11.40), (v_pid, v_iban, 10.90), (v_pid, v_bizum, 11.10), (v_pid, v_posta, 11.10),
    (v_pid, v_reales, 60.37), (v_pid, v_mxn, 229.38), (v_pid, v_pdo, 1057.25), (v_pid, v_rublos, 1400)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_carnicos, 'CARNE DE CERDO AL CORTE 5lb', 'carne-de-cerdo-al-corte-5lb', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 16.25), (v_pid, v_iban, 15.75), (v_pid, v_bizum, 15.95), (v_pid, v_posta, 15.95),
    (v_pid, v_reales, 92.85), (v_pid, v_mxn, 352.35), (v_pid, v_pdo, 1630), (v_pid, v_rublos, 1940)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_carnicos, 'JAMÓN PRENSADO 2lb', 'jamon-prensado-2lb', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 6.90), (v_pid, v_iban, 6.59), (v_pid, v_bizum, 6.76), (v_pid, v_posta, 6.76),
    (v_pid, v_reales, 37.20), (v_pid, v_mxn, 141.54), (v_pid, v_pdo, 650), (v_pid, v_rublos, 800)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_carnicos, 'JAMÓN VICKY 2lb', 'jamon-vicky-2lb', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 4.88), (v_pid, v_iban, 4.63), (v_pid, v_bizum, 4.78), (v_pid, v_posta, 4.78),
    (v_pid, v_reales, 28.85), (v_pid, v_mxn, 105), (v_pid, v_pdo, 488), (v_pid, v_rublos, 582)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  -- PRODUCTOS LÁCTEOS (5 productos)
  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_lacteos, 'LECHE AMARILLA 1kg', 'leche-amarilla-1kg', 'Consulta disponibilidad antes de confirmar.', 'available')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 9.62), (v_pid, v_iban, 9.38), (v_pid, v_bizum, 9.50), (v_pid, v_posta, 9.50),
    (v_pid, v_reales, 56.91), (v_pid, v_mxn, 212.50), (v_pid, v_pdo, 489.5), (v_pid, v_rublos, 1175.08)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_lacteos, 'PAQUETE DE MANTEQUILLA 250g', 'paquete-de-mantequilla-250g', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 1.79), (v_pid, v_iban, 1.59), (v_pid, v_bizum, 1.69), (v_pid, v_posta, 1.69),
    (v_pid, v_reales, 9.10), (v_pid, v_mxn, 35.99), (v_pid, v_pdo, 168.70), (v_pid, v_rublos, 201.49)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_lacteos, 'LECHE CONDENSADA 1u', 'leche-condensada-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 2.10), (v_pid, v_iban, 1.85), (v_pid, v_bizum, 2.05), (v_pid, v_posta, 2.05),
    (v_pid, v_reales, 10.90), (v_pid, v_mxn, 40.60), (v_pid, v_pdo, 189.5), (v_pid, v_rublos, 224.88)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_lacteos, 'QUESO BLANCO 2lb', 'queso-blanco-2lb', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 4.81), (v_pid, v_iban, 4.58), (v_pid, v_bizum, 4.69), (v_pid, v_posta, 4.69),
    (v_pid, v_reales, 27.90), (v_pid, v_mxn, 98.80), (v_pid, v_pdo, 487.50), (v_pid, v_rublos, 583.00)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_lacteos, 'QUESO GOUDA 1KG', 'queso-gouda-1kg', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 15.55), (v_pid, v_iban, 15.32), (v_pid, v_bizum, 15.46), (v_pid, v_posta, 15.46),
    (v_pid, v_reales, 96.43), (v_pid, v_mxn, 364.86), (v_pid, v_pdo, 1687), (v_pid, v_rublos, 1990.99)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  -- GRANOS (6 productos)
  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_granos, 'ARROZ 1KG', 'arroz-1kg', 'Paquete de un kilogramo.', 'available')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 1.99), (v_pid, v_iban, 1.77), (v_pid, v_bizum, 1.82), (v_pid, v_posta, 1.82),
    (v_pid, v_reales, 10.81), (v_pid, v_mxn, 52.70), (v_pid, v_pdo, 243.75), (v_pid, v_rublos, 291.06)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_granos, 'GARBANZOS 500g', 'garbanzos-500g', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 3.00), (v_pid, v_iban, 2.82), (v_pid, v_bizum, 2.90), (v_pid, v_posta, 2.90),
    (v_pid, v_reales, 19.28), (v_pid, v_mxn, 73.97), (v_pid, v_pdo, 335.7), (v_pid, v_rublos, 390.90)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_granos, 'FRIJOLES NEGROS 1KG', 'frijoles-negros-1kg', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 2.48), (v_pid, v_iban, 2.31), (v_pid, v_bizum, 2.37), (v_pid, v_posta, 2.37),
    (v_pid, v_reales, 12.79), (v_pid, v_mxn, 44.59), (v_pid, v_pdo, 207.25), (v_pid, v_rublos, 246.26)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_granos, 'FRIJOLES COLORADOS 1KG', 'frijoles-colorados-1kg', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 2.60), (v_pid, v_iban, 2.41), (v_pid, v_bizum, 2.50), (v_pid, v_posta, 2.50),
    (v_pid, v_reales, 13.50), (v_pid, v_mxn, 57.75), (v_pid, v_pdo, 262.5), (v_pid, v_rublos, 313.42)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_granos, 'AZÚCAR 1kg', 'azucar-1kg', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 2.80), (v_pid, v_iban, 2.65), (v_pid, v_bizum, 2.70), (v_pid, v_posta, 2.70),
    (v_pid, v_reales, 14.90), (v_pid, v_mxn, 60.91), (v_pid, v_pdo, 282.95), (v_pid, v_rublos, 335.83)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_granos, 'SAL 1kg', 'sal-1kg', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.89), (v_pid, v_iban, 0.68), (v_pid, v_bizum, 0.79), (v_pid, v_posta, 0.79),
    (v_pid, v_reales, 6.40), (v_pid, v_mxn, 24.32), (v_pid, v_pdo, 99.00), (v_pid, v_rublos, 130.00)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  -- CONFITURAS (15 productos)
  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'GALLETAS DE SODA 7u', 'galletas-de-soda-7u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 3.88), (v_pid, v_iban, 3.75), (v_pid, v_bizum, 3.80), (v_pid, v_posta, 3.80),
    (v_pid, v_reales, 22.96), (v_pid, v_mxn, 85.46), (v_pid, v_pdo, 459.68), (v_pid, v_rublos, 428.75)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'GALLETAS DE SODA CON SABOR A QUESO 7u', 'galletas-de-soda-sabor-queso-7u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 4.84), (v_pid, v_iban, 4.66), (v_pid, v_bizum, 4.78), (v_pid, v_posta, 4.78),
    (v_pid, v_reales, 25.45), (v_pid, v_mxn, 97.05), (v_pid, v_pdo, 381.08), (v_pid, v_rublos, 466.09)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'PAQUETE DE GELATINA 1u', 'paquete-de-gelatina-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.88), (v_pid, v_iban, 0.80), (v_pid, v_bizum, 0.85), (v_pid, v_posta, 0.85),
    (v_pid, v_reales, 4.54), (v_pid, v_mxn, 17.14), (v_pid, v_pdo, 67.18), (v_pid, v_rublos, 83.03)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'PAQUETE DE GOMITAS 1u', 'paquete-de-gomitas-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.70), (v_pid, v_iban, 0.66), (v_pid, v_bizum, 0.69), (v_pid, v_posta, 0.69),
    (v_pid, v_reales, 3.65), (v_pid, v_mxn, 13.90), (v_pid, v_pdo, 54.57), (v_pid, v_rublos, 66.60)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'PAQUETE DE SORBETO 1u', 'paquete-de-sorbeto-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.80), (v_pid, v_iban, 0.75), (v_pid, v_bizum, 0.78), (v_pid, v_posta, 0.78),
    (v_pid, v_reales, 4.50), (v_pid, v_mxn, 15.76), (v_pid, v_pdo, 61.36), (v_pid, v_rublos, 74.70)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'PANQUESITOS 1u', 'panquesitos-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.58), (v_pid, v_iban, 0.50), (v_pid, v_bizum, 0.55), (v_pid, v_posta, 0.55),
    (v_pid, v_reales, 2.75), (v_pid, v_mxn, 13.95), (v_pid, v_pdo, 40.90), (v_pid, v_rublos, 49.70)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'GALLETAS RELLENAS CON CHOCOLATE (pequeñas) 1u', 'galletas-rellenas-chocolate-pequenas-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.58), (v_pid, v_iban, 0.50), (v_pid, v_bizum, 0.55), (v_pid, v_posta, 0.55),
    (v_pid, v_reales, 2.75), (v_pid, v_mxn, 13.95), (v_pid, v_pdo, 40.90), (v_pid, v_rublos, 49.70)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'GALLETAS DE CHOCOLATE RELLENAS (grandes) 1u', 'galletas-de-chocolate-rellenas-grandes-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 1.05), (v_pid, v_iban, 0.99), (v_pid, v_bizum, 1.03), (v_pid, v_posta, 1.03),
    (v_pid, v_reales, 3.63), (v_pid, v_mxn, 20.93), (v_pid, v_pdo, 81.81), (v_pid, v_rublos, 97.30)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'PAQUETE DE CARAMELOS DE LECHE 50u', 'paquete-de-caramelos-de-leche-50u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 3.57), (v_pid, v_iban, 3.18), (v_pid, v_bizum, 3.27), (v_pid, v_posta, 3.27),
    (v_pid, v_reales, 17.81), (v_pid, v_mxn, 66.27), (v_pid, v_pdo, 356.25), (v_pid, v_rublos, 370.05)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'PAQUETE DE CARAMELO DE MENTA', 'paquete-de-caramelo-de-menta', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 2.85), (v_pid, v_iban, 2.63), (v_pid, v_bizum, 2.74), (v_pid, v_posta, 2.74),
    (v_pid, v_reales, 16.87), (v_pid, v_mxn, 59.30), (v_pid, v_pdo, 255.29), (v_pid, v_rublos, 320.75)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'PAQUETES DE GALLETAS VAQUITAS 12u', 'paquetes-de-galletas-vaquitas-12u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 3.29), (v_pid, v_iban, 3.05), (v_pid, v_bizum, 2.80), (v_pid, v_posta, 2.80),
    (v_pid, v_reales, 19.28), (v_pid, v_mxn, 62.73), (v_pid, v_pdo, 273.15), (v_pid, v_rublos, 337.60)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'NUTELLA 1u', 'nutella-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 2.85), (v_pid, v_iban, 2.63), (v_pid, v_bizum, 2.77), (v_pid, v_posta, 2.77),
    (v_pid, v_reales, 16.07), (v_pid, v_mxn, 52.32), (v_pid, v_pdo, 225.20), (v_pid, v_rublos, 284.25)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'MALTA GUAJIRA 6u (pequeñas)', 'malta-guajira-6u-pequenas', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 6.99), (v_pid, v_iban, 6.75), (v_pid, v_bizum, 6.80), (v_pid, v_posta, 6.80),
    (v_pid, v_reales, 32.75), (v_pid, v_mxn, 117.79), (v_pid, v_pdo, 480.90), (v_pid, v_rublos, 580.20)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'POTE DE PAPITAS 1u (Grande)', 'pote-de-papitas-1u-grande', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 2.82), (v_pid, v_iban, 2.66), (v_pid, v_bizum, 2.79), (v_pid, v_posta, 2.79),
    (v_pid, v_reales, 14.54), (v_pid, v_mxn, 55.81), (v_pid, v_pdo, 200.34), (v_pid, v_rublos, 264.05)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_confituras, 'PELLYS DE QUESO 1u', 'pelllys-de-queso-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.66), (v_pid, v_iban, 0.58), (v_pid, v_bizum, 0.61), (v_pid, v_posta, 0.61),
    (v_pid, v_reales, 3.18), (v_pid, v_mxn, 12.20), (v_pid, v_pdo, 47.72), (v_pid, v_rublos, 58.20)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  -- ASEO (8 productos)
  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_aseo, 'FRASADA 1u', 'frasada-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.83), (v_pid, v_iban, 0.75), (v_pid, v_bizum, 0.79), (v_pid, v_posta, 0.79),
    (v_pid, v_reales, 3.80), (v_pid, v_mxn, 14.74), (v_pid, v_pdo, 55.40), (v_pid, v_rublos, 67.20)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_aseo, 'JABONES DE BAÑO 1u', 'jabones-de-bano-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.88), (v_pid, v_iban, 0.77), (v_pid, v_bizum, 0.82), (v_pid, v_posta, 0.82),
    (v_pid, v_reales, 4.54), (v_pid, v_mxn, 17.44), (v_pid, v_pdo, 68.18), (v_pid, v_rublos, 83.33)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_aseo, 'JABONES DE LAVAR', 'jabones-de-lavar', 'Precio pendiente para algunas tarifas.', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.83), (v_pid, v_iban, 0.75), (v_pid, v_bizum, 0.79), (v_pid, v_posta, 0.79)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_aseo, 'DETERGENTE 500g', 'detergente-500g', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 1.75), (v_pid, v_iban, 1.68), (v_pid, v_bizum, 1.71), (v_pid, v_posta, 1.71)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_aseo, 'DETERGENTE LÍQUIDO 1 L', 'detergente-liquido-1-l', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  -- No hay precios para Detergente Líquido 1L (todos vacíos)

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_aseo, 'DETERGENTE EN PASTA 500g', 'detergente-en-pasta-500g', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 3.68), (v_pid, v_iban, 3.55), (v_pid, v_bizum, 3.63), (v_pid, v_posta, 3.63)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_aseo, 'PASTA DENTAL', 'pasta-dental', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 1.10), (v_pid, v_iban, 1.05), (v_pid, v_bizum, 1.07), (v_pid, v_posta, 1.07)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_aseo, 'ESPONJAS PARA FREGAR 3u', 'esponjas-para-fregar-3u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.73), (v_pid, v_iban, 0.66), (v_pid, v_bizum, 0.69), (v_pid, v_posta, 0.69)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  -- OTROS (7 productos)
  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_otros, 'HUEVO', 'huevo', '', 'available')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 6.80), (v_pid, v_iban, 6.20), (v_pid, v_bizum, 6.50), (v_pid, v_posta, 6.50),
    (v_pid, v_reales, 32.72), (v_pid, v_mxn, 125.58), (v_pid, v_pdo, 490.90), (v_pid, v_rublos, 550.87)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_otros, 'ACEITE 900 ML 1u', 'aceite-900-ml-1u', 'Botella de 900 ml.', 'available')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 5.35), (v_pid, v_iban, 4.85), (v_pid, v_bizum, 5.23), (v_pid, v_posta, 5.23),
    (v_pid, v_reales, 27.27), (v_pid, v_mxn, 104.65), (v_pid, v_pdo, 399.70), (v_pid, v_rublos, 470.80)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_otros, 'LATA DE SPAM 1u', 'lata-de-spam-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 2.40), (v_pid, v_iban, 2.15), (v_pid, v_bizum, 2.33), (v_pid, v_posta, 2.33),
    (v_pid, v_reales, 14.54), (v_pid, v_mxn, 55.81), (v_pid, v_pdo, 218.18), (v_pid, v_rublos, 266.66)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_otros, 'PAQUETE DE SALCHICHAS 1u', 'paquete-de-salchichas-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 2.40), (v_pid, v_iban, 2.25), (v_pid, v_bizum, 2.35), (v_pid, v_posta, 2.35),
    (v_pid, v_reales, 12.75), (v_pid, v_mxn, 48.83), (v_pid, v_pdo, 190.90), (v_pid, v_rublos, 220.55)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_otros, 'ESPAGETTI 500G', 'espagetti-500g', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 1.20), (v_pid, v_iban, 0.99), (v_pid, v_bizum, 1.00), (v_pid, v_posta, 1.00),
    (v_pid, v_reales, 7.27), (v_pid, v_mxn, 27.90), (v_pid, v_pdo, 109.09), (v_pid, v_rublos, 133.33)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_otros, 'PAQUETE DE SOPITAS 1u', 'paquete-de-sopitas-1u', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 0.75), (v_pid, v_iban, 0.66), (v_pid, v_bizum, 0.69), (v_pid, v_posta, 0.69),
    (v_pid, v_reales, 3.63), (v_pid, v_mxn, 13.95), (v_pid, v_pdo, 54.40), (v_pid, v_rublos, 65.60)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  INSERT INTO public.products (category_id, name, slug, description, status) VALUES
    (v_otros, 'PAQUETE DE CAFÉ 250g', 'paquete-de-cafe-250g', '', 'check_availability')
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO v_pid;
  INSERT INTO public.product_prices (product_id, pricing_option_id, amount) VALUES
    (v_pid, v_zelle, 4.41), (v_pid, v_iban, 4.20), (v_pid, v_bizum, 4.30), (v_pid, v_posta, 4.30),
    (v_pid, v_reales, 22.70), (v_pid, v_mxn, 85.22), (v_pid, v_pdo, 340.70), (v_pid, v_rublos, 400.66)
    ON CONFLICT (product_id, pricing_option_id) DO UPDATE SET amount = EXCLUDED.amount;

  RAISE NOTICE '47 productos importados correctamente.';
END $$;

-- ------------------------------------------------------------
-- FIN
-- ------------------------------------------------------------
