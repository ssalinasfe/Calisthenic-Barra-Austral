# Barra Austral — Estado del proyecto (archivo de contexto del agente)

> **AUDIENCIA: el agente (Claude), no el usuario.** El usuario no lee esto.
> Es la memoria del proyecto para recuperar contexto tras una compactación.
> Ya hay git (desde ~ago-2026), pero la bitácora de abajo sigue siendo el
> historial con contexto y decisiones. **Mantenerlo actualizado:**
> al terminar cada cambio que pida el usuario, añadir una entrada a la
> **Bitácora de cambios (al FINAL del archivo)** y ajustar la sección afectada.
> Escribir denso y factual, sin relleno.

App de seguimiento de entrenamiento de calistenia (peso corporal), autoalojada
(Docker + Cloudflare Tunnel). Plan de rutinas por niveles ("un día, una rutina":
Push / Pull / Squats en 5 niveles).

---

## 0. Orientación rápida (leer esto primero)

**Ubicación:** `/home/david/apps/appGym`. Entorno Linux, zsh. **Sí es repo git**
(remoto `github.com:ssalinasfe/Calisthenic-Barra-Austral`, rama `main`).

**Cómo se ejecuta y se aplica un cambio** (siempre por Docker, no hay dev server):
```bash
docker compose build frontend && docker compose up -d frontend   # tras tocar React
docker compose build backend  && docker compose up -d backend    # tras tocar Python
```
Contenedores: `barra-austral-frontend`, `barra-austral-backend`, `barra-austral-db`.
Acceso a la BD: `docker exec barra-austral-db psql -U calistia -d calistia -c "..."`.

**Archivos que más se tocan:**
- Color/etiquetas del calendario → `frontend/src/components/Calendar.jsx`.
- Categorías/colores y catálogo → `frontend/src/exercises.js`.
- Editor de rutinas y selector de categoría → `frontend/src/components/Routines.jsx`.
- Modelos/semillas backend → `backend/db.py`, `backend/seeds.py`, `backend/seed_cuyi.py`.
  (`seed_demo.py` ya no existe; los datos demo se generan en `seeds.py`.)

**El registro cronológico de cambios está en la _Bitácora de cambios_ al final
del archivo.**

**Gotchas / decisiones:**
- **`data/users/*.json` es storage MUERTO** (previo a Postgres, mayo 2026). Ningún
  archivo del backend lo referencia. No editarlo creyendo que cambia algo.
- Hay git, pero gran parte del trabajo previo se hizo sin él → este MD sigue
  siendo la memoria con el "por qué" de cada decisión.
- **Convención de nombres del catálogo**: si un ejercicio requiere equipo, el
  nombre lo lleva (equipo primero en inglés: `Kettlebell Swings`, `Barbell Squat`,
  `Bent Over Barbell Rows`; en español "… con pesa rusa / con barra"). Pedido por
  el usuario el 14-ago-2026. **OJO: no renombrar ejercicios ya existentes** — las
  sesiones guardan el nombre como string, renombrar orfana el historial.
- **Hablarle al usuario siempre en español chileno**, nunca en argentino/rioplatense
  (nada de "vos"/"probalo"/voseo porteño). App y usuario son chilenos.
- Todo se guarda como **un blob JSON completo** por usuario (`POST /api/data`
  reemplaza todo). El modelo `routines` tiene columna `categories` (JSON).
- Cambios directos en BD para `cuyi` se hicieron por script vía
  `docker exec -i barra-austral-backend python3 < script.py` (usa los modelos).
- El backend, al arrancar, corre `run_seeds()` que incluye backfills y
  `strip_cardio_from_routine_categories()` (idempotentes).

---

## 1. Arquitectura general

| Capa       | Tecnología                                   | Contenedor            |
|------------|----------------------------------------------|-----------------------|
| Frontend   | React 18 + Vite + Tailwind (servido por Nginx)| `barra-austral-frontend` |
| Backend    | FastAPI (Python) + SQLAlchemy                | `barra-austral-backend`  |
| Base datos | PostgreSQL 16                                | `barra-austral-db`         |

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
  - `GET /api/data` — leer el blob completo del usuario.
  - `POST /api/data` — **reemplazo PARCIAL**: solo borra y reescribe las
    colecciones **presentes** en el payload. `{"routines":[...]}` no toca
    sesiones. **OJO: mandar `{"x":[]}` borra esa colección entera** (así se
    perdieron las rutinas de cuyi el 14-ago).
  - `POST /api/sessions` — upsert de UNA sesión (lo que usa terminar/editar un
    entrenamiento). Exige `id` y `startTime` o devuelve 400.
  - `DELETE /api/sessions/{id}` — borra una sesión; 404 si no existe.
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
  `routine_id` como referencia débil). Columnas de pulso:
  - `avg_hr` / `max_hr` / `min_hr` — agregados de la sesión.
  - `hr_samples` — **toda** lectura de la banda, una por segundo:
    `[{t, bpm, contact?, energy?, rr?}]`. `t` = segundos desde el inicio, eje
    compartido por el gráfico, los eventos y el HRV. Ya NO se diezma.
  - `events` — log de diagnóstico `[{t, type, inferred?}]`. **NULL = el backfill
    de `seeds.py` no la ha visto; `[]` = vista y sin nada que anotar.**
  - `hr_device` — identidad de la banda y serie de batería:
    `{name, manufacturer, model, firmware, sensorLocation, battery:[{t,pct}]}`.
- `session_exercises` / `session_sets` — ejercicios y series efectivas por sesión
  (reps, peso, duración, descanso, `start_hr`/`avg_hr`/`max_hr`).
- `photos` — fotos asociadas a una sesión.

---

## 3. Frontend (`/frontend/src`)

Punto de entrada `App.jsx`: si no hay token muestra `LockScreen`, si lo hay
muestra `Dashboard`. El token y el fondo se guardan en `localStorage`. Fondo de
pantalla personalizable con overlay.

### Navegación principal (`Dashboard.jsx`)
**Cinco** pestañas (const `NAV`): **Train · Calendar · Muscles · Progress ·
More**. History **no** es pestaña: vive dentro de More. Gestiona la sesión
activa, el cronómetro y el guardado.

Claves de `localStorage` de la sesión activa (tres, a propósito separadas —
cadencias de escritura distintas):
- `gym_active_session` — estructura de la sesión; se reescribe al cambiar un set.
- `gym_active_hr` — serie de pulso; espejo cada ≤5s mientras llegan lecturas.
- `gym_session_log` — log de eventos; se escribe en CADA evento.

### Módulos (no componentes) en `frontend/src`
- **`api.js`** — `fetchData`, `saveData` (parcial), `saveSession`,
  `deleteSession`, fotos.
- **`heartRate.js`** — Web Bluetooth, store externo. Parsea el paquete GATT
  completo (bpm, contacto, RR, energía) y lee batería / ubicación / fabricante /
  modelo / firmware al conectar.
- **`sound.js`** — beep de descanso y tics (`gym_rest_beep`, persistido).
- **`autoRun.js`** — piloto automático de circuito + coordinación entre tarjetas
  (solo un descanso corriendo a la vez). No persistido.
- **`wakeLock.js`** — mantiene la pantalla encendida (`gym_wake_lock`, persistido).
- **`sessionLog.js`** — log de eventos de diagnóstico de la sesión.
- **`hrv.js`** — RMSSD/SDNN/pNN50 desde intervalos RR, con filtro de artefactos.
- **`exercises.js`** — catálogo, colores y `migrateData`.
- **`utils.js`** — `setNotation`, `fmtDuration`, `sessionCategories`, etc.

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
- **`More`** — menú con cinco secciones: **History**, **Routines**, **Locations**,
  **Heart Rate** (emparejar la banda y ver bpm en vivo) y **Documentation**.
  Muscles y Progress **no** están acá: son pestañas propias (`MuscleStats.jsx`,
  `ExerciseProgress.jsx`).
- **`Routines`** — crear/editar rutinas: ejercicios, tempo/reps/sets/descanso,
  supersets, días programados y **categoría/color**.
- **`SessionLogModal`** — visor del log de eventos ("View logs"), abierto desde la
  sesión activa y desde el resumen.
- **`Settings`** — fondo de pantalla y toggle del wake lock.

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

- **`cuyi`** — contraseña = `API_TOKEN` (`.env`). **17 rutinas en la BD**, pero
  **el seeder solo tiene 15** (`seed_cuyi.routines_for_cuyi()`: Push/Pull/Squats
  niveles 1–5). Las otras dos las creó el usuario y **NO se regeneran**:
  **"Push L3 + Pull L2 + Squat L3"** y **"Misión Rusa (Kettlebell)"**. Si se
  borran, hay que sacarlas de un backup (pasó el 14-ago).
