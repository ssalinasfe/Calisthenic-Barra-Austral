import { useState, useMemo } from 'react'
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer,
} from 'recharts'
import { format } from 'date-fns'
import { X, TrendingUp, TrendingDown, Minus } from 'lucide-react'
import { setNotation, totalReps, fmtDuration } from '../utils'
import { CATEGORY_LABEL, CATEGORY_PILL, isIsometric } from '../exercises'

// Average seconds held per set in a session (for isometric exercises) — fairer
// than the total, since it doesn't reward simply doing more sets.
function avgSeconds(sets) {
  const done = (sets || []).filter(s => s.duration !== null && s.duration !== undefined)
  if (done.length === 0) return 0
  return Math.round(done.reduce((sum, s) => sum + (s.duration || 0), 0) / done.length)
}

// Per-set holds, e.g. "45s · 40s · 38s".
function holdNotation(sets) {
  const done = (sets || []).filter(s => s.duration !== null && s.duration !== undefined)
  if (done.length === 0) return '—'
  return done.map(s => fmtDuration(s.duration || 0)).join(' · ')
}

const CustomTooltip = ({ active, payload }) => {
  if (!active || !payload?.length) return null
  const d = payload[0].payload
  return (
    <div className="bg-gray-900 border border-white/10 rounded-xl px-3 py-2.5 shadow-xl">
      <p className="text-gray-500 text-xs mb-1">{d.fullDate}</p>
      <p className="text-white font-bold text-sm">{d.display}</p>
      <p className="text-cyan-400 font-mono text-xs mt-0.5">{d.notation}</p>
    </div>
  )
}

const WeightTooltip = ({ active, payload }) => {
  if (!active || !payload?.length) return null
  const d = payload[0].payload
  return (
    <div className="bg-gray-900 border border-white/10 rounded-xl px-3 py-2.5 shadow-xl">
      <p className="text-gray-500 text-xs mb-1">{d.fullDate}</p>
      <p className="text-amber-300 font-bold text-sm">{d.weight} kg</p>
    </div>
  )
}

const HrTooltip = ({ active, payload }) => {
  if (!active || !payload?.length) return null
  const d = payload[0].payload
  return (
    <div className="bg-gray-900 border border-white/10 rounded-xl px-3 py-2.5 shadow-xl">
      <p className="text-gray-500 text-xs mb-1">{d.fullDate}</p>
      <p className="text-red-400 font-bold text-sm">{d.hrAvg} bpm avg</p>
      {d.hrMax != null && <p className="text-red-300/70 font-mono text-xs mt-0.5">max {d.hrMax}</p>}
    </div>
  )
}

