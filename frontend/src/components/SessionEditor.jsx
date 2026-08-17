import { useState, useRef } from 'react'
import { X, Trash2, Save, AlertTriangle, Plus, Pencil, Search, Check, MapPin, FileText, Camera, Image, Tag, CalendarClock, Activity } from 'lucide-react'
import { format } from 'date-fns'
import { saveSession, deleteSession, uploadPhoto, deletePhoto, photoUrl } from '../api'
import { fmtDuration, sessionCategories } from '../utils'
import { EXERCISES, CATEGORY_LABEL, CATEGORY_PILL } from '../exercises'

// Muscle groups a session can be tagged with (cardio is not a coloring group).
const GROUP_OPTIONS = ['Push', 'Pull', 'Piernas', 'Custom']

// ── Inline exercise name picker ──────────────────────────────────────────────
function ExercisePicker({ value, onChange }) {
  const [editing, setEditing] = useState(false)
  const [query, setQuery] = useState(value)
  const inputRef = useRef(null)

  const matches = query.trim().length >= 1
    ? EXERCISES.filter(e =>
        e.name.toLowerCase().includes(query.toLowerCase()) ||
        (e.es && e.es.toLowerCase().includes(query.toLowerCase()))
      ).slice(0, 6)
    : []

  function pick(name, category) {
    onChange({ name, category })
    setQuery(name)
    setEditing(false)
  }

  function confirmCustom() {
    const v = query.trim()
    if (!v) return
    const known = EXERCISES.find(e => e.name.toLowerCase() === v.toLowerCase())
    if (known) pick(known.name, known.category)
    else pick(v, null)   // custom name: keep the exercise's current category
  }

  if (!editing) {
    return (
      <div className="flex items-center gap-2 flex-1 min-w-0">
        <span className="text-white font-medium text-sm truncate">{value}</span>
        <button
          onClick={() => { setEditing(true); setTimeout(() => inputRef.current?.focus(), 50) }}
          className="text-gray-600 hover:text-cyan-400 transition-colors flex-shrink-0"
        >
          <Pencil size={13} />
        </button>
      </div>
    )
  }

  return (
    <div className="flex-1 relative">
      <div className="flex items-center gap-2 bg-white/10 rounded-lg px-2 py-1">
        <Search size={13} className="text-gray-500 flex-shrink-0" />
        <input
          ref={inputRef}
          value={query}
          onChange={e => setQuery(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && confirmCustom()}
          className="flex-1 bg-transparent text-white text-sm outline-none min-w-0"
          placeholder="Search exercise..."
        />
        <button onClick={confirmCustom} className="text-cyan-400 flex-shrink-0">
          <Check size={14} />
        </button>
      </div>
      {matches.length > 0 && (
        <div className="absolute top-full mt-1 left-0 right-0 bg-gray-900 border border-white/10 rounded-xl shadow-2xl z-30 overflow-hidden">
          {matches.map(ex => (
            <button
              key={ex.id}
              onMouseDown={() => pick(ex.name, ex.category)}
              className="w-full text-left px-3 py-2 hover:bg-white/8 flex justify-between items-center gap-2"
            >
              <span className="text-white text-xs">{ex.name}</span>
              <span className="text-gray-600 text-xs flex-shrink-0">{CATEGORY_LABEL[ex.category] || ex.category}</span>
            </button>
          ))}
        </div>
      )}
    </div>
  )
}

// ── Single set row (editable) ─────────────────────────────────────────────────
function SetRow({ set, index, onChange, onDelete }) {
  // duration stored in seconds; let user type MM:SS or plain seconds
  const [durInput, setDurInput] = useState(() => {
    const d = set.duration ?? 0
    const m = Math.floor(d / 60)
    const s = d % 60
    return m > 0 ? `${m}:${String(s).padStart(2, '0')}` : String(s)
  })
  const [weightInput, setWeightInput] = useState(set.weight != null ? String(set.weight) : '')

  function parseDur(val) {
    if (val.includes(':')) {
      const [m, s] = val.split(':').map(Number)
      return (m || 0) * 60 + (s || 0)
    }
    return parseInt(val) || 0
  }

  function commitDur(val) {
    onChange({ ...set, duration: parseDur(val) })
  }

  function commitWeight(val) {
    const n = parseFloat(val)
    onChange({ ...set, weight: isNaN(n) ? null : n })
  }

  return (
    <div className="flex items-center gap-2 py-1.5">
      {/* Weight */}
      <input
        type="number"
        value={weightInput}
        onChange={e => setWeightInput(e.target.value)}
        onBlur={e => commitWeight(e.target.value)}
        onKeyDown={e => e.key === 'Enter' && commitWeight(weightInput)}
        placeholder="—"
        min="0"
        step="0.5"
        className="w-14 bg-white/10 text-white rounded-lg px-2 py-1 text-sm text-center outline-none focus:ring-1 focus:ring-cyan-500 transition-colors"
      />

      {/* Duration */}
      <input
        value={durInput}
        onChange={e => setDurInput(e.target.value)}
        onBlur={e => commitDur(e.target.value)}
        onKeyDown={e => e.key === 'Enter' && commitDur(durInput)}
        placeholder="0:00"
        className="w-16 bg-white/8 text-gray-300 font-mono rounded-lg px-2 py-1 text-xs text-center outline-none focus:ring-1 focus:ring-white/20 transition-colors"
        title="Duration (MM:SS or seconds)"
      />

      {/* Reps */}
      <input
        type="number"
        value={set.reps ?? 0}
        onChange={e => onChange({ ...set, reps: Math.max(0, parseInt(e.target.value) || 0) })}
        min="0"
        className="w-14 bg-white/10 text-white rounded-lg px-2 py-1 text-sm text-center outline-none focus:ring-1 focus:ring-cyan-500 transition-colors"
      />

      <button
        onClick={onDelete}
        className="text-gray-700 hover:text-red-400 p-1 ml-auto rounded transition-colors flex-shrink-0"
      >
        <X size={12} />
      </button>
    </div>
  )
}

// ── Exercise block ────────────────────────────────────────────────────────────
function ExerciseBlock({ exercise, exIdx, onChange, onDelete }) {
  function addSet() {
    onChange({
      ...exercise,
      sets: [...exercise.sets, { duration: 0, reps: 0 }],
    })
  }

  function updateSet(setIdx, updated) {
    onChange({
      ...exercise,
      sets: exercise.sets.map((s, i) => (i === setIdx ? updated : s)),
    })
  }

  function deleteSet(setIdx) {
    const newSets = exercise.sets.filter((_, i) => i !== setIdx)
    if (newSets.length === 0) { onDelete(); return }
    onChange({ ...exercise, sets: newSets })
  }

  function renameExercise({ name, category }) {
    onChange({ ...exercise, name, ...(category ? { category } : {}) })
  }

  return (
    <div className="bg-white/5 border border-white/8 rounded-2xl overflow-hidden">
      <div className="flex items-center gap-2 px-4 py-3 border-b border-white/6">
        <ExercisePicker value={exercise.name} onChange={renameExercise} />
        <button
          onClick={onDelete}
          className="text-gray-700 hover:text-red-400 p-1 rounded transition-colors flex-shrink-0"
          title="Delete exercise"
        >
          <Trash2 size={13} />
        </button>
      </div>

      <div className="px-4 py-2">
        <div className="flex items-center gap-2 pt-1 text-gray-600 text-[10px] uppercase tracking-wider">
          <span className="w-14 text-center flex-shrink-0">kg</span>
          <span className="w-16 text-center flex-shrink-0">time</span>
          <span className="w-14 text-center flex-shrink-0">reps</span>
        </div>
        {exercise.sets.map((set, setIdx) => (
          <SetRow
            key={setIdx}
            set={set}
            index={setIdx}
            onChange={updated => updateSet(setIdx, updated)}
            onDelete={() => deleteSet(setIdx)}
          />
        ))}

        <button
          onClick={addSet}
          className="w-full flex items-center justify-center gap-1.5 py-2 mt-1 border border-dashed border-white/12 rounded-xl text-gray-600 hover:text-cyan-400 hover:border-cyan-500/30 transition-colors text-xs"
        >
          <Plus size={13} />
          Add set
        </button>
      </div>
    </div>
  )
}

// ── Add exercise search bar ───────────────────────────────────────────────────
function AddExerciseBar({ onAdd }) {
  const [query, setQuery] = useState('')
  const [open, setOpen] = useState(false)
  const inputRef = useRef(null)

  const matches = query.trim().length >= 1
    ? EXERCISES.filter(e =>
        e.name.toLowerCase().includes(query.toLowerCase()) ||
        (e.es && e.es.toLowerCase().includes(query.toLowerCase()))
      ).slice(0, 6)
    : []

  const showCustom = query.trim().length >= 2 &&
    !EXERCISES.some(e => e.name.toLowerCase() === query.trim().toLowerCase())

  function pick(name, category = 'Custom') {
    onAdd({ name, category, sets: [{ duration: 0, reps: 0 }] })
    setQuery('')
    setOpen(false)
  }

  return (
    <div className="relative">
      <div className="flex items-center gap-2 bg-white/5 border border-white/10 rounded-xl px-3 py-2.5 focus-within:border-cyan-500/50 transition-colors">
        <Plus size={15} className="text-gray-600 flex-shrink-0" />
        <input
          ref={inputRef}
          value={query}
          onChange={e => { setQuery(e.target.value); setOpen(true) }}
          onFocus={() => setOpen(true)}
          onBlur={() => setTimeout(() => setOpen(false), 180)}
          placeholder="Add exercise..."
          className="flex-1 bg-transparent text-white text-sm outline-none placeholder-gray-700"
        />
      </div>

      {open && (matches.length > 0 || showCustom) && (
        <div className="absolute bottom-full mb-2 left-0 right-0 bg-gray-900 border border-white/10 rounded-xl shadow-2xl z-30 overflow-hidden animate-fadeIn">
          {matches.map(ex => (
            <button
              key={ex.id}
              onMouseDown={() => pick(ex.name, ex.category)}
              className="w-full text-left px-4 py-2.5 hover:bg-white/5 flex justify-between items-center gap-3"
            >
              <span className="text-white text-sm">{ex.name}</span>
              <span className="text-gray-600 text-xs flex-shrink-0">{CATEGORY_LABEL[ex.category] || ex.category}</span>
            </button>
          ))}
          {showCustom && (
            <button
              onMouseDown={() => pick(query.trim())}
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

// ── Photos panel ─────────────────────────────────────────────────────────────
function PhotosPanel({ photos, token, onChange }) {
  const [uploading, setUploading] = useState(false)
  const fileRef = useRef(null)
  const galleryRef = useRef(null)

  async function handleFiles(files) {
    if (!files?.length) return
    setUploading(true)
    try {
      const uploaded = []
      for (const f of files) {
        const { filename } = await uploadPhoto(token, f)
        uploaded.push(filename)
      }
      onChange([...(photos || []), ...uploaded])
    } catch {
      // ignored — caller handles errors via global error state
    }
    setUploading(false)
  }

  async function removePhoto(filename) {
    onChange((photos || []).filter(p => p !== filename))
    try { await deletePhoto(token, filename) } catch { /* leave file orphaned */ }
  }

  return (
    <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-3 space-y-3">
      <div className="flex items-center justify-between">
        <p className="text-gray-500 text-xs font-medium">Photos ({photos?.length || 0})</p>
        <div className="flex gap-2">
          <input
            ref={fileRef}
            type="file"
            accept="image/*"
            capture="environment"
            multiple
            onChange={e => { handleFiles([...e.target.files]); e.target.value = '' }}
            className="hidden"
          />
          <input
            ref={galleryRef}
            type="file"
            accept="image/*"
            multiple
            onChange={e => { handleFiles([...e.target.files]); e.target.value = '' }}
            className="hidden"
          />
          <button
            onClick={() => fileRef.current?.click()}
            disabled={uploading}
            className="flex items-center gap-1 text-cyan-400 hover:text-cyan-300 text-xs font-medium px-2 py-1 rounded-lg transition-colors disabled:opacity-50"
            title="Take photo"
          >
            <Camera size={14} />
            {uploading ? 'Uploading...' : 'Camera'}
          </button>
          <button
            onClick={() => galleryRef.current?.click()}
            disabled={uploading}
            className="flex items-center gap-1 text-cyan-400 hover:text-cyan-300 text-xs font-medium px-2 py-1 rounded-lg transition-colors disabled:opacity-50"
            title="Pick from gallery"
          >
            <Image size={14} />
            Gallery
          </button>
        </div>
      </div>
      {photos?.length > 0 && (
        <div className="grid grid-cols-3 gap-2">
          {photos.map(p => (
            <div key={p} className="relative aspect-square bg-white/5 rounded-lg overflow-hidden">
              <img
                src={photoUrl(token, p)}
                alt=""
                className="w-full h-full object-cover"
                loading="lazy"
              />
              <button
                onClick={() => removePhoto(p)}
                className="absolute top-1 right-1 bg-black/70 text-white rounded-full p-1 hover:bg-red-500/90 transition-colors"
                title="Remove"
              >
                <X size={11} />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

// ── Main editor ───────────────────────────────────────────────────────────────
export default function SessionEditor({ session, allData, token, onSave, onClose }) {
  const [exercises, setExercises] = useState(
    session.exercises.map(ex => ({
      ...ex,
      sets: ex.sets.map(s => ({ ...s })),
    }))
  )
  const [title, setTitle] = useState(session.title || '')
  // Pre-fill with saved groups, or the inferred ones for legacy sessions.
  const [categories, setCategories] = useState(() => {
    const explicit = (session.categories || []).filter(Boolean)
    return explicit.length ? explicit : sessionCategories(session)
  })
  const [startTime, setStartTime] = useState(session.startTime || new Date().toISOString())
  const [notes, setNotes] = useState(session.notes || '')
  const [locationId, setLocationId] = useState(session.locationId || '')
  const [photos, setPhotos] = useState(session.photos || [])
  const [saving, setSaving] = useState(false)
  const [confirmDelete, setConfirmDelete] = useState(false)
  const [error, setError] = useState('')

  const locations = allData.locations || []

  function updateExercise(idx, updated) {
    setExercises(prev => prev.map((e, i) => (i === idx ? updated : e)))
  }

  function deleteExercise(idx) {
    setExercises(prev => prev.filter((_, i) => i !== idx))
  }

  function addExercise(ex) {
    setExercises(prev => [...prev, ex])
  }

  function toggleCategory(cat) {
    setCategories(prev => prev.includes(cat) ? prev.filter(c => c !== cat) : [...prev, cat])
  }

  async function handleSave() {
    setSaving(true)
    setError('')
    try {
      const startIso = new Date(startTime).toISOString()
      // If the start time moved, shift every absolute timestamp (end time and
      // per-set startedAt) by the same delta so durations and the HR chart
      // (which positions sets relative to the start) stay consistent.
      const delta = new Date(startIso).getTime() - new Date(session.startTime).getTime()
      const shiftIso = iso => iso ? new Date(new Date(iso).getTime() + delta).toISOString() : iso
      const shiftedExercises = delta === 0 ? exercises : exercises.map(ex => ({
        ...ex,
        sets: ex.sets.map(st => st.startedAt ? { ...st, startedAt: shiftIso(st.startedAt) } : st),
      }))
      const updatedSession = {
        ...session,
        title: title.trim(),
        startTime: startIso,
        endTime: shiftIso(session.endTime),
        date: startIso.slice(0, 10),
        categories: GROUP_OPTIONS.filter(c => categories.includes(c)),
        exercises: shiftedExercises,
        notes: notes.trim(),
        locationId: locationId || null,
        photos,
      }
      const newData = {
        ...allData,
        sessions: allData.sessions.map(s => s.id === session.id ? updatedSession : s),
      }
      await saveSession(token, updatedSession)   // solo esta sesión viaja
      onSave(newData)
      onClose()
    } catch {
      setError('Failed to save')
      setSaving(false)
    }
  }

  async function handleDeleteSession() {
    setSaving(true)
    setError('')
    try {
      const newData = {
        ...allData,
        sessions: allData.sessions.filter(s => s.id !== session.id),
      }
      await deleteSession(token, session.id)
      onSave(newData)
      onClose()
    } catch {
      setError('Failed to delete')
      setSaving(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black/75 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4 animate-fadeIn">
      <div className="bg-gray-950 border border-white/10 rounded-t-3xl sm:rounded-2xl w-full sm:max-w-lg max-h-[92vh] overflow-y-auto shadow-2xl">

        {/* Header */}
        <div className="flex items-center justify-between px-5 py-4 border-b border-white/10 sticky top-0 bg-gray-950 z-10">
          <div>
            <h2 className="text-white font-bold text-base">Edit session</h2>
            <p className="text-gray-500 text-xs mt-0.5">
              {format(new Date(session.startTime), "EEEE d MMM · HH:mm")}
            </p>
          </div>
          <button onClick={onClose} className="text-gray-600 hover:text-white p-2 rounded-lg transition-colors">
            <X size={18} />
          </button>
        </div>

        <div className="px-5 py-5 space-y-3">
          {error && (
            <div className="bg-red-500/15 border border-red-500/30 rounded-xl px-4 py-2 text-red-300 text-sm">
              {error}
            </div>
          )}

          {/* Title */}
          <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-3">
            <label className="flex items-center gap-2 text-gray-500 text-xs font-medium mb-2">
              <Tag size={12} />
              Title
            </label>
            <input
              type="text"
              value={title}
              onChange={e => setTitle(e.target.value)}
              placeholder="Defaults to routine or date"
              className="w-full rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-cyan-500"
            />
          </div>

          {/* Muscle groups */}
          <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-3">
            <label className="flex items-center gap-2 text-gray-500 text-xs font-medium mb-2">
              <Activity size={12} />
              Muscle groups
            </label>
            <div className="flex flex-wrap gap-1.5">
              {GROUP_OPTIONS.map(cat => {
                const active = categories.includes(cat)
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
          </div>

          {/* Date & time */}
          <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-3">
            <label className="flex items-center gap-2 text-gray-500 text-xs font-medium mb-2">
              <CalendarClock size={12} />
              Date & time
            </label>
            <input
              type="datetime-local"
              value={(() => {
                const d = new Date(startTime)
                if (isNaN(d.getTime())) return ''
                const pad = n => String(n).padStart(2, '0')
                return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
              })()}
              onChange={e => {
                const v = e.target.value
                if (!v) return
                setStartTime(new Date(v).toISOString())
              }}
              className="w-full rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-cyan-500"
            />
          </div>

          {/* Location */}
          <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-3">
            <label className="flex items-center gap-2 text-gray-500 text-xs font-medium mb-2">
              <MapPin size={12} />
              Location
            </label>
            <select
              value={locationId}
              onChange={e => setLocationId(e.target.value)}
              className="w-full bg-white/8 text-white rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-cyan-500"
            >
              <option value="">— No location —</option>
              {locations.map(l => (
                <option key={l.id} value={l.id}>{l.name}</option>
              ))}
            </select>
            {locations.length === 0 && (
              <p className="text-gray-600 text-xs mt-1">Add locations from More → Locations</p>
            )}
          </div>

          {/* Notes */}
          <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-3">
            <label className="flex items-center gap-2 text-gray-500 text-xs font-medium mb-2">
              <FileText size={12} />
              Notes
            </label>
            <textarea
              value={notes}
              onChange={e => setNotes(e.target.value)}
              rows={3}
              placeholder="How did the session go?"
              className="w-full bg-white/8 text-white rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-cyan-500 resize-y placeholder-gray-600"
            />
          </div>

          {/* Photos */}
          <PhotosPanel photos={photos} token={token} onChange={setPhotos} />

          {exercises.length === 0 && (
            <p className="text-gray-600 text-sm text-center py-4">
              No exercises — add one below or delete the session
            </p>
          )}

          {exercises.map((ex, idx) => (
            <ExerciseBlock
              key={idx}
              exercise={ex}
              exIdx={idx}
              onChange={updated => updateExercise(idx, updated)}
              onDelete={() => deleteExercise(idx)}
            />
          ))}

          {/* Add exercise */}
          <AddExerciseBar onAdd={addExercise} />

          {/* Delete session */}
          {!confirmDelete ? (
            <button
              onClick={() => setConfirmDelete(true)}
              className="w-full flex items-center justify-center gap-2 py-3 border border-red-500/20 text-red-500/70 hover:text-red-400 hover:bg-red-500/8 rounded-2xl text-sm transition-colors"
            >
              <Trash2 size={14} />
              Delete session
            </button>
          ) : (
            <div className="bg-red-500/10 border border-red-500/30 rounded-2xl px-4 py-4">
              <div className="flex items-center gap-2 text-red-300 text-sm mb-3">
                <AlertTriangle size={15} />
                Delete this session? This cannot be undone.
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => setConfirmDelete(false)}
                  className="flex-1 py-2 rounded-xl border border-white/10 text-gray-400 text-sm hover:bg-white/5 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleDeleteSession}
                  disabled={saving}
                  className="flex-1 py-2 rounded-xl bg-red-500 hover:bg-red-400 text-white text-sm font-semibold disabled:opacity-50 transition-colors"
                >
                  Delete
                </button>
              </div>
            </div>
          )}

          {/* Save */}
          <button
            onClick={handleSave}
            disabled={saving}
            className="w-full flex items-center justify-center gap-2 bg-cyan-500 hover:bg-cyan-400 disabled:opacity-50 text-white font-semibold py-3.5 rounded-2xl text-sm transition-colors"
          >
            <Save size={15} />
            {saving ? 'Saving...' : 'Save changes'}
          </button>
        </div>
      </div>
    </div>
  )
}