- **`demo`** — contraseña `1234`. **Datos de demostración jun–oct 2026** (76
  sesiones con progresión realista de calistenia, HR, pesos y 9 fotos; ver
  bitácora 2026-07-18). Rutinas: Push Day, Pull Day, Leg Day, Full Body.
  Ubicaciones: Parque Bustamante, Casa, Cerro San Cristóbal. IDs de sesión con
  prefijo `demo-` (la PK de `sessions` es global; evita colisiones con cuyi).

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
docker exec barra-austral-db pg_dump -U calistia -d calistia > backup_calistia_$(date +%Y%m%d_%H%M%S).sql
```

Los `backup_*.sql` están en `.gitignore`: **traen tokens y hashes de contraseña**.
También está ignorado `data/photos/` (fotos personales, ~127 MB).

Verificar un respaldo restaurándolo en una base desechable (no basta con que el
archivo exista):
```bash
docker exec barra-austral-db psql -U calistia -d postgres -c "CREATE DATABASE prueba_restore;"
docker exec -i barra-austral-db psql -U calistia -d prueba_restore < backup_XXX.sql
docker exec barra-austral-db psql -U calistia -d prueba_restore -c "SELECT count(*) FROM sessions;"
docker exec barra-austral-db psql -U calistia -d postgres -c "DROP DATABASE prueba_restore;"
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
- [2026-07-19] **SessionSummary: mejoras de UI móvil.** (1) Gráfico de HR con botón
  **Expand** (`Maximize2`) → modal fullscreen (`z-[60]`) con el chart en un contenedor
  `overflow-x-auto` de ancho fijo (`maxT*0.7 px`, mín ancho de pantalla) para
  desplazar/inspeccionar con el dedo; tooltip al tocar puntos sigue funcionando. Se
  extrajo `HrComposedChart` reutilizable (inline vía ResponsiveContainer, expandido con
  width/height fijos). (2) `ExerciseDetailCard` ahora es de **dos filas**: arriba color +
  nombre completo (ya no se corta) + chevron; abajo los datos (kg, ♥ avg/max, notación,
  reps) alineados bajo el nombre. Toca la tarjeta para ver la tabla por rep. · `SessionSummary.jsx`
- [2026-07-19] Gráfico de HR: **zona de quema de grasa** marcada con banda ámbar +
  dos `ReferenceLine` en `FAT_BURN_ZONE = {low:112, high:131}` (60-70% de FCmáx para
  edad 33; constante fácil de cambiar). El dominio del YAxis se expande para que la zona
  siempre sea visible. Aplica tanto al gráfico inline como al expandido (comparten
  `HrComposedChart`). · `SessionSummary.jsx`
- [2026-07-19] Banner de HR: dos métricas nuevas de **distribución vs la zona** (desde
  `session.hrSamples`, cada muestra ≈ tiempo igual): **% en zona** (112–131), **% arriba**
  (>131) y % abajo, con barra apilada (gris/ámbar/rojo). `hrZone` memo. · `SessionSummary.jsx`
- [2026-07-18] **Revisión de músculos del catálogo** (pedida por el usuario):
  Banded Pull-downs `['Lats','Back']` → `['Lats','Mid Back']` (se eliminó el músculo
  genérico `Back`, era su único uso); Passive Hang → solo `['Forearms']` (en colgado
  pasivo el dorsal está en estiramiento); Deep Squats → `['Quads','Glutes']` (sin
  Hamstrings). Se quitaron `Back` y `Calves` de `MUSCLE_ES` (sin ejercicios que los
  usen; el usuario decidió no añadir ejercicios de pantorrilla). **Backend
  sincronizado**: se añadieron Jogging (32) y Burpees (33) a `CATALOG` en `seeds.py`
  (faltaban; solo existían en el frontend) y se replicaron las 3 correcciones de
  músculos. Verificado en BD tras rebuild. Plank Hold queda en `Push` a propósito
  (decisión del usuario, viene del PDF como calentamiento). · `exercises.js`, `seeds.py`
- [2026-07-18] **Regla de cardio aclarada por el usuario**: cardio SÍ es categoría de
  color, pero solo cuando es lo ÚNICO de la sesión/día; con grupos principales
  presentes se ignora. (El Calendar ya lo hacía; ver fix de History abajo.)
- [2026-07-18] **Revisión completa del código → lote de fixes de inconsistencias:**
  - `MuscleStats.jsx`: el fallback por categoría devolvía músculos en español
    ('Pecho'…) y 'Otro' → ahora claves canónicas en inglés ('Chest'…, 'Other').
  - `SessionEditor.jsx`: renombrar un ejercicio ahora actualiza también su
    `category` cuando se elige del catálogo (antes solo el nombre → grupos mal);
    cambiar fecha/hora desplaza `endTime` y los `startedAt` de los sets por el
    mismo delta (antes quedaban desalineados); se quitó la prop muerta
    `existingNames` de `AddExerciseBar`.
  - `FinishSessionModal.jsx`: quitar una foto subida, Skip o cancelar ahora borran
    los archivos del disco (`deletePhoto`); antes quedaban huérfanos.
  - `Routines.jsx` / `Locations.jsx`: editar ya no reordena (reemplazo in-place,
    antes `[...others, updated]` mandaba el elemento al final). Tempo `maxLength`
    4→8 (la semilla Pull L4 usa '10000', 5 dígitos; la BD admite 8).
  - `History.jsx`: sesión solo-cardio ahora muestra pill "Cardio" cian (misma
    regla que las celdas del Calendar). Comentario de la regla actualizado en
    `exercises.js` (`MUSCLE_ORDER`).
  - `SessionSummary.jsx`: se eliminó el `fmtDuration` duplicado (usa `utils.js`);
    el CSV del cliente ahora tiene las MISMAS columnas que `/api/export/csv`.
  - Backend: **borrado `seed_demo.py`** (código muerto, nadie lo importaba y
    divergía de `seed_demo_data` en `seeds.py`); `_ROUTINE_CATEGORIES` del demo
    full body ya no incluye 'Remo' (antes lo escribía un backfill y lo borraba
    otro); `user_data_to_json(user)` sin el param `db` sin uso (4 call sites en
    `main.py`); quitado `by_name` sin uso en `seeds.py`.
  - Verificado tras rebuild: login demo, `/api/data` (169 sesiones), export CSV
    con columnas nuevas, `rt_demo_full_body` = Push/Pull/Piernas. ·
    `MuscleStats.jsx`, `SessionEditor.jsx`, `FinishSessionModal.jsx`,
    `Routines.jsx`, `Locations.jsx`, `History.jsx`, `SessionSummary.jsx`,
    `exercises.js`, `seeds.py`, `serializers.py`, `main.py`, `seed_demo.py` (borrado)
- [2026-07-18] **Fondos de pantalla arreglados y ampliados.** Causa de los fondos
  NEGROS: las URLs externas de wallhaven/alphacoders bloquean hotlinking (403 con
  Referer de otro sitio; con curl sin Referer dan 200) → **regla: todo fondo debe
  vivir en `frontend/public/`** (local). Cambios:
  - Descargados los 14 fondos anime externos → `anime-01..14` (anime-02 es `.png`;
    el `.jpg` de wallhaven no existía). Sin ImageMagick/ffmpeg en el host, así que
    anime-04 (8MB) y anime-06 (5.6MB) quedaron sin re-comprimir.
  - **30 fondos nuevos** `fit-01..30.jpg` (Unsplash CDN, `?w=1600&q=75`, estética
    fitness/gym realista para público general), validados uno a uno (JPEG >40KB).
  - Se conectaron al selector los **18 `cal-wp*.jpg`** de calistenia que estaban
    huérfanos en `public/` desde mayo (descargados pero nunca enlazados).
  - `Settings.jsx`: PRESETS → `SECTIONS` con encabezados (Fitness·Gym 30 /
    Calistenia 18 / Zero Two 8 / Anime gym 15), grid scrolleable `max-h-96`.
  - `App.jsx`: `BG_MIGRATION` — si `gym_bg` en localStorage es una de las URLs
    externas viejas, se migra sola a la copia local al cargar.
  - `public/` pesa 34MB. Verificado: todos los fondos sirven 200 vía nginx. ·
    `Settings.jsx`, `App.jsx`, `frontend/public/` (+45 archivos)
