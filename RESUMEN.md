# Barra Austral — Estado del proyecto (archivo de contexto del agente)

> **AUDIENCIA: el agente (Claude), no el usuario.** El usuario no lee esto.
> Es la memoria del proyecto para recuperar contexto tras una compactación.
> No hay git → este archivo es el único historial. **Mantenerlo actualizado:**
> al terminar cada cambio que pida el usuario, añadir una entrada a la
> **Bitácora de cambios (al FINAL del archivo)** y ajustar la sección afectada.
> Escribir denso y factual, sin relleno.

App de seguimiento de entrenamiento de calistenia (peso corporal), autoalojada
(Docker + Cloudflare Tunnel). Plan de rutinas por niveles ("un día, una rutina":
Push / Pull / Squats en 5 niveles).

---

## 0. Orientación rápida (leer esto primero)

**Ubicación:** `/home/david/apps/appGym` (NO es repo git). Entorno Linux, zsh.

**Cómo se ejecuta y se aplica un cambio** (siempre por Docker, no hay dev server):
```bash
docker compose build frontend && docker compose up -d frontend   # tras tocar React
docker compose build backend  && docker compose up -d backend    # tras tocar Python
```
Contenedores: `gymtracker-frontend`, `gymtracker-backend`, `calistia-db`.
Acceso a la BD: `docker exec calistia-db psql -U calistia -d calistia -c "..."`.

**Archivos que más se tocan:**
- Color/etiquetas del calendario → `frontend/src/components/Calendar.jsx`.
- Categorías/colores y catálogo → `frontend/src/exercises.js`.
- Editor de rutinas y selector de categoría → `frontend/src/components/Routines.jsx`.
- Modelos/semillas backend → `backend/db.py`, `backend/seeds.py`, `backend/seed_cuyi.py`.

**El registro cronológico de cambios está en la _Bitácora de cambios_ al final
del archivo.**

**Gotchas / decisiones:**
- No hay git → no hay historial; este MD es la memoria del proyecto.
- Todo se guarda como **un blob JSON completo** por usuario (`POST /api/data`
  reemplaza todo). El modelo `routines` tiene columna `categories` (JSON).
- Cambios directos en BD para `cuyi` se hicieron por script vía
  `docker exec -i gymtracker-backend python3 < script.py` (usa los modelos).
- El backend, al arrancar, corre `run_seeds()` que incluye backfills y
  `strip_cardio_from_routine_categories()` (idempotentes).

---

## 1. Arquitectura general

| Capa       | Tecnología                                   | Contenedor            |
|------------|----------------------------------------------|-----------------------|
| Frontend   | React 18 + Vite + Tailwind (servido por Nginx)| `gymtracker-frontend` |
| Backend    | FastAPI (Python) + SQLAlchemy                | `gymtracker-backend`  |
| Base datos | PostgreSQL 16                                | `calistia-db`         |

- Orquestación con `docker-compose.yml`, red interna `gymnet`.
- El frontend (Nginx) expone el puerto `${PORT}` (por defecto 50666 en `.env`) y
  hace de proxy de `/api/*` hacia el backend.
- Persistencia en `./data` (Postgres en `./data/postgres`, fotos en
  `./data/photos`).
- Variables clave en `.env`: `API_TOKEN` (contraseña de la app) y `PORT`.

### Flujo de datos
El backend expone toda la información del usuario como un único blob JSON
(`GET /api/data`) y lo reemplaza completo al guardar (`POST /api/data`). El
frontend mantiene ese blob en memoria y lo reescribe entero en cada cambio
(rutinas, sesiones, ubicaciones).

---

## 2. Backend (`/backend`)

- **`main.py`** — App FastAPI. Al arrancar espera la BD, crea el esquema
  (`init_db`) y ejecuta las semillas (`run_seeds`). Endpoints:
  - `POST /api/login` — login por usuario/contraseña; devuelve token. Bloqueo tras
    6 intentos fallidos (requiere reiniciar el contenedor).
  - `GET/POST /api/data` — leer / reemplazar el blob completo del usuario.
  - `GET /api/me`, `GET /api/exercises` — usuario actual y catálogo.
  - `POST/GET/DELETE /api/photos` — subida/consulta/borrado de fotos (máx. 20 MB,
    extensiones permitidas jpg/jpeg/png/webp/heic).
  - `GET /api/export/json | flat | csv` — exportación de datos.
  - `GET /api/health` — healthcheck.
  - Autenticación por cabecera `x-api-token` (o `?token=` para fotos/exportes).
- **`db.py`** — Modelos SQLAlchemy y `init_db()` con migraciones idempotentes
  (`ALTER TABLE ... ADD COLUMN IF NOT EXISTS`).
