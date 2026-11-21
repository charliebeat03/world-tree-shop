-- World Tree: importación idempotente de los combos A-E de Susana.
-- Los combos y sus líneas/precios quedan en tablas normales y se pueden editar desde Admin.
-- Ejecutar una sola vez. Si se vuelve a ejecutar, restaura los contenidos/precios originales de Susana.
begin;

-- Añadir etiquetas de precio utilizadas por Susana sin alterar las opciones existentes.
do $$ declare r record; begin
  for r in select conname from pg_constraint where conrelid='public.pricing_options'::regclass and contype='c' and pg_get_constraintdef(oid) ilike '%code%' loop
    execute format('alter table public.pricing_options drop constraint %I', r.conname);
  end loop;
end $$;
alter table public.pricing_options add constraint pricing_options_code_check check (code in ('Zelle','IBAN','Bizum','Posta','Reales','MXN','PDO','Rublos','Guyana','Western'));
insert into public.pricing_options(code,display_name,sort_order,is_active) values ('Guyana','Guyana (DGY)',9,true),('Western','Western Union',10,true) on conflict(code) do update set display_name=excluded.display_name, is_active=true;

-- Crear solo los productos que no existan. Los ya existentes se reutilizan por slug.
insert into public.products(category_id,name,slug,description,status)
select c.id,v.name,v.slug,'Producto incorporado para los combos de Susana. Completar ficha, precio e imagen desde Administración.', 'check_availability'::public.product_status
from (values
  ('granos','Arroz 1 kg','arroz-1kg'),
  ('granos','Frijoles negros 1 kg','frijoles-negros-1kg'),
  ('granos','Azúcar 1 kg','azucar-1kg'),
  ('granos','Sal 2 lb','sal-2lb'),
  ('otros','Huevos (cartón de 30 unidades)','huevos-30u'),
  ('otros','Puré de tomate 500 g','pure-de-tomate-500g'),
  ('otros','Aceite 900 ml','aceite-900-ml-1u'),
  ('otros','Lata de Spam','lata-de-spam-1u'),
  ('granos','Espaguetis 500 g','espaguetis-500g'),
  ('confituras','Nutella','nutella-1u'),
  ('lacteos','Leche condensada','leche-condensada-1u'),
  ('carnicos','Paquete de pollo 10 lb','paquete-de-pollo-10lb'),
  ('carnicos','Jamón prensado 2 lb','jamon-prensado-2lb'),
  ('carnicos','Carne de res 5 lb','carne-de-res-5lb'),
  ('lacteos','Mantequilla 250 g','paquete-de-mantequilla-250g'),
  ('confituras','Galletas de soda (7 unidades)','galletas-de-soda-7u'),
  ('aseo','Jabón de baño 100 g','jabones-de-bano-1u'),
  ('lacteos','Leche amarilla 1 kg','leche-amarilla-1kg'),
  ('confituras','Malta Guajira (6 unidades)','malta-guajira-6u-pequenas'),
  ('lacteos','Queso blanco 2 lb','queso-blanco-2lb'),
  ('carnicos','Jamón Vicky 2 lb','jamon-vicky-2lb'),
  ('confituras','Pellys de queso','pelllys-de-queso-1u'),
  ('confituras','Gomitas','paquete-de-gomitas-1u'),
  ('carnicos','Carne de cerdo al corte 5 lb','carne-de-cerdo-al-corte-5lb'),
  ('otros','Café 250 g','paquete-de-cafe-250g'),
  ('otros','Sopitas','paquete-de-sopitas-1u'),
  ('aseo','Jabón de lavar','jabones-de-lavar'),
  ('aseo','Detergente 500 g','detergente-500g'),
  ('aseo','Juego de champú y suavizante','juego-champu-suavizante'),
  ('aseo','Colonias','colonias'),
  ('aseo','Paquetes de íntimas','paquetes-intimas'),
  ('aseo','Pasta dental','pasta-dental')
) as v(category_slug,name,slug)
join public.categories c on c.slug=v.category_slug
on conflict(slug) do nothing;

-- Crear/actualizar los cinco combos como publicados. Se podrán editar desde Admin.
insert into public.combos(name,slug,description,status,sort_order)
values
  ('Combo A','combo-a','Combo A de Susana. Incluye los productos y cantidades registrados en su composición original.','available'::public.combo_status,1),
  ('Combo B','combo-b','Combo B de Susana. Incluye los productos y cantidades registrados en su composición original.','available'::public.combo_status,2),
  ('Combo C','combo-c','Combo C de Susana. Incluye los productos y cantidades registrados en su composición original.','available'::public.combo_status,3),
  ('Combo D','combo-d','Combo D de Susana. Incluye los productos y cantidades registrados en su composición original.','available'::public.combo_status,4),
  ('Combo E','combo-e','Combo E de Susana. Incluye los productos y cantidades registrados en su composición original.','available'::public.combo_status,5)
on conflict(slug) do update set name=excluded.name, description=excluded.description, status='available', sort_order=excluded.sort_order, updated_at=now();

-- Sustituir las líneas y precios de estos combos por la composición exacta importada.
delete from public.combo_items where combo_id in (select id from public.combos where slug in ('combo-a','combo-b','combo-c','combo-d','combo-e'));
delete from public.combo_prices where combo_id in (select id from public.combos where slug in ('combo-a','combo-b','combo-c','combo-d','combo-e'));

