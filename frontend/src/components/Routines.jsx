import { useState } from 'react'
import { ListChecks, Plus, Pencil, Trash2, Save, X, AlertTriangle, Search, Link2, Link2Off, ArrowUp, ArrowDown } from 'lucide-react'
import { saveData } from '../api'
import { EXERCISES, CATEGORY_LABEL, CATEGORY_PILL, exerciseTypeOf, categoryColorStyle } from '../exercises'

const WEEKDAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
// Categories a routine's color can be built from (matches the calendar legend).
// Cardio is a cooldown, not a coloring category — a routine's color comes from
// the muscle groups it trains.
const ROUTINE_CATEGORIES = ['Push', 'Pull', 'Piernas', 'Custom']

function newId() {
  return `rt_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 6)}`
}

function emptyRoutine() {
  return { name: '', description: '', exercises: [], weekdays: [], categories: [] }
}

function defaultRoutineExercise(name, category) {
  const type = exerciseTypeOf(name)
  if (type === 'machine') {
    return {
      name,
      category,
      type: 'machine',
      timeSeconds: 600,    // default 10 min
      resistance: 5,
      targetSets: 1,
      restSeconds: 0,
      supersetGroup: null,
    }
  }
  return {
    name,
    category,
    type: 'reps',
    tempo: '2010',
    targetReps: 10,
    targetSets: 3,
    restSeconds: 120,
    supersetGroup: null,
  }
}

function ExercisePicker({ onAdd }) {
  const [query, setQuery] = useState('')
  const [open, setOpen] = useState(false)

  const matches = query.trim().length >= 1
    ? EXERCISES.filter(e =>
        e.name.toLowerCase().includes(query.toLowerCase()) ||
        (e.es && e.es.toLowerCase().includes(query.toLowerCase()))
      ).slice(0, 6)
    : []

  const showCustom = query.trim().length >= 2 &&
    !EXERCISES.some(e => e.name.toLowerCase() === query.trim().toLowerCase())

  function pick(name, category) {
    onAdd(defaultRoutineExercise(name, category))
    setQuery('')
    setOpen(false)
  }

  return (
    <div className="relative">
      <div className="flex items-center gap-2 bg-white/5 border border-white/10 rounded-xl px-3 py-2.5 focus-within:border-cyan-500/50 transition-colors">
        <Search size={15} className="text-gray-600 flex-shrink-0" />
        <input
          value={query}
          onChange={e => { setQuery(e.target.value); setOpen(true) }}
          onFocus={() => setOpen(true)}
          onBlur={() => setTimeout(() => setOpen(false), 180)}
          placeholder="Add exercise..."
          className="flex-1 bg-transparent text-white text-sm outline-none placeholder-gray-700"
        />
      </div>
      {open && (matches.length > 0 || showCustom) && (
        <div className="absolute top-full mt-1 left-0 right-0 bg-gray-900 border border-white/10 rounded-xl shadow-2xl z-30 overflow-hidden">
          {matches.map(ex => (
            <button
              key={ex.id}
              onMouseDown={() => pick(ex.name, ex.category)}
              className="w-full text-left px-4 py-2.5 hover:bg-white/5 flex justify-between items-center gap-3"
            >
              <div className="flex-1 min-w-0">
                <p className="text-white text-sm truncate">{ex.name}</p>
                {ex.es && <p className="text-gray-500 text-xs truncate">{ex.es}</p>}
              </div>
              <span className="text-gray-600 text-xs flex-shrink-0">{CATEGORY_LABEL[ex.category] || ex.category}</span>
            </button>
          ))}
          {showCustom && (
            <button
              onMouseDown={() => pick(query.trim(), 'Custom')}
              className="w-full text-left px-4 py-2.5 hover:bg-white/5 flex items-center gap-2 border-t border-white/5"
            >
              <Plus size={13} className="text-cyan-400" />
              <span className="text-cyan-300 text-sm">Add &ldquo;{query.trim()}&rdquo;</span>
            </button>
          )}
        </div>
      )}
    </div>
  )
}