- [2026-07-18] **Fondos v2 — curados a mano, verticales, y sección Chile.** Feedback
  del usuario sobre la v1: (a) es una app de CALISTENIA, nada de pesas/máquinas;
  (b) el uso principal es el celu → fondos verticales; (c) app chilena → fondos de
  Chile; (d) no recortar los apaisados: que el código los adapte.
  - Flujo de curación: descarga de ~44 candidatas fitness (Unsplash, vertical
    1080×1920) + 20 de Chile (API de **Wikimedia Commons**, única búsqueda abierta:
    Unsplash napi y wallhaven no sirvieron) → hojas de contacto con Pillow en un
    contenedor `python:3.11-slim` efímero → **revisión visual del agente** →
    seleccionadas 21 fitness (descartadas todas las de barras/mancuernas/máquinas)
    y 18 de Chile (Villarrica, Torres del Paine, Atacama, Chiloé, Capillas de
    Mármol, Santiago, Valparaíso…).
  - **Ojo Docker**: el daemon NO ve `/tmp` (mounts salen vacíos); montar solo rutas
    bajo `/home`. Pillow en contenedor también re-comprimió anime-04/06 (8MB→295KB).
  - `fit-01..21.jpg` = verticales curadas (reemplazan el set v1 de 30 apaisadas);
    `chile-01..18.jpg` = **apaisadas sin recortar** (max 1920px).
  - **Adaptación por orientación** (`App.jsx` + `index.css`): al cargar el fondo se
    compara su orientación con la de la pantalla; si difieren → modo `blurfill`:
    imagen completa centrada (`contain`) sobre una copia desenfocada que rellena
    los bordes (`.backdrop-blur-fill`). Si coinciden → `cover` normal. Recalcula
    en `resize`.
  - `Settings.jsx`: secciones Fitness·Calistenia (21) / Chile (18) / Calistenia
    wallpapers (18) / Zero Two (8) / Anime gym (15); thumbs `aspect-[3/4]`,
    `grid-cols-5`. Fuentes de cada imagen en `public/CREDITS-fondos.txt`.
  - `public/` quedó en 29MB. Verificado: fondos sirven 200, app carga. ·
    `Settings.jsx`, `App.jsx`, `index.css`, `frontend/public/`
- [2026-07-18] **Fondos v3 — celu SIEMPRE pantalla completa.** El usuario vio la
  imagen "chica con bordes negros" en el celu por DOS causas: (1) su celu tenía
  cacheada la v1 apaisada de `/fit-01.jpg` (mismo nombre, contenido distinto) y el
  blur-fill la letterboxeó correctamente; (2) la regla v2 aplicaba blur-fill
  también en el celu para imágenes apaisadas. Reglas nuevas:
  - **Viewport vertical (celu): siempre `cover`** — llena la pantalla, recorta lo
    que haga falta, jamás bordes. **Viewport horizontal (PC): blur-fill solo si la
    imagen es vertical**; apaisadas → cover.
  - Set fitness **renombrado `fit-*` → `cw-01..21.jpg`** para reventar el caché
    (lección: al reemplazar contenido de un asset, cambiar el nombre). `migrateBg()`
    en `App.jsx` migra lo guardado en localStorage (mapa de URLs externas + regex
    `/fit-NN.jpg` → `/cw-NN.jpg`). Verificado: `cw-*` y `chile-*` sirven 200,
    `/fit-01.jpg` da 404. · `App.jsx`, `Settings.jsx`, `frontend/public/`
- [2026-07-18] **Datos demo regenerados: jun–oct 2026 (para demos de la app).**
  Se borró TODO lo del usuario `demo` (169 sesiones viejas, rutinas, ubicaciones)
  y se regeneró por script directo en la BD (patrón `docker exec -i
  barra-austral-backend python3 < script`; NO se tocó `seeds.py` — `seed_demo_data`
  solo corre si demo no tiene sesiones, así que no interfiere). Resultado:
  **76 sesiones** (13-19/mes) con:
  - **Progresión realista**: dominadas Band Assisted → Negativas → 1ª estricta
    (15-jul) → lastradas 2.5→7.5kg (desde 16-sep) → PR 10 reps (28-oct); pistol
    asistida → libre (11-sep); plank 45s→99s; sentadillas con mochila 6→10kg
    (desde 14-ago); Archer push-ups desde ~10-ago; One-arm desde mediados oct.
    OJO: el usuario ELIGIÓ el año 2026 aunque parte sea futuro — va a presentar
    la app en los próximos meses y quiere el calendario del mes actual lleno.
    Primero se generó jun–oct 2025; se regeneró a 2026 recalculando los hitos
    para que cayeran en los weekdays correctos (lun push/mié pull/vie legs/sáb
    full).
  - **Tipos de sesión**: Push/Pull/Leg Day, Full Body (sáb), Upper Body (mixto,
    1 lunes de cada 4 desde ago), cardio-only (Trote matutino / Burpees + trote,
    → celda cian "Cardio"), semana de vacaciones 17-23 ago (solo un trote).
  - **HR**: desde el 13-jun ("estrena el cinturón", nota milestone). Curva
    sintética muestreada cada 5s (`hrSamples`), avg/max/min por sesión y
    startHr/avgHr/maxHr por set. Coherente: trote avg~147 > burpees 142 > legs
    123 > push 117 > pull 114; el fitness mejora (misma carga, menos bpm).
  - **9 fotos** (hitos + foto de progreso mensual el 1er sábado): archivos en
    `data/photos/demo/` (copias de `cw-*.jpg` con nombre estilo upload real,
    subidas con `docker cp`; ojo: docker snap NO lee `/tmp` ni dot-dirs de
    `$HOME` → staging en dir visible bajo `/home`). El calendario muestra la
    miniatura en la celda del día.
  - Horarios en UTC que mapean a tarde/mañana de Chile (UTC-4 invierno, -3 tras
    6-sep); notas en español (pool + hitos). Rutinas demo recreadas con targets
    reales; ubicaciones chilenas (Parque Bustamante, Casa, Cerro San Cristóbal).
  - **Aislamiento entre usuarios verificado** (pedido explícito del usuario):
    todos los endpoints filtran por token→usuario; fotos en
    `data/photos/<username>/`; lo único compartido es el catálogo `exercises`.
    IDs de sesión demo con prefijo `demo-` (la PK de sessions es global).
    Conteos de cuyi idénticos antes/después (35 ses / 16 rut / 2 loc / 33
    fotos). Verificado por API: login demo, blob completo, fotos 200.
- [2026-07-20] **Filas de series sin unidades inline: encabezados de columna.**
  Se quitaron las etiquetas "reps"/"kg" a la derecha de los inputs de cada serie
  y se añadió una fila de encabezado sobre las columnas. En `ExerciseCard.jsx`
  (Train, `CompletedSet`): encabezado "reps · kg" alineado por anchos fijos
  (w-5 índice / w-14 tiempo / flex-1 reps / w-14 kg / w-6 botón X). En
  `SessionEditor.jsx` (`SetRow`): se quitaron también el "s" de duración y el
  encabezado es "kg · time · reps" (mismo orden de los inputs: peso, duración,
  reps). · `ExerciseCard.jsx`, `SessionEditor.jsx`
- [2026-07-20] Banner de rutina en Train: el "rest" pasa de segundos ("180s") a
  `fmtDuration` de `utils.js` ("3m 0s"), el formato estándar de duraciones de la
  app (el usuario rechazó el intermedio "03:00"). · `ExerciseCard.jsx`
- [2026-07-20] **Catálogo: Warm-up (34, "Calentamiento") y Cool-down (35,
  "Enfriamiento")**, `category: 'Remo'` (Cardio), `muscles: ['Heart']` — como
  Jogging/Burpees, así no ensucian stats de músculos ni colores. Añadidos a las
  **20 rutinas** de la BD (16 cuyi + 4 demo) por script directo (patrón
  `docker exec -i barra-austral-backend python3 < script`, idempotente): Warm-up en
  posición 0 (resto desplazado +1) y Cool-down al final, ambos `timeSeconds:300`,
  1 set, rest 0. (Hubo un vaivén: el usuario pidió quitarlos de demo y al tiro
  los volvió a querer — quedaron en TODAS las rutinas.) `seed_cuyi.py` NO se
  tocó (solo corre si cuyi no tiene rutinas). Verificado en BD: 40 filas =
  2×20 rutinas. · `exercises.js`, `seeds.py`, BD