insert into public.combo_items(combo_id,product_id,quantity)
select c.id,p.id,v.quantity
from (values
  ('combo-a','arroz-1kg',2),
  ('combo-a','frijoles-negros-1kg',2),
  ('combo-a','huevos-30u',1),
  ('combo-a','espaguetis-500g',2),
  ('combo-a','nutella-1u',1),
  ('combo-a','leche-condensada-1u',1),
  ('combo-a','pure-de-tomate-500g',1),
  ('combo-a','lata-de-spam-1u',1),
  ('combo-a','azucar-1kg',2),
  ('combo-a','paquete-de-cafe-250g',1),
  ('combo-a','aceite-900-ml-1u',2),
  ('combo-a','paquete-de-pollo-10lb',1),
  ('combo-a','jamon-prensado-2lb',2),
  ('combo-b','arroz-1kg',4),
  ('combo-b','frijoles-negros-1kg',2),
  ('combo-b','carne-de-res-5lb',1),
  ('combo-b','aceite-900-ml-1u',1),
  ('combo-b','pure-de-tomate-500g',1),
  ('combo-b','paquete-de-mantequilla-250g',1),
  ('combo-b','galletas-de-soda-7u',1),
  ('combo-b','leche-condensada-1u',1),
  ('combo-b','jabones-de-bano-1u',2),
  ('combo-c','aceite-900-ml-1u',1),
  ('combo-c','leche-amarilla-1kg',1),
  ('combo-c','huevos-30u',1),
  ('combo-c','malta-guajira-6u-pequenas',2),
  ('combo-c','paquete-de-mantequilla-250g',1),
  ('combo-c','galletas-de-soda-7u',2),
  ('combo-c','queso-blanco-2lb',1),
  ('combo-c','jamon-vicky-2lb',1),
  ('combo-c','pelllys-de-queso-1u',5),
  ('combo-c','paquete-de-gomitas-1u',3),
  ('combo-d','arroz-1kg',4),
  ('combo-d','carne-de-cerdo-al-corte-5lb',1),
  ('combo-d','aceite-900-ml-1u',1),
  ('combo-d','pure-de-tomate-500g',1),
  ('combo-d','azucar-1kg',2),
  ('combo-d','leche-amarilla-1kg',1),
  ('combo-d','jamon-prensado-2lb',1),
  ('combo-d','paquete-de-cafe-250g',2),
  ('combo-d','paquete-de-sopitas-1u',2),
  ('combo-d','sal-2lb',2),
  ('combo-d','jabones-de-bano-1u',3),
  ('combo-d','jabones-de-lavar',3),
  ('combo-d','detergente-500g',1),
  ('combo-e','jabones-de-bano-1u',5),
  ('combo-e','jabones-de-lavar',5),
  ('combo-e','detergente-500g',5),
  ('combo-e','juego-champu-suavizante',2),
  ('combo-e','colonias',2),
  ('combo-e','paquetes-intimas',2),
  ('combo-e','pasta-dental',2)
) as v(combo_slug,product_slug,quantity)
join public.combos c on c.slug=v.combo_slug
join public.products p on p.slug=v.product_slug;

insert into public.combo_prices(combo_id,pricing_option_id,amount)
select c.id,o.id,v.amount
from (values
  ('combo-a','Zelle',76.24),
  ('combo-a','IBAN',69.85),
  ('combo-a','Bizum',73.52),
  ('combo-a','Posta',73.52),
  ('combo-a','Guyana',19300),
  ('combo-a','Reales',401.7),
  ('combo-a','MXN',1413.41),
  ('combo-a','Western',80.94),
  ('combo-b','Zelle',45.7),
  ('combo-b','IBAN',38.89),
  ('combo-b','Bizum',40.75),
  ('combo-b','Posta',40.75),
  ('combo-b','Guyana',11750),
  ('combo-b','Reales',216.68),
  ('combo-b','MXN',844.9),
  ('combo-b','Western',57.4),
  ('combo-c','Zelle',65.59),
  ('combo-c','IBAN',60.51),
  ('combo-c','Bizum',63.49),
  ('combo-c','Posta',63.49),
  ('combo-c','Guyana',14600),
  ('combo-c','Reales',289.09),
  ('combo-c','MXN',1254),
  ('combo-c','Western',77.2),
  ('combo-d','Zelle',68.01),
  ('combo-d','IBAN',63.82),
  ('combo-d','Bizum',66.91),
  ('combo-d','Posta',66.91),
  ('combo-d','Guyana',15200),
  ('combo-d','Reales',289.6),
  ('combo-d','MXN',1331),
  ('combo-d','Western',79.4),
  ('combo-e','Zelle',46.93),
  ('combo-e','IBAN',43.0),
  ('combo-e','Bizum',44.41),
  ('combo-e','Posta',44.41),
  ('combo-e','Guyana',16450),
  ('combo-e','Reales',138.81),
  ('combo-e','Western',58.7)
) as v(combo_slug,price_code,amount)
join public.combos c on c.slug=v.combo_slug
join public.pricing_options o on o.code=v.price_code;

commit;
