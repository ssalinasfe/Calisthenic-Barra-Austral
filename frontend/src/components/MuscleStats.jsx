import { useState, useMemo } from 'react'
import {
  format, startOfWeek, endOfWeek, startOfMonth, endOfMonth,
  addWeeks, addMonths, isWithinInterval,
} from 'date-fns'
import { ChevronLeft, ChevronRight, ChevronDown, ChevronUp, Activity } from 'lucide-react'
import { MUSCLES_BY_NAME, MUSCLE_ES, CATEGORY_LABEL, CATEGORY_PILL, CATEGORY_BAR } from '../exercises'
import { totalReps as sumReps } from '../utils'

function getMusclesForExercise(ex) {
  // Prefer mapping from name (handles renamed/edited exercises)
  if (MUSCLES_BY_NAME[ex.name]) return MUSCLES_BY_NAME[ex.name]
  if (Array.isArray(ex.muscles) && ex.muscles.length > 0) return ex.muscles
  // Fallback by category
  switch (ex.category) {
    case 'Push':    return ['Pecho', 'Tríceps', 'Hombros']
    case 'Pull':    return ['Dorsales', 'Bíceps']
    case 'Piernas': return ['Cuádriceps', 'Glúteos']
    case 'Remo':    return ['Heart']
    default:        return ['Otro']
  }
}

function aggregate(sessions) {
  let totalReps = 0, totalSets = 0
  const byCategory = {}, byMuscle = {}
  const exerciseSet = new Set()

  sessions.forEach(s => {
    (s.exercises || []).forEach(ex => {
      const reps = sumReps(ex.sets)
      const setCount = (ex.sets || []).filter(st => st.duration !== null && st.duration !== undefined).length
      if (setCount === 0 && reps === 0) return

      exerciseSet.add(ex.name)
      totalReps += reps
      totalSets += setCount

      const cat = ex.category || 'Custom'
      if (!byCategory[cat]) byCategory[cat] = { reps: 0, sets: 0 }
      byCategory[cat].reps += reps
      byCategory[cat].sets += setCount

      getMusclesForExercise(ex).forEach(m => {
        if (!byMuscle[m]) byMuscle[m] = { reps: 0, sets: 0, exercises: {}, category: cat }
        byMuscle[m].reps += reps
        byMuscle[m].sets += setCount
        const e = byMuscle[m].exercises[ex.name] || { reps: 0, sets: 0 }
        e.reps += reps
        e.sets += setCount
        byMuscle[m].exercises[ex.name] = e
      })
    })
  })

  return {
    totalReps,
    totalSets,
    totalSessions: sessions.length,
    totalExercises: exerciseSet.size,
    byCategory,
    byMuscle,
  }
}

