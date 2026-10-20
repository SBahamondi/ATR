-- ATR · Cambios OPCIONALES y ADITIVOS para Supabase (NO ejecutados, solo para revisión).
-- La app actual funciona SIN ejecutar nada de esto. No borra ni modifica datos existentes.
-- Sirven para mostrar en las tarjetas lo que el diseño de Canva prevé (modalidad, dirección, etiquetas).

-- 1) Modalidad, ubicación y etiquetas de cada oferta
ALTER TABLE offers ADD COLUMN IF NOT EXISTS modality TEXT
  CHECK (modality IN ('virtual','presencial','mixto'));          -- NULL = sin dato (ofertas existentes)
ALTER TABLE offers ADD COLUMN IF NOT EXISTS location_text TEXT;  -- dirección aproximada (para enlace a Maps)
ALTER TABLE offers ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT ARRAY[]::TEXT[];

-- 2) Perfil del adolescente (Edad, Dirección, Descripción, Notas del Canva)
ALTER TABLE users ADD COLUMN IF NOT EXISTS birth_date_teen DATE;   -- opcional: calcular edad
ALTER TABLE users ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS bio TEXT;

-- 3) Verificación (ya existente, manual):
-- UPDATE users SET verified = true WHERE username = 'nombre_de_usuario_de_la_empresa';

-- NO INCLUIDO a propósito (requiere decisión tuya): activar RLS + Supabase Auth, métodos de pago,
-- historial de trabajo con reseñas, límites 6 h/día y 36 h/semana.
