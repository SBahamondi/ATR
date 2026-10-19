# 🏗️ Arquitectura Técnica - ATR v3.0

## 📐 Diagrama General

```
┌─────────────────────────────────────────────────────────┐
│                 NAVEGADOR (Cliente)                      │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │   atr-prototype-v3.html (SPA - Vanilla JS)         │ │
│  │                                                    │ │
│  │  ┌─────────────┐  ┌──────────────┐  ┌───────────┐ │ │
│  │  │  Router     │  │  State Mgmt  │  │  Render   │ │ │
│  │  │             │  │              │  │  Engine   │ │ │
│  │  │ - Login     │  │ - currentUser│  │           │ │ │
│  │  │ - Register  │  │ - allUsers   │  │ - Dynamic │ │ │
│  │  │ - Dashboard │  │ - allOffers  │  │   HTML    │ │ │
│  │  │ - Calendar  │  │ - allAssign  │  │           │ │ │
│  │  └─────────────┘  └──────────────┘  └───────────┘ │ │
│  │                                                    │ │
│  │  ┌────────────────────────────────────────────┐   │ │
│  │  │  Supabase JavaScript Client (v2.39.0)    │   │ │
│  │  │                                            │   │ │
│  │  │  - createClient()                          │   │ │
│  │  │  - supabase.from('table').select/insert   │   │ │
│  │  └────────────────────────────────────────────┘   │ │
│  └────────────────────────────────────────────────────┘ │
│                          ▲                               │
│                          │ HTTP/HTTPS                    │
│                          │                               │
│                          ▼                               │
│              ┌───────────────────────┐                  │
│              │  Supabase JS SDK      │                  │
│              │  (esm.sh)             │                  │
│              └───────────────────────┘                  │
└─────────────────────────────────────────────────────────┘
                          │
                          │ HTTPS API Calls
                          │ REST/PostgREST
                          ▼
    ┌──────────────────────────────────────────────┐
    │         SUPABASE (Backend/DB)                │
    │  https://uhaoomiguwssiqnkecec.supabase.co   │
    │                                              │
    │  ┌──────────────────────────────────────┐   │
    │  │   PostgREST API Gateway              │   │
    │  │                                      │   │
    │  │   GET  /rest/v1/users               │   │
    │  │   POST /rest/v1/users               │   │
    │  │   GET  /rest/v1/offers              │   │
    │  │   POST /rest/v1/assignments         │   │
    │  └──────────────────────────────────────┘   │
    │                  │                          │
    │                  ▼                          │
    │  ┌──────────────────────────────────────┐   │
    │  │   PostgreSQL Database                │   │
    │  │                                      │   │
    │  │   ┌─────────────────────────────┐   │   │
    │  │   │ TABLE: users                │   │   │
    │  │   │ - id, role, username        │   │   │
    │  │   │ - full_name, email, dni     │   │   │
    │  │   │ - (+ campos específicos/rol)│   │   │
    │  │   └─────────────────────────────┘   │   │
    │  │                                      │   │
    │  │   ┌─────────────────────────────┐   │   │
    │  │   │ TABLE: offers               │   │   │
    │  │   │ - id, employer_id, title    │   │   │
    │  │   │ - category, start_time      │   │   │
    │  │   │ - end_time, pay             │   │   │
    │  │   └─────────────────────────────┘   │   │
    │  │                                      │   │
    │  │   ┌─────────────────────────────┐   │   │
    │  │   │ TABLE: assignments          │   │   │
    │  │   │ - id, offer_id, student_id  │   │   │
    │  │   │ - status (pending/approved) │   │   │
    │  │   └─────────────────────────────┘   │   │
    │  └──────────────────────────────────────┘   │
    └──────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Datos

### 1. Registro de Usuario

```
┌─────────────────────────────────────────────────┐
│ Usuario llena formulario de registro            │
│ (Tutor/Teen/Employer)                           │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ Validaciones en Frontend (JavaScript)           │
│ - Email válido                                  │
│ - Contraseña ≥ 8 caracteres                    │
│ - Username único (búsqueda en BD)               │
│ - Edad ≥ 18 para Tutor                          │
│ - Formato de username (3-30, [A-Za-z0-9._-])    │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ supabase.from('users').insert({payload})        │
│ POST a PostgREST API                            │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ PostgreSQL inserta nuevo registro               │
│ (rol, username, password, datos específicos)    │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ Supabase retorna user object con ID             │
│ Frontend vuelve al login con mensaje de éxito   │
└─────────────────────────────────────────────────┘
```

### 2. Login

```
┌─────────────────────────────────────────────────┐
│ Usuario ingresa username + password             │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ SELECT * FROM users                             │
│ WHERE username ILIKE 'ana.garcia'               │
│ (comodines escapados; se compara sin distinguir │
│  mayúsculas en el cliente)                      │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ Comparar password (texto plano en prototipo)    │
│ ⚠️ En producción: bcrypt/argon2                │
└──────────────┬──────────────────────────────────┘
               │
               ▼ Si coincide:
┌─────────────────────────────────────────────────┐
│ localStorage.setItem('atr_session', {...})      │
│ Establecer state.currentUser                    │
│ Renderizar Dashboard                            │
└─────────────────────────────────────────────────┘
```

### 3. Crear Oferta (Empleador)

```
┌─────────────────────────────────────────────────┐
│ Empleador completa formulario:                  │
│ - Título, categoría, descripción                │
│ - Horario inicio/fin, paga                      │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ Validaciones:                                   │
│ - Categoría en lista permitida                  │
│ - start_time < end_time                         │
│ - pay > 0                                       │
│ - Fuera de la franja nocturna 20:00-08:00       │
│   (construcción/carga/químicos no están en la   │
│   lista de categorías)                          │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ INSERT INTO offers (...)                        │
│ employer_id = currentUser.id                    │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ Oferta visible en catálogo para adolescentes    │
└─────────────────────────────────────────────────┘
```

### 4. Postulación (Adolescente)

```
┌─────────────────────────────────────────────────┐
│ Adolescente ve oferta                           │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ checkOfferCompat(teen, offer):                  │
│  1. ¿Categoría permitida?                       │
│  2. ¿Solapa con el horario escolar?             │
│  3. ¿Solapa con 20:00-08:00?                    │
│  4. ¿Solapa con un trabajo YA APROBADO?         │
│  Cualquier "sí" → Badge "🚫 Conflicto" + motivo,│
│  sin botón "Postularme".                        │
│  Todo "no" → Badge "✓ Compatible" + botón.      │
└──────────────┬──────────────────────────────────┘
               │ clic en "Postularme"
               ▼
┌─────────────────────────────────────────────────┐
│ INSERT INTO assignments                         │
│   (offer_id, student_id, status='pending')      │
│ UNIQUE(offer_id, student_id) impide duplicados  │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ syncApplicationArrays (espejo informativo):     │
│  - offers.student_applications += student_id    │
│  - users.applications          += offer_id      │
│ (best-effort: si falla, assignments sigue       │
│  siendo la fuente de verdad)                    │
└─────────────────────────────────────────────────┘
```

> No hay notificaciones al tutor: lo ve en la pestaña "Postulaciones".

### 5. Aprobación / rechazo por Tutor

```
┌─────────────────────────────────────────────────┐
│ Tutor ve en "Postulaciones" las filas de        │
│ assignments de sus menores (tutor_id = su id)   │
└──────────────┬──────────────────────────────────┘
               │
       ┌───────┴────────┐
       ▼                ▼
   "Aprobar"        "Rechazar"
       │                │
       ▼                ▼
┌──────────────┐  UPDATE assignments
│ Revalida:    │  SET status='rejected'
│ categoría,   │
│ escuela,     │
│ 20:00-08:00, │
│ otros        │
│ aprobados    │
└──────┬───────┘
       │ ¿conflicto? → alerta con el motivo y NO aprueba
       ▼
UPDATE assignments SET status='approved'
       │
       ▼
Trabajo en el Calendario del adolescente, del tutor
y del empleador (💼 Diseño gráfico 15:00-17:00)
```

El empleador no asigna ni aprueba. Las ofertas no tienen fecha, por lo que el calendario repite cada trabajo aprobado todos los días de la semana mostrada.

---

## 🔐 Manejo de Sesión

### localStorage

```javascript
// Al hacer login:
localStorage.setItem('atr_session', JSON.stringify({
  id: 1,
  username: 'ana.garcia',
  role: 'tutor',
  fullName: 'Ana García López'
}))