- [2026-07-21] **Beep al terminar el descanso entre sets + botón on/off.** Nuevo
  módulo `sound.js` (mismo patrón external-store que `heartRate.js`): `playBeep()`
  (Web Audio, dos tonos cortos) gateado por un flag `enabled` persistido en
  `localStorage` (`gym_rest_beep`, default ON), hook `useRestSound()`.
  `RestTimer` (`ExerciseCard.jsx`) ahora recibe `targetSeconds={exercise.restSeconds}`
  (el descanso objetivo de la rutina) y dispara el beep **una sola vez** al
  cruzar ese umbral (ref `beepedRef`, se resetea solo porque el componente se
  desmonta/remonta cada vez que `rest` pasa de null a no-null); el timer se
  pone verde cuando se cumplió el objetivo. Botón **Bell/BellOff** en el header
  de `Dashboard.jsx` (junto al cronómetro de sesión, visible solo con sesión
  activa) para mutear/activar el sonido globalmente. · `sound.js` (nuevo),
  `ExerciseCard.jsx`, `Dashboard.jsx`
- [2026-07-22] **Optimización de espacio durante la sesión activa.** (1) Se quitó la
  columna con el número de set (1,2,3…) de las filas de series — ya no aporta info,
  el orden es visual. Afecta `ActiveSet`/`CompletedSet` (Train) y `SetRow`
  (History → editar sesión), incluidos los spacers de encabezado. (2) El header
  (`Dashboard.jsx`) oculta "Barra Austral" y "@usuario" mientras `status === 'active'`
  (se mantiene el div `flex-1` vacío para no correr el resto del layout), dejando
  más espacio para el cronómetro grande y el BPM sin tener que sacar el botón de
  campana (beep). Fuera de sesión activa se ve todo igual que antes. ·
  `ExerciseCard.jsx`, `SessionEditor.jsx`, `Dashboard.jsx`
- [2026-07-22] **Countdown de 5s antes de contar ejercicios isométricos.** Al
  presionar "Start set" en un ejercicio isométrico (`isIsometric()`, catálogo:
  solo **Plank Hold** y **Passive Hang** tienen `isometric: true`; no hay otros
  en `EXERCISES` que calcen con el fallback por nombre hold/hang/plank/wall
  sit/l-sit/hollow/bridge), `ActiveSet` (`ExerciseCard.jsx`) entra en fase
  `'prep'`: tarjeta ámbar "Prepárate…" con cuenta regresiva 5→1 (1s cada uno) y
  botón **Skip**. Al llegar a 0 (o Skip) pasa a fase `'active'` y ahí recién
  arranca el cronómetro del hold (mismo look cian de siempre); el tiempo de
  acomodo NO se guarda como duración del set ni se acumula HR (bpm solo se
  junta durante `'active'`, así `startHr` queda como el pulso al empezar el
  hold real, no al presionar Start). Ejercicios no isométricos sin cambios
  (arrancan directo en `'active'`). · `ExerciseCard.jsx`
- [2026-07-22] **Bip al arrancar el hold + tick cada 10s.** Nuevo `playTick()` en
  `sound.js` (beep corto único, distinto del triple beep de fin de descanso) para
  no confundir señales. En `ActiveSet` (`ExerciseCard.jsx`): al pasar de `'prep'`
  a `'active'` (countdown llega a 0 o se presiona Skip) suena `playBeep()` (el
  mismo triple-beep de siempre, como "go"); mientras el hold corre, cada 10s de
  `elapsed` (10, 20, 30…) suena `playTick()`. Ambos respetan el toggle
  Bell/BellOff del header (mismo flag `gym_rest_beep`). · `sound.js`,
  `ExerciseCard.jsx`
- [2026-07-22] **Catálogo: Bench Press (36) y Barbell Squat (37).** Bench Press
  `category: 'Push'`, `muscles: ['Chest','Triceps','Shoulders']` (mismo patrón
  que Push-ups, sin `type: 'machine'`, el peso se registra con el campo kg
  normal de cada set). Barbell Squat `category: 'Piernas'`,
  `muscles: ['Quads','Glutes','Hamstrings']` (como Bulgarian Split Squats).
  Añadidos con id fuera de la secuencia de su sección (36/37 al final, igual
  que Jogging/Burpees) para no reordenar ids existentes. Sincronizado
  frontend (`exercises.js`) + backend (`seeds.py` CATALOG, upsert idempotente
  al reiniciar); verificado en BD tras rebuild. · `exercises.js`, `seeds.py`
- [2026-08-14] **Catálogo: 10 ejercicios de kettlebell (38–47) + rutina "Misión Rusa".**
  Fuente: video de **Chuy Almada** "Misión Rusa FUERZA SUDOR y QUEMAR GRASA (22 Minutos)"
  (`youtube.com/watch?v=Pa2dSlRJm3Y`, 22:54). El listado de ejercicios NO está en la
  descripción ni en capítulos → se sacó de la **transcripción ASR** (yt-dlp standalone
  descargado al scratchpad; el host no tiene pip/yt-dlp y el endpoint `timedtext`
  directo devuelve vacío). Formato real: **10 ejercicios × 2 rondas, 40s trabajo /
  20s descanso**.
  - **Convención de nombres pedida por el usuario**: si el ejercicio requiere equipo,
    el nombre lo lleva (equipo primero en inglés: `Kettlebell Swings`, `Barbell Squat`;
    en español "… con pesa rusa"). Los 10 llevan `Kettlebell`/`pesa rusa` → buscables
    por implemento en `ExerciseSearch` (filtra por name, es y category).
  - Ejercicios (id, category, muscles): 38 Kettlebell Swings `Piernas`
    [Glutes,Hamstrings,Core,Shoulders]; 39 Single-arm Swings `Piernas`
    [Glutes,Hamstrings,Core,Forearms]; 40 Clean and Press `Push`
    [Shoulders,Triceps,Traps,Core]; 41 Squat + Halo `Piernas`
    [Quads,Glutes,Shoulders,Core]; 42 Thrusters `Push` [Quads,Glutes,Shoulders,Triceps];
    43 Deadlift + Around the Body `Piernas` [Hamstrings,Glutes,Core,Forearms];
    44 Lunges + Pass Through `Piernas` [Quads,Glutes,Hamstrings,Core];
    45 Sumo Squat + Upright Row `Piernas` [Quads,Glutes,Adductors,Traps];
    46 Kneeling Twists `Custom` [Core,Obliques]; 47 Russian Twists `Custom`
    [Core,Obliques]. Sección propia en `exercises.js` (bloque por **implemento**, no
    por patrón — es la primera vez que se rompe el agrupado por categoría).
  - **Nuevo músculo `Obliques` → 'Oblicuos'** en `MUSCLE_ES` (lo usan 46 y 47).
  - Categoría `Custom` (= "Other") para los dos twists: no existe categoría Core/Abs
    (Plank Hold vive en `Push` por decisión previa).
  - **Rutina `rt_cuyi_kb_mision_rusa`** ("Misión Rusa (Kettlebell)") creada para `cuyi`
    por script directo (patrón `docker exec -i barra-austral-backend python3 < script`,
    idempotente: borra y re-crea por id). 12 filas = Warm-up (pos 0, 300s) + los 10 en
    **un solo `superset_group=1`** (`Dashboard.jsx` lo pinta como bloque morado
    "Superset · do all back-to-back" = el circuito) con `targetSets=2`,
    `timeSeconds=40`, `restSeconds=20` + Cool-down (300s). `categories: ['Push','Piernas']`
    — el circuito **no tiene tracción real** (ni dominadas ni remo al torso), así que no
    es Full Body pese a venderse como tal.
  - Verificado tras rebuild: 47 ejercicios en `/api/exercises`, 17 rutinas de cuyi,
    38 sesiones intactas, frontend 200. · `exercises.js`, `seeds.py`, BD