- **`serializers.py`** — Traducción entre filas de la BD y el JSON del frontend
  (camelCase), y `replace_user_data()` que reescribe ubicaciones, rutinas y
  sesiones a partir del blob.
- **`seeds.py`** — Siembra usuarios, catálogo de ejercicios, rutinas de `cuyi` y
  un año de datos de demostración para el usuario `demo`. Incluye backfills:
  títulos de sesión, categorías de rutina, y limpieza de cardio de las categorías.
- **`seed_cuyi.py`** — Define las 15 rutinas del PDF (Push/Pull/Squats × 5 niveles)
  con tempo, reps, sets, descanso y supersets.

### Modelo de datos (tablas)
- `users` — usuario, contraseña, token.
- `exercises` — catálogo (nombre EN/ES, categoría, músculos, tipo `reps`/`machine`).
- `locations` — lugares de entrenamiento del usuario.
- `routines` — plan: nombre, descripción, `weekdays` (días programados),
  `categories` (grupos musculares para el color del calendario).
- `routine_exercises` — ejercicios de una rutina (tempo, reps/sets objetivo,
  descanso, tiempo, resistencia, `superset_group`, posición).
- `sessions` — sesión realizada (título, fecha, inicio/fin, duración, notas,
  `categories` (grupos musculares elegidos por el usuario), ubicación,
  `routine_id` como referencia débil).
- `session_exercises` / `session_sets` — ejercicios y series efectivas por sesión
  (reps, peso, duración, descanso).
- `photos` — fotos asociadas a una sesión.

---

## 3. Frontend (`/frontend/src`)

Punto de entrada `App.jsx`: si no hay token muestra `LockScreen`, si lo hay
muestra `Dashboard`. El token y el fondo se guardan en `localStorage`. Fondo de
pantalla personalizable con overlay.

### Navegación principal (`Dashboard.jsx`)
Cuatro pestañas: **Train · History · Calendar · More**. Gestiona la sesión activa
(persistida en `localStorage` como `gym_active_session`), el cronómetro y el
guardado.

### Componentes clave
- **`LockScreen`** — login con usuario/contraseña; estado bloqueado tras fallos.
- **Train** (`ExerciseSearch`, `ExerciseCard`, `RoutineChooser`,
  `SessionSummary`, `FinishSessionModal`) — iniciar sesión (vacía o desde una
  rutina), registrar series por ejercicio y finalizar la sesión.
- **`History`** — historial de sesiones, edición (`SessionEditor`) y panel de
  **exportación** (JSON completo, JSON plano, CSV).
- **`Calendar`** — vista mensual. Cada día se colorea **solo con las sesiones
  realizadas**, mezclando el color de los grupos entrenados; resumen mensual y
  agenda semanal de rutinas. (Ver reglas de color abajo.)
- **`More`** — menú con: **Routines**, **Locations**, **Documentation**,
  **Progress** (gráficos por ejercicio) y **Muscles** (estadísticas por músculo).
- **`Routines`** — crear/editar rutinas: ejercicios, tempo/reps/sets/descanso,
  supersets, días programados y **categoría/color**.
- **`Settings`** — fondo de pantalla, bloqueo, etc.

### Catálogo y colores (`exercises.js`)
- `EXERCISES` — catálogo con nombre EN/ES, categoría y músculos.
- Categorías internas: `Push`, `Pull`, `Piernas` (Legs), `Remo` (Cardio),
  `Custom` (Other). `CATEGORY_LABEL` traduce a las etiquetas visibles.
- Colores: `CATEGORY_PILL` / `CATEGORY_FILL` / `CATEGORY_BAR`, y
  `blendCategoryColor` / `categoryColorStyle` para **mezclar** colores de
  rutinas/días multi-categoría.

---

## 4. Sistema de colores del calendario (reglas actuales)

- Solo las **sesiones ya realizadas** colorean un día; las rutinas programadas se
  muestran únicamente en la agenda semanal, no en las celdas.
- **Cardio (Remo) no cuenta como categoría** de color: un día con cardio + un
  grupo muscular pertenece a ese grupo muscular.
- Los grupos musculares **no se infieren**: se eligen al iniciar la sesión
  (desde la rutina, o seleccionándolos en una sesión vacía) y se guardan en
  `session.categories`. La inferencia por ejercicios solo se usa como **respaldo**
  para sesiones antiguas sin ese dato (`sessionCategories()` en `utils.js`).
- Color del día = **mezcla** de los grupos musculares entrenados ese día.
- Etiqueta del día:
  - 1 grupo → su nombre (Push / Pull / Legs).
  - 2 grupos → nombres concatenados (ej. **"Push Pull"**).
  - 3 grupos (Push + Pull + Piernas) → **"Full Body"**, con color destacado
    (degradado naranja→azul→verde con borde magenta y resplandor).