// Al cargar la app (init): se lee la sesión, se cargan los datos y se
// vuelve a buscar el usuario por id; si ya no existe, se limpia la sesión
const session = JSON.parse(localStorage.getItem('atr_session') || 'null')
if(session){
  await loadAllData()
  state.currentUser = state.allUsers.find(u => u.id === session.id) || null
  if(!state.currentUser) localStorage.removeItem('atr_session')
}

// Al logout:
localStorage.removeItem('atr_session')
```

---

## 🗄️ Estructura de Tablas

Resumen; el detalle columna por columna está en `SETUP-SUPABASE.md` y el DDL real en `supabase-setup.sql`.

### Tabla: users (una sola tabla para los 3 roles)

```sql
CREATE TABLE users (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  role TEXT NOT NULL CHECK (role IN ('tutor','teen','employer')),
  username TEXT NOT NULL UNIQUE,          -- además índice único sobre LOWER(username)
  password TEXT NOT NULL,                 -- texto plano (deuda de seguridad conocida)
  email TEXT, dni TEXT,
  full_name TEXT, birth_date DATE,        -- tutor / teen
  tutored_students TEXT[],                -- tutor
  tutor_id BIGINT REFERENCES users(id) ON DELETE SET NULL,  -- teen
  tutor_username TEXT, school_start TEXT, school_end TEXT,
  skills TEXT[],                          -- reservado
  applications TEXT[],                    -- espejo de assignments
  company_name TEXT, phone TEXT, description TEXT, contact_name TEXT,  -- employer
  verified BOOLEAN DEFAULT false,
  banned_categories TEXT[],               -- reservado
  created_at TIMESTAMPTZ, updated_at TIMESTAMPTZ   -- updated_at por trigger
);
```

### Tabla: offers

```sql
CREATE TABLE offers (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  employer_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT, description TEXT, company_name TEXT,
  category TEXT CHECK (category IN ('tutoria','diseno','edicion','programacion','redaccion','apoyo_escolar')),
  start_time TEXT, end_time TEXT,         -- 'HH:MM'
  pay INTEGER CHECK (pay > 0),
  student_applications TEXT[],            -- espejo de assignments
  created_at TIMESTAMPTZ, updated_at TIMESTAMPTZ,
  CHECK (start_time < end_time),
  CHECK (start_time >= '08:00' AND end_time <= '20:00')
);
```

### Tabla: assignments (fuente de verdad de postulaciones y asignaciones)

```sql
CREATE TABLE assignments (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  offer_id BIGINT NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
  student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  created_at TIMESTAMPTZ, updated_at TIMESTAMPTZ,
  UNIQUE (offer_id, student_id)
);
```

### Triggers

| Trigger | Efecto |
|---------|--------|
| `set_updated_at` (en las 3 tablas) | Actualiza `updated_at` en cada UPDATE |
| `check_user_roles` | `users.tutor_id` debe apuntar a un usuario con rol `tutor` |
| `check_offer_employer` | `offers.employer_id` debe ser un usuario `employer` |
| `check_assignment_student` | `assignments.student_id` debe ser un usuario `teen` |

---

## 🔄 Ciclo de Vida del Estado (State Management)

```javascript
state = {
  // Pantalla: 'login' | 'roleSelect' | 'registerTutor' | 'registerTeen' | 'registerEmployer'
  // (con sesión iniciada siempre se muestra el dashboard)
  screen: 'login',

  // Usuario actual: la fila completa de `users` (snake_case: full_name, school_start, ...)
  currentUser: null,

  // Pestaña del dashboard según rol:
  //  tutor: dashboard | applications | calendar | settings
  //  teen: dashboard | offers | calendar | profile
  //  employer: dashboard | offers (Mis ofertas) | create | calendar
  currentTab: 'dashboard',

  // Semana del calendario y filtro de ofertas
  calendarWeekStart: Date,
  offerFilter: 'all',

  // Datos de Supabase (en memoria)
  allUsers: [], allOffers: [], allAssignments: [],

  // Mensaje de éxito para mostrar tras registrarse
  flash: ''
}
```

---

## 🔌 Conexión Supabase

### Inicialización

```javascript
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

const supabase = createClient(
  'https://uhaoomiguwssiqnkecec.supabase.co',
  'eyJhbGc...' // API Key anon
)
```

### Operaciones CRUD

```javascript
// SELECT
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('id', 1)

// INSERT
const { data } = await supabase
  .from('users')
  .insert([{ role: 'tutor', username: 'xxx', ... }])
  .select()