- [2026-08-14] **Contenedores renombrados a `barra-austral-*`** (pedido del usuario:
  otra IA intentó bajar los contenedores creyendo que `calistia-db` no tenía relación
  con `gymtracker-*`). `docker-compose.yml`: `calistia-db` → **`barra-austral-db`**,
  `gymtracker-backend` → **`barra-austral-backend`**, `gymtracker-frontend` →
  **`barra-austral-frontend`**. Ahora los tres salen juntos en `docker ps`.
  - **Solo se cambió `container_name`, NO los nombres de servicio** (`db`, `backend`,
    `frontend`): el DNS interno de la red `gymnet` usa el nombre de SERVICIO —
    `DATABASE_URL=...@db:5432` y `proxy_pass http://backend:8000` en `nginx.conf`.
    Tocar los servicios habría roto ambas conexiones.
  - Seguro de recrear porque los volúmenes son **bind mounts** (`./data/postgres`,
    `./data`), no volúmenes nombrados: los datos viven en el host. Igual se hizo
    `pg_dump` antes (`backup_calistia_20260814_014533.sql`, 1.1 MB).
  - `cloudflared` NO se ve afectado: usa túnel con `TUNNEL_TOKEN` (config remota en
    el panel de Cloudflare) y vive en otra red (`cloudflare_default`), así que llega
    por el puerto publicado `${PORT}`, no por nombre de contenedor.
  - Se actualizaron las referencias en `RESUMEN.md` (12) y en `.claude/settings.json`
    (permiso `docker exec ... python3 -c`). **Sin tocar**: el usuario/BD de Postgres
    siguen siendo `calistia` (renombrarlos exige migración real y no se ve en
    `docker ps`), y `frontend/package.json` sigue con `"name": "gymtracker"` (nombre
    del paquete npm, interno al build).
  - Verificado tras recrear: 3 contenedores healthy, sin huérfanos, BD con 2 usuarios
    / 47 ejercicios / 114 sesiones / 21 rutinas / 45 fotos, login de cuyi OK,
    frontend 200, `/api/health` ok. · `docker-compose.yml`, `.claude/settings.json`
- [2026-08-14] **Solo un descanso corriendo a la vez (bug de descansos cruzados).**
  El estado `rest` vive DENTRO de cada `ExerciseCard`, así que "Start set (saves
  rest)" solo cortaba el descanso de esa misma tarjeta: al terminar una serie del
  ejercicio A (arranca su descanso) y partir una serie del ejercicio B, el descanso
  de A seguía corriendo y beepeando. Se notaba sobre todo en supersets (Misión
  Rusa: se rota entre 10 ejercicios).
  - Registro pub/sub a nivel de módulo en `ExerciseCard.jsx` (`restListeners` +
    `announceSetStart(owner)`): `addSet()` avisa al resto y **cada otra tarjeta
    finaliza su descanso** (lo guarda en su última serie completada, igual que
    Stop) — no se pierde el tiempo descansado. Identidad por `useRef({})` por
    montaje (no por `instanceId`).
  - El listener se registra con `[]` deps y usa refs (`restRef`, `exerciseRef`,
    `onChangeRef`) para leer props frescas desde el evento de otra tarjeta.
  - De paso: `stopRest(elapsed)` → **`finishRest()`** (sin argumento, calcula el
    elapsed desde `getCurrentRestElapsed()`, misma fuente que mostraba el timer),
    compartido por el botón Stop y el corte remoto; se extrajo `lastCompletedIdx()`
    (estaba duplicado en `setsWithRest` y `stopRest`).
  - Verificado: build OK, frontend 200. · `ExerciseCard.jsx`
- [2026-08-14] **Modo automático (piloto de circuito).** Botón ⚡ (`Zap`) en la
  cabecera junto a la campana, solo con sesión activa. Encadena la rutina sola:
  serie corre su `timeSeconds` → 3 ticks de cuenta regresiva → beep → **auto-Stop**
  → descanso corre su `restSeconds` → beep → **auto-Stop del descanso** → arranca
  el set siguiente. Pensado para circuitos de cardio con peso (Misión Rusa: 10
  kettlebell, 40s/20s, 2 rondas).
  - **Nuevo módulo `autoRun.js`** (external store, patrón de `sound.js`). Se llevó
    ahí también la coordinación entre tarjetas (`announceSetStart`) que estaba
    inline en `ExerciseCard.jsx` — es el único lugar que ve TODAS las tarjetas a
    la vez, porque el set activo y el descanso son estado local de cada card.
  - **Registro de tarjetas**: cada `ExerciseCard` se inscribe con
    `registerCard(ownerRef, cardRef.current)` y **reescribe su descriptor en cada
    render** (`order`, `group`, `targetSets`, `completed`, `running`, `resting`,
    `startSet`, `finishRest`) — identidad estable vía `useRef({})`, valores siempre
    frescos. `order` = índice que pasa `Dashboard`.
  - **Orden de avance** (`nextCard`): en superset rota al siguiente del bloque y
    **da la vuelta al primero** para la ronda siguiente; sale del bloque solo
    cuando TODOS llegaron a `targetSets`. Suelto: repite el mismo ejercicio hasta
    su `targetSets` y recién ahí avanza. `blockOf()` usa el run **contiguo** de
    `supersetGroup`, igual que el agrupado visual de `Dashboard`.
  - `ADVANCE_DELAY_MS = 400`: pausa entre sets Y el respiro que necesita React
    para volcar el set terminado al estado antes de contar `completed` (clave en
    el camino `restSeconds === 0`, que avanza sin esperar descanso).
  - Al **encender** con nada corriendo arranca el primer ejercicio pendiente; al
    terminar la rutina se **apaga solo**; `Dashboard` lo apaga al salir de
    `status === 'active'`. **No se persiste** (a diferencia del beep): es modo de
    un entrenamiento, y quedar armado tras un reload dispararía timers de sorpresa.
  - Si el ejercicio no tiene `timeSeconds` (reps), el set NO se auto-para: lo
    paras tú y desde ahí la cadena sigue igual. Pausar el descanso corta la cadena
    (escotilla de escape).
  - Al auto-arrancar una tarjeta se despliega (`setCollapsed(false)`) y hace
    `scrollIntoView` centrado, para que el celu muestre siempre el ejercicio que
    corre.
  - Verificado: build OK, frontend 200, y **simulación de la secuencia con el
    código real** (`nextCard`/`blockOf` extraídas del archivo por texto y
    evaluadas): Misión Rusa da 22 sets = Warm-up + 2 rondas de los 10 + Cool-down;
    ejercicio suelto de 3 sets se repite 3 veces antes de avanzar. ·
    `autoRun.js` (nuevo), `ExerciseCard.jsx`, `Dashboard.jsx`
- [2026-08-14] **Screen Wake Lock: la pantalla no se apaga durante la sesión.**
  Motivo: con la pantalla bloqueada Android estrangula los `setInterval` y el
  auto-Stop del modo automático + el beep de descanso llegan tarde o no llegan —
  justo cuando el celu está en el suelo. Nuevo `wakeLock.js` (external store,
  patrón de `sound.js`):
  - `navigator.wakeLock.request('screen')` mientras `enabled && wanted`; `wanted`
    lo setea `Dashboard` con `status === 'active'` (+ cleanup al desmontar).
  - **El sistema suelta el lock cada vez que la página deja de ser visible**, así
    que se re-pide en `visibilitychange` (listener global al importar el módulo).
    Pedirlo con la página oculta tira excepción → se chequea `visibilityState`.
  - Guardas: `requesting` contra requests solapadas, y si `enabled`/`wanted`
    cambiaron mientras el request estaba en vuelo se suelta al tiro (race).
    `catch` silencioso: si lo niegan (ahorro de batería, permissions policy) la
    app sigue igual.
  - **Toggle en Settings** ("Pantalla → Mantener la pantalla encendida"),
    preferencia persistida en `localStorage` (`gym_wake_lock`, default ON). Si el
    navegador no soporta la API el switch sale deshabilitado y lo dice.
  - Requiere contexto seguro: OK en `gym.ssalinas.cl` (HTTPS por el túnel) y en
    localhost. **Falta probar en Brave Android** (es Chromium y debería andar,
    pero ahí ya falló Web Bluetooth). · `wakeLock.js` (nuevo), `Dashboard.jsx`,
    `Settings.jsx`
- [2026-08-14] **Cuenta regresiva de 3 tics también en el descanso.** El set ya
  tenía los 3 `playTick()` antes de terminar (modo automático); el descanso solo
  tenía el triple beep final. Ahora `RestTimer` tickea igual los últimos 3s.
  Diferencia a propósito: los tics del SET solo existen en modo automático
  (dependen de `autoStopAt`), los del DESCANSO suenan **siempre que la rutina
  tenga `restSeconds`**, igual que el beep final que ya existía desde antes del
  piloto automático. No tickea en pausa (`rest.paused`) ni después del beep final
  (`beepedRef`). · `ExerciseCard.jsx`
