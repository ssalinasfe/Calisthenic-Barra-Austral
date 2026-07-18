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
- [2026-07-18] **Pulsómetro Bluetooth (BLE) / frecuencia cardíaca.** Se conecta un
  cinturón HR por **Web Bluetooth** (perfil GATT estándar Heart Rate `0x180D` /
  measurement `0x2A37`); ANT+ no es accesible desde el navegador, solo el lado
  Bluetooth de bandas dual-band (p.ej. Decathlon HRM BELT). Requiere HTTPS/localhost
  y, en **Brave**, activar `brave://flags/#brave-web-bluetooth-api`.
  - Nuevo store `frontend/src/heartRate.js` (external store + hook `useHeartRate`):
    `connect`/`reconnect` (silencioso vía `navigator.bluetooth.getDevices()`)/
    `disconnect`/`forget`; dispositivo recordado en `localStorage` (`gym_hr_device`).
  - Nueva pantalla en **More → Heart Rate** (`components/HeartRate.jsx`): emparejar,
    ver BPM en vivo, estado, olvidar; avisos si Web Bluetooth no está disponible.
  - `Dashboard.jsx`: mientras la sesión está activa muestra BPM en vivo en la
    cabecera y **recoge una serie downsampled (~1 muestra/5 s)**; al finalizar guarda
    `avgHr`/`maxHr`/`minHr`/`hrSamples` en la sesión.
  - Se muestra el HR guardado en `SessionSummary.jsx` (banda con avg/max/min) e
    `History.jsx` (pill "❤️ avg bpm").
  - Backend: columnas nuevas en `sessions` (`avg_hr`,`max_hr`,`min_hr`,`hr_samples`
    JSON) con migración idempotente (`db.py`) y round-trip en `serializers.py`
    (`avgHr`/`maxHr`/`minHr`/`hrSamples`). · `db.py`, `serializers.py`,
    `heartRate.js`, `HeartRate.jsx`, `More.jsx`, `Dashboard.jsx`, `SessionSummary.jsx`,
    `History.jsx`
- [2026-07-18] **HR por serie + gráfico de pulso.** Verificado funcionando con el
  cinturón real (Decathlon HRM BELT sobre `gym.ssalinas.cl` en Brave).
  - El cronómetro de cada serie (`ActiveSet` en `ExerciseCard.jsx`) muestra el **BPM
    en vivo** junto al tiempo. Mientras corre, acumula las lecturas (~1/s) y al pulsar
    Stop guarda por serie: **`startHr`** (pulso al apretar Start = primera lectura),
    **`avgHr`** y **`maxHr`**. (Se descartó `minHr` por serie a pedido del usuario.)
    `CompletedSet` muestra un chip "♥ avg" con tooltip start/avg/max.
  - `Dashboard.finalizeSession` propaga `startHr`/`avgHr`/`maxHr` por set.
  - `SessionSummary.jsx`: nuevo **gráfico de línea del pulso** (recharts) desde
    `session.hrSamples` (x = mm:ss, y = bpm); y cada set en Details muestra
    `start→avg (max)`.
  - Backend: columnas nuevas en `session_sets` (`start_hr`,`avg_hr`,`max_hr`) con
    migración idempotente y round-trip en serializers. · `ExerciseCard.jsx`,
    `Dashboard.jsx`, `SessionSummary.jsx`, `db.py`, `serializers.py`
- [2026-07-18] **Fix + detalle de HR en el resumen.**
  - **Bug fijado**: el HR por serie NO se guardaba porque el render pasaba
    `onStop={dur => stopSet(idx, dur)}` y descartaba `hrStats`. Ahora
    `onStop={(dur, hrStats) => stopSet(idx, dur, hrStats)}`. · `ExerciseCard.jsx`
  - `SessionSummary.jsx` **Details**: cada ejercicio es ahora un
    `ExerciseDetailCard` **expandible** con tabla por rep (Rep, Reps, Weight [si se
    usó], Time, Rest, y ♥ Start/Avg/Max). La fila colapsada muestra un dot de color
    del ejercicio + badge "♥ avg/max".
  - **Gráfico de HR** pasó de `LineChart` a `ComposedChart`: la línea de pulso más
    un `Scatter` **por ejercicio** (color distinto, `EX_COLORS`) con un **punto por
    rep** en el segundo donde arrancó (y = `startHr` o bpm interpolado). Tooltip
    muestra el **nombre del ejercicio + nº de rep** al tocar el punto; leyenda de
    colores debajo. Se arregló el clipping del eje Y (width 40, margen). ·
    `SessionSummary.jsx`
