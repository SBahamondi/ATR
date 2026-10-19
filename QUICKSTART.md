# ⚡ Quickstart - ATR v3.0 + Supabase

## 🚀 5 Minutos para Empezar

### Paso 1: Setup Supabase (2 minutos)

1. Abre tu proyecto Supabase:
   ```
   https://app.supabase.com/projects
   ```

2. Selecciona proyecto: `uhaoomiguwssiqnkecec`

3. Ve a **SQL Editor** → **New Query**

4. Copia TODO el contenido de `supabase-setup.sql`

5. Pégalo en el editor y haz clic en **Run** ▶️

6. ✅ Espera a que termine (verás 7 usuarios, 6 ofertas, 2 asignaciones)

> ⚠️ El script borra y recrea las tablas: úsalo solo para reiniciar la base.

---

### Paso 2: Abre la Aplicación (1 minuto)

1. Abre `atr-prototype-v3.html` en tu navegador (necesita internet: carga Supabase JS y las fuentes desde un CDN)

2. ¡Listo! La aplicación está conectada automáticamente

---

### Paso 3: Prueba (2 minutos)

#### Test 1: Login como Tutor
- **Usuario:** `ana.garcia`
- **Contraseña:** `Tutor2024!`
- ✓ Dashboard con 2 menores a cargo (Juan y María)
- ✓ **Calendario** con el horario escolar de cada menor y sus trabajos aprobados

#### Test 2: Login como Adolescente
- **Usuario:** `juan_talento`
- **Contraseña:** `Teen2024!`
- ✓ **Dashboard:** horario escolar, 0 postulaciones activas, 1 trabajo aprobado
- ✓ **Ofertas:** cada oferta con badge ✓ Compatible o 🚫 Conflicto; el botón **Postularme** solo aparece en las compatibles
- ✓ **Calendario:** ves 💼 *Diseño gráfico 15:00-17:00*

#### Test 3: Login como Empleador
- **Usuario:** `techstart.studio`
- **Contraseña:** `Employer2024!`
- ✓ **Mis ofertas:** tus ofertas con la lista de postulantes y su estado
- ✓ **Nueva oferta:** formulario de publicación

---

## 🎯 Estructura Rápida

### Tablas en Supabase

```
users (7 registros)
├── Tutores (2): ana.garcia, roberto.lopez
├── Adolescentes (3): juan_talento, maria_creativa, lucas_musician
└── Empleadores (2): techstart.studio, academia.plus

offers (6 registros)
├── Diseño gráfico 15:00-17:00      → Juan (aprobado)
├── Edición de video 16:00-18:00    → María (aprobado)
├── Tutoría de Matemáticas          → (sin postulantes)
├── Apoyo escolar                   → (sin postulantes)
├── Programación React              → (sin postulantes)
└── Redacción de ensayos            → (sin postulantes)

assignments (2 registros)
├── Juan → Diseño (APROBADO)
└── María → Edición (APROBADO)
```

---

## 📱 Flujos Principales

### Como Tutor
```
1. Login (ana.garcia / Tutor2024!)
2. Dashboard → Menores a cargo
3. Postulaciones → Aprobar / Rechazar las pendientes
4. Calendario → Horario escolar de cada menor y trabajos aprobados
5. Configuración → Tus datos
```

### Como Adolescente
```
1. Login (juan_talento / Teen2024!)
2. Ofertas → Filtro por categoría y validación de horario
3. Postularme a una oferta compatible
4. Esperar la aprobación del tutor (Dashboard → Historial de postulaciones)
5. Ver el trabajo en el Calendario una vez aprobado
6. Perfil → Editar horario escolar
```

### Como Empleador
```
1. Login (techstart.studio / Employer2024!)
2. Nueva oferta → Publicar
3. Mis ofertas → Ver postulantes y su estado
4. El tutor del menor aprueba o rechaza (el empleador no asigna)
5. Calendario → Trabajos aprobados de tus ofertas
```

---

## 🔐 Credenciales de Prueba

| Usuario | Contraseña | Rol | Notas |
|---------|-----------|-----|-------|
| `ana.garcia` | `Tutor2024!` | Tutor | 2 menores a cargo |
| `juan_talento` | `Teen2024!` | Teen | Tutor: ana.garcia · escuela 07:30-13:00 |
| `maria_creativa` | `Teen2024!` | Teen | Tutor: ana.garcia · escuela 08:00-13:30 |
| `roberto.lopez` | `Tutor2024!` | Tutor | 1 menor a cargo |
| `lucas_musician` | `Teen2024!` | Teen | Tutor: roberto.lopez · escuela 07:00-12:30 |
| `techstart.studio` | `Employer2024!` | Employer | Verificado |
| `academia.plus` | `Employer2024!` | Employer | Verificado |

---

## ✅ Checklist de Instalación