- [2026-08-14] **Gráfico de pulso: línea punteada en los descansos.** Pedido del
  usuario. Recharts **no puede** puntear parte de una sola `<Line>`, así que el
  trazo se dibuja como **dos `<Line>` superpuestas** que se anulan mutuamente:
  `chart.work` (sólida, `bpm: null` en descanso) y `chart.rest` (punteada
  `strokeDasharray="4 5"`, opacidad .65, `bpm: null` en trabajo), ambas con
  `connectNulls={false}`.
  - **Clasificar por SEGMENTO, no por punto** (corregido el mismo día, ver abajo).
  - Ventanas de descanso reconstruidas en `hrChart` desde los sets guardados:
    `startedAt + duration` → `+ restDuration`, en segundos desde `startTime`.
  - `HrTooltip` arreglado: con dos series, `payload[0].value` puede ser el `null`
    de la otra → ahora busca el primer valor no nulo (`payload.find(...)`).
  - Leyenda "línea punteada = descanso" (inline y en la vista expandida), solo si
    `hasRest`.
  - **Ojo con los tiempos**: `startTime` y `startedAt` salen ambos por `_iso()`
    de `serializers.py` (sufijo `Z`), así que `new Date()` los interpreta igual y
    no hay desfase de zona. Si alguna vez se cambia uno solo, los punteados se
    desplazan enteros.
  - Verificado con sesión real de `cuyi` (2026-08-17, 417 muestras, 70 min):
    26 ventanas, 0 fuera de rango, 16 tramos punteados, 63% del tiempo en
    descanso, sin solapes. El bpm promedio sale MÁS ALTO en descanso (114 vs 111)
    — no es un error de alineación, es el lag cardíaco: el pulso peaquea después
    de terminar el esfuerzo. · `SessionSummary.jsx`
- [2026-08-14] **Fila del set: pulso ahora muestra `avg/max` (ej. `83/97`).**
  Antes solo salía `set.avgHr`; `startHr`/`maxHr` estaban únicamente en el
  atributo `title`, **inútil en celular** (no hay hover) — que es donde el usuario
  usa la app. El max va en `text-red-400/50` para que se lea como secundario, y
  **se oculta si `maxHr === avgHr`** (una sola lectura de la banda) para no
  mostrar "83/83". El `title` con start · avg · max se mantiene para escritorio.
  La tabla de detalle de `SessionSummary` ya tenía las 3 columnas separadas, no se
  tocó. · `ExerciseCard.jsx`
- [2026-08-14] **BUG corregido en la línea punteada (lo pilló el usuario).** Se
  veía casi todo punteado; tras iniciar un set salía sólido "un segundo" y volvía
  a punteado. **Las ventanas estaban bien** (trabajo vs descanso se pisan 1s en
  toda la sesión); el error era el **método de partición**:
  - v1 (malo): clasificar cada PUNTO y untar los vecinos a la punteada. En un set
    con 2 muestras AMBAS son frontera → la punteada se dibuja encima de la sólida
    y la tapa. Cossack Squats #1 (47s, 2 muestras) era justo ese caso.
  - v2 (malo también): clasificar cada SEGMENTO por su punto medio pero marcando
    los puntos en arreglos alineados a `samples`. Un segmento aislado entre dos
    del otro tipo necesita sus dos extremos en la otra línea → **se dibuja dos
    veces** (5 casos reales, medidos).
  - v3 (correcta): `lineFor(wantRest)` recorre los segmentos y emite **solo las
    corridas que le tocan**, separadas por un `{t, bpm: null}` explícito que
    quiebra el path. Los dos arreglos ya NO están alineados con `samples` ni
    entre sí, y eso está bien.
  - Verificado sobre la sesión real: 416 segmentos, 105 sólidos + 311 punteados =
    416, **0 dibujados dos veces, 0 mal clasificados**. Script de verificación:
    extrae `lineFor` del .jsx por texto y lo evalúa en node contra el JSON de la
    BD (así se valida el código real, no una copia).
  - **Hallazgo aparte, NO es bug del gráfico**: la banda se desconecta harto. En
    esa sesión hay 1 muestra cada 10.2s (esperado 5s), **24 huecos >20s que cubren
    el 48% del eje** (el mayor de 311s), y **10 de 27 ventanas de trabajo tienen 0
    o 1 muestra** → esos sets no tienen pulso registrado y la línea que los cruza
    es interpolación entre puntos lejanos. · `SessionSummary.jsx`
- [2026-08-14] **La línea se corta cuando no hay señal de la banda.** Constante
  `HR_GAP_S = 20` en `SessionSummary.jsx` (la banda se muestrea cada ~5s, así que
  un hueco >20s son ≥3 lecturas perdidas: es caída, no jitter). En `lineFor`, el
  segmento que cruza un hueco **no lo toma ninguna de las dos líneas** → queda el
  vacío visible en vez de una recta inventada.
  - Verificado sobre la sesión real: 416 segmentos = 93 sólidos + 299 punteados +
    24 omitidos por hueco, 0 duplicados, y **0 segmentos dibujados cruzan un hueco
    >20s**. Queda el 50% del eje en blanco: es la mitad de la sesión sin señal.
  - **Cómo se "detecta" la desconexión: NO se detecta, se infiere.** `Dashboard`
    solo guarda una muestra si `hr.status === 'connected'` y llegó lectura nueva
    (`Dashboard.jsx:98-105`), y `session.hrSamples` no registra eventos de
    conexión. Un hueco puede ser: banda desconectada, banda conectada sin emitir
    (fuera de rango / sin contacto con la piel), **o la página en segundo plano
    con los timers estrangulados** (justo lo que el wake lock intenta evitar).
  - Por eso la leyenda dice **"cortes = sin señal de la banda"** y no "banda
    desconectada": afirmar la causa sería inventar. Si alguna vez se quiere la
    causa real, hay que registrar los eventos de `heartRate.js` (`connected` /
    `disconnected`) dentro de la sesión. · `SessionSummary.jsx`
- [2026-08-14] **Log de eventos de sesión (`session.events`).** Pedido del usuario:
  guardar los timestamps reales en vez de inferirlos. **Es un log interno, NO se
  muestra en la UI.** Nuevo `frontend/src/sessionLog.js`; `t` en segundos desde el
  inicio, mismo eje que `hrSamples[].t`.
  - **Vocabulario**, elegido para cubrir las 4 (y solo 4) causas posibles de que
    falte pulso: `belt-off`/`belt-on` (banda cae), `hidden`/`visible`
    (navegador en segundo plano, timers estrangulados), `reload` (se remontó el
    Dashboard y se perdió el estado en memoria), `stall-start`/`stall-end` (banda
    dice "conectada" pero dejó de emitir — **no lo detecta `hr.status`**, hay
    watchdog de 20s sobre `hr.lastAt`). Contexto extra: `auto-on`/`auto-off`,
    `wake-on`/`wake-off`.
  - Eventos repetidos se colapsan (`hr.status` pasa por `connecting` al volver,
    y visibilitychange dispara de más).
  - **El log se persiste en el blob de sesión activa** de `localStorage`: sin eso
    una recarga lo borraría, justo el evento que más interesa registrar.
    `sessionLog.restore()` lo retoma y anota el `reload`.
  - Backend: columna `sessions.events JSON` **sin DEFAULT a propósito** (NULL =
    no procesada por el backfill, `[]` = procesada sin nada que anotar).
    `backfill_session_events()` en `seeds.py` reconstruye pares
    `belt-off`/`belt-on` desde los huecos >20s de `hr_samples` de las sesiones
    viejas, **marcados `inferred: True`** — un hueco prueba que no hubo dato,
    nunca por qué, y nada río abajo debe confundir la inferencia con una medición.
  - `SessionSummary` deriva las ventanas ciegas del log (`ENDS` empareja
    inicio/fin, cierra en `maxT` lo que quedó abierto, descarta parpadeos <5s) y
    **mantiene la regla de huecos como red de seguridad**: el log puede no tener
    evento para una causa, pero un hueco en las muestras es falta de dato por
    definición.
  - Verificado: 116 sesiones backfilleadas (0 quedaron NULL), la del 2026-08-17
    con 48 eventos = los 24 huecos medidos antes; la API los devuelve; el
    derivador del gráfico saca 24 ventanas, todas cerradas, 0 `belt-off` sin
    pareja, y produce los mismos 24 cortes.
    · `sessionLog.js` (nuevo), `Dashboard.jsx`, `db.py`, `serializers.py`,
    `seeds.py`, `SessionSummary.jsx`