- **Resumen mensual**: cuenta cada grupo por **cada día** en que se entrenó
  (un día Push+Legs suma 1 a Push y 1 a Legs; Full Body suma 1 a los tres). El
  total "days trained" sigue contando días, no grupos.

---

## 5. Usuarios y rutinas sembradas

- **`cuyi`** — contraseña = `API_TOKEN` (`.env`). Tiene las 15 rutinas del PDF
  (Push/Pull/Squats niveles 1–5) más una rutina combinada
  **"Push L3 + Pull L2 + Squat L3"** (categorías Push+Pull+Piernas).
- **`demo`** — contraseña `1234`. Un año de sesiones generadas + rutinas demo
  (Push day, Pull day, Leg day, Full body).

---

## 6. Puesta en marcha

```bash
# desde la raíz del proyecto
docker compose up -d --build

# ver estado
docker ps

# reconstruir solo un servicio tras cambios
docker compose build frontend && docker compose up -d frontend
docker compose build backend  && docker compose up -d backend
```

La app queda disponible en `http://localhost:${PORT}` (por defecto 50666).

---

## 7. Respaldo de la base de datos

```bash
docker exec calistia-db pg_dump -U calistia -d calistia > backup_calistia_$(date +%Y%m%d_%H%M%S).sql
```

---

## 8. Bitácora de cambios

> Añadir una entrada al final por cada cambio que pida el usuario (más nuevo
> abajo). Formato: `- [fecha] descripción · archivos tocados`.

- [2026-07-17] Respaldo de BD generado en la raíz (`backup_calistia_*.sql`, `pg_dump`).
- [2026-07-17] Rutina combinada de `cuyi` **"Push L3 + Pull L2 + Squat L3"**
  (id `rt_cuyi_combo_push3_pull2_squat3`, categorías `["Push","Pull","Piernas"]`,
  sin cooldown de cardio, supersets renumerados por bloque). Insertada por script
  directo en la BD.
- [2026-07-17] Calendario: las celdas se colorean **solo con sesiones realizadas**;
  se quitó la vista previa de rutinas programadas de las celdas. · `Calendar.jsx`
- [2026-07-17] **Cardio (Remo) deja de contar como categoría de color** en todos
  lados; días multi-grupo usan color **mezclado**; se limpió `Remo` de las
  categorías guardadas (backfill idempotente al arrancar backend). ·
  `Calendar.jsx`, `Routines.jsx`, `seeds.py`
- [2026-07-17] Etiqueta del día = nombres concatenados ("Push Pull"); 3 grupos =
  **"Full Body"** con color destacado (degradado naranja→azul→verde + borde
  magenta + glow). · `Calendar.jsx`
- [2026-07-17] Resumen mensual cuenta **cada grupo por cada día** entrenado (no
  solo el dominante); total "days trained" = nº de días. · `Calendar.jsx`
- [2026-07-17] Creado este `RESUMEN.md` como archivo de contexto del agente; se
  acordó mantener esta bitácora al final del archivo.
- [2026-07-17] Historial: el pill de cada sesión ahora refleja **todos** los
  grupos entrenados (antes solo el dominante) → concatenado ("Push Pull") o
  **"Full Body"** con color destacado, cardio excluido. Se extrajeron helpers
  compartidos (`muscleCategoriesOf`, `isFullBody`, `groupLabel`,
  `FULL_BODY_STYLE`) a `exercises.js`, reusados en `Calendar.jsx` e `History.jsx`;
  se eliminó `dominantCategory` de `utils.js` (sin uso). · `exercises.js`,
  `Calendar.jsx`, `History.jsx`, `utils.js`
- [2026-07-17] Los grupos musculares ya **no se infieren**: se seleccionan al
  crear rutina (ya obligatorio) o al iniciar **sesión vacía** (nuevo selector en
  `RoutineChooser`), y se guardan en `session.categories` (nueva columna JSON +
  migración). Calendar/History leen `session.categories` con respaldo a
  inferencia (`sessionCategories()` en `utils.js`) para sesiones antiguas. ·
  `db.py`, `serializers.py`, `RoutineChooser.jsx`, `Dashboard.jsx`, `Routines.jsx`,
  `utils.js`, `Calendar.jsx`, `History.jsx`
- [2026-07-17] El editor de sesión (`SessionEditor`) ahora permite **editar los
  grupos musculares** de una sesión: selector precargado con lo guardado (o lo
  inferido para sesiones antiguas) que se persiste en `session.categories`. ·
  `SessionEditor.jsx`