function ExerciseChart({ exerciseName, allData, onClose }) {
  const iso = isIsometric(exerciseName)
  const unit = iso ? 'seconds held' : 'reps'

  const chartData = useMemo(() => {
    return (allData.sessions || [])
      .filter(s => s.exercises?.some(e => e.name === exerciseName))
      .map(s => {
        const ex = s.exercises.find(e => e.name === exerciseName)
        const value = iso ? avgSeconds(ex.sets) : totalReps(ex.sets)
        const weights = ex.sets.filter(st => st.weight != null).map(st => st.weight)
        const hrAvgs = ex.sets.filter(st => st.avgHr != null).map(st => st.avgHr)
        const hrMaxs = ex.sets.filter(st => st.maxHr != null).map(st => st.maxHr)
        return {
          date: format(new Date(s.startTime), 'dd/MM'),
          fullDate: format(new Date(s.startTime), "d MMM yyyy"),
          value,
          display: iso ? fmtDuration(value) : `${value} reps`,
          notation: iso ? holdNotation(ex.sets) : setNotation(ex.sets),
          sets: ex.sets.length,
          weight: weights.length ? Math.max(...weights) : null,
          hrAvg: hrAvgs.length ? Math.round(hrAvgs.reduce((a, b) => a + b, 0) / hrAvgs.length) : null,
          hrMax: hrMaxs.length ? Math.max(...hrMaxs) : null,
        }
      })
  }, [exerciseName, allData, iso])

  const weightData = useMemo(() => chartData.filter(d => d.weight != null), [chartData])
  const hrData = useMemo(() => chartData.filter(d => d.hrAvg != null), [chartData])

  const last = chartData[chartData.length - 1]
  const prev = chartData[chartData.length - 2]
  const trend = chartData.length >= 2 ? last.value - prev.value : null
  const trendLabel = iso
    ? `${trend > 0 ? '+' : '−'}${fmtDuration(Math.abs(trend))} vs previous session`
    : `${trend > 0 ? '+' : ''}${trend} reps vs previous session`

  return (
    <div className="fixed inset-0 bg-black/75 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4 animate-fadeIn">
      <div className="bg-gray-950 border border-white/10 rounded-t-3xl sm:rounded-2xl w-full sm:max-w-lg shadow-2xl max-h-[90vh] overflow-y-auto">

        <div className="flex items-center justify-between px-5 py-4 border-b border-white/10 sticky top-0 bg-gray-950 z-10">
          <div>
            <h2 className="text-white font-bold text-base">{exerciseName}</h2>
            <p className="text-gray-600 text-xs mt-0.5">
              {chartData.length} {chartData.length === 1 ? 'session' : 'sessions'} recorded
              {iso && <span className="text-cyan-500/80"> · avg hold per set</span>}
            </p>
          </div>
          <button onClick={onClose} className="text-gray-600 hover:text-white p-2 rounded-lg transition-colors">
            <X size={18} />
          </button>
        </div>

        <div className="px-5 py-5">
          {chartData.length === 0 && (
            <p className="text-gray-600 text-sm text-center py-10">No data</p>
          )}

          {chartData.length === 1 && (
            <div className="text-center py-6">
              <p className="text-white font-bold text-2xl font-mono">{last.notation}</p>
              <p className="text-gray-500 text-sm mt-1">{last.fullDate}</p>
              <p className="text-gray-600 text-xs mt-3">At least 2 sessions are needed to show progression</p>
            </div>
          )}

          {chartData.length >= 2 && (
            <>
              {trend !== null && (
                <div className="flex items-center gap-2 mb-5">
                  {trend > 0 ? (
                    <span className="flex items-center gap-1.5 text-green-400 text-sm font-medium">
                      <TrendingUp size={16} /> {trendLabel}
                    </span>
                  ) : trend < 0 ? (
                    <span className="flex items-center gap-1.5 text-red-400 text-sm font-medium">
                      <TrendingDown size={16} /> {trendLabel}
                    </span>
                  ) : (
                    <span className="flex items-center gap-1.5 text-gray-500 text-sm">
                      <Minus size={16} /> No change vs previous session
                    </span>
                  )}
                </div>
              )}

              <div className="bg-white/3 rounded-2xl p-4 border border-white/5 mb-5">
                <ResponsiveContainer width="100%" height={190}>
                  <LineChart data={chartData} margin={{ top: 10, right: 10, left: -26, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                    <XAxis
                      dataKey="date"
                      tick={{ fill: '#6b7280', fontSize: 11 }}
                      axisLine={false}
                      tickLine={false}
                    />
                    <YAxis
                      tick={{ fill: '#6b7280', fontSize: 11 }}
                      axisLine={false}
                      tickLine={false}
                    />
                    <Tooltip content={<CustomTooltip />} />
                    <Line
                      type="monotone"
                      dataKey="value"
                      stroke="#06b6d4"
                      strokeWidth={2.5}
                      dot={{ fill: '#06b6d4', r: 5, strokeWidth: 0 }}
                      activeDot={{ r: 7, fill: '#06b6d4', strokeWidth: 0 }}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>

              {/* Weight progression */}
              {weightData.length >= 2 && (
                <div className="mb-5">
                  <p className="text-gray-400 text-xs font-medium mb-2">Weight per session (kg)</p>
                  <div className="bg-white/3 rounded-2xl p-4 border border-white/5">
                    <ResponsiveContainer width="100%" height={160}>
                      <LineChart data={weightData} margin={{ top: 10, right: 10, left: -26, bottom: 0 }}>
                        <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                        <XAxis dataKey="date" tick={{ fill: '#6b7280', fontSize: 11 }} axisLine={false} tickLine={false} />
                        <YAxis tick={{ fill: '#6b7280', fontSize: 11 }} axisLine={false} tickLine={false} domain={['dataMin - 2', 'dataMax + 2']} />
                        <Tooltip content={<WeightTooltip />} />
                        <Line
                          type="monotone"
                          dataKey="weight"
                          stroke="#f59e0b"
                          strokeWidth={2.5}
                          dot={{ fill: '#f59e0b', r: 5, strokeWidth: 0 }}
                          activeDot={{ r: 7, fill: '#f59e0b', strokeWidth: 0 }}
                        />
                      </LineChart>
                    </ResponsiveContainer>
                  </div>
                </div>
              )}

              {/* Heart rate during this exercise */}
              {hrData.length >= 2 && (
                <div className="mb-5">
                  <p className="text-gray-400 text-xs font-medium mb-1">Heart rate during this exercise</p>
                  <p className="text-gray-600 text-[11px] mb-2">Lower avg over time at the same load = your heart is adapting.</p>
                  <div className="bg-white/3 rounded-2xl p-4 border border-white/5">
                    <ResponsiveContainer width="100%" height={160}>
                      <LineChart data={hrData} margin={{ top: 10, right: 10, left: -26, bottom: 0 }}>
                        <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                        <XAxis dataKey="date" tick={{ fill: '#6b7280', fontSize: 11 }} axisLine={false} tickLine={false} />
                        <YAxis tick={{ fill: '#6b7280', fontSize: 11 }} axisLine={false} tickLine={false} domain={['dataMin - 5', 'dataMax + 5']} />
                        <Tooltip content={<HrTooltip />} />
                        <Line type="monotone" dataKey="hrMax" stroke="#fca5a5" strokeWidth={2} strokeDasharray="4 3" dot={{ fill: '#fca5a5', r: 3, strokeWidth: 0 }} activeDot={{ r: 5 }} />
                        <Line type="monotone" dataKey="hrAvg" stroke="#f43f5e" strokeWidth={2.5} dot={{ fill: '#f43f5e', r: 5, strokeWidth: 0 }} activeDot={{ r: 7 }} />
                      </LineChart>
                    </ResponsiveContainer>
                    <div className="flex gap-4 mt-3 px-1">
                      <span className="flex items-center gap-1.5 text-xs text-gray-400"><span className="w-3 h-0.5 rounded bg-[#f43f5e] inline-block" /> avg</span>
                      <span className="flex items-center gap-1.5 text-xs text-gray-400"><span className="w-3 h-0.5 rounded bg-[#fca5a5] inline-block" /> max</span>
                    </div>
                  </div>
                </div>
              )}

              <div className="space-y-2">
                <p className="text-gray-700 text-xs font-medium mb-2">History</p>
                {[...chartData].reverse().map((d, i) => (
                  <div key={i} className="flex items-center justify-between py-1 gap-2">
                    <span className="text-gray-500 text-xs w-24 flex-shrink-0">{d.fullDate}</span>
                    <span className="text-cyan-400 font-mono text-sm font-semibold flex-1 text-center truncate">
                      {d.notation}
                    </span>
                    {d.weight != null && (
                      <span className="text-amber-400/80 text-xs font-mono w-12 text-right flex-shrink-0">{d.weight}kg</span>
                    )}
                    <span className="text-white text-sm font-semibold w-20 text-right flex-shrink-0">
                      {d.display}
                    </span>
                  </div>
                ))}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}

export default function ExerciseProgress({ allData }) {
  const [selected, setSelected] = useState(null)

  const exercises = useMemo(() => {
    const map = new Map()
    ;(allData.sessions || []).forEach(s => {
      ;(s.exercises || []).forEach(ex => {
        if (!map.has(ex.name)) {
          map.set(ex.name, { name: ex.name, category: ex.category || 'Custom', count: 0, iso: isIsometric(ex.name), lastNotation: '—' })
        }
        const entry = map.get(ex.name)
        entry.count++
        entry.lastNotation = entry.iso ? fmtDuration(avgSeconds(ex.sets)) : setNotation(ex.sets)
      })
    })
    return [...map.values()].sort((a, b) => b.count - a.count)
  }, [allData])

  if (exercises.length === 0) {
    return (
      <div className="text-center py-20">
        <p className="text-gray-600 text-sm">No exercise data yet</p>
      </div>
    )
  }

  return (
    <>
      <p className="text-gray-700 text-xs font-medium mb-3">
        {exercises.length} exercises tracked
      </p>
      <div className="grid grid-cols-2 gap-3">
        {exercises.map(ex => {
          const colorClass = CATEGORY_PILL[ex.category] || CATEGORY_PILL.Custom
          return (
            <button
              key={ex.name}
              onClick={() => setSelected(ex.name)}
              className="bg-white/5 border border-white/8 rounded-2xl p-4 text-left hover:bg-white/8 hover:border-cyan-500/30 transition-all hover:scale-[1.02]"
            >
              <span className={`text-xs px-2 py-0.5 rounded-full border ${colorClass} inline-block mb-2`}>
                {CATEGORY_LABEL[ex.category] || ex.category}
              </span>
              <p className="text-white font-medium text-sm leading-tight">{ex.name}</p>
              <p className="text-cyan-400 font-mono font-bold text-base mt-2">{ex.lastNotation}</p>
              <p className="text-gray-600 text-xs mt-0.5">
                {ex.count} {ex.count === 1 ? 'session' : 'sessions'}
              </p>
            </button>
          )
        })}
      </div>

      {selected && (
        <ExerciseChart
          exerciseName={selected}
          allData={allData}
          onClose={() => setSelected(null)}
        />
      )}
    </>
  )
}