function PeriodCard({ stats, sessions }) {
  const [expanded, setExpanded] = useState(null)
  const muscleEntries = Object.entries(stats.byMuscle)
    .sort((a, b) => b[1].reps - a[1].reps)
  const maxMuscleReps = muscleEntries[0]?.[1].reps || 1

  const categoryEntries = Object.entries(stats.byCategory)
    .sort((a, b) => b[1].reps - a[1].reps)

  if (sessions.length === 0) {
    return (
      <div className="bg-white/3 border border-white/8 rounded-2xl p-8 text-center">
        <p className="text-gray-600 text-sm">No workouts in this period</p>
      </div>
    )
  }

  return (
    <div className="space-y-3">
      {/* Totals */}
      <div className="grid grid-cols-3 gap-2">
        <div className="bg-white/5 border border-white/8 rounded-xl px-3 py-3 text-center">
          <p className="text-cyan-400 font-bold text-xl">{stats.totalSessions}</p>
          <p className="text-gray-600 text-xs mt-0.5">{stats.totalSessions === 1 ? 'session' : 'sessions'}</p>
        </div>
        <div className="bg-white/5 border border-white/8 rounded-xl px-3 py-3 text-center">
          <p className="text-cyan-400 font-bold text-xl">{stats.totalSets}</p>
          <p className="text-gray-600 text-xs mt-0.5">sets</p>
        </div>
        <div className="bg-white/5 border border-white/8 rounded-xl px-3 py-3 text-center">
          <p className="text-cyan-400 font-bold text-xl">{stats.totalReps}</p>
          <p className="text-gray-600 text-xs mt-0.5">reps</p>
        </div>
      </div>

      {/* Categories */}
      {categoryEntries.length > 0 && (
        <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-4">
          <p className="text-gray-500 text-xs font-medium mb-3">By group</p>
          <div className="space-y-2">
            {categoryEntries.map(([cat, data]) => {
              const pill = CATEGORY_PILL[cat] || CATEGORY_PILL.Custom
              const bar = CATEGORY_BAR[cat] || CATEGORY_BAR.Custom
              const pct = stats.totalReps > 0 ? Math.round((data.reps / stats.totalReps) * 100) : 0
              return (
                <div key={cat}>
                  <div className="flex items-center gap-2 mb-1">
                    <span className={`text-xs px-2 py-0.5 rounded-full border ${pill}`}>
                      {CATEGORY_LABEL[cat] || cat}
                    </span>
                    <span className="text-gray-600 text-xs">{data.sets} sets · {data.reps} reps</span>
                    <span className="text-gray-700 text-xs ml-auto">{pct}%</span>
                  </div>
                  <div className="h-1.5 bg-white/5 rounded-full overflow-hidden">
                    <div className={`h-full ${bar}`} style={{ width: `${pct}%` }} />
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      )}

      {/* Muscles */}
      <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-4">
        <p className="text-gray-500 text-xs font-medium mb-3">By muscle</p>
        <div className="space-y-2">
          {muscleEntries.map(([muscle, data]) => {
            const bar = CATEGORY_BAR[data.category] || CATEGORY_BAR.Custom
            const pct = Math.round((data.reps / maxMuscleReps) * 100)
            const muscleEs = MUSCLE_ES[muscle]
            const exCount = Object.keys(data.exercises).length
            const open = expanded === muscle
            const exEntries = Object.entries(data.exercises).sort((a, b) => b[1].reps - a[1].reps)
            return (
              <div key={muscle}>
                <button
                  onClick={() => setExpanded(open ? null : muscle)}
                  className="w-full text-left group"
                >
                  <div className="flex items-center gap-2 mb-1 flex-wrap">
                    <span className="text-white text-sm font-semibold">{muscle}</span>
                    {muscleEs && muscleEs !== muscle && (
                      <span className="text-gray-500 text-xs">{muscleEs}</span>
                    )}
                    <span className="text-gray-600 text-xs">· {exCount} {exCount === 1 ? 'exercise' : 'exercises'}</span>
                    <span className="text-cyan-400 font-mono text-xs ml-auto font-semibold">{data.reps} reps</span>
                    {open
                      ? <ChevronUp size={13} className="text-gray-600 group-hover:text-white transition-colors" />
                      : <ChevronDown size={13} className="text-gray-600 group-hover:text-white transition-colors" />}
                  </div>
                  <div className="h-1.5 bg-white/5 rounded-full overflow-hidden">
                    <div className={`h-full ${bar}`} style={{ width: `${pct}%` }} />
                  </div>
                </button>

                {open && (
                  <div className="mt-2 mb-1.5 ml-1 pl-3 border-l border-white/10 space-y-2 animate-fadeIn">
                    <p className="text-gray-600 text-[10px]">
                      % en negrita = del músculo · % gris = del total del periodo
                    </p>
                    {exEntries.map(([name, e]) => {
                      const share = data.reps > 0 ? Math.round((e.reps / data.reps) * 100) : 0
                      const periodShare = stats.totalReps > 0 ? Math.round((e.reps / stats.totalReps) * 100) : 0
                      return (
                        <div key={name}>
                          <div className="flex items-center gap-2">
                            <span className="text-gray-300 text-xs truncate flex-1">{name}</span>
                            <span className="text-gray-500 text-xs font-mono">{e.reps} reps</span>
                            <span className="text-gray-300 text-xs font-mono w-9 text-right font-semibold">{share}%</span>
                          </div>
                          <div className="flex items-center gap-2 mt-1">
                            <div className="h-1 bg-white/5 rounded-full overflow-hidden flex-1">
                              <div className={`h-full ${bar} opacity-70`} style={{ width: `${share}%` }} />
                            </div>
                            <span className="text-gray-600 text-[10px] font-mono whitespace-nowrap">{periodShare}% del periodo</span>
                          </div>
                        </div>
                      )
                    })}
                  </div>
                )}
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}

function PeriodNavigator({ label, onPrev, onNext, canNext }) {
  return (
    <div className="flex items-center gap-2 bg-white/5 border border-white/8 rounded-xl px-2 py-1.5">
      <button
        onClick={onPrev}
        className="text-gray-500 hover:text-white p-1.5 rounded-lg transition-colors"
        title="Previous"
      >
        <ChevronLeft size={16} />
      </button>
      <p className="text-white text-sm font-medium flex-1 text-center capitalize truncate">{label}</p>
      <button
        onClick={onNext}
        disabled={!canNext}
        className="text-gray-500 hover:text-white disabled:opacity-30 disabled:hover:text-gray-500 p-1.5 rounded-lg transition-colors"
        title="Next"
      >
        <ChevronRight size={16} />
      </button>
    </div>
  )
}

export default function MuscleStats({ allData }) {
  const [mode, setMode] = useState('week')        // session | week | month
  const [offset, setOffset] = useState(0)         // 0 = current, -1 = prev, etc.

  const sessions = (allData.sessions || []).slice().sort(
    (a, b) => new Date(a.startTime) - new Date(b.startTime)
  )

  const { filtered, label } = useMemo(() => {
    if (sessions.length === 0) return { filtered: [], label: '—' }

    if (mode === 'session') {
      // offset 0 = most recent session, -1 = before that, etc.
      const idx = sessions.length - 1 + offset
      if (idx < 0 || idx >= sessions.length) return { filtered: [], label: 'No session' }
      const s = sessions[idx]
      const lbl = format(new Date(s.startTime), "EEEE d MMM · HH:mm")
      return { filtered: [s], label: lbl }
    }

    const now = new Date()

    if (mode === 'week') {
      const ref = addWeeks(now, offset)
      const start = startOfWeek(ref, { weekStartsOn: 1 })
      const end = endOfWeek(ref, { weekStartsOn: 1 })
      const lbl = `Week of ${format(start, 'd MMM')} - ${format(end, 'd MMM')}`
      const inRange = sessions.filter(s => isWithinInterval(new Date(s.startTime), { start, end }))
      return { filtered: inRange, label: lbl }
    }

    // month
    const ref = addMonths(now, offset)
    const start = startOfMonth(ref)
    const end = endOfMonth(ref)
    const lbl = format(ref, "MMMM yyyy")
    const inRange = sessions.filter(s => isWithinInterval(new Date(s.startTime), { start, end }))
    return { filtered: inRange, label: lbl }
  }, [sessions, mode, offset])

  const stats = useMemo(() => aggregate(filtered), [filtered])

  function changeMode(m) {
    setMode(m)
    setOffset(0)
  }

  const canGoNext = offset < 0

  if (sessions.length === 0) {
    return (
      <div className="text-center py-20">
        <Activity className="text-gray-700 mx-auto mb-3" size={32} />
        <p className="text-gray-600 text-sm">No workouts recorded yet</p>
      </div>
    )
  }

  return (
    <div className="space-y-3">
      {/* Mode tabs */}
      <div className="flex bg-white/5 border border-white/8 rounded-xl p-1">
        {[
          { id: 'session', label: 'Session' },
          { id: 'week',    label: 'Week' },
          { id: 'month',   label: 'Month' },
        ].map(t => (
          <button
            key={t.id}
            onClick={() => changeMode(t.id)}
            className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${
              mode === t.id
                ? 'bg-cyan-500 text-white'
                : 'text-gray-500 hover:text-white'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {/* Period navigator */}
      <PeriodNavigator
        label={label}
        onPrev={() => setOffset(o => o - 1)}
        onNext={() => setOffset(o => Math.min(0, o + 1))}
        canNext={canGoNext}
      />

      <PeriodCard stats={stats} sessions={filtered} />
    </div>
  )
}
