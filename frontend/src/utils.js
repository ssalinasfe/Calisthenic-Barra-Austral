import { muscleCategoriesOf } from './exercises'

export function fmtDuration(secs) {
  const h = Math.floor(secs / 3600)
  const m = Math.floor((secs % 3600) / 60)
  const s = secs % 60
  if (h > 0) return `${h}h ${m}m`
  if (m > 0) return `${m}m ${s}s`
  return `${s}s`
}

// Returns "3×12" if all sets equal, "3×[10,12,8]" if mixed
export function setNotation(sets) {
  const done = sets.filter(s => s.duration !== null && (s.reps ?? 0) > 0)
  if (done.length === 0) return '—'
  const allSame = done.every(s => s.reps === done[0].reps)
  if (allSame) return `${done.length}×${done[0].reps}`
  return `${done.length}×[${done.map(s => s.reps).join(',')}]`
}

export function totalReps(sets) {
  return sets.filter(s => s.duration !== null).reduce((sum, s) => sum + (s.reps || 0), 0)
}

// Muscle groups for a session: the user's explicit selection (chosen when the
// session started), or, for legacy sessions saved before groups were selectable,
// inferred from the exercises trained. Cardio is always excluded.
export function sessionCategories(session) {
  const explicit = (session.categories || []).filter(Boolean)
  if (explicit.length) {
    return muscleCategoriesOf(Object.fromEntries(explicit.map(c => [c, 1])))
  }
  const tally = {}
  ;(session.exercises || []).forEach(ex => {
    const cat = ex.category || 'Custom'
    tally[cat] = (tally[cat] || 0) + totalReps(ex.sets || [])
  })
  return muscleCategoriesOf(tally)
}
