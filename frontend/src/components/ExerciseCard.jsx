import { useState, useEffect, useRef } from 'react'
import { Plus, X, Square, ChevronDown, ChevronUp, Pause, Play, StopCircle, Pencil, Search, Check, HeartPulse } from 'lucide-react'
import { EXERCISES, CATEGORY_LABEL } from '../exercises'
import { useHeartRate } from '../heartRate'

function fmt(secs) {
  const m = Math.floor(secs / 60)
  const s = secs % 60
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
}

// ── Active set timer ──────────────────────────────────────────────────────────
function ActiveSet({ set, index, onStop }) {
  const [elapsed, setElapsed] = useState(0)
  const hr = useHeartRate()
  const hrAccRef = useRef([])   // bpm readings collected during this set

  useEffect(() => {
    const start = new Date(set.startedAt).getTime()
    const id = setInterval(() => setElapsed(Math.floor((Date.now() - start) / 1000)), 100)
    return () => clearInterval(id)
  }, [set.startedAt])

  // Accumulate live bpm while this set is running (full resolution, ~1/s).
  useEffect(() => {
    if (hr.status === 'connected' && hr.bpm != null) hrAccRef.current.push(hr.bpm)
  }, [hr.lastAt, hr.status, hr.bpm])

  function stop() {
    const bpms = hrAccRef.current
    const hrStats = bpms.length
      ? {
          startHr: bpms[0],   // pulse at the moment "Start" was pressed
          avgHr: Math.round(bpms.reduce((a, b) => a + b, 0) / bpms.length),
          maxHr: Math.max(...bpms),
        }
      : null
    onStop(elapsed, hrStats)
  }

  const live = hr.status === 'connected' && hr.bpm != null

  return (
    <div className="flex items-center gap-3 bg-cyan-500/10 border border-cyan-500/30 rounded-xl px-3 py-2.5 animate-fadeIn">
      <span className="text-gray-600 text-xs w-5 text-center font-mono">{index + 1}</span>
      <span className="text-cyan-300 font-mono text-xl font-bold flex-1 tracking-wider">
        {fmt(elapsed)}
      </span>
      {live && (
        <span className="flex items-center gap-1 text-red-400 font-mono text-base font-bold">
          <HeartPulse size={14} className="animate-pulse" />
          {hr.bpm}
        </span>
      )}
      <button
        onClick={stop}
        className="flex items-center gap-1.5 bg-red-500 hover:bg-red-400 text-white px-3 py-1.5 rounded-lg text-xs font-medium transition-colors"
      >
        <Square size={12} fill="white" />
        Stop
      </button>
    </div>
  )
}

// ── Rest timer ────────────────────────────────────────────────────────────────
function RestTimer({ rest, onPause, onResume, onStop }) {
  const [elapsed, setElapsed] = useState(rest.elapsed)

  useEffect(() => {
    if (rest.paused) { setElapsed(rest.elapsed); return }
    const start = new Date(rest.startedAt).getTime()
    const id = setInterval(() => {
      setElapsed(rest.elapsed + Math.floor((Date.now() - start) / 1000))
    }, 100)
    return () => clearInterval(id)
  }, [rest])

  return (
    <div className="flex items-center gap-2 bg-amber-500/8 border border-amber-500/20 rounded-xl px-3 py-2.5 animate-fadeIn">
      <span className="text-amber-400/60 text-xs w-5 text-center">💤</span>
      <span className="text-amber-300 text-xs flex-1">Descanso</span>
      <span className={`font-mono text-base font-bold ${rest.paused ? 'text-gray-500' : 'text-amber-300'}`}>
        {fmt(elapsed)}
      </span>
      {rest.paused ? (
        <button
          onClick={onResume}
          className="text-amber-400 hover:text-amber-300 p-1.5 rounded-lg transition-colors"
          title="Resume rest"
        >
          <Play size={14} fill="currentColor" />
        </button>
      ) : (
        <button
          onClick={onPause}
          className="text-amber-400 hover:text-amber-300 p-1.5 rounded-lg transition-colors"
          title="Pause rest"
        >
          <Pause size={14} fill="currentColor" />
        </button>
      )}
      <button
        onClick={() => onStop(elapsed)}
        className="text-gray-600 hover:text-red-400 p-1.5 rounded-lg transition-colors"
        title="End rest"
      >
        <StopCircle size={14} />
      </button>
    </div>
  )
}

