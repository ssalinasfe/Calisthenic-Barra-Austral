// Each exercise has muscles in English (canonical). MUSCLE_ES maps to Spanish.
export const EXERCISES = [
  // ===== PUSH =====
  { id: 1,  name: 'Plank Hold',                   es: 'Plancha',                       category: 'Push',    muscles: ['Core', 'Shoulders'], isometric: true },
  { id: 2,  name: 'Scapula Push-ups',             es: 'Flexiones escapulares',         category: 'Push',    muscles: ['Serratus', 'Traps', 'Shoulders'] },
  { id: 3,  name: 'Negative Push-ups',            es: 'Flexiones negativas',           category: 'Push',    muscles: ['Chest', 'Triceps', 'Shoulders'] },
  { id: 4,  name: 'Push-ups',                     es: 'Flexión estándar',              category: 'Push',    muscles: ['Chest', 'Triceps', 'Shoulders'] },
  { id: 5,  name: 'Wide Push-ups',                es: 'Flexión amplia',                category: 'Push',    muscles: ['Chest', 'Shoulders'] },
  { id: 6,  name: 'Diamond Push-ups',             es: 'Flexión diamante',              category: 'Push',    muscles: ['Triceps', 'Chest'] },
  { id: 7,  name: 'Tricep Extensions',            es: 'Extensiones de tríceps',        category: 'Push',    muscles: ['Triceps'] },
  { id: 8,  name: 'Explosive Push-ups',           es: 'Flexión explosiva',             category: 'Push',    muscles: ['Chest', 'Triceps', 'Shoulders'] },
  { id: 9,  name: 'Archer Push-ups',              es: 'Flexión de arquero',            category: 'Push',    muscles: ['Chest', 'Triceps', 'Shoulders'] },
  { id: 10, name: 'One-arm Push-up',              es: 'Flexión a una mano',            category: 'Push',    muscles: ['Chest', 'Triceps', 'Core'] },
  { id: 36, name: 'Bench Press',                  es: 'Press de banca',                category: 'Push',    muscles: ['Chest', 'Triceps', 'Shoulders'] },

  // ===== PULL =====
  { id: 11, name: 'Banded Overhead Pull-aparts',  es: 'Aperturas superiores con banda', category: 'Pull',   muscles: ['Rear Delts', 'Traps'] },
  { id: 12, name: 'Banded Horizontal Pull-aparts',es: 'Aperturas horizontales con banda', category: 'Pull', muscles: ['Rear Delts', 'Rhomboids'] },
  { id: 13, name: 'Banded Pull-downs',            es: 'Jalones con banda',             category: 'Pull',    muscles: ['Lats', 'Mid Back'] },
  { id: 14, name: 'Bent Over Barbell Rows',       es: 'Remo inclinado con barra',      category: 'Pull',    muscles: ['Lats', 'Mid Back', 'Biceps'] },
  { id: 15, name: 'Passive Hang',                 es: 'Colgado pasivo',                category: 'Pull',    muscles: ['Forearms'], isometric: true },
  { id: 16, name: 'Scapula Pull-ups',             es: 'Dominadas escapulares',         category: 'Pull',    muscles: ['Traps', 'Lats'] },
  { id: 17, name: 'Australian Pull-ups',          es: 'Dominadas australianas',        category: 'Pull',    muscles: ['Lats', 'Mid Back', 'Biceps'] },
  { id: 18, name: 'Negative Pull-ups',            es: 'Dominadas negativas',           category: 'Pull',    muscles: ['Lats', 'Biceps', 'Forearms'] },
  { id: 19, name: 'Band Assisted Pull-ups',       es: 'Dominadas asistidas con banda', category: 'Pull',    muscles: ['Lats', 'Biceps', 'Forearms'] },
  { id: 20, name: 'Pull-ups',                     es: 'Dominada',                      category: 'Pull',    muscles: ['Lats', 'Biceps', 'Forearms'] },

  // ===== LEGS =====
  { id: 21, name: 'Bodyweight Squats',            es: 'Sentadilla con peso corporal',  category: 'Piernas', muscles: ['Quads', 'Glutes'] },
  { id: 22, name: 'Narrow Stance Squats',         es: 'Sentadilla postura cerrada',    category: 'Piernas', muscles: ['Quads'] },
  { id: 23, name: 'Deep Squats',                  es: 'Sentadilla profunda',           category: 'Piernas', muscles: ['Quads', 'Glutes'] },
  { id: 24, name: 'Bulgarian Split Squats',       es: 'Sentadilla búlgara',            category: 'Piernas', muscles: ['Quads', 'Glutes', 'Hamstrings'] },
  { id: 25, name: 'Cossack Squats',               es: 'Sentadilla cosaca',             category: 'Piernas', muscles: ['Quads', 'Glutes', 'Adductors'] },
  { id: 26, name: 'Pistol Squats (assisted)',     es: 'Sentadilla pistola (variante)', category: 'Piernas', muscles: ['Quads', 'Glutes', 'Core'] },
  { id: 27, name: 'Pistol Squats',                es: 'Sentadilla pistola',            category: 'Piernas', muscles: ['Quads', 'Glutes', 'Core'] },
  { id: 37, name: 'Barbell Squat',                es: 'Sentadilla con barra',          category: 'Piernas', muscles: ['Quads', 'Glutes', 'Hamstrings'] },

  // ===== KETTLEBELL ("Misión Rusa", Chuy Almada — 10 ejercicios × 2 rondas) =====
  // Bloque definido por el implemento (pesa rusa), no por el patrón: cada uno
  // lleva su propia `category` (Push / Piernas / Custom) como el resto.
  { id: 38, name: 'Kettlebell Swings',              es: 'Swing con pesa rusa',                        category: 'Piernas', muscles: ['Glutes', 'Hamstrings', 'Core', 'Shoulders'] },
  { id: 39, name: 'Kettlebell Single-arm Swings',   es: 'Swing a una mano con pesa rusa',             category: 'Piernas', muscles: ['Glutes', 'Hamstrings', 'Core', 'Forearms'] },
  { id: 40, name: 'Kettlebell Clean and Press',     es: 'Cargada y press con pesa rusa',              category: 'Push',    muscles: ['Shoulders', 'Triceps', 'Traps', 'Core'] },
  { id: 41, name: 'Kettlebell Squat + Halo',        es: 'Sentadilla con pesa rusa y giro sobre la cabeza', category: 'Piernas', muscles: ['Quads', 'Glutes', 'Shoulders', 'Core'] },
  { id: 42, name: 'Kettlebell Thrusters',           es: 'Thruster con pesa rusa',                     category: 'Push',    muscles: ['Quads', 'Glutes', 'Shoulders', 'Triceps'] },
  { id: 43, name: 'Kettlebell Deadlift + Around the Body', es: 'Peso muerto con pesa rusa y giro a la cintura', category: 'Piernas', muscles: ['Hamstrings', 'Glutes', 'Core', 'Forearms'] },
  { id: 44, name: 'Kettlebell Lunges + Pass Through', es: 'Estocada con pesa rusa y paso bajo la pierna', category: 'Piernas', muscles: ['Quads', 'Glutes', 'Hamstrings', 'Core'] },
  { id: 45, name: 'Kettlebell Sumo Squat + Upright Row', es: 'Sentadilla sumo con pesa rusa y remo al mentón', category: 'Piernas', muscles: ['Quads', 'Glutes', 'Adductors', 'Traps'] },
  { id: 46, name: 'Kettlebell Kneeling Twists',     es: 'Giro de torso de rodillas con pesa rusa',    category: 'Custom',  muscles: ['Core', 'Obliques'] },
  { id: 47, name: 'Kettlebell Russian Twists',      es: 'Giro ruso con pesa rusa',                    category: 'Custom',  muscles: ['Core', 'Obliques'] },

  // ===== CARDIO / MACHINES =====
  { id: 28, name: 'Rowing Machine',               es: 'Máquina de remos',              category: 'Remo',    muscles: ['Heart'], type: 'machine' },
  { id: 29, name: 'Treadmill',                    es: 'Trotadora',                     category: 'Remo',    muscles: ['Heart'], type: 'machine' },
  { id: 30, name: 'Air Bike',                     es: 'Bicicleta de aire',             category: 'Remo',    muscles: ['Heart'], type: 'machine' },
  { id: 31, name: 'Spin Bike',                    es: 'Bicicleta de spinning',         category: 'Remo',    muscles: ['Heart'], type: 'machine' },
  { id: 32, name: 'Jogging',                      es: 'Trotar',                        category: 'Remo',    muscles: ['Heart'] },
  { id: 33, name: 'Burpees',                      es: 'Burpees',                       category: 'Remo',    muscles: ['Heart'] },
  { id: 34, name: 'Warm-up',                      es: 'Calentamiento',                 category: 'Remo',    muscles: ['Heart'] },
  { id: 35, name: 'Cool-down',                    es: 'Enfriamiento',                  category: 'Remo',    muscles: ['Heart'] },
]

