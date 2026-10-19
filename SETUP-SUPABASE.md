# 🗄️ Setup Supabase para ATR Prototype v3.0

## 📋 Información de tu Proyecto

```
URL: https://uhaoomiguwssiqnkecec.supabase.co
API Key (anon): eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVoYW9vbWlndXdzc2lxbmtlY2VjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg3ODcxMDIsImV4cCI6MjEwNDM2MzEwMn0.z-5SBQP_kmou8uURpvNgRxUA-TIuqQr06tIEjdRLzGA
```

✅ **Ya está configurada en `atr-prototype-v3.html`** (constantes `SUPABASE_URL` y `SUPABASE_KEY`).

---

## 🏗️ Crear las tablas y los datos de prueba

La única forma soportada es el script **`supabase-setup.sql`**. Crea las tablas, los índices, las restricciones y los datos de ejemplo en un solo paso.

1. Abre tu proyecto en Supabase
2. **SQL Editor** → **New Query**
3. Copia **todo** el contenido de `supabase-setup.sql` y pégalo
4. Haz clic en **Run** ▶️

> ⚠️ El script empieza con `DROP TABLE ... CASCADE` para `assignments`, `offers` y `users`: **borra los datos existentes** y los recrea. Ejecútalo solo cuando quieras reiniciar la base.

### Qué deberías ver al terminar

| Resultado | Cantidad |
|-----------|----------|
| `users` | 7 (2 tutores, 3 adolescentes, 2 empleadores) |
| `offers` | 6 |
| `assignments` | 2 (Juan → Diseño y María → Edición, ambas `approved`) |

Los datos de prueba no dependen de IDs fijos: tutores, empleadores y ofertas se enlazan por `username` y título, así que funcionan aunque los IDs generados cambien.

---

## 📊 Estructura de datos

### Tabla `users` (una sola tabla para los 3 roles)

| Columna | Tipo | Se usa en | Notas |
|---------|------|-----------|-------|
| id | bigint identity | todos | PK |
| role | text | todos | `tutor`, `teen`, `employer` |
| username | text | todos | único (también sin distinguir mayúsculas) |
| password | text | todos | texto plano (ver sección Seguridad) |
| email | text | tutor, empleador | |
| full_name | text | tutor, teen | |
| birth_date | date | tutor | debe ser mayor de 18 |
| dni | text | todos | |
| tutored_students | text[] | tutor | ids (como texto) de sus adolescentes |
| tutor_id | bigint → users.id | teen | FK, `ON DELETE SET NULL` |
| tutor_username | text | teen | |
| school_start / school_end | text `HH:MM` | teen | editable desde Perfil |
| skills | text[] | teen | reservado, no se usa en la interfaz |
| applications | text[] | teen | ids de ofertas a las que se postuló (espejo de `assignments`) |
| company_name, phone, description, contact_name | text | empleador | |
| verified | boolean | empleador | `false` por defecto; se cambia manualmente |
| banned_categories | text[] | empleador | reservado, no se usa |
| created_at / updated_at | timestamptz | todos | `updated_at` lo mantiene un trigger |

### Tabla `offers`

| Columna | Tipo | Notas |
|---------|------|-------|
| id | bigint identity | PK |
| employer_id | bigint → users.id | `ON DELETE CASCADE` |
| title, description, company_name | text | |
| category | text | `CHECK`: tutoria, diseno, edicion, programacion, redaccion, apoyo_escolar |
| start_time / end_time | text `HH:MM` | `CHECK`: formato HH:MM, `start_time < end_time` y dentro de 08:00-20:00 (descanso obligatorio) |
| pay | integer | `CHECK (pay > 0)` |
| student_applications | text[] | ids de adolescentes postulados (espejo de `assignments`) |
| created_at / updated_at | timestamptz | |

### Tabla `assignments` (postulaciones y asignaciones)

| Columna | Tipo | Notas |
|---------|------|-------|
| id | bigint identity | PK |
| offer_id | bigint → offers.id | `ON DELETE CASCADE` |
| student_id | bigint → users.id | `ON DELETE CASCADE` |
| status | text | `pending` (defecto), `approved`, `rejected` |
| created_at / updated_at | timestamptz | |