- [2026-08-14] **Arreglada la pérdida de pulso al recargar.** `hrSamplesRef` vivía
  solo en memoria: **recargar a mitad de sesión borraba todo el pulso acumulado**
  y la sesión se guardaba solo con lo posterior. Probablemente explique varios de
  los huecos históricos mejor que la banda.
  - **Clave propia `gym_active_hr`**, escrita en el mismo efecto que agrega la
    muestra (~cada 5s). NO se metió en el blob `gym_active_session` a propósito:
    ese solo se reescribe cuando cambian los sets, así que una recarga durante un
    descanso largo habría perdido minutos igual. Mismo razonamiento para el log,
    que ahora se persiste solo en `gym_session_log` en cada `log()`.
  - Se restaura en el efecto de montaje, junto con `sessionLog.restore()`.
  - **`startSession()` borra `gym_active_hr`**: sin banda conectada nada lo
    sobrescribiría y una recarga resucitaría el pulso de la sesión anterior
    dentro de la nueva. Igual en `discardSession()` y al finalizar.
  - `sessionLog.stop()` **rebindea** `events = []` en vez de mutar, para que el
    objeto de sesión que `finalizeSession()` acaba de leer conserve su copia.
  - Verificado con el `sessionLog.js` real y un `localStorage` falso en node:
    los eventos sobreviven la recarga, el `reload` queda anotado con su `t`
    correcto, los repetidos colapsan, `stop()` limpia la clave sin tocar la copia
    ya entregada, y tras `stop()` no se registra nada más.
    · `sessionLog.js`, `Dashboard.jsx`
- [2026-08-14] **Botón "View logs" para ver el log de eventos.** Nuevo
  `SessionLogModal.jsx`, compartido por las dos vistas: en la **sesión activa**
  (bajo "Finish session", lee `sessionLog.events()` en vivo) y en el **resumen de
  sesión** (bajo "Export CSV", lee `session.events` guardado).
  - Cada fila: tiempo desde el inicio (`mm:ss`), **hora de reloj** derivada de
    `startTime` (para cruzar con lo que pasó de verdad en el gimnasio), y la
    etiqueta en inglés. Los `inferred` del backfill salen marcados como tales.
  - Color por tono: rojo lo que corta datos (`belt-off`, `hidden`,
    `stall-start`), verde la recuperación, ámbar `reload`/`wake-off`, gris el
    contexto.
  - **Al agregar un tipo de evento nuevo hay que agregarlo al mapa `EVENTS` del
    modal**, si no se muestra el slug crudo. Verificado con un chequeo cruzado:
    los 11 tipos emitidos por `sessionLog.js`/`Dashboard.jsx` coinciden
    exactamente con los 11 etiquetados, sin faltantes ni sobrantes.
  - El modal en vivo no se re-renderiza si llega un evento con él abierto (lee un
    arreglo de módulo, no estado de React). Se cierra y se abre y ya. ·
    `SessionLogModal.jsx` (nuevo), `Dashboard.jsx`, `SessionSummary.jsx`
- [2026-08-14] **Fuera las líneas punteadas amarillas de la zona quema-grasa.**
  Quedan solo como banda sombreada (`ReferenceArea`, opacidad .08). Motivo: desde
  que el trazo de pulso usa punteado para el descanso, dos estilos punteados en
  el mismo gráfico compiten. Se fueron con ellas las etiquetas 112/131 (estaban
  en el `label` de cada `ReferenceLine`); los valores siguen en `FAT_BURN_ZONE` y
  en el desglose de % en zona. Import de `ReferenceLine` eliminado, sin usos
  residuales. · `SessionSummary.jsx`
- [2026-08-14] **% en zona quema-grasa: ponderado por tiempo + cobertura.**
  El usuario preguntó si el cálculo consideraba los huecos. **No los consideraba**:
  contaba muestras asumiendo "cada muestra ≈ tiempo igual".
  - Medido antes de tocar nada: contar muestras da 29/61/10 y ponderar por tiempo
    da 30/60/10. **Un punto de diferencia** — dentro de los tramos medidos las
    muestras SÍ están parejas cada 5s, así que la aritmética no era el problema.
  - **El problema real era de encuadre**: ese 61% era de la mitad medida, mostrado
    como si fuera de la sesión. Y lo que falta **no es aleatorio**: en la sesión
    del 17-ago la cobertura fue **32% en trabajo vs 59% en descanso** (la banda se
    cae al doble durante el esfuerzo: movimiento, sudor). La sesión fue 35%
    trabajo / 64% descanso pero lo medido fue 22%/77%, así que "en zona" y
    "arriba" salían **subestimados**.
  - Ahora `hrZone` pondera por `dt` de cada intervalo y **descarta los > HR_GAP_S**
    (no los reparte), y devuelve `coveragePct` contra `session.durationSeconds`
    (no contra la última muestra: si la banda murió antes del final, ese tiempo
    también está sin medir). Se muestra "· of the N% of the session the belt
    measured" cuando la cobertura baja de 98%.
  - **La ponderación se REVIRTIÓ** (pedido del usuario) tras medirla contra las 5
    sesiones: cambia **0 puntos en 3 de 5** y 1–2 en las otras dos, porque entre
    el 93% y el 100% de los intervalos miden exactamente 5s y con intervalos
    iguales contar y ponderar son la misma operación. Vuelve a contar muestras:
    un voto por lectura. **La cobertura sí se quedó** — era la parte que
    importaba.
  - Si algún día el muestreo deja de ser regular (la banda peor: la sesión del
    14-ago ya tiene solo 80% de intervalos de 5s y ahí la ponderación daba −2),
    reconsiderar. Las fórmulas quedaron explicadas en el hilo con el usuario.
  - (ver también la entrada de guardado incremental, más abajo)
  - Verificado con el `useMemo` real extraído del .jsx contra las 5 sesiones con
    pulso: los porcentajes suman 100–101 (redondeo de 3 valores independientes,
    esperado). **Cobertura muy variable**: 86%, 89%, 77%, **25%**, 50% — la del
    14-ago con 25% tiene un "34% en zona" prácticamente sin sentido, y ahora se
    ve. · `SessionSummary.jsx`
- [2026-08-14] **Guardado incremental: se acabó el blob todo-o-nada.** Pedido del
  usuario ("no hay razón para enviar la info repetida si ya está en la db").
  Antes, CADA guardado borraba y reinsertaba **1.016 filas** de `cuyi` (40
  sesiones, 217 ejercicios de sesión, 613 series, 17 rutinas, 129 ejercicios de
  rutina) para agregar una sola sesión.
  - **`POST /api/sessions`** (upsert de UNA sesión) y **`DELETE /api/sessions/{id}`**.
    `upsert_session()` borra solo la fila con esa id y reescribe; `write_session()`
    se extrajo de `replace_user_data` y lo comparten ambos caminos.
  - **`POST /api/data` ahora es PARCIAL**: solo reemplaza las colecciones
    presentes en el payload. `{"routines": [...]}` no toca sesiones. Esto mata el
    problema de "la pestaña vieja gana" para todo lo que no sea su propia
    colección.
  - Frontend: `finalizeSession` y el editor de sesión usan `saveSession`/
    `deleteSession`; `Routines` manda `{routines}`, `Locations` manda
    `{locations}`. **El borrado de ubicación ya no manda sesiones**: la FK
    `location_id` es `ON DELETE SET NULL`, la BD limpia sola. El único que sigue
    mandando el blob completo es la migración de formato al cargar, que es
    correcto porque reescribe todo a la vez.
  - `upsert_session` exige `id` **y `startTime`** → 400. Sin esa guarda, un
    payload malo borraba la fila y fallaba el insert por `NOT NULL`, devolviendo
    un 500 opaco (la transacción sí revertía bien).
  - Verificado contra la API: upsert crea (+1 sesión, resto intacto), actualiza
    sin duplicar, payload inválido da 400, `{"routines":[]}` deja las 40 sesiones
    intactas, DELETE borra y el segundo DELETE da 404.
- [2026-08-14] **Pulso a resolución completa + todo lo que manda el sensor.**
  - Se eliminó el diezmado de 1 muestra/5s: ahora se guarda **cada lectura**
    (~1/s, una por segundo como máximo). Esto arregla de paso que el `maxHr` de
    la sesión se calculaba sobre la serie diezmada y podía perderse el peak real.
  - **`parseHeartRate` ahora lee el paquete GATT completo**, no solo el bpm:
    bit 2/1 de flags = **contacto con la piel**, bit 3 = energía (se salta),
    bit 4 = **intervalos RR** (unidades de 1/1024 s → se guardan en ms enteros,
    son la base de la variabilidad cardíaca). En el estado: `contact` y `rr`.
  - En la muestra solo se guarda `contact` **cuando es false** y `rr` cuando
    viene: la ausencia significa normal, y así no se paga bytes por lo esperable.
  - **Nuevos eventos `contact-lost`/`contact-ok`** en el log — es el diagnóstico
    directo que faltaba para los tramos "conectada pero muda". Etiquetados en
    `SessionLogModal`.
  - El espejo a `localStorage` pasó a ser **cada 5s como máximo** (`hrFlushRef`):
    a resolución completa el arreglo llega a decenas de KB y serializarlo cada
    segundo en el celular no vale 4 segundos extra de protección.
  - Las dos cosas se habilitan mutuamente: guardar por sesión abarata justo lo
    que encarece guardar el pulso completo.