// Helper: get the type for an exercise by name (defaults to 'reps')
export function exerciseTypeOf(name) {
  const e = EXERCISES.find(x => x.name === name || x.es === name)
  return e?.type || 'reps'
}

// Isometric holds (Plank, Hang, etc.): progress is measured in seconds held, not
// reps. Uses the catalog flag, plus a name fallback so custom-named holds work too.
export function isIsometric(name) {
  const e = EXERCISES.find(x => x.name === name || x.es === name)
  if (e) return !!e.isometric
  return /\b(hold|hang|plank|isometric|wall\s*sit|l-?sit|hollow|bridge)\b/i.test(name || '')
}

// Lookup: exercise canonical name (English) → muscles
export const MUSCLES_BY_NAME = Object.fromEntries(
  EXERCISES.map(e => [e.name, e.muscles])
)

// Backwards compatibility: also map by Spanish name → muscles
EXERCISES.forEach(e => {
  if (e.es && !MUSCLES_BY_NAME[e.es]) MUSCLES_BY_NAME[e.es] = e.muscles
})

// Spanish exercise name → English (canonical) for migrating old data
export const ES_TO_EN_NAME = Object.fromEntries(
  EXERCISES.filter(e => e.es).map(e => [e.es, e.name])
)

export function canonicalExerciseName(name) {
  return ES_TO_EN_NAME[name] || name
}