- [2026-07-18] **Auto-reconexión del pulsómetro + indicador de estado.** Una
  conexión BLE no sobrevive a un reload (limitación del navegador), así que se
  reconecta sola y en silencio vía `navigator.bluetooth.getDevices()`.
  - `heartRate.js`: `autoConnect()` (llamado al montar Dashboard y la pantalla HR),
    `reconnect({silent})`, retry con backoff `scheduleReconnect` (hasta ~20 intentos,
    500 ms→10 s) disparado también en `gattserverdisconnected`. `manualDisconnect`
    evita reconectar tras Disconnect/Forget.
  - `Dashboard.jsx`: **indicador permanente en la cabecera** cuando hay un cinturón
    emparejado: conectado (♥ rojo + bpm), reconectando (♥ ámbar), o desconectado
    (`HeartOff` gris, tap para reconectar). Sustituye al BPM que solo salía en sesión.
    · `heartRate.js`, `Dashboard.jsx`, `HeartRate.jsx`
- [2026-07-18] **Diagnóstico de auto-reconexión.** El silent-reconnect solo funciona
  si el permiso BLE se concedió *después* de activar la flag
  `enable-web-bluetooth-new-permissions-backend` (si no, `getDevices()` devuelve
  vacío). `reconnect()` ahora retorna `{retriable}`: si el navegador NO recuerda el
  cinturón, no reintenta en bucle (inútil); si lo recuerda pero está fuera de rango,
  reintenta. Nuevo `probeRemembered()` + tarjeta en `HeartRate.jsx` que indica si el
  auto-reconnect está activo (verde) o no (ámbar, con pasos: Forget → re-emparejar
  con la flag activa → recargar). · `heartRate.js`, `HeartRate.jsx`
  - **Conclusión probada en el dispositivo del usuario**: en **Brave Android** el
    silent-reconnect NO funciona ni re-emparejando con la flag activa (`getDevices()`
    sigue vacío tras recargar; Brave no persiste el permiso BLE). Queda el reconnect
    de un toque (selector del navegador). El auto-reconnect real requiere **Chrome
    Android** (mismo código, sin cambios). El usuario decidió dejarlo así.
- [2026-07-18] **Estilo intermedio para combinados de 2 grupos** (p.ej. "Push Legs").
  Nuevo `comboCategoryStyle(cats, variant)` en `exercises.js`: degradado con los
  colores propios de los grupos + borde vivo (blend a 0.75) + glow suave (6px) —
  más llamativo que una categoría sola, más sobrio que `FULL_BODY_STYLE`. Reemplaza
  a `categoryColorStyle` para el caso multi-grupo (no full body) en el pill de
  `History.jsx` y el fill de celda de `Calendar.jsx`. · `exercises.js`,
  `History.jsx`, `Calendar.jsx`
- [2026-07-18] **Muscles (`MuscleStats.jsx`): filas de músculo expandibles.** Al
  tocar un músculo se despliega el desglose de **ejercicios** que lo trabajaron con
  sus **reps** y el **% que aporta al total de reps de ese músculo** (barra + %).
  `aggregate()` ahora guarda `byMuscle[m].exercises` como objeto `{name: {reps,sets}}`
  (antes `Set`); el % de cada ejercicio = `e.reps / muscle.reps`. · `MuscleStats.jsx`
- [2026-07-18] Muscles: el desglose por ejercicio ahora muestra **dos %**: el del
  músculo (`e.reps/muscle.reps`, en negrita) y el del **total del periodo**
  (`e.reps/stats.totalReps`, en gris), con leyenda aclaratoria. · `MuscleStats.jsx`
- [2026-07-18] **Progress: ejercicios isométricos medidos en segundos.** Nuevo flag
  `isometric: true` en el catálogo (Plank Hold, Passive Hang) + helper `isIsometric()`
  (con fallback por nombre: hold/hang/plank/wall sit/l-sit/hollow/bridge). En
  `ExerciseProgress.jsx`, si el ejercicio es isométrico, el gráfico/tendencia/historial
  usan **segundos sostenidos** (suma de `set.duration`) en vez de reps; la notación
  por sesión muestra los holds (ej. "45s · 40s"). El resto sigue en reps. ·
  `exercises.js`, `ExerciseProgress.jsx`