function NumberField({ label, value, onChange, suffix, step = 1, min = 0, w = 'w-16' }) {
  return (
    <div className="flex items-center gap-1">
      <input
        type="number"
        value={value ?? ''}
        onChange={e => {
          const v = e.target.value
          onChange(v === '' ? null : Number(v))
        }}
        step={step}
        min={min}
        className={`${w} bg-white/8 text-white rounded px-1.5 py-1 text-xs text-center outline-none focus:ring-1 focus:ring-cyan-500`}
      />
      <span className="text-gray-600 text-[10px]">{suffix || label}</span>
    </div>
  )
}

function RoutineExerciseRow({ ex, idx, total, onChange, onRemove, onMove, onToggleSuperset }) {
  const pill = CATEGORY_PILL[ex.category] || CATEGORY_PILL.Custom
  const isMachine = ex.type === 'machine'
  const inSuperset = ex.supersetGroup != null

  function set(field, value) { onChange({ ...ex, [field]: value }) }

  return (
    <div className={`bg-white/5 border rounded-xl px-3 py-2 space-y-2 ${
      inSuperset ? 'border-purple-500/40' : 'border-white/8'
    }`}>
      <div className="flex items-center gap-2">
        <span className="text-gray-600 text-xs w-5 text-center font-mono">{idx + 1}</span>
        <span className={`text-[10px] px-1.5 py-0.5 rounded border ${pill}`}>
          {CATEGORY_LABEL[ex.category] || ex.category}
        </span>
        <span className="text-white text-sm flex-1 truncate">{ex.name}</span>
        {inSuperset && (
          <span className="text-[10px] text-purple-300 bg-purple-500/15 border border-purple-500/30 px-1.5 py-0.5 rounded-full">
            Superset {ex.supersetGroup}
          </span>
        )}
        <button onClick={() => onMove(-1)} disabled={idx === 0} className="text-gray-600 hover:text-white disabled:opacity-30 px-1" title="Move up">
          <ArrowUp size={12} />
        </button>
        <button onClick={() => onMove(1)} disabled={idx === total - 1} className="text-gray-600 hover:text-white disabled:opacity-30 px-1" title="Move down">
          <ArrowDown size={12} />
        </button>
        <button onClick={onRemove} className="text-gray-600 hover:text-red-400 p-1" title="Remove">
          <X size={13} />
        </button>
      </div>

      <div className="flex flex-wrap items-center gap-2 pl-7">
        {isMachine ? (
          <>
            <NumberField label="time"       value={ex.timeSeconds} onChange={v => set('timeSeconds', v)} suffix="sec" w="w-20" />
            <NumberField label="resistance" value={ex.resistance}  onChange={v => set('resistance', v)}  suffix="resist." step={0.5} w="w-16" />
            <NumberField label="sets"       value={ex.targetSets}  onChange={v => set('targetSets', v)}  suffix="sets" w="w-14" />
            <NumberField label="rest"       value={ex.restSeconds} onChange={v => set('restSeconds', v)} suffix="rest s" w="w-16" />
          </>
        ) : (
          <>
            <div className="flex items-center gap-1">
              <input
                type="text"
                value={ex.tempo ?? ''}
                onChange={e => set('tempo', e.target.value)}
                placeholder="2010"
                maxLength={4}
                className="w-14 bg-white/8 text-white rounded px-1.5 py-1 text-xs text-center font-mono outline-none focus:ring-1 focus:ring-cyan-500"
              />
              <span className="text-gray-600 text-[10px]">tempo</span>
            </div>
            <NumberField label="reps" value={ex.targetReps}  onChange={v => set('targetReps', v)}  suffix="reps" w="w-14" />
            <NumberField label="sets" value={ex.targetSets}  onChange={v => set('targetSets', v)}  suffix="sets" w="w-14" />
            <NumberField label="rest" value={ex.restSeconds} onChange={v => set('restSeconds', v)} suffix="rest s" w="w-16" />
          </>
        )}
        <button
          onClick={() => onToggleSuperset(idx)}
          className={`ml-auto flex items-center gap-1 text-[10px] px-2 py-1 rounded-full border transition-colors ${
            inSuperset
              ? 'bg-purple-500/20 text-purple-200 border-purple-500/40 hover:bg-purple-500/30'
              : 'bg-white/3 text-gray-500 border-white/10 hover:text-purple-300 hover:border-purple-500/30'
          }`}
          title="Superset with the next exercise"
        >
          {inSuperset ? <Link2Off size={11} /> : <Link2 size={11} />}
          {inSuperset ? 'Break superset' : 'Link with next'}
        </button>
      </div>
    </div>
  )
}