// ── Completed set row ─────────────────────────────────────────────────────────
function CompletedSet({ set, index, onUpdateReps, onUpdateWeight, onDelete }) {
  const [reps, setReps] = useState(set.reps != null ? String(set.reps) : '')
  const [weight, setWeight] = useState(set.weight != null ? String(set.weight) : '')

  function commitReps(val) {
    onUpdateReps(Math.max(1, parseInt(val) || 1))
  }

  function commitWeight(val) {
    const n = parseFloat(val)
    onUpdateWeight(isNaN(n) ? null : n)
  }

  return (
    <div className="flex items-center gap-3 bg-white/5 rounded-xl px-3 py-2.5 animate-fadeIn">
      <span className="text-gray-600 text-xs w-5 text-center font-mono">{index + 1}</span>
      <span className="text-gray-500 font-mono text-xs w-14">{fmt(set.duration)}</span>
      <div className="flex items-center gap-1.5 flex-1">
        <input
          type="number"
          value={reps}
          onChange={e => setReps(e.target.value)}
          onBlur={e => commitReps(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && commitReps(reps)}
          placeholder="1"
          min="1"
          className="w-14 bg-white/10 text-white rounded-lg px-2 py-1 text-sm text-center outline-none focus:ring-1 focus:ring-cyan-500 transition-colors"
        />
        <span className="text-gray-600 text-xs">reps</span>
      </div>
      <div className="flex items-center gap-1.5">
        <input
          type="number"
          value={weight}
          onChange={e => setWeight(e.target.value)}
          onBlur={e => commitWeight(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && commitWeight(weight)}
          placeholder="—"
          min="0"
          step="0.5"
          className="w-14 bg-white/10 text-white rounded-lg px-2 py-1 text-sm text-center outline-none focus:ring-1 focus:ring-cyan-500 transition-colors"
        />
        <span className="text-gray-600 text-xs">kg</span>
      </div>
      {set.avgHr != null && (
        <span
          title={`Heart rate — ${set.startHr != null ? `start ${set.startHr} · ` : ''}avg ${set.avgHr}${set.maxHr != null ? ` · max ${set.maxHr}` : ''} bpm`}
          className="text-red-400/80 text-xs font-mono flex items-center gap-0.5 flex-shrink-0"
        >
          <HeartPulse size={11} />{set.avgHr}
        </span>
      )}
      {set.restDuration > 0 && (
        <span className="text-amber-500/60 text-xs font-mono">{fmt(set.restDuration)}</span>
      )}
      <button onClick={onDelete} className="text-gray-700 hover:text-red-400 p-1 rounded transition-colors">
        <X size={13} />
      </button>
    </div>
  )
}

// ── Inline name editor ────────────────────────────────────────────────────────
function NameEditor({ exercise, onChange }) {
  const [editing, setEditing] = useState(false)
  const [query, setQuery] = useState(exercise.name)
  const inputRef = useRef(null)

  const matches = (editing && query.trim().length >= 1)
    ? EXERCISES.filter(e =>
        e.name.toLowerCase().includes(query.toLowerCase()) ||
        (e.es && e.es.toLowerCase().includes(query.toLowerCase()))
      ).slice(0, 6)
    : []

  function pick(ex) {
    onChange({ name: ex.name, category: ex.category })
    setQuery(ex.name)
    setEditing(false)
  }

  function confirmCustom() {
    const v = query.trim()
    if (!v) return
    const known = EXERCISES.find(e => e.name.toLowerCase() === v.toLowerCase())
    if (known) pick(known)
    else { onChange({ name: v, category: exercise.category || 'Custom' }); setEditing(false) }
  }

  if (!editing) {
    return (
      <div className="flex-1 min-w-0 flex items-center gap-2">
        <h3 className="text-white font-semibold text-sm leading-tight truncate">{exercise.name}</h3>
        <button
          onClick={() => { setEditing(true); setQuery(exercise.name); setTimeout(() => inputRef.current?.focus(), 50) }}
          className="text-gray-600 hover:text-cyan-400 transition-colors flex-shrink-0"
          title="Edit name"
        >
          <Pencil size={12} />
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
          onKeyDown={e => {
            if (e.key === 'Enter') confirmCustom()
            else if (e.key === 'Escape') { setEditing(false); setQuery(exercise.name) }
          }}
          onBlur={() => setTimeout(() => setEditing(false), 200)}
          className="flex-1 bg-transparent text-white text-sm outline-none min-w-0"
          placeholder="Search exercise..."
        />
        <button onMouseDown={e => { e.preventDefault(); confirmCustom() }} className="text-cyan-400 flex-shrink-0">
          <Check size={14} />
        </button>
      </div>
      {matches.length > 0 && (
        <div className="absolute top-full mt-1 left-0 right-0 bg-gray-900 border border-white/10 rounded-xl shadow-2xl z-30 overflow-hidden">
          {matches.map(ex => (
            <button
              key={ex.id}
              onMouseDown={e => { e.preventDefault(); pick(ex) }}
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

// ── Main exercise card ────────────────────────────────────────────────────────
export default function ExerciseCard({ exercise, onChange, onRemove }) {
  const [collapsed, setCollapsed] = useState(false)
  const [activeIdx, setActiveIdx] = useState(null)
  // rest: { startedAt: ISO, paused: bool, elapsed: number } | null
  const [rest, setRest] = useState(null)
  const restRef = useRef(rest)
  restRef.current = rest

  function getCurrentRestElapsed() {
    const r = restRef.current
    if (!r) return 0
    if (r.paused) return r.elapsed
    return r.elapsed + Math.floor((Date.now() - new Date(r.startedAt).getTime()) / 1000)
  }

  // Save rest duration to the last completed set, return updated sets
  function setsWithRest(sets) {
    const restDuration = getCurrentRestElapsed()
    if (!restDuration) return sets
    // Find last completed set
    let lastIdx = -1
    for (let i = sets.length - 1; i >= 0; i--) {
      if (sets[i].duration !== null) { lastIdx = i; break }
    }
    if (lastIdx < 0) return sets
    return sets.map((s, i) => i === lastIdx ? { ...s, restDuration } : s)
  }

  function addSet() {
    if (activeIdx !== null) return

    // Finalise rest → save to last set
    let currentSets = rest ? setsWithRest(exercise.sets) : [...exercise.sets]
    setRest(null)

    // Inherit weight from the last completed set that has weight
    let inheritedWeight = null
    for (let i = currentSets.length - 1; i >= 0; i--) {
      if (currentSets[i].weight != null) { inheritedWeight = currentSets[i].weight; break }
    }

    const newSet = { id: Date.now(), startedAt: new Date().toISOString(), duration: null, reps: null, weight: inheritedWeight }
    const updated = { ...exercise, sets: [...currentSets, newSet] }
    setActiveIdx(updated.sets.length - 1)
    onChange(updated)
  }

  function stopSet(idx, duration, hrStats) {
    const newSets = exercise.sets.map((s, i) =>
      i === idx ? { ...s, duration, reps: s.reps ?? 1, ...(hrStats || {}) } : s)
    onChange({ ...exercise, sets: newSets })
    setActiveIdx(null)
    // Start rest timer
    setRest({ startedAt: new Date().toISOString(), paused: false, elapsed: 0 })
  }

  function pauseRest() {
    setRest(r => ({ ...r, elapsed: getCurrentRestElapsed(), startedAt: null, paused: true }))
  }

  function resumeRest() {
    setRest(r => ({ ...r, startedAt: new Date().toISOString(), paused: false }))
  }

  function stopRest(elapsed) {
    // Save rest to last completed set
    const restDuration = elapsed
    let lastIdx = -1
    for (let i = exercise.sets.length - 1; i >= 0; i--) {
      if (exercise.sets[i].duration !== null) { lastIdx = i; break }
    }
    if (lastIdx >= 0) {
      const newSets = exercise.sets.map((s, i) => i === lastIdx ? { ...s, restDuration } : s)
      onChange({ ...exercise, sets: newSets })
    }
    setRest(null)
  }

  function updateReps(idx, reps) {
    onChange({ ...exercise, sets: exercise.sets.map((s, i) => i === idx ? { ...s, reps } : s) })
  }

  function updateWeight(idx, weight) {
    onChange({ ...exercise, sets: exercise.sets.map((s, i) => i === idx ? { ...s, weight } : s) })
  }

  function deleteSet(idx) {
    if (activeIdx === idx) { setActiveIdx(null); setRest(null) }
    else if (activeIdx !== null && activeIdx > idx) setActiveIdx(activeIdx - 1)
    onChange({ ...exercise, sets: exercise.sets.filter((_, i) => i !== idx) })
  }

  const completedSets = exercise.sets.filter(s => s.duration !== null)
  const totalReps = completedSets.reduce((sum, s) => sum + (s.reps || 0), 0)

  return (
    <div className="bg-white/5 border border-white/10 rounded-2xl overflow-hidden animate-fadeIn">
      {/* Routine target banner (only when this exercise comes from a routine) */}
      {(exercise.tempo || exercise.targetReps || exercise.targetSets || exercise.timeSeconds || exercise.type === 'machine') && (
        <div className="bg-cyan-500/8 border-b border-cyan-500/15 px-4 py-2 flex flex-wrap gap-x-3 gap-y-1 text-[11px]">
          {exercise.tempo && (
            <span className="text-cyan-300">tempo <span className="font-mono font-semibold">{exercise.tempo}</span></span>
          )}
          {exercise.targetSets && exercise.targetReps && (
            <span className="text-gray-400">target <span className="text-white font-semibold">{exercise.targetSets}×{exercise.targetReps}</span></span>
          )}
          {exercise.timeSeconds && !exercise.targetReps && (
            <span className="text-gray-400">target <span className="text-white font-semibold">{exercise.targetSets || 1}× {exercise.timeSeconds}s</span></span>
          )}
          {exercise.type === 'machine' && exercise.resistance != null && (
            <span className="text-gray-400">resistance <span className="text-white font-semibold">{exercise.resistance}</span></span>
          )}
          {exercise.restSeconds != null && exercise.restSeconds > 0 && (
            <span className="text-amber-300/80">rest <span className="font-mono">{exercise.restSeconds}s</span></span>
          )}
        </div>
      )}

      {/* Header */}
      <div className="flex items-start gap-3 px-4 py-3">
        <div className="flex-1 min-w-0">
          <NameEditor
            exercise={exercise}
            onChange={({ name, category }) => onChange({ ...exercise, name, category })}
          />
          <p className="text-gray-600 text-xs mt-0.5">
            {completedSets.length} {completedSets.length === 1 ? 'set' : 'sets'}
            {totalReps > 0 && ` · ${totalReps} reps`}
          </p>
        </div>
        <button onClick={() => setCollapsed(c => !c)} className="text-gray-600 hover:text-white p-1 transition-colors">
          {collapsed ? <ChevronDown size={16} /> : <ChevronUp size={16} />}
        </button>
        <button onClick={onRemove} className="text-gray-700 hover:text-red-400 p-1 transition-colors">
          <X size={16} />
        </button>
      </div>

      {!collapsed && (
        <div className="px-4 pb-4 space-y-2">
          {exercise.sets.map((set, idx) =>
            set.duration === null ? (
              <ActiveSet key={set.id} set={set} index={idx} onStop={(dur, hrStats) => stopSet(idx, dur, hrStats)} />
            ) : (
              <CompletedSet
                key={set.id}
                set={set}
                index={idx}
                onUpdateReps={reps => updateReps(idx, reps)}
                onUpdateWeight={weight => updateWeight(idx, weight)}
                onDelete={() => deleteSet(idx)}
              />
            )
          )}

          {/* Rest timer */}
          {rest && activeIdx === null && (
            <RestTimer
              rest={rest}
              onPause={pauseRest}
              onResume={resumeRest}
              onStop={stopRest}
            />
          )}

          {/* Add set button */}
          {activeIdx === null && (
            <button
              onClick={addSet}
              className="w-full flex items-center justify-center gap-2 py-2.5 border border-dashed border-white/15 rounded-xl text-gray-600 hover:text-cyan-400 hover:border-cyan-500/40 transition-colors text-sm"
            >
              <Plus size={15} />
              {rest ? 'Start set (saves rest)' : 'Add set'}
            </button>
          )}
        </div>
      )}
    </div>
  )
}
