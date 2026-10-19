# 🔌 Referencia API REST - Supabase PostgREST

## 📋 Índice Rápido

- [Conceptos Básicos](#conceptos-básicos)
- [CRUD Operations](#crud-operations)
- [Filtros Comunes](#filtros-comunes)
- [Queries Avanzadas](#queries-avanzadas)
- [Ejemplos Reales](#ejemplos-reales)
- [Troubleshooting](#troubleshooting)

---

## 🏗️ Conceptos Básicos

### URL Base
```
https://uhaoomiguwssiqnkecec.supabase.co/rest/v1/
```

### Headers Requeridos
```javascript
{
  'apikey': 'YOUR_ANON_KEY',
  'Authorization': 'Bearer YOUR_ANON_KEY',
  'Content-Type': 'application/json'
}
```

> Con el SDK (`createClient(url, key)`) los headers se agregan solos. La app usa la clave `anon` embebida en el HTML.

### Formato de Respuesta

- **SDK:** cada consulta devuelve `{ data, error }`. Si `error` no es `null`, `data` es `null`.
- **REST directo:** el cuerpo es el JSON de las filas (array) y el resultado se indica con el código HTTP (200, 201, 4xx...). Para que un `POST`/`PATCH` devuelva la fila hay que enviar `Prefer: return=representation` (el SDK lo hace con `.select()`).

---

## 📝 CRUD Operations

### CREATE (INSERT)

#### Opción 1: Supabase JS SDK (Recomendado en ATR)
```javascript
const { data, error } = await supabase
  .from('users')
  .insert([{
    role: 'tutor',
    username: 'ana.garcia',
    password: 'Tutor2024!',
    email: 'ana@email.com',
    full_name: 'Ana García López',
    birth_date: '1985-03-22',
    dni: '30123456'
  }])
  .select()

if(error) console.error(error)
else console.log('Nuevo usuario:', data)
```

#### Opción 2: HTTP REST directo
```bash
curl -X POST \
  'https://uhaoomiguwssiqnkecec.supabase.co/rest/v1/users' \
  -H 'apikey: YOUR_ANON_KEY' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -H 'Prefer: return=representation' \
  -d '{
    "role": "tutor",
    "username": "ana.garcia",
    "password": "Tutor2024!",
    "email": "ana@email.com",
    "full_name": "Ana García López"
  }'
```

### READ (SELECT)

#### Obtener todos los usuarios
```javascript
const { data } = await supabase
  .from('users')
  .select('*')

console.log(data) // Array de 7 usuarios
```

#### Obtener usuario específico
```javascript
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('id', 1)
  .single() // Retorna un objeto, no array

console.log(data) // { id: 1, username: 'ana.garcia', ... }
```

#### Seleccionar solo algunas columnas
```javascript
const { data } = await supabase
  .from('users')
  .select('id, username, full_name, role')
  .eq('role', 'teen')

console.log(data)
// [
//   { id: 3, username: 'juan_talento', full_name: 'Juan Pérez García', role: 'teen' },
//   { id: 4, username: 'maria_creativa', full_name: 'María Pérez García', role: 'teen' },
//   ...
// ]
```

### UPDATE

#### Actualizar un registro
```javascript
const { data, error } = await supabase
  .from('users')
  .update({ verified: true })
  .eq('id', 5)
  .select()

console.log('Usuario actualizado:', data)
```

#### Actualizar array (agregar elemento)
PostgREST no tiene un `array_append` en `.update()`: se lee el array, se agrega el valor y se escribe completo (es lo que hace `syncApplicationArrays` en la app).
```javascript
// Agregar la oferta 1 a las postulaciones del adolescente 3
const { data: u } = await supabase.from('users').select('applications').eq('id', 3).single()
const applications = Array.from(new Set([...(u.applications || []), '1']))  // ids como texto
const { data } = await supabase
  .from('users')
  .update({ applications })
  .eq('id', 3)
  .select()
```

### DELETE

#### Eliminar un registro
```javascript
const { error } = await supabase
  .from('assignments')
  .delete()
  .eq('id', 1)

if(!error) console.log('Eliminado')
```

---

## 🔍 Filtros Comunes

### Igualdad (.eq)
```javascript
// SELECT * FROM users WHERE role = 'tutor'
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('role', 'tutor')
```

### No igual (.neq)
```javascript
// SELECT * FROM users WHERE role != 'employer'
const { data } = await supabase
  .from('users')
  .select('*')
  .neq('role', 'employer')
```

### Mayor que (.gt) / Mayor o igual (.gte)
```javascript
// SELECT * FROM offers WHERE pay > 200
const { data } = await supabase
  .from('offers')
  .select('*')
  .gt('pay', 200)

// SELECT * FROM offers WHERE pay >= 200
const { data } = await supabase
  .from('offers')
  .select('*')
  .gte('pay', 200)
```

### Menor que (.lt) / Menor o igual (.lte)
```javascript
// SELECT * FROM offers WHERE pay < 300
const { data } = await supabase
  .from('offers')
  .select('*')
  .lt('pay', 300)
```

### Paginación (.range)
```javascript
// SELECT * FROM offers LIMIT 5 OFFSET 0 (primeros 5)
const { data } = await supabase
  .from('offers')
  .select('*')
  .range(0, 4)
```

### Contiene texto (.ilike) - Case insensitive
```javascript
// SELECT * FROM users WHERE username ILIKE '%juan%'
const { data } = await supabase
  .from('users')
  .select('*')
  .ilike('username', '%juan%')
```

### En lista (.in)
```javascript
// SELECT * FROM users WHERE role IN ('tutor', 'teen')
const { data } = await supabase
  .from('users')
  .select('*')
  .in('role', ['tutor', 'teen'])
```

### Múltiples filtros (AND)
```javascript
// SELECT * FROM users WHERE role='teen' AND tutor_id=1
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('role', 'teen')
  .eq('tutor_id', 1)
```

### Ordenamiento (.order)
```javascript
// SELECT * FROM users ORDER BY created_at DESC
const { data } = await supabase
  .from('users')
  .select('*')
  .order('created_at', { ascending: false })

// SELECT * FROM offers ORDER BY pay DESC, title ASC
const { data } = await supabase
  .from('offers')
  .select('*')
  .order('pay', { ascending: false })
  .order('title', { ascending: true })
```

### Límite de resultados (.limit)
```javascript
// SELECT * FROM users LIMIT 10
const { data } = await supabase
  .from('users')
  .select('*')
  .limit(10)
```

---

## 🔗 Queries Avanzadas

### JOIN con Relaciones

#### Obtener adolescente con datos del tutor
```javascript
// SELECT u.*, t.full_name as tutor_name
// FROM users u
// LEFT JOIN users t ON u.tutor_id = t.id
// WHERE u.role = 'teen'

const { data } = await supabase
  .from('users')
  .select(`
    id,
    full_name,
    role,
    tutor:tutor_id(full_name, username)
  `)
  .eq('role', 'teen')

console.log(data[0])
// {
//   id: 3,
//   full_name: 'Juan Pérez García',
//   role: 'teen',
//   tutor: { full_name: 'Ana García López', username: 'ana.garcia' }
// }
```

#### Obtener oferta con datos del empleador
```javascript
const { data } = await supabase
  .from('offers')
  .select(`
    id,
    title,
    category,
    pay,
    employer:employer_id(company_name, email, phone)
  `)

console.log(data[0])
// {
//   id: 1,
//   title: 'Diseño gráfico',
//   category: 'diseno',
//   pay: 250,
//   employer: { company_name: 'TechStart Studio', email: '...', ... }
// }
```

### Contar registros
```javascript
// SELECT COUNT(*) FROM users
const { count } = await supabase
  .from('users')
  .select('*', { count: 'exact', head: true })

console.log(`Total usuarios: ${count}`)
```

### Búsqueda Full Text (si está configurado)
```javascript
// SELECT * FROM offers WHERE to_tsvector(description) @@ 'diseño'
const { data } = await supabase
  .from('offers')
  .select('*')
  .textSearch('description', 'diseño')
```

### Agregaciones (Group By)
```javascript
// SELECT role, COUNT(*) FROM users GROUP BY role
// Nota: Supabase PostgREST tiene limitaciones con GROUP BY
// Mejor usar SQL directo:

// (la base de ejemplo no define ninguna función RPC; hay que crearla si se quiere usar)
const { data } = await supabase.rpc('get_user_stats')
```

---

## 💡 Ejemplos Reales (del Sistema ATR)

### 1. Obtener los menores de un tutor
```javascript
async function getStudentsOfTutor(tutorId){
  const { data } = await supabase
    .from('users')
    .select('id, full_name, username, school_start, school_end')
    .eq('role', 'teen')
    .eq('tutor_id', tutorId)
  return data
}

// getStudentsOfTutor(1) → Juan (id 3) y María (id 4)
```
La fuente de verdad es `users.tutor_id`; `tutored_students` es solo un espejo en el tutor.

### 2. Obtener ofertas de un empleador con sus postulantes
```javascript
async function getEmployerOffers(employerId){
  const { data: offers } = await supabase
    .from('offers')
    .select('id, title, category, start_time, end_time, pay')
    .eq('employer_id', employerId)

  // La fuente de verdad de los postulantes es assignments (no student_applications)
  const { data: assignments } = await supabase
    .from('assignments')
    .select('id, status, offer_id, student:student_id(full_name, username)')
    .in('offer_id', offers.map(o => o.id))

  return { offers, assignments }
}
```

### 3. Validar disponibilidad de adolescente
```javascript
async function checkStudentAvailability(studentId, startTime, endTime){
  const { data: student } = await supabase
    .from('users')
    .select('school_start, school_end')
    .eq('id', studentId)
    .single()

  const { data: assignments } = await supabase
    .from('assignments')
    .select('offer:offer_id(start_time, end_time)')
    .eq('student_id', studentId)
    .eq('status', 'approved')

  // Validación lógica
  const blockedRanges = [
    [student.school_start, student.school_end],
    ['20:00', '08:00'],
    ...assignments.map(a => [a.offer.start_time, a.offer.end_time])
  ]

  const hasConflict = timeSlotCollides(startTime, endTime, blockedRanges)
  return !hasConflict
}
```

### 4. Obtener todas las asignaciones aprobadas con detalles
```javascript
async function getApprovedAssignments(){
  const { data } = await supabase
    .from('assignments')
    .select(`
      id,
      status,
      student:student_id(
        full_name,
        username,
        school_start,
        school_end
      ),
      offer:offer_id(
        title,
        category,
        start_time,
        end_time,
        pay,
        company_name
      )
    `)
    .eq('status', 'approved')

  return data
}

// Resultado:
// [
//   {
//     id: 1,
//     status: 'approved',
//     student: { full_name: 'Juan Pérez', ... },
//     offer: { title: 'Diseño gráfico', pay: 250, ... }
//   }
// ]
```

### 5. Buscar usuario por username (sin distinguir mayúsculas)
```javascript
// Los comodines % y _ del texto ingresado se escapan para que no actúen como patrón
const escapeLike = v => String(v).replace(/[\\%_]/g, c => '\\' + c)

async function findByUsername(username){
  const { data } = await supabase
    .from('users')
    .select('*')
    .ilike('username', escapeLike(username))

  // se confirma la coincidencia exacta en el cliente
  return (data || []).find(u => u.username.toLowerCase() === username.toLowerCase()) || null
}
```

### 6. Registrar un usuario (empleador)
```javascript
async function registerEmployer(payload){
  if(await findByUsername(payload.username)) throw new Error('Ese usuario ya existe.')

  const { data, error } = await supabase
    .from('users')
    .insert([{
      role: 'employer',
      username: payload.username,
      password: payload.password,   // ⚠️ texto plano en el prototipo (seguridad pendiente)
      company_name: payload.companyName,
      email: payload.email,
      phone: payload.phone,
      description: payload.description,
      contact_name: payload.contactName,
      dni: payload.dni,
      verified: false               // created_at lo pone la base por defecto
    }])
    .select()

  if(error) throw error
  return data[0]
}
```
El índice único sobre `LOWER(username)` también impide duplicados si dos registros llegan a la vez (error `23505`).

### 7. Obtener estadísticas por categoría
```javascript
async function getCategoryStats(){
  const { data: offers } = await supabase
    .from('offers')
    .select('category, id')

  const stats = {}
  offers.forEach(o => {
    stats[o.category] = (stats[o.category] || 0) + 1
  })

  return stats
}

// Resultado:
// {
//   "diseno": 1,
//   "edicion": 1,
//   "tutoria": 1,
//   "apoyo_escolar": 1,
//   "programacion": 1,
//   "redaccion": 1
// }
```

### 8. Postularse a una oferta
```javascript
async function applyForOffer(studentId, offerId){
  // 1) Fuente de verdad: una fila pending en assignments
  const { data, error } = await supabase
    .from('assignments')
    .insert([{ offer_id: offerId, student_id: studentId, status: 'pending' }])
    .select()
  if(error) throw error   // 23505 si ya se había postulado (UNIQUE offer_id, student_id)

  // 2) Espejo informativo (best-effort): offers.student_applications y users.applications
  //    (leer el array, agregar el id como texto y hacer update, ver "Actualizar array")
  return data[0]
}
```

### 9. Aprobar / rechazar (tutor)
```javascript
const { data } = await supabase
  .from('assignments')
  .update({ status: 'approved' })   // o 'rejected'
  .eq('id', assignmentId)
  .select()
```
Antes de aprobar, la app revalida categoría, horario escolar, franja 20:00-08:00 y solapamiento con otros trabajos aprobados.

---

## 🚨 Troubleshooting

### Error: "401 Unauthorized"
**Causa:** API Key inválida o expirada
**Solución:**
```javascript
// Verificar que estés usando la API Key correcta en el cliente
const SUPABASE_KEY = 'eyJhbGc...' // Debe ser la key anon
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)
```

### Error: "PGRST116 - single() returned more than one row"
**Causa:** Esperabas 1 resultado pero vinieron múltiples
**Solución:**
```javascript
// Agregar filtro más específico
const { data } = await supabase
  .from('users')
  .select('*')
  .ilike('username', 'juan')
  // .single() // ❌ Sacá esto
  // Ahora retorna array

// O usa .eq() en lugar de .ilike()
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('username', 'juan_talento')
  .single() // ✅ Ahora sí funciona
```

### Error: "undefined" al acceder a propiedad
**Causa:** El JOIN no retornó datos esperados
**Solución:**
```javascript
// Verificar estructura correcta
const { data } = await supabase
  .from('offers')
  .select(`
    id,
    title,
    employer:employer_id(company_name) // ✅ Correcto
  `)

// ❌ Incorrecto:
// .select('*, employer(*)')  // Supabase no soporta así

// Acceder correctamente:
console.log(data[0].employer.company_name)
```

### Error: "Column does not exist"
**Causa:** Nombre de columna incorrecto
**Solución:**
```javascript
// Verificar nombres exactos (snake_case en Supabase)
.select('full_name')    // ✅ Correcto
// .select('fullName')  // ❌ Incorrecto

.select('school_start')  // ✅ Correcto
// .select('schoolStart') // ❌ Incorrecto
```

### Error: "violates check constraint" / mensajes de trigger
**Causa:** la base rechazó datos inválidos (categoría fuera de lista, `pay <= 0`, `inicio >= fin`, oferta fuera de 08:00-20:00, o un rol incorrecto: "Solo un usuario con rol employer puede publicar ofertas", "Solo un adolescente (teen) puede postularse", "tutor_id debe referenciar a un usuario con rol tutor").
**Solución:** corregir los datos; la interfaz ya valida casi todo antes de enviar.

### Error: "Rows affected: 0"
**Causa:** El WHERE no encontró registros
**Solución:**
```javascript
// Verificar que el filtro sea correcto
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('id', 999) // ❌ ID no existe

// Primero, verifica que exista
const { data: all } = await supabase.from('users').select('*')
console.log(all) // Ver qué IDs existen
```

---

## 📊 Ejemplos SQL vs PostgREST

### SQL puro
```sql
SELECT * FROM users WHERE role='tutor' ORDER BY created_at DESC LIMIT 10;
```

### PostgREST equivalente
```javascript
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('role', 'tutor')
  .order('created_at', { ascending: false })
  .limit(10)
```

### SQL con JOIN
```sql
SELECT 
  o.id, o.title, o.pay,
  u.full_name as employer_name,
  (SELECT COUNT(*) FROM assignments WHERE offer_id=o.id) as applicants
FROM offers o
JOIN users u ON o.employer_id = u.id
WHERE u.verified = true
ORDER BY o.created_at DESC;
```

### PostgREST equivalente (simplificado)
```javascript
const { data } = await supabase
  .from('offers')
  .select('id, title, pay, employer:employer_id!inner(company_name, verified)')
  .eq('employer.verified', true)
  .order('created_at', { ascending: false })
// La cantidad de postulantes requeriría un RPC o un select anidado de assignments
```

---

## 🔐 Consideraciones de Seguridad (pendiente)

Seguridad queda fuera de alcance por ahora. Estado actual del prototipo:

- La clave `anon` está en el HTML y las tablas no tienen RLS: cualquiera con la clave puede leer y escribir todo.
- Las contraseñas se guardan y comparan en texto plano.
- El rol y la sesión viajan en el cliente (`localStorage`).

Antes de usar datos reales hay que migrar a Supabase Auth y definir políticas RLS (por ejemplo, `USING (auth.uid() = id)` sobre una columna enlazada a `auth.users`).

---

## 📚 Recursos

- [Documentación PostgREST](https://postgrest.org/en/stable/api.html)
- [Supabase JS Client Docs](https://supabase.com/docs/reference/javascript)
- [PostgreSQL JSON Functions](https://www.postgresql.org/docs/current/functions-json.html)

---

**Versión:** 3.0  
**Última actualización:** Octubre 2026  
**API:** PostgREST / Supabase