- [ ] Supabase project accesible
- [ ] SQL script ejecutado en Supabase
- [ ] 7 usuarios creados
- [ ] 6 ofertas creadas
- [ ] HTML abierto en navegador
- [ ] Login exitoso con ana.garcia
- [ ] Dashboard visible
- [ ] Puedo ver ofertas como adolescente
- [ ] Puedo crear oferta como empleador

---

## 🐛 Troubleshooting Rápido

### "Error de conexión"
- Verifica que Supabase esté online
- Abre Console (F12) y busca errores
- Recarga la página

### "No veo los datos"
- Ejecuta el SQL nuevamente
- Verifica que `SELECT COUNT(*) FROM users;` devuelva 7
- Recarga la aplicación

### "Login no funciona"
- Verifica mayúsculas/minúsculas en la contraseña (el usuario no distingue)
- Revisa la contraseña exacta
- Comprueba que el usuario exista en Supabase

### "Las ofertas no aparecen"
- Ve a Supabase → Table Editor → offers
- Verifica que haya registros
- Revisa el filtro de categoría (debe estar en "Todas las categorías")
- Abre Console (F12) para ver errores

### "No veo el botón Postularme"
- Hay conflicto de horario (se muestra el motivo), o ya te postulaste (se muestra el estado)

---

## 📊 Tabla de Validaciones

| Acción | Validación | Resultado |
|--------|-----------|-----------|
| Adolescente ve oferta en su horario escolar | ❌ Bloqueada | Badge "🚫 Conflicto" + motivo |
| Adolescente ve oferta entre 20:00 y 08:00 | ❌ Bloqueada | Badge "🚫 Conflicto" + motivo |
| Oferta solapada con un trabajo ya aprobado | ❌ Bloqueada | Badge "🚫 Conflicto" + motivo |
| Adolescente ve oferta compatible | ✓ Permitida | Badge "✓ Compatible" + botón Postularme |
| Adolescente se postula dos veces a la misma oferta | ❌ Bloqueada | Se muestra el estado, sin botón |
| Tutor aprueba una postulación válida | ✓ Permitida | `status = approved` |
| Tutor aprueba una postulación que ahora colisiona | ❌ Bloqueada | Alerta con el motivo |
| Tutor rechaza postulación | ✓ Permitida | `status = rejected` |
| Empleador elige categoría | Solo las 6 permitidas | Construcción, carga pesada y químicos no están en la lista |
| Empleador publica en franja 20:00-08:00 | ❌ Bloqueada | Mensaje de error |
| Empleador publica con inicio ≥ fin o paga ≤ 0 | ❌ Bloqueada | Mensaje de error |

---

## 🎮 Caso de Uso Completo

### Escenario: Juan quiere un trabajo extra

1. **Carlos (empleador) TechStart** publica una oferta nueva:
   - Título: "Redacción de contenido para blog"
   - Categoría: Redacción · Horario: 13:30-14:30 (después de la escuela y antes del Diseño de las 15:00) · Paga: $200/hora

2. **Juan (adolescente)** abre la app
   - Login: `juan_talento` / `Teen2024!`
   - En **Ofertas** ve la oferta como ✓ Compatible (no choca con la escuela, con el descanso ni con su trabajo de 15:00)
   - Hace clic en **Postularme** → queda ⏳ Pendiente

3. **Ana (tutora de Juan)** revisa la postulación
   - Login: `ana.garcia` / `Tutor2024!`
   - **Postulaciones** → ve la de Juan → **Aprobar**

4. **Resultado**
   - Estado: ✅ Aprobada
   - Juan la ve en su **Calendario**: 💼 Redacción de contenido para blog 13:30-14:30
   - Carlos la ve como postulante aprobado en **Mis ofertas**

---

## 🚀 Próximos Pasos

Una vez que TODO funciona:

1. **Crear más usuarios** → Regístrate desde la app
2. **Publicar más ofertas** → Como empleador
3. **Testear validaciones** → Mira `TESTING-CASES.md`
4. **Revisar Calendario** → Visualiza la semana con franjas bloqueadas

---

## 📖 Documentación Completa

- `GUIA-ATR-V2.md` - Roles, reglas y flujos funcionales
- `SETUP-SUPABASE.md` - Configuración detallada de Supabase y estructura de datos
- `supabase-setup.sql` - Script SQL completo
- `ARQUITECTURA-TECNICA.md` - Cómo está construida la app
- `API-REST-REFERENCE.md` - Consultas a Supabase (SDK y REST)
- `TESTING-CASES.md` - Casos de prueba
- `README-FINAL.md` - Resumen ejecutivo

---

## 💡 Tips

✅ **Guarda las credenciales** en un documento
✅ **Prueba todos los roles** para entender el sistema
✅ **Usa Console (F12)** para ver errores de conexión
✅ **Recarga la página** si algo no funciona
✅ **Limpia localStorage** si hay sesión antigua: `localStorage.clear()`

---

**¡Listo para empezar! 🎉**

Cualquier duda, revisa la Console (F12 → Console Tab).

Versión: 3.0 | Octubre 2026 | Supabase ✅
