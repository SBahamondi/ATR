-- ============================================================================
-- ATR PROTOTYPE v3.0 - Script SQL Completo para Supabase (corregido)
-- ============================================================================
-- Copia TODO este contenido y pégalo en Supabase → SQL Editor → New Query
-- Luego haz clic en "Run" (play button)
--
-- Cambios respecto a la versión anterior:
--  * Ya no se asumen IDs fijos: las relaciones se resuelven por username/título.
--  * tutored_students se calcula a partir de los adolescentes realmente creados.
--  * student_applications queda coherente con las asignaciones (ver final).
--  * Una postulación = una fila en assignments con status 'pending'.
--  * Restricción UNIQUE (offer_id, student_id) para evitar postulaciones duplicadas.
--  * Trigger que mantiene updated_at.
--  * CHECK de formato HH:MM y de franja permitida 08:00-20:00 en offers.
--  * Triggers de roles: employer_id debe ser empleador, student_id adolescente y tutor_id tutor.
-- ============================================================================

DROP TABLE IF EXISTS assignments CASCADE;
DROP TABLE IF EXISTS offers CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================================================
-- TABLA 1: USERS
-- ============================================================================
CREATE TABLE users (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  role TEXT NOT NULL CHECK (role IN ('tutor', 'teen', 'employer')),
  username TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  email TEXT,

  -- Tutor Legal
  full_name TEXT,
  birth_date DATE,
  dni TEXT,
  tutored_students TEXT[] DEFAULT ARRAY[]::TEXT[],

  -- Adolescente
  tutor_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
  tutor_username TEXT,
  school_start TEXT,
  school_end TEXT,
  skills TEXT[] DEFAULT ARRAY[]::TEXT[],
  applications TEXT[] DEFAULT ARRAY[]::TEXT[],

  -- Empleador
  company_name TEXT,
  phone TEXT,
  description TEXT,
  contact_name TEXT,
  verified BOOLEAN DEFAULT false,
  banned_categories TEXT[] DEFAULT ARRAY[]::TEXT[],

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_tutor_id ON users(tutor_id);
CREATE INDEX idx_users_email ON users(email);
CREATE UNIQUE INDEX idx_users_username_lower ON users(LOWER(username));

-- ============================================================================
-- TABLA 2: OFFERS
-- ============================================================================
CREATE TABLE offers (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  employer_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('tutoria', 'diseno', 'edicion', 'programacion', 'redaccion', 'apoyo_escolar')),
  description TEXT,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  pay INTEGER NOT NULL CHECK (pay > 0),
  company_name TEXT,
  student_applications TEXT[] DEFAULT ARRAY[]::TEXT[],

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  CHECK (start_time ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$' AND end_time ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'),
  CHECK (start_time < end_time),
  -- Descanso obligatorio 20:00-08:00: la oferta debe caer dentro de 08:00-20:00
  CHECK (start_time >= '08:00' AND end_time <= '20:00')
);

CREATE INDEX idx_offers_employer_id ON offers(employer_id);
CREATE INDEX idx_offers_category ON offers(category);
CREATE INDEX idx_offers_created_at ON offers(created_at DESC);

-- ============================================================================
-- TABLA 3: ASSIGNMENTS (postulaciones y asignaciones)
-- ============================================================================
CREATE TABLE assignments (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  offer_id BIGINT NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
  student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE (offer_id, student_id)
);

CREATE INDEX idx_assignments_student_id ON assignments(student_id);
CREATE INDEX idx_assignments_offer_id ON assignments(offer_id);
CREATE INDEX idx_assignments_status ON assignments(status);