- [2026-07-18] Progress isométricos: la métrica pasó de **suma** a **promedio por
  set** (`avgSeconds`), para no premiar hacer más sets. Subtítulo "· avg hold per
  set". · `ExerciseProgress.jsx`
- [2026-07-18] **Progress: dos gráficos nuevos por ejercicio.** (1) **Peso por sesión**
  (kg, máx del set por sesión, ámbar) — solo si ≥2 sesiones con `weight`. (2) **Heart
  rate durante el ejercicio** (avg sólido + max punteado, por sesión) — solo si ≥2
  sesiones con `avgHr`; con nota "avg más bajo al mismo peso = corazón adaptándose".
  El historial ahora muestra el `{weight}kg` por sesión. · `ExerciseProgress.jsx`
- [2026-07-18] **Calendario: días clicables → abren el resumen completo.** Al tocar un
  día con sesión se abre `SessionSummary` (mismo detalle + gráficos que al terminar la
  sesión). Si el día tiene >1 sesión, primero un mini-picker para elegir cuál.
  `SessionSummary` ahora acepta `token` (renderiza las **fotos** de la sesión arriba,
  abribles en pestaña nueva) y `heading` (título configurable; el calendario pasa el
  título de la sesión). · `Calendar.jsx`, `SessionSummary.jsx`
- [2026-07-18] Detalle de sesión (`SessionSummary` `ExerciseDetailCard`): se quitó la
  columna "Rep" (se infiere por el orden); "Reps" pasa a ser la primera. La columna
  **Weight** ya existía (aparece si `hasWeight`); además se añadió un **badge de peso**
  (`{maxWeight}kg`, ámbar) en la fila colapsada del ejercicio para verlo sin expandir.
  · `SessionSummary.jsx`
- [2026-07-18] Gráfico "Reps per exercise vs previous session": los puntos de la línea
  **Today** se colorean con el color del ejercicio (`EX_COLORS`, mismo que Details y el
  gráfico de pulso) vía dot custom `ExerciseDot` + `color` en cada dato. · `SessionSummary.jsx`
- [2026-07-18] Gráfico reps vs previous: se invirtió el orden de las líneas (Previous
  primero, **Today encima**) para que el punto de color no quede tapado; punto de Today
  agrandado (r=7/activeDot 9), Previous achicado (r=3). · `SessionSummary.jsx`
- [2026-07-18] **Reorganización de navegación.** Barra inferior ahora:
  **Train · Calendar · Muscles · Progress · More** (5 tabs). `Muscles` (`MuscleStats`)
  y `Progress` (`ExerciseProgress`) pasaron de estar dentro de More a ser tabs
  propias en `Dashboard.jsx`. **History** salió de la barra y ahora es una entrada del
  menú **More** (primera de la lista). · `Dashboard.jsx`, `More.jsx`
- [2026-07-18] **Cardio en el calendario solo si es lo único de la sesión.** Recordatorio:
  la categoría interna `Remo` = etiqueta "Cardio" (nombre heredado; el usuario nunca ve
  "Remo"). `tallyByDay` ahora marca `hasCardio` por día; en la celda, si no hay grupos
  musculares (`cats` vacío) pero `hasCardio`, se usa `['Remo']` → la celda se colorea
  cian y muestra "Cardio". Con grupos musculares presentes, cardio sigue oculto. El
  Month summary y la leyenda NO cambian (cardio sigue fuera). · `Calendar.jsx`
- [2026-07-18] Catálogo: nuevo ejercicio **Jogging / Trotar** (id 32, `category: 'Remo'`
  = Cardio, `muscles: ['Heart']`, sin `type` machine porque es al aire libre). El
  buscador (`ExerciseSearch`) usa `EXERCISES` del frontend, no hace falta tocar backend.
  · `exercises.js`
- [2026-07-18] Catálogo: nuevo ejercicio **Burpees** (id 33, `category: 'Remo'` = Cardio,
  `muscles: ['Heart']`). El usuario lo clasificó como Cardio (es full-body: push+legs+
  cardio, sin pull, pero eligió tratarlo como acondicionamiento). · `exercises.js`