function RoutineEditor({ routine, onCancel, onSave, saving }) {
  const [draft, setDraft] = useState({ categories: [], ...routine })

  function toggleWeekday(idx) {
    setDraft(d => ({
      ...d,
      weekdays: d.weekdays.includes(idx)
        ? d.weekdays.filter(w => w !== idx)
        : [...d.weekdays, idx].sort((a, b) => a - b),
    }))
  }

  function toggleCategory(cat) {
    setDraft(d => {
      const cats = d.categories || []
      return {
        ...d,
        categories: cats.includes(cat) ? cats.filter(c => c !== cat) : [...cats, cat],
      }
    })
  }

  function addExercise(ex) {
    setDraft(d => ({ ...d, exercises: [...d.exercises, ex] }))
  }

  function updateExercise(i, updated) {
    setDraft(d => ({ ...d, exercises: d.exercises.map((e, idx) => idx === i ? updated : e) }))
  }

  function removeExercise(i) {
    setDraft(d => ({ ...d, exercises: d.exercises.filter((_, idx) => idx !== i) }))
  }

  function moveExercise(i, dir) {
    setDraft(d => {
      const arr = [...d.exercises]
      const j = i + dir
      if (j < 0 || j >= arr.length) return d
      ;[arr[i], arr[j]] = [arr[j], arr[i]]
      return { ...d, exercises: arr }
    })
  }

  // Toggle a superset link between exercise i and i+1.
  function toggleSuperset(i) {
    setDraft(d => {
      const arr = d.exercises.slice()
      if (i >= arr.length - 1) return d
      const cur = arr[i]
      const next = arr[i + 1]
      if (cur.supersetGroup != null && next.supersetGroup === cur.supersetGroup) {
        // Unlink: clear group from cur and next (and trailing chain on next)
        const g = cur.supersetGroup
        arr[i]     = { ...cur, supersetGroup: null }
        arr[i + 1] = { ...next, supersetGroup: null }
        // If exercises after i+1 share the same group, keep them grouped (re-wire to next)
        return { ...d, exercises: arr }
      }
      // Link: assign next free group id (max + 1) or extend current
      const groups = arr.map(e => e.supersetGroup).filter(g => g != null)
      const newG = cur.supersetGroup != null ? cur.supersetGroup : (groups.length ? Math.max(...groups) + 1 : 1)
      arr[i]     = { ...cur, supersetGroup: newG }
      arr[i + 1] = { ...next, supersetGroup: newG }
      return { ...d, exercises: arr }
    })
  }

  return (
    <div className="bg-white/5 border border-white/10 rounded-2xl p-4 space-y-4">
      <div className="flex items-center justify-between">
        <p className="text-white font-semibold text-sm">{draft.id ? 'Edit routine' : 'New routine'}</p>
        <button onClick={onCancel} className="text-gray-500 hover:text-white p-1">
          <X size={16} />
        </button>
      </div>

      <div>
        <label className="text-gray-600 text-xs mb-1 block">Name</label>
        <input
          autoFocus
          value={draft.name}
          onChange={e => setDraft(s => ({ ...s, name: e.target.value }))}
          placeholder="Push day"
          className="w-full bg-white/8 text-white rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-cyan-500"
        />
      </div>

      <div>
        <label className="text-gray-600 text-xs mb-1 block">Description (optional)</label>
        <input
          value={draft.description}
          onChange={e => setDraft(s => ({ ...s, description: e.target.value }))}
          placeholder="Chest, shoulders, triceps"
          className="w-full bg-white/8 text-white rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-cyan-500"
        />
      </div>

      <div>
        <div className="flex items-center justify-between mb-2">
          <label className="text-gray-600 text-xs block">Category / color</label>
          <span
            className="text-[10px] px-2 py-0.5 rounded-full border"
            style={categoryColorStyle(draft.categories, 'pill')}
          >
            {(draft.categories || []).length
              ? draft.categories.map(c => CATEGORY_LABEL[c] || c).join(' + ')
              : 'Other (gray)'}
          </span>
        </div>
        <div className="flex flex-wrap gap-1.5">
          {ROUTINE_CATEGORIES.map(cat => {
            const active = (draft.categories || []).includes(cat)
            return (
              <button
                key={cat}
                type="button"
                onClick={() => toggleCategory(cat)}
                className={`text-xs px-2.5 py-1.5 rounded-full border transition-colors ${
                  active ? CATEGORY_PILL[cat] : 'bg-white/3 text-gray-500 border-white/10 hover:text-white'
                }`}
              >
                {CATEGORY_LABEL[cat] || cat}
              </button>
            )
          })}
        </div>
        <p className="text-gray-700 text-[10px] mt-1.5">
          Pick the categories this routine covers. Combine several to blend their colors on the calendar (e.g. Push + Pull). Leave empty to show as gray/Other.
        </p>
      </div>

      <div>
        <label className="text-gray-600 text-xs mb-2 block">Scheduled days</label>
        <div className="flex gap-1.5">
          {WEEKDAYS.map((w, i) => {
            const active = draft.weekdays.includes(i)
            return (
              <button
                key={w}
                onClick={() => toggleWeekday(i)}
                className={`flex-1 py-2 text-xs font-semibold rounded-lg border transition-colors ${
                  active
                    ? 'bg-cyan-500 text-white border-cyan-500'
                    : 'bg-white/5 text-gray-500 border-white/10 hover:text-white'
                }`}
              >
                {w}
              </button>
            )
          })}
        </div>
      </div>

      <div>
        <label className="text-gray-600 text-xs mb-2 block">Exercises ({draft.exercises.length})</label>
        <div className="space-y-1.5 mb-2">
          {draft.exercises.map((ex, i) => (
            <RoutineExerciseRow
              key={i}
              ex={ex}
              idx={i}
              total={draft.exercises.length}
              onChange={updated => updateExercise(i, updated)}
              onRemove={() => removeExercise(i)}
              onMove={dir => moveExercise(i, dir)}
              onToggleSuperset={() => toggleSuperset(i)}
            />
          ))}
        </div>
        <ExercisePicker onAdd={addExercise} />
      </div>

      <button
        onClick={() => onSave(draft)}
        disabled={saving || !draft.name.trim() || !(draft.categories?.length)}
        className="w-full flex items-center justify-center gap-2 bg-cyan-500 hover:bg-cyan-400 disabled:opacity-50 text-white font-semibold py-2.5 rounded-xl text-sm transition-colors"
      >
        <Save size={14} />
        {saving
          ? 'Saving...'
          : !draft.name.trim() ? 'Name required'
          : !(draft.categories?.length) ? 'Pick a muscle group'
          : 'Save routine'}
      </button>
    </div>
  )
}