// UPDATE
const { data } = await supabase
  .from('assignments')
  .update({ status: 'approved' })
  .eq('id', 1)
  .select()

// DELETE
await supabase
  .from('assignments')
  .delete()
  .eq('id', 1)
```

---

## ⚡ Performance

### Índices en PostgreSQL

```sql
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_tutor_id ON users(tutor_id);
CREATE INDEX idx_users_email ON users(email);
CREATE UNIQUE INDEX idx_users_username_lower ON users(LOWER(username));
CREATE INDEX idx_offers_employer_id ON offers(employer_id);
CREATE INDEX idx_offers_category ON offers(category);
CREATE INDEX idx_offers_created_at ON offers(created_at DESC);
CREATE INDEX idx_assignments_student_id ON assignments(student_id);
CREATE INDEX idx_assignments_offer_id ON assignments(offer_id);
CREATE INDEX idx_assignments_status ON assignments(status);
```

### Carga de Datos

```javascript
// Al iniciar sesión se cargan las 3 tablas; si una consulta falla se
// conservan los datos que ya había en memoria (no se vacía el estado)
async function loadAllData(){
  const results = await Promise.allSettled([
    supabase.from('users').select('*'),
    supabase.from('offers').select('*').order('id'),
    supabase.from('assignments').select('*').order('id')
  ])
  // pick(result, nombre, valorPrevio) → data, o el valor previo si hubo error
}

// Luego se filtra en memoria
const myOffers = state.allOffers.filter(o => o.employer_id === userId)
```

---

## 🎯 Validaciones (3 Capas)

### 1. Frontend (JavaScript)
- Email válido, contraseña ≥ 8, usuario con formato válido y único, tutor ≥ 18
- Horarios: `checkOfferCompat` (categoría, escuela, descanso 20:00-08:00, otros trabajos aprobados) y `timeSlotCollides`, que parte los rangos que cruzan medianoche
- Revalidación al aprobar y al editar el horario escolar

### 2. Base de Datos (SQL)
- CHECK: rol, categoría, estado, `pay > 0`, formato HH:MM, `start_time < end_time` y franja 08:00-20:00
- UNIQUE: username (sin distinguir mayúsculas) y `(offer_id, student_id)`
- FK y NOT NULL en campos obligatorios
- Triggers de rol (empleador / adolescente / tutor) y de `updated_at`

### 3. Supabase API
- Row Level Security y Supabase Auth: **no implementados** (seguridad fuera de alcance por ahora, ver abajo)

---

## 🔒 Seguridad Actual vs. Producción (pendiente)

### ⚠️ Prototipo (Actual)
```javascript
// ❌ Inseguro
password: 'Tutor2024!' // Texto plano en DB
// ❌ Sin autenticación
auth: false // Confía en localStorage
// ❌ API Key pública
SUPABASE_KEY: 'eyJhb...' // Visible en HTML
```

### ✅ Producción (Recomendado)
```javascript
// ✓ Hash de contraseñas
password: bcrypt.hash('Tutor2024!') // bcrypt/argon2
// ✓ Supabase Auth
user = await supabase.auth.signInWithPassword()
// ✓ JWT tokens
token = session.access_token // Temporal
// ✓ Row Level Security
CREATE POLICY "Users see own data" ON users
  USING (auth.uid() = id)
```

---

## 📱 Responsividad

```css
/* Desktop */
.dashboard { display: flex; gap: 24px; }
.sidebar { width: 240px; }

/* Tablet */
@media(max-width:1024px){
  .dashboard { flex-direction: column; }
  .sidebar { width: 100%; }
}

/* Mobile */
@media(max-width:768px){
  .main { padding: 16px; }
  .sidebar-item { padding: 12px; }
}
```

---

## 📊 Escalabilidad

### Límites Actuales
- 100 usuarios: ✓ Sin problemas
- 1,000 usuarios: ✓ Sin problemas
- 10,000 usuarios: ⚠️ Puede ralentizar loadAllData()
- 100,000 usuarios: ❌ Necesita paginación

### Mejoras para Escalar
```javascript
// En lugar de select('*'), paginar en bloques:
const { data } = await supabase
  .from('users')
  .select('*')
  .range(0, 99) // Primeros 100; pedir el siguiente bloque con range(100, 199)
```

---

**Versión:** 3.0  
**Última actualización:** Octubre 2026  
**Stack:** Vanilla JS + Supabase + PostgreSQL
