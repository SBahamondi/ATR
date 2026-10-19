# 📘 Guía Funcional - ATR v3.0

Descripción de qué hace cada rol, qué reglas aplica el sistema y cómo fluye una postulación de punta a punta. Lo que está acá describe el comportamiento **real** de `atr-prototype-v3.html`.

> El archivo se llama `GUIA-ATR-V2.md` por historia (los 3 roles y el calendario nacieron en la v2). El contenido está actualizado a la v3.0 con Supabase.

---

## 👥 Roles

### 👨‍⚖️ Tutor Legal
Adulto responsable de uno o más menores.

| Sección | Qué hace |
|---------|----------|
| **Dashboard** | Lista de menores a cargo (nombre, usuario, horario escolar). |
| **Postulaciones** | Postulaciones de sus menores, pendientes primero. Botones **Aprobar** / **Rechazar** en las pendientes. |
| **Calendario** | Semana con el horario escolar de cada menor, el descanso obligatorio y los trabajos aprobados (con el nombre del menor). |
| **Configuración** | Sus datos (nombre, usuario, email, DNI) y cantidad de menores. |

Reglas:
- Debe ser mayor de 18 años para registrarse (la edad se calcula con la fecha exacta).
- El usuario (de cualquier rol) debe tener 3 a 30 caracteres: letras, números, `.`, `-` o `_`.
- Solo puede aprobar o rechazar postulaciones de **sus** menores (`tutor_id` del adolescente = su id).
- Al aprobar, el sistema vuelve a validar horario, franja nocturna, categoría y solapamiento con otros trabajos aprobados. Si hay conflicto, no aprueba y explica el motivo.

### 🌱 Trabajador / Adolescente
| Sección | Qué hace |
|---------|----------|
| **Dashboard** | Horario escolar, postulaciones activas (pendientes), trabajos aprobados e **historial de postulaciones** con su estado. |
| **Ofertas** | Catálogo con **filtro por categoría**. Cada oferta muestra badge ✓ Compatible o 🚫 Conflicto, si la empresa está verificada y, si es compatible, el botón **Postularme**. |
| **Calendario** | Semana con escuela, descanso obligatorio y trabajos aprobados (💼). |
| **Perfil** | Datos personales, tutor y **edición del horario escolar**. |

Reglas:
- Debe indicar un tutor existente (rol tutor) al registrarse; queda vinculado y se agrega a `tutored_students` del tutor.
- No puede postularse dos veces a la misma oferta (tampoco si fue rechazada).
- Si cambia su horario escolar y colisiona con un trabajo ya aprobado, el cambio se rechaza.

### 🏢 Empleador / Empresa
| Sección | Qué hace |
|---------|----------|
| **Dashboard** | Ofertas publicadas, postulaciones recibidas y estado de verificación. |
| **Mis ofertas** | Sus ofertas con la lista de postulantes y el estado de cada uno (pendiente / aprobada / rechazada). |
| **Nueva oferta** | Formulario de publicación. |
| **Calendario** | Trabajos aprobados de sus ofertas (con el nombre del adolescente). |

Reglas:
- Solo los empleadores pueden publicar ofertas.
- Una empresa nueva queda **sin verificar** (`verified = false`). Puede publicar, pero los adolescentes ven el badge "⏳ Empresa sin verificar". La verificación es manual en este prototipo (ver abajo).
- El empleador **no** asigna ni aprueba trabajos: eso lo hace el tutor del menor.

---

## ⏰ Reglas de validación horaria

Una oferta es **compatible** con un adolescente solo si cumple todo:

1. Su categoría es permitida: `tutoria`, `diseno`, `edicion`, `programacion`, `redaccion`, `apoyo_escolar`.
2. No se solapa con su **horario escolar**.
3. No se solapa con el **descanso obligatorio 20:00-08:00** (el rango cruza medianoche y se evalúa correctamente: 21:00-22:00, 00:00-01:00 y 07:00-08:00 son conflicto; 19:00-20:00 y 08:00-09:00 no).
4. No se solapa con otro trabajo **ya aprobado** del adolescente.

Dos ofertas que se solapan entre sí pueden estar ambas *pendientes*; en cuanto el tutor aprueba una, la otra pasa a conflicto y ya no se puede aprobar.

Al **crear una oferta** el empleador también está limitado: categoría de la lista, inicio anterior al fin, paga mayor a 0 y fuera de la franja 20:00-08:00. La base de datos lo refuerza con restricciones `CHECK` y triggers de rol (solo empleadores publican, solo adolescentes se postulan).

> Las ofertas no tienen fecha, solo horario. Por eso el calendario repite el trabajo aprobado **todos los días** de la semana mostrada (horario semanal recurrente).

---

## 🔄 Ciclo de vida de una postulación

```
Adolescente "Postularme"   →  assignments.status = 'pending'
Tutor "Aprobar"            →  status = 'approved'  (aparece en calendarios)
Tutor "Rechazar"           →  status = 'rejected'  (no aparece en calendarios)
```

La tabla `assignments` es la **fuente de verdad**. Las columnas `offers.student_applications` y `users.applications` son un espejo informativo que se actualiza al postularse.

---

## 🎮 Caso completo: Juan quiere trabajar

1. **Juan** (`juan_talento`) entra y ve su horario escolar 07:30-13:00.
2. En **Ofertas** ve "Diseño gráfico para proyecto web" 15:00-17:00 → ✓ Compatible. Pulsa **Postularme** (queda ⏳ Pendiente).
3. **Ana** (`ana.garcia`), su tutora, va a **Postulaciones**, ve la solicitud de Juan y pulsa **Aprobar**.
4. Juan ve 💼 *Diseño gráfico 15:00-17:00* en su **Calendario**, y **TechStart** lo ve como postulante ✅ Aprobada en **Mis ofertas**.

> Los datos de ejemplo ya traen a Juan y María con un trabajo aprobado cada uno. Para recorrer el flujo desde cero, postulate con Juan a una oferta distinta (por ejemplo "Tutoría de Matemáticas" 14:00-15:30 no es compatible porque pisa su trabajo aprobado de las 15:00; probá "Redacción de ensayos" 14:00-15:00) o registrá un adolescente nuevo.

---

## ✅ Verificar una empresa (manual)

En Supabase → SQL Editor:

```sql
UPDATE users SET verified = true WHERE username = 'nombre_de_usuario_de_la_empresa';
```

---

## 🧩 Campos reservados

`users.skills` y `users.banned_categories` existen en la base pero **no se usan todavía** en la interfaz.

---

## 🐛 Solución de problemas

| Síntoma | Qué revisar |
|---------|-------------|
| No aparecen ofertas | Ejecutar `supabase-setup.sql`; en Supabase, tabla `offers` con 6 filas. |
| El botón Postularme no aparece | Hay conflicto de horario, o ya te postulaste (se muestra el estado). |
| El tutor no ve postulaciones | El adolescente debe tener `tutor_id` = id del tutor. |
| "Error de conexión" | Consola (F12), verificar URL/clave de Supabase y que el proyecto esté activo. |
| Sesión vieja o rara | `localStorage.clear()` y recargar. |