// Normalise an entire data blob: rewrites Spanish exercise names to English.
// Returns { data, changed } so callers can persist if anything changed.
export function migrateData(data) {
  if (!data || !Array.isArray(data.sessions)) return { data, changed: false }
  let changed = false
  const sessions = data.sessions.map(s => {
    const exs = (s.exercises || []).map(ex => {
      const newName = canonicalExerciseName(ex.name)
      if (newName !== ex.name) { changed = true; return { ...ex, name: newName } }
      return ex
    })
    return { ...s, exercises: exs }
  })
  return {
    data: {
      ...data,
      sessions,
      locations: Array.isArray(data.locations) ? data.locations : [],
      routines: Array.isArray(data.routines) ? data.routines : [],
    },
    changed: changed || !Array.isArray(data.locations) || !Array.isArray(data.routines),
  }
}

// English → Spanish for muscles
export const MUSCLE_ES = {
  Chest:       'Pecho',
  Triceps:     'Tríceps',
  Biceps:      'Bíceps',
  Shoulders:   'Hombros',
  'Rear Delts':'Hombros posteriores',
  Traps:       'Trapecios',
  Rhomboids:   'Romboides',
  Serratus:    'Serratos',
  Lats:        'Dorsales',
  'Mid Back':  'Espalda media',
  Forearms:    'Antebrazos',
  Quads:       'Cuádriceps',
  Hamstrings:  'Isquiotibiales',
  Glutes:      'Glúteos',
  Adductors:   'Aductores',
  Core:        'Core',
  Obliques:    'Oblicuos',
  Legs:        'Piernas',
  Heart:       'Corazón',
  Other:       'Otro',
}

// English display label for each category (data still uses original keys)
export const CATEGORY_LABEL = {
  Push:    'Push',
  Pull:    'Pull',
  Piernas: 'Legs',
  Remo:    'Cardio',
  Custom:  'Other',
}

export const CATEGORY_LABEL_ES = {
  Push:    'Empuje',
  Pull:    'Tracción',
  Piernas: 'Piernas',
  Remo:    'Cardio',
  Custom:  'Otro',
}

// Shared pill class strings for consistent visuals across components
export const CATEGORY_PILL = {
  Push:    'bg-orange-500/15 text-orange-300 border-orange-500/25',
  Pull:    'bg-blue-500/15 text-blue-300 border-blue-500/25',
  Piernas: 'bg-green-500/15 text-green-300 border-green-500/25',
  Remo:    'bg-cyan-500/15 text-cyan-300 border-cyan-500/25',
  Custom:  'bg-gray-500/15 text-gray-300 border-gray-500/25',
}

// Stronger fill for calendar cells / emphasis
export const CATEGORY_FILL = {
  Push:    'bg-orange-500/30 text-orange-200 border-orange-500/40',
  Pull:    'bg-blue-500/30 text-blue-200 border-blue-500/40',
  Piernas: 'bg-green-500/30 text-green-200 border-green-500/40',
  Remo:    'bg-cyan-500/30 text-cyan-200 border-cyan-500/40',
  Custom:  'bg-gray-500/30 text-gray-200 border-gray-500/40',
}

// Bar color (full opacity) for charts
export const CATEGORY_BAR = {
  Push:    'bg-orange-500/60',
  Pull:    'bg-blue-500/60',
  Piernas: 'bg-green-500/60',
  Remo:    'bg-cyan-500/60',
  Custom:  'bg-gray-500/60',
}

