
export type Tariff = 'Zelle' | 'IBAN' | 'Bizum' | 'Posta' | 'Reales' | 'MXN' | 'PDO' | 'Rublos'
export type Product = {
  id: number
  name: string
  category: string
  description: string
  prices: Partial<Record<Tariff, number>>
  status: 'available' | 'check' | 'sold_out'
  image?: string
}

export const tariffs: Tariff[] = ['Zelle', 'IBAN', 'Bizum', 'Posta', 'Reales', 'MXN', 'PDO', 'Rublos']

// Muestras visuales solamente. Los precios definitivos se cargarán desde el catálogo validado.
export const demoProducts: Product[] = [
  { id: 1, name: 'Paquete de pollo 10 lb', category: 'Cárnicos', description: 'Paquete familiar. Consulta disponibilidad antes de confirmar.', prices: { Zelle: 14.70, IBAN: 14.50, Bizum: 14.63, Posta: 14.63, Reales: 84.87, MXN: 297.45, PDO: 1500, Rublos: 1630 }, status: 'available' },
  { id: 2, name: 'Carne de cerdo deshuesada 5 lb', category: 'Cárnicos', description: 'Presentación de 5 libras.', prices: { Zelle: 21.65, IBAN: 20.90, Bizum: 21.49, Posta: 21.54, Reales: 125, MXN: 48.2, PDO: 2031.25, Rublos: 2400 }, status: 'check' },
  { id: 3, name: 'Leche amarilla 1 kg', category: 'Productos lácteos', description: 'Consulta disponibilidad antes de confirmar.', prices: { Zelle: 9.62, IBAN: 9.38, Bizum: 9.50, Posta: 9.50, Reales: 56.91, MXN: 212.50, PDO: 489.5, Rublos: 1175.08 }, status: 'available' },
  { id: 4, name: 'Arroz 1 kg', category: 'Granos', description: 'Paquete de un kilogramo.', prices: { Zelle: 1.99, IBAN: 1.77, Bizum: 1.82, Posta: 1.82, Reales: 10.81, MXN: 52.70, PDO: 243.75, Rublos: 291.06 }, status: 'available' },
  { id: 5, name: 'Jabones de lavar', category: 'Aseo', description: 'Precio pendiente para algunas tarifas.', prices: { Zelle: 0.83, IBAN: 0.75, Bizum: 0.79, Posta: 0.79 }, status: 'check' },
  { id: 6, name: 'Aceite 900 ml', category: 'Otros', description: 'Botella de 900 ml.', prices: { Zelle: 5.35, IBAN: 4.85, Bizum: 5.23, Posta: 5.23, Reales: 27.27, MXN: 104.65, PDO: 399.70, Rublos: 470.80 }, status: 'available' }
]