export default function Routines({ allData, token, onDataChange }) {
  const [editing, setEditing] = useState(null)
  const [confirmDelete, setConfirmDelete] = useState(null)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  const routines = allData.routines || []

  async function persist(newRoutines) {
    setSaving(true)
    try {
      const newData = { ...allData, routines: newRoutines }
      await saveData(token, newData)
      onDataChange(newData)
      setEditing(null)
      setConfirmDelete(null)
    } catch {
      setError('Failed to save')
    }
    setSaving(false)
  }

  function handleSave(draft) {
    const id = draft.id || newId()
    const others = routines.filter(r => r.id !== id)
    const updated = [...others, { ...draft, id }]
    persist(updated)
  }

  function handleDelete(rt) {
    persist(routines.filter(r => r.id !== rt.id))
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2 text-gray-500 text-xs">
        <ListChecks size={13} />
        <span>Pre-defined exercise lists you can run on schedule</span>
      </div>

      {error && (
        <div className="bg-red-500/15 border border-red-500/30 rounded-xl px-4 py-2 text-red-300 text-sm">
          {error}
        </div>
      )}

      {routines.length === 0 && !editing && (
        <p className="text-gray-600 text-sm text-center py-6">No routines yet</p>
      )}

      <div className="space-y-2">
        {routines.map(rt => {
          const days = rt.weekdays?.length
            ? rt.weekdays.map(i => WEEKDAYS[i]).join(' · ')
            : 'No days assigned'
          return (
            <div key={rt.id} className="bg-white/5 border border-white/8 rounded-2xl px-4 py-3 flex items-center gap-3">
              <span
                className="w-2.5 h-2.5 rounded-full border flex-shrink-0"
                style={categoryColorStyle(rt.categories, 'fill')}
                title={(rt.categories || []).length ? rt.categories.map(c => CATEGORY_LABEL[c] || c).join(' + ') : 'Other'}
              />
              <div className="flex-1 min-w-0">
                <p className="text-white text-sm font-semibold truncate">{rt.name}</p>
                {rt.description && <p className="text-gray-500 text-xs truncate">{rt.description}</p>}
                <p className="text-gray-600 text-xs mt-0.5">
                  {rt.exercises.length} {rt.exercises.length === 1 ? 'exercise' : 'exercises'} · {days}
                </p>
              </div>
              <button
                onClick={() => setEditing(rt)}
                className="text-gray-500 hover:text-cyan-400 p-2 rounded-lg transition-colors"
                title="Edit"
              >
                <Pencil size={14} />
              </button>
              <button
                onClick={() => setConfirmDelete(rt)}
                className="text-gray-500 hover:text-red-400 p-2 rounded-lg transition-colors"
                title="Delete"
              >
                <Trash2 size={14} />
              </button>
            </div>
          )
        })}
      </div>

      {!editing && (
        <button
          onClick={() => setEditing(emptyRoutine())}
          className="w-full flex items-center justify-center gap-2 py-3 border border-dashed border-white/15 rounded-2xl text-gray-500 hover:text-cyan-400 hover:border-cyan-500/40 transition-colors text-sm"
        >
          <Plus size={15} />
          New routine
        </button>
      )}

      {editing && (
        <RoutineEditor
          routine={editing}
          onCancel={() => setEditing(null)}
          onSave={handleSave}
          saving={saving}
        />
      )}

      {confirmDelete && (
        <div className="fixed inset-0 bg-black/75 flex items-end sm:items-center justify-center z-50 p-4">
          <div className="bg-gray-950 border border-white/10 rounded-2xl max-w-sm w-full p-5 space-y-3">
            <div className="flex items-center gap-2 text-red-300">
              <AlertTriangle size={16} />
              <p className="font-semibold text-sm">Delete this routine?</p>
            </div>
            <p className="text-gray-500 text-xs">"{confirmDelete.name}" will be removed.</p>
            <div className="flex gap-2">
              <button
                onClick={() => setConfirmDelete(null)}
                className="flex-1 py-2 rounded-xl border border-white/10 text-gray-400 text-sm hover:bg-white/5 transition-colors"
              >Cancel</button>
              <button
                onClick={() => handleDelete(confirmDelete)}
                disabled={saving}
                className="flex-1 py-2 rounded-xl bg-red-500 hover:bg-red-400 text-white text-sm font-semibold disabled:opacity-50"
              >Delete</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