-- ============================================================================
-- TRIGGER updated_at
-- ============================================================================
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_offers_updated BEFORE UPDATE ON offers
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_assignments_updated BEFORE UPDATE ON assignments
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- TRIGGERS DE ROLES (integridad entre tablas)
-- ============================================================================
CREATE OR REPLACE FUNCTION check_user_roles() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tutor_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM users WHERE id = NEW.tutor_id AND role = 'tutor') THEN
    RAISE EXCEPTION 'tutor_id debe referenciar a un usuario con rol tutor';
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_offer_employer() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM users WHERE id = NEW.employer_id AND role = 'employer') THEN
    RAISE EXCEPTION 'Solo un usuario con rol employer puede publicar ofertas';
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_assignment_student() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM users WHERE id = NEW.student_id AND role = 'teen') THEN
    RAISE EXCEPTION 'Solo un adolescente (teen) puede postularse';
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_roles BEFORE INSERT OR UPDATE OF tutor_id ON users
  FOR EACH ROW EXECUTE FUNCTION check_user_roles();
CREATE TRIGGER trg_offers_employer BEFORE INSERT OR UPDATE OF employer_id ON offers
  FOR EACH ROW EXECUTE FUNCTION check_offer_employer();
CREATE TRIGGER trg_assignments_student BEFORE INSERT OR UPDATE OF student_id ON assignments
  FOR EACH ROW EXECUTE FUNCTION check_assignment_student();

-- ============================================================================
-- DATOS DE PRUEBA: TUTORES
-- ============================================================================
INSERT INTO users (role, username, password, email, full_name, birth_date, dni)
VALUES
  ('tutor', 'ana.garcia',    'Tutor2024!', 'ana@email.com',     'Ana García López',        '1985-03-22', '30123456'),
  ('tutor', 'roberto.lopez', 'Tutor2024!', 'roberto@email.com', 'Roberto López Fernández', '1980-07-15', '25111111');

-- ============================================================================
-- DATOS DE PRUEBA: ADOLESCENTES (tutor resuelto por username)
-- ============================================================================
INSERT INTO users (role, username, password, full_name, dni, tutor_id, tutor_username, school_start, school_end, skills)
SELECT 'teen', 'juan_talento', 'Teen2024!', 'Juan Pérez García', '55123456',
       t.id, t.username, '07:30', '13:00', ARRAY['diseño', 'edición']::TEXT[]
FROM users t WHERE t.username = 'ana.garcia';

INSERT INTO users (role, username, password, full_name, dni, tutor_id, tutor_username, school_start, school_end, skills)
SELECT 'teen', 'maria_creativa', 'Teen2024!', 'María Pérez García', '55123457',
       t.id, t.username, '08:00', '13:30', ARRAY['redacción', 'diseño']::TEXT[]
FROM users t WHERE t.username = 'ana.garcia';

INSERT INTO users (role, username, password, full_name, dni, tutor_id, tutor_username, school_start, school_end, skills)
SELECT 'teen', 'lucas_musician', 'Teen2024!', 'Lucas Flores López', '58234567',
       t.id, t.username, '07:00', '12:30', ARRAY['programación', 'tutorías']::TEXT[]
FROM users t WHERE t.username = 'roberto.lopez';

-- tutored_students calculado a partir de los adolescentes reales
UPDATE users t
SET tutored_students = COALESCE(
  (SELECT ARRAY_AGG(s.id::TEXT ORDER BY s.id) FROM users s WHERE s.tutor_id = t.id),
  ARRAY[]::TEXT[]
)
WHERE t.role = 'tutor';

-- ============================================================================
-- DATOS DE PRUEBA: EMPLEADORES
-- ============================================================================
INSERT INTO users (role, username, password, email, company_name, phone, description, contact_name, dni, verified)
VALUES
  ('employer', 'techstart.studio', 'Employer2024!', 'carlos@techstart.com',
   'TechStart Studio', '351 555 1234',
   'Estudio especializado en diseño gráfico, desarrollo web y edición de contenidos digitales',
   'Carlos García Martínez', '25987654', true),
  ('employer', 'academia.plus', 'Employer2024!', 'sofia@academiaplus.com',
   'Academia Virtual Plus', '0221 3333-2222',
   'Plataforma de educación virtual ofreciendo tutoría académica, apoyo escolar y redacción de trabajos',
   'Sofia Martínez González', '38456789', true);