// Base RGB per category — used to blend a color for routines that span
// more than one category (e.g. Push + Pull → a muted lilac).
export const CATEGORY_RGB = {
  Push:    [249, 115, 22],   // orange-500
  Pull:    [59, 130, 246],   // blue-500
  Piernas: [34, 197, 94],    // green-500
  Remo:    [6, 182, 212],    // cyan-500
  Custom:  [107, 114, 128],  // gray-500
}

function mixWithWhite([r, g, b], amount) {
  return [r, g, b].map(c => Math.round(c + (255 - c) * amount))
}

// Average the RGB of every selected category. Empty/unknown → gray (Custom/Other).
export function blendCategoryColor(categories) {
  const cats = (categories || []).filter(c => CATEGORY_RGB[c])
  if (cats.length === 0) return CATEGORY_RGB.Custom
  const sum = cats.reduce((acc, c) => {
    const [r, g, b] = CATEGORY_RGB[c]
    return [acc[0] + r, acc[1] + g, acc[2] + b]
  }, [0, 0, 0])
  return sum.map(v => Math.round(v / cats.length))
}

// ── Muscle-group categorization (shared by Calendar + History) ───────────────
// Cardio (Remo) never mixes with the main muscle groups: a session/day with
// cardio + a group belongs to that group. A cardio-ONLY session/day does show
// as "Cardio" — that fallback lives in the callers (Calendar cells, History
// pill), since muscleCategoriesOf only reports the main groups below.
export const MUSCLE_ORDER = ['Push', 'Pull', 'Piernas', 'Custom']

// Given a { category: reps } tally, return the muscle groups trained (reps > 0),
// in canonical order, excluding cardio.
export function muscleCategoriesOf(tally) {
  return MUSCLE_ORDER.filter(c => (tally[c] || 0) > 0)
}

export function isFullBody(cats) {
  return cats.includes('Push') && cats.includes('Pull') && cats.includes('Piernas')
}

// Label for a session/day: "Full Body" for all three groups, otherwise the
// category labels concatenated ("Push Pull"). Null when nothing trained.
export function groupLabel(cats) {
  if (isFullBody(cats)) return 'Full Body'
  if (!cats || cats.length === 0) return null
  return cats.map(c => CATEGORY_LABEL[c] || c).join(' ')
}

// Standout style for a Full Body session/day: vivid orange→blue→green blend with
// a bright magenta edge and glow so it pops.
export const FULL_BODY_STYLE = {
  background: 'linear-gradient(135deg, rgba(249,115,22,0.55) 0%, rgba(59,130,246,0.55) 50%, rgba(34,197,94,0.55) 100%)',
  borderColor: 'rgba(217,70,239,0.85)',
  color: '#ffffff',
  boxShadow: '0 0 10px rgba(217,70,239,0.35)',
}

// Standout style for a multi-group (but not Full Body) session/day, e.g.
// "Push Legs". A gradient of the trained groups' own colors with a vivid blended
// border and a soft glow — flashier than a single category, milder than Full Body.
export function comboCategoryStyle(categories, variant = 'pill') {
  const cats = (categories || []).filter(c => CATEGORY_RGB[c])
  if (cats.length < 2) return categoryColorStyle(categories, variant)
  const bgAlpha = variant === 'fill' ? 0.5 : 0.42
  const stops = cats.map((c, i) => {
    const [r, g, b] = CATEGORY_RGB[c]
    const pct = Math.round((i / (cats.length - 1)) * 100)
    return `rgba(${r}, ${g}, ${b}, ${bgAlpha}) ${pct}%`
  }).join(', ')
  const [br, bg, bb] = blendCategoryColor(cats)
  return {
    background: `linear-gradient(135deg, ${stops})`,
    borderColor: `rgba(${br}, ${bg}, ${bb}, 0.75)`,
    color: '#ffffff',
    boxShadow: `0 0 6px rgba(${br}, ${bg}, ${bb}, 0.3)`,
  }
}

// Inline style for a routine's color badge/fill, built from its blended RGB.
// variant 'pill' matches CATEGORY_PILL, 'fill' matches CATEGORY_FILL.
export function categoryColorStyle(categories, variant = 'pill') {
  const rgb = blendCategoryColor(categories)
  const [r, g, b] = rgb
  const bgAlpha = variant === 'fill' ? 0.3 : 0.15
  const borderAlpha = variant === 'fill' ? 0.5 : 0.35
  const textAmount = variant === 'fill' ? 0.65 : 0.5
  const [tr, tg, tb] = mixWithWhite(rgb, textAmount)
  return {
    backgroundColor: `rgba(${r}, ${g}, ${b}, ${bgAlpha})`,
    borderColor: `rgba(${r}, ${g}, ${b}, ${borderAlpha})`,
    color: `rgb(${tr}, ${tg}, ${tb})`,
  }
}
