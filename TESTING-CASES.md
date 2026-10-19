# 🧪 Casos de Prueba - ATR v3.0

## 📋 Indice de Pruebas

- [Registro](#registro)
- [Login](#login)
- [Validación Horaria](#validación-horaria)
- [Creación de Ofertas](#creación-de-ofertas)
- [Postulaciones](#postulaciones)
- [Aprobación de Tutor](#aprobación-de-tutor)
- [Calendario](#calendario)
- [Edge Cases](#edge-cases)

---

## ✍️ Registro

### TC-REG-001: Registro Tutor - Datos Válidos

**Precondiciones:** 
- Usuario no está registrado

**Pasos:**
1. Ve a "Registrate" → "Tutor Legal"
2. Ingresa:
   - Nombre: "Roberto López"
   - Fecha: "1980-01-15"
   - DNI: "25987654"
   - Email: "roberto@email.com"
   - Usuario: "roberto_test"
   - Contraseña: "Password123"
   - Confirm: "Password123"
3. Acepta términos
4. Haz clic en "Crear cuenta"

**Resultado esperado:**
- ✅ Cuenta creada
- ✅ Redirige a login
- ✅ Puede hacer login con nuevas credenciales

**Resultado actual:** ___________

---

### TC-REG-002: Registro Tutor - Menor de 18 años

**Pasos:**
1. Ve a "Registrate" → "Tutor Legal"
2. Fecha de nacimiento: "2020-01-01" (4 años)
3. Intenta crear cuenta

**Resultado esperado:**
- ❌ Error: "Debés ser mayor de 18 años."
- ❌ No se crea la cuenta

**Resultado actual:** ___________

---

### TC-REG-003: Registro Tutor - Email Inválido

**Pasos:**
1. Ve a "Registrate" → "Tutor Legal"
2. Email: "esto_no_es_email"
3. Intenta crear cuenta

**Resultado esperado:**
- ❌ Error: "Email inválido."

**Resultado actual:** ___________

---

### TC-REG-004: Registro Tutor - Contraseña Corta

**Pasos:**
1. Ve a "Registrate" → "Tutor Legal"
2. Contraseña: "123"
3. Intenta crear cuenta

**Resultado esperado:**
- ❌ Error: "La contraseña debe tener al menos 8 caracteres."

**Resultado actual:** ___________

---

### TC-REG-005: Registro Tutor - Contraseñas No Coinciden

**Pasos:**
1. Ve a "Registrate" → "Tutor Legal"
2. Contraseña: "Password123"
3. Confirm: "Password456"
4. Intenta crear cuenta

**Resultado esperado:**
- ❌ Error: "Las contraseñas no coinciden."

**Resultado actual:** ___________

---

### TC-REG-006: Registro Tutor - Username Duplicado

**Pasos:**
1. Ve a "Registrate" → "Tutor Legal"
2. Username: "ana.garcia" (ya existe)
3. Intenta crear cuenta

**Resultado esperado:**
- ❌ Error: "Ese usuario ya existe. Elegí otro."

**Resultado actual:** ___________

---

### TC-REG-007: Registro Adolescente - Datos Válidos

**Pasos:**
1. Ve a "Registrate" → "Adolescente/Teen"
2. Ingresa:
   - Nombre: "Lucas Test"
   - DNI: "58999999"
   - Tutor: "ana.garcia" (debe existir)
   - Horario escolar: 07:00 a 13:00
   - Usuario: "lucas_test"
   - Contraseña: "Password123"
3. Crea cuenta

**Resultado esperado:**
- ✅ Cuenta creada
- ✅ Vinculada a tutor ana.garcia
- ✅ Puede hacer login

**Resultado actual:** ___________

---

### TC-REG-008: Registro Adolescente - Tutor No Existe

**Pasos:**
1. Ve a "Registrate" → "Adolescente/Teen"
2. Tutor: "usuario_falso"
3. Intenta crear cuenta

**Resultado esperado:**
- ❌ Error: "El tutor no existe o no es válido."

**Resultado actual:** ___________

---

### TC-REG-009: Registro Empleador - Datos Válidos

**Pasos:**
1. Ve a "Registrate" → "Empleador/Empresa"
2. Ingresa todos los datos
3. Acepta términos
4. Crea cuenta

**Resultado esperado:**
- ✅ Cuenta creada
- ✅ Estado de verificación: "⏳ Pendiente" (`verified = false`)
- ✅ Puede hacer login

**Resultado actual:** ___________

---

### TC-REG-010: Registro - Formato de Usuario Inválido

**Pasos:**
1. Ve a "Registrate" → cualquier rol
2. Usuario: "a b" (con espacio) o "ab" (menos de 3 caracteres)
3. Completa el resto de los campos correctamente y envía

**Resultado esperado:**
- ❌ Error: "El usuario debe tener entre 3 y 30 caracteres: letras, números, punto, guion o guion bajo."
- ❌ No se crea la cuenta

**Resultado actual:** ___________

---

## 🔐 Login

### TC-LOGIN-001: Login Exitoso - Tutor

**Pasos:**
1. Usuario: "ana.garcia"
2. Contraseña: "Tutor2024!"
3. Haz clic en "Ingresar"

**Resultado esperado:**
- ✅ Login exitoso
- ✅ Redirige a Dashboard
- ✅ Muestra nombre y rol

**Resultado actual:** ___________

---

### TC-LOGIN-002: Login Exitoso - Adolescente

**Pasos:**
1. Usuario: "juan_talento"
2. Contraseña: "Teen2024!"
3. Haz clic en "Ingresar"

**Resultado esperado:**
- ✅ Login exitoso
- ✅ Muestra horario escolar (07:30-13:00)

**Resultado actual:** ___________

---

### TC-LOGIN-003: Login - Usuario No Existe

**Pasos:**
1. Usuario: "usuario_falso"
2. Contraseña: "Password123"
3. Intenta login

**Resultado esperado:**
- ❌ Error: "Usuario o contraseña incorrectos."

**Resultado actual:** ___________

---

### TC-LOGIN-004: Login - Contraseña Incorrecta

**Pasos:**
1. Usuario: "ana.garcia"
2. Contraseña: "ContraseñaFalsa"
3. Intenta login

**Resultado esperado:**
- ❌ Error: "Usuario o contraseña incorrectos."

**Resultado actual:** ___________

---

### TC-LOGIN-005: Logout

**Pasos:**
1. Login como "ana.garcia"
2. Haz clic en "Cerrar sesión"

**Resultado esperado:**
- ✅ Sesión cerrada
- ✅ Redirige a login
- ✅ localStorage limpiado

**Resultado actual:** ___________

---

## ⏰ Validación Horaria

### TC-HORA-001: Oferta Dentro de Horario Escolar

**Precondiciones:**
- Login como juan_talento (horario escolar 07:30-13:00)
- Oferta: 09:00-11:00

**Pasos:**
1. Ve a "Ofertas"
2. Busca oferta "09:00-11:00"

**Resultado esperado:**
- 🚫 Badge: "🚫 Conflicto"
- ❌ Botón "Postularme": deshabilitado
- ⚠️ Mensaje: "colisiona con tu horario escolar"

**Resultado actual:** ___________

---

### TC-HORA-002: Oferta Dentro de Franja Nocturna

**Precondiciones:**
- Login como adolescente
- Oferta: 21:00-22:00

**Pasos:**
1. Ve a "Ofertas"
2. Busca oferta "21:00-22:00"

**Resultado esperado:**
- 🚫 Badge: "🚫 Conflicto"
- ❌ Botón deshabilitado
- ⚠️ Mensaje: "colisiona con ... franja nocturna"

**Resultado actual:** ___________

---

### TC-HORA-003: Oferta Compatible

**Precondiciones:**
- Login como juan_talento (07:30-13:00 escuela)
- Oferta: 15:00-17:00

**Pasos:**
1. Ve a "Ofertas"
2. Busca oferta "15:00-17:00"

**Resultado esperado:**
- ✅ Badge: "✓ Compatible"
- ✅ Botón "Postularme": habilitado
- ✅ Sin mensajes de error

**Resultado actual:** ___________

---

### TC-HORA-004: Calendario - Franja Bloqueada Escuela

**Precondiciones:**
- Login como juan_talento
- Ir a Calendario

**Pasos:**
1. Ve "Calendario"
2. Observa los días

**Resultado esperado:**
- 🎓 Cada día muestra: "🎓 Escuela: 07:30-13:00"
- 🌙 Cada día muestra: "🚫 Descanso: 20:00-08:00"

**Resultado actual:** ___________

---

## 📝 Creación de Ofertas

### TC-OFFER-001: Crear Oferta - Datos Válidos

**Precondiciones:**
- Login como techstart.studio

**Pasos:**
1. Ve a "Nueva oferta"
2. Título: "Redacción de contenido"
3. Categoría: "redaccion"
4. Descripción: "Escribir articulos de blog"
5. Hora inicio: "14:00"
6. Hora fin: "15:30"
7. Paga: "200"
8. Haz clic en "Publicar oferta"

**Resultado esperado:**
- ✅ Oferta publicada
- ✅ Aparece en "Mis ofertas"
- ✅ Se guarda en Supabase

**Resultado actual:** ___________

---

### TC-OFFER-002: Crear Oferta - Categoría Prohibida (Construcción)

**Pasos:**
1. Ve a "Nueva oferta"
2. Categoría: "construcción" (si está en lista)
3. Intenta publicar

**Resultado esperado:**
- ❌ La categoría no está en la lista del desplegable (solo las 6 permitidas)
- ❌ No permite publicar

**Resultado actual:** ___________

---

### TC-OFFER-003: Crear Oferta - Hora Inicio >= Fin

**Pasos:**
1. Ve a "Nueva oferta"
2. Hora inicio: "16:00"
3. Hora fin: "15:00"
4. Intenta publicar

**Resultado esperado:**
- ❌ Error: "La hora de inicio debe ser anterior a la hora de fin."
- ❌ No se publica

**Resultado actual:** ___________

---

### TC-OFFER-004: Crear Oferta - Paga Negativa

**Pasos:**
1. Ve a "Nueva oferta"
2. Paga: "-100"
3. Intenta publicar

**Resultado esperado:**
- ❌ Error: "La paga por hora debe ser mayor a 0."
- ❌ No se publica

**Resultado actual:** ___________

---

### TC-OFFER-005: Crear Oferta - Franja Nocturna

**Pasos:**
1. Ve a "Nueva oferta"
2. Hora inicio: "19:00", hora fin: "21:00"
3. Intenta publicar

**Resultado esperado:**
- ❌ Error: "No se permiten ofertas en la franja nocturna (20:00-08:00)."
- ❌ No se publica (y, si se intentara insertar directo, la BD la rechaza por CHECK)

**Resultado actual:** ___________

---

## 📋 Postulaciones

### TC-POST-001: Postularse a Oferta Compatible

**Precondiciones:**
- Login como juan_talento
- Oferta: "Diseño gráfico" 15:00-17:00 (compatible)

**Pasos:**
1. Ve a "Ofertas"
2. Busca "Diseño gráfico"
3. Haz clic en "Postularme"

**Resultado esperado:**
- ✅ Alerta: "✓ Te postulaste a esta oferta. Tu tutor deberá aprobarla."
- ✅ Nueva fila en `assignments` con `status = pending`
- ✅ El espejo `offers.student_applications` / `users.applications` se actualiza
- ✅ Tutor recibe notificación (próx. versión)

**Resultado actual:** ___________

---

### TC-POST-002: No Permitir Postularse a Incompatible

**Precondiciones:**
- Login como juan_talento
- Oferta: "Tarea escolar" 09:00-10:00 (conflicto)

**Pasos:**
1. Ve a "Ofertas"
2. Busca oferta en conflicto
3. Intenta haz clic en "Postularme"

**Resultado esperado:**
- ❌ Botón deshabilitado (no hace nada)
- 🚫 Badge "Conflicto" visible
- ⚠️ Mensaje de alerta

**Resultado actual:** ___________

---

### TC-POST-003: Ver Postulaciones en Tutor

**Precondiciones:**
- juan_talento se postulo a oferta
- Login como ana.garcia (tutor)

**Pasos:**
1. Ve a "Postulaciones"
2. Observa ofertas de sus menores

**Resultado esperado:**
- ✅ Ve lista de postulaciones
- ✅ Muestra nombre del menor
- ✅ Muestra oferta y horario
- ✅ Botones "Aprobar" y "Rechazar"

**Resultado actual:** ___________

---

## ✅ Aprobación de Tutor

### TC-APPR-001: Tutor Aprueba Postulación

**Precondiciones:**
- juan_talento tiene una postulación `pending` a una oferta compatible (p. ej. "Redacción de ensayos" 14:00-15:00; "Diseño gráfico" ya viene aprobada en los datos de ejemplo)
- Login como ana.garcia

**Pasos:**
1. Ve a "Postulaciones"
2. Ve postulación de Juan
3. Haz clic en "Aprobar"

**Resultado esperado:**
- ✅ La fila de `assignments` pasa a `status = approved` (no se crea otra)
- ✅ Aparece en Calendario de Juan
- ✅ Aparece como "✅ Aprobada" en Mis ofertas del empleador
- ✅ BD actualizada

**Resultado actual:** ___________

---

### TC-APPR-002: Tutor Rechaza Postulación

**Precondiciones:**
- Postulación pendiente

**Pasos:**
1. Ve a "Postulaciones"
2. Haz clic en "Rechazar"

**Resultado esperado:**
- ✅ La fila de `assignments` pasa a `status = rejected`
- ✅ Adolescente NO ve en Calendario
- ✅ BD actualizada

**Resultado actual:** ___________

---

### TC-APPR-003: Validación de Horario en Aprobación

**Precondiciones:**
- Postulación que colisiona

**Pasos:**
1. Con Juan, postula a dos ofertas que se solapan entre sí (ambas quedan pendientes)
2. El tutor aprueba una
3. El tutor intenta aprobar la otra

**Resultado esperado:**
- ⚠️ Alerta con el motivo del conflicto
- ❌ No se aprueba; la postulación sigue `pending` (el tutor puede rechazarla)

**Resultado actual:** ___________

---

## 📅 Calendario

### TC-CAL-001: Ver Calendario Semanal

**Pasos:**
1. Login como cualquier rol
2. Ve a "Calendario"

**Resultado esperado:**
- ✅ Muestra los 7 días de la semana
- ✅ Muestra fecha actual
- ✅ Día actual resaltado en teal
- ✅ Fines de semana en rosa

**Resultado actual:** ___________

---

### TC-CAL-002: Navegar a Semana Anterior

**Pasos:**
1. Ve a "Calendario"
2. Haz clic en "← Semana anterior"

**Resultado esperado:**
- ✅ Calendario retrocede 7 días
- ✅ Fechas actualizadas

**Resultado actual:** ___________

---

### TC-CAL-003: Navegar a Siguiente Semana

**Pasos:**
1. Ve a "Calendario"
2. Haz clic en "Siguiente semana →"

**Resultado esperado:**
- ✅ Calendario avanza 7 días
- ✅ Fechas actualizadas

**Resultado actual:** ___________

---

### TC-CAL-004: Ver Franjas Bloqueadas

**Precondiciones:**
- Login como adolescente

**Pasos:**
1. Ve a "Calendario"
2. Observa cada día

**Resultado esperado:**
- 🎓 "🎓 Escuela: 07:30-13:00" (amarillo)
- 🌙 "🚫 Descanso: 20:00-08:00" (rojo)

**Resultado actual:** ___________

---

### TC-CAL-005: Ver Trabajo Asignado en Calendario

**Precondiciones:**
- juan_talento tiene asignación aprobada
- Trabajo: Diseño 15:00-17:00

**Pasos:**
1. Login como juan_talento
2. Ve a "Calendario"
3. Observa el día del trabajo

**Resultado esperado:**
- 💼 "💼 Diseño gráfico 15:00-17:00" (verde)

**Resultado actual:** ___________

---

## 🚨 Edge Cases

### TC-EDGE-001: Cambiar Horario Escolar Dinámicamente

**Pasos:**
1. Login como adolescente
2. Cambia el horario escolar desde Perfil
3. Ve a "Ofertas"

**Resultado esperado:**
- ✅ Validaciones se actualizan
- ✅ Ofertas que eran compatibles ahora conflictúan
- ✅ Cambios se reflejan en Calendario

**Resultado actual:** ___________

---

### TC-EDGE-002: Múltiples Trabajos Asignados en el Mismo Día

**Pasos:**
1. Asigna 2 trabajos el mismo día sin conflicto
2. Ve a "Calendario"

**Resultado esperado:**
- ✅ Muestra ambos trabajos
- ✅ No se solapan

**Resultado actual:** ___________

---

### TC-EDGE-003: Oferta de Medianoche (00:00-01:00)

**Pasos:**
1. Crear oferta: 00:00-01:00
2. Adolescente intenta postularse

**Resultado esperado:**
- ❌ Bloqueada (dentro de 20:00-08:00)

**Resultado actual:** ___________

---

### TC-EDGE-004: Adolescente sin Tutor Intenta Registrarse

**Pasos:**
1. Ve a "Registrate" → "Adolescente"
2. Deja campo tutor vacío

**Resultado esperado:**
- ❌ Error: "Completá todos los campos obligatorios."
- ❌ No permite crear sin tutor

**Resultado actual:** ___________

---

### TC-EDGE-005: Tutor con Muchos Menores

**Precondiciones:**
- Tutor con 10+ menores (simulado)

**Pasos:**
1. Login como tutor
2. Ve a "Dashboard"

**Resultado esperado:**
- ✅ Muestra todos (scroll si es necesario)
- ✅ Carga correctamente
- ✅ Sin problemas de performance

**Resultado actual:** ___________

---

### TC-EDGE-006: Empleador sin Ofertas Publicadas

**Pasos:**
1. Login como empleador nuevo
2. Ve a "Mis ofertas"

**Resultado esperado:**
- ✅ Mensaje: "No has publicado ofertas aún. Crea una"
- ✅ El enlace lleva a "Nueva oferta"

**Resultado actual:** ___________

---

### TC-EDGE-007: Tutor Intenta Crear Oferta (Bloqueado)

**Pasos:**
1. Login como tutor
2. Intenta navegar a "Nueva oferta"
3. O intenta enviar POST directo

**Resultado esperado:**
- ❌ No ve la opción en el menú
- ❌ Si inserta directo en `offers`: la BD lo rechaza ("Solo un usuario con rol employer puede publicar ofertas")

**Resultado actual:** ___________

---

## 📊 Resumen de Pruebas

| ID | Prueba | Estado | Notas |
|----|--------|--------|-------|
| TC-REG-001 | Registro Tutor válido | _____ | |
| TC-LOGIN-001 | Login exitoso | _____ | |
| TC-HORA-001 | Bloqueo horario escolar | _____ | |
| TC-OFFER-001 | Crear oferta | _____ | |
| TC-POST-001 | Postularse | _____ | |
| TC-APPR-001 | Aprobar postulación | _____ | |
| TC-CAL-001 | Ver calendario | _____ | |

---

## ✅ Checklist Pre-Release

- [ ] Todos los TC-REG pasan
- [ ] Todos los TC-LOGIN pasan
- [ ] Todos los TC-HORA pasan
- [ ] Todos los TC-OFFER pasan
- [ ] Todos los TC-POST pasan
- [ ] Todos los TC-APPR pasan
- [ ] Todos los TC-CAL pasan
- [ ] Todos los TC-EDGE pasan
- [ ] Console sin errores críticos
- [ ] Responsive en móvil
- [ ] Supabase datos actualizados correctamente

---

**Versión:** 3.0  
**Última actualización:** Octubre 2026  
**Total de casos:** 42