`UNIQUE (offer_id, student_id)`: un adolescente no puede postularse dos veces a la misma oferta.

### Triggers

| Trigger | Efecto |
|---------|--------|
| `set_updated_at` (3 tablas) | Mantiene `updated_at` |
| `check_user_roles` | `users.tutor_id` debe ser un usuario con rol `tutor` |
| `check_offer_employer` | `offers.employer_id` debe ser un `employer` |
| `check_assignment_student` | `assignments.student_id` debe ser un `teen` |

**`assignments` es la fuente de verdad.** Una postulación es una fila `pending`; el tutor la cambia a `approved` o `rejected`.

---

## ✅ Verificar una empresa

Las empresas nuevas quedan con `verified = false`. Para verificarlas:

```sql
UPDATE users SET verified = true WHERE username = 'nombre_de_usuario';
```

---

## 🔍 Verificar la conexión

### Desde Supabase
```sql
SELECT role, COUNT(*) FROM users GROUP BY role;   -- tutor 2, teen 3, employer 2
SELECT COUNT(*) FROM offers;                      -- 6
SELECT COUNT(*) FROM assignments;                 -- 2
```

### Desde la aplicación
1. Abre DevTools (F12) → Console: no debería haber errores en rojo
2. Inicia sesión con `ana.garcia` / `Tutor2024!`
3. En Network deberían verse llamadas a `uhaoomiguwssiqnkecec.supabase.co/rest/v1/`

---

## 🧪 Probar desde la aplicación

1. Abre `atr-prototype-v3.html`
2. **Registrate** → Tutor Legal → crea la cuenta (vuelves al login con un mensaje de éxito)
3. **Registrate** → Trabajador → indica el usuario del tutor recién creado
4. **Registrate** → Empleador → luego verifícalo con el `UPDATE` de arriba si quieres que figure como verificado
5. Como empleador, publica una oferta; como adolescente, postúlate; como tutor, apruébala

---

## 🐛 Solución de problemas

| Error | Causa | Solución |
|-------|-------|----------|
| "Error de conexión" | URL o clave incorrecta, o proyecto pausado | Revisa las constantes del HTML; copia URL y clave desde Supabase → Settings → API |
| No aparecen datos | Script no ejecutado | Ejecuta `supabase-setup.sql` y verifica los conteos |
| `undefined` en pantalla | Nombre de columna distinto | Las columnas son `snake_case` (`full_name`, `school_start`, `start_time`) |
| `violates check constraint` al crear una oferta | Categoría fuera de lista, `pay <= 0`, `inicio >= fin` u oferta fuera de 08:00-20:00 | Usa los valores permitidos (la interfaz ya los valida) |
| `duplicate key` al postularse | Ya existe una postulación para esa oferta | Es esperado: la restricción `UNIQUE (offer_id, student_id)` lo impide |
| Error de Row Level Security | RLS activado sin políticas | Ver sección siguiente |

---

## 🔒 Seguridad (pendiente, fuera de alcance por ahora)

Estado del prototipo, tal como está:

- Las tablas creadas con el script **no tienen RLS activado**: la clave `anon` puede leer y escribir todo.
- Las contraseñas se guardan y comparan en texto plano.
- La sesión es un `localStorage` sin autenticación del servidor.

Está documentado como deuda conocida. Antes de usar datos reales (sobre todo de menores) hay que migrar a Supabase Auth y definir políticas RLS.

---

## 📝 Checklist de Setup

- [ ] Proyecto Supabase accesible
- [ ] `supabase-setup.sql` ejecutado sin errores
- [ ] 7 usuarios, 6 ofertas, 2 asignaciones
- [ ] `atr-prototype-v3.html` abierto en el navegador
- [ ] Login con `ana.garcia` exitoso
- [ ] Registro de un usuario nuevo visible en Table Editor → `users`

---

**Versión:** 3.0  
**Última actualización:** Octubre 2026  
**Ambiente:** Desarrollo