-- ============================================================================
-- OFERTAS (employer resuelto por username)
-- ============================================================================
INSERT INTO offers (employer_id, title, category, description, start_time, end_time, pay, company_name)
SELECT u.id, v.title, v.category, v.description, v.start_time, v.end_time, v.pay, u.company_name
FROM (VALUES
  ('techstart.studio', 'Diseño gráfico para proyecto web', 'diseno',
   'Necesitamos crear mockups de interfaz UI/UX para plataforma web. Trabajo en Figma. Ideal para aprender diseño real.',
   '15:00', '17:00', 250),
  ('techstart.studio', 'Edición de video para redes sociales', 'edicion',
   'Editar videos cortos (reels) para Instagram y TikTok. Uso de Adobe Premiere o equivalente. 5-6 videos semanales.',
   '16:00', '18:00', 200),
  ('academia.plus', 'Tutoría de Matemáticas nivel secundario', 'tutoria',
   'Clases particulares de matemática para estudiantes de 1er a 3er año. Sesiones de 1 hora. Requiere disponibilidad flexible.',
   '14:00', '15:30', 300),
  ('academia.plus', 'Apoyo escolar en Lengua y Literatura', 'apoyo_escolar',
   'Ayuda a estudiantes con comprensión de lecturas, análisis de obras literarias y redacción. Sesiones online.',
   '15:00', '16:00', 200),
  ('techstart.studio', 'Programación web frontend (React)', 'programacion',
   'Proyecto pequeño frontend en React. Ideal para practicar componentes, hooks y API REST. Proyecto portfolio-friendly.',
   '17:00', '19:00', 400),
  ('academia.plus', 'Redacción de ensayos académicos', 'redaccion',
   'Ayudar a estudiantes a estructurar y redactar ensayos. Revisión de ortografía y coherencia. Remoto, horario flexible.',
   '14:00', '15:00', 180)
) AS v(employer_username, title, category, description, start_time, end_time, pay)
JOIN users u ON u.username = v.employer_username;

-- ============================================================================
-- ASIGNACIONES (resueltas por username y título)
-- ============================================================================
INSERT INTO assignments (offer_id, student_id, status)
SELECT o.id, s.id, 'approved'
FROM users s, offers o
WHERE s.username = 'juan_talento' AND o.title = 'Diseño gráfico para proyecto web';

INSERT INTO assignments (offer_id, student_id, status)
SELECT o.id, s.id, 'approved'
FROM users s, offers o
WHERE s.username = 'maria_creativa' AND o.title = 'Edición de video para redes sociales';

-- Coherencia de los arrays de apoyo con assignments
UPDATE offers o
SET student_applications = COALESCE(
  (SELECT ARRAY_AGG(a.student_id::TEXT ORDER BY a.student_id) FROM assignments a WHERE a.offer_id = o.id),
  ARRAY[]::TEXT[]
);

UPDATE users u
SET applications = COALESCE(
  (SELECT ARRAY_AGG(a.offer_id::TEXT ORDER BY a.offer_id) FROM assignments a WHERE a.student_id = u.id),
  ARRAY[]::TEXT[]
)
WHERE u.role = 'teen';

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================
SELECT id, username, role, full_name, company_name, tutor_id, tutored_students FROM users ORDER BY id;
SELECT o.id, o.title, o.category, u.username AS employer, o.start_time, o.end_time FROM offers o JOIN users u ON u.id = o.employer_id ORDER BY o.id;
SELECT a.id, o.title, s.username AS student, a.status
FROM assignments a
JOIN offers o ON a.offer_id = o.id
JOIN users s ON a.student_id = s.id
ORDER BY a.id;

-- Resultado esperado: 7 usuarios (2 tutores + 3 adolescentes + 2 empleadores),
-- 6 ofertas y 2 asignaciones aprobadas (Juan → Diseño, María → Edición).