- [2026-08-14] **INCIDENTE: borré las 17 rutinas de `cuyi` probando.** Al testear
  la semántica parcial mandé `POST /api/data {"routines":[]}` **contra la BD real**
  — que es exactamente lo que el endpoint debe hacer: reemplazar las rutinas por
  la lista vacía. Restauradas las 17 + 129 ejercicios desde
  `backup_calistia_20260814_014533.sql` (parseando los bloques COPY del pg_dump);
  conteos verificados contra los de antes del incidente y Misión Rusa intacta.
  **Lección: `seed_cuyi_routines` solo repone 15** — el combo y Misión Rusa los
  creó el usuario y NO están en el seeder, así que un reinicio no los recupera.
  **Nunca probar payloads destructivos contra los datos reales**: crear un usuario
  de prueba, o mandar de vuelta la colección real en vez de `[]`.
- [2026-08-14] **Análisis de HRV en el resumen de sesión.** Nuevo
  `frontend/src/hrv.js` + panel al final de `SessionSummary`.
  - **Métricas de dominio temporal**: RMSSD (la principal, tono vagal a corto
    plazo), SDNN, pNN50, RR medio. NO se hizo dominio de frecuencia (LF/HF):
    exige minutos de señal estacionaria que un entrenamiento nunca da.
  - **Se mide en los DESCANSOS, no en toda la sesión.** La variabilidad se
    desploma bajo esfuerzo por diseño, así que un número global mide sobre todo
    cuánto de la sesión fue dura, no la recuperación. Si el reposo no junta
    suficientes latidos cae a la sesión completa y **lo dice en pantalla**
    (`scope`), no lo hace pasar por lo otro.
  - **Filtrado de artefactos** (crítico, una correa que se mueve genera muchos):
    se descartan RR fuera de 300–2000 ms y los que saltan >20% respecto del
    anterior aceptado. **Un latido rechazado CORTA la corrida**: RMSSD son
    diferencias sucesivas, y puentear un latido eliminado inventaría una
    diferencia entre dos latidos que nunca fueron vecinos. Mínimo 20 latidos o
    devuelve `null`.
  - Se muestra cuántos latidos respaldan el número y cuántos se descartaron, y
    que se compara contra las propias sesiones, no contra un valor de
    referencia. **No se interpreta la cifra** (las normas de HRV varían
    demasiado entre personas).
  - `restWindows(session)` se extrajo a nivel de módulo: la comparten el gráfico
    (que las puntea) y el HRV (que mide dentro). **Ventana inclusiva en ambos
    extremos**, así que puede entrar una muestra de esfuerzo justo en el borde;
    el filtro de salto la aísla y no contamina el RMSSD (verificado).
  - Verificado con el código real en node: serie alternante 800/850 da RMSSD
    exactamente 50; serie constante da 0; dos artefactos (120 y 2500 ms) se
    descartan **sin alterar el RMSSD**; <20 latidos y sin datos dan `null`; un
    salto de 800→1100 se rechaza; y el memo cruzado con las ventanas usa solo
    los latidos del descanso (122 de 282).
  - **Ninguna sesión existente tiene RR** — la captura empezó hoy. El panel no
    se dibuja hasta la próxima sesión, y solo si la banda reporta RR (bit 4 de
    los flags GATT); no se ha podido comprobar que la de cuyi lo haga.
    · `hrv.js` (nuevo), `SessionSummary.jsx`
- [2026-08-14] **Se captura TODO lo que manda el sensor.** Pedido del usuario, para
  poder cambiar los gráficos después sin haber perdido el dato. Banda del usuario:
  **Decathlon pulsómetro Bluetooth + ANT+** (solo el lado BLE es accesible desde
  el navegador).
  - **Bug encontrado**: `requestDevice()` pedía únicamente `heart_rate`, así que el
    navegador **negaba el acceso** a batería e info del dispositivo. Se agregó
    `optionalServices: [battery_service, device_information]`. **OJO: el permiso
    se decide al emparejar** → una banda ya emparejada seguirá sin dar esos
    servicios hasta que se la olvide y se empareje de nuevo.
  - `parseHeartRate` ya leía la **energía gastada** (kJ, bit 3) y la tiraba
    (`i += 2`). Ahora se guarda.
  - **Nuevas lecturas al conectar** (`readExtras`, cada una con su try/catch, todas
    opcionales): `body_sensor_location` (0x2A38 → Chest/Wrist/…), **nivel de
    batería** (0x180F, lectura + notificaciones si la banda las soporta), y
    fabricante / modelo / firmware (0x180A). Se llama DESPUÉS de que el pulso ya
    fluye y con `.catch()`: perder cualquiera de estos jamás debe costar la
    conexión.
  - En cada muestra ahora van `contact` y `energy` **siempre que la banda los
    reporte** (antes solo `contact:false`). Se prefirió explícito sobre compacto:
    guardar solo las anomalías obliga a todo consumidor futuro a conocer la
    convención.
  - **Columna nueva `sessions.hr_device` (JSON)**: `{name, manufacturer, model,
    firmware, sensorLocation, battery: [{t, pct}]}`. Un blob extensible en vez de
    una columna por campo, porque cada banda expone cosas distintas. La batería se
    anota solo cuando cambia el entero.
  - Verificado el viaje completo con una sesión de prueba (creada y borrada):
    `hr_device` con batería, y muestras con `contact`, `energy` y `rr` vuelven
    intactas por la API. · `heartRate.js`, `Dashboard.jsx`, `db.py`,
    `serializers.py`
- [2026-08-14] **Fusión de paquetes en el mismo segundo + evento `battery-low`.**
  - La serie está indexada por segundo entero, y `if (last && t <= last.t) return`
    **descartaba el paquete completo, con sus RR**, cuando la banda mandaba dos
    dentro del mismo segundo. Ahora se **fusiona**: refresca bpm/contact/energy y
    **concatena** los RR. Ningún latido se pierde aunque el eje siga en segundos.
  - **`battery-low`** cuando la batería baja de 15%: la serie ya se guardaba pero
    no lo decía en el log, y es la sospechosa principal de las caídas.
  - Chequeo cruzado: 14 tipos emitidos = 14 etiquetados en `SessionLogModal`.
  - **Sigue SIN registrarse el motivo técnico del fallo BLE**: Web Bluetooth no
    entrega razón en `gattserverdisconnected`; solo hay los `humanError()` de los
    reintentos, que hoy no se anotan. Ofrecido al usuario, no implementado.
    · `Dashboard.jsx`, `SessionLogModal.jsx`
- [2026-08-14] **Auditoría del RESUMEN contra el código.** El usuario pidió
  verificar que lo que dice sea cierto. Estaba desactualizado en varias cosas:
  - Decía "**cuatro** pestañas Train · History · Calendar · More". Son **cinco**
    (`NAV`): Train · Calendar · Muscles · Progress · More, y **History no es
    pestaña**, vive dentro de More junto a Routines, Locations, Heart Rate y
    Documentation.
  - La sección de frontend solo describía `exercises.js`. Faltaban **ocho
    módulos**: `api.js`, `heartRate.js`, `sound.js`, `autoRun.js`, `wakeLock.js`,
    `sessionLog.js`, `hrv.js`, `utils.js`. Agregados.
  - Decía que cuyi tiene "15 rutinas + 1 combinada". Son **17 en la BD y solo 15
    en el seeder**: el combo y Misión Rusa NO se regeneran.
  - Datos demo: decía "jun–oct **2025**", son **2026** (verificado en la BD).
  - Referenciaba `backend/seed_demo.py`, que **ya no existe**.
  - No advertía que **`data/users/*.json` es storage muerto** previo a Postgres.
  - Sección 7: agregado el procedimiento para **verificar un respaldo
    restaurándolo** en una base desechable, y por qué los dumps y las fotos están
    en `.gitignore`.
  - Verificación cruzada automática al final: los 9 módulos declarados existen,
    todo módulo existente está documentado, los componentes citados existen, las
    **6 claves de `localStorage`** del código están descritas y los **14
    endpoints** de `main.py` aparecen en la sección 2.
