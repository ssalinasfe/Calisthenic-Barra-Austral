import { useMemo, useState } from 'react'
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip,
  Legend, ResponsiveContainer, ComposedChart, Scatter,
} from 'recharts'
import { X, Download, CheckCircle, Clock, Layers, Zap, HeartPulse, ChevronDown, ChevronUp } from 'lucide-react'
import { format } from 'date-fns'
import { setNotation } from '../utils'
import { photoUrl } from '../api'

function fmtDuration(secs) {
  const h = Math.floor(secs / 3600)
  const m = Math.floor((secs % 3600) / 60)
  const s = secs % 60
  if (h > 0) return `${h}h ${m}m`
  if (m > 0) return `${m}m ${s}s`
  return `${s}s`
}

function exportCSV(allData) {
  const rows = [['Date', 'Exercise', 'Set', 'Reps', 'Weight (kg)', 'Duration (s)']]
  ;(allData.sessions || []).forEach(session => {
    ;(session.exercises || []).forEach(ex => {
      ;(ex.sets || []).forEach((set, i) => {
        rows.push([session.date, ex.name, i + 1, set.reps ?? '', set.weight ?? '', set.duration ?? ''])
      })
    })
  })
  const csv = rows.map(r => r.map(v => `"${v}"`).join(',')).join('\n')
  const blob = new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `workouts_${format(new Date(), 'yyyy-MM-dd')}.csv`
  a.click()
  URL.revokeObjectURL(url)
}

const CustomTooltip = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null
  return (
    <div className="bg-gray-900 border border-white/10 rounded-xl px-3 py-2 shadow-xl text-sm">
      <p className="text-white font-medium mb-1">{payload[0]?.payload?.fullName || label}</p>
      {payload.map(p => (
        <p key={p.name} style={{ color: p.color }}>
          {p.name}: <span className="font-bold">{p.value}</span> reps
        </p>
      ))}
    </div>
  )
}

function mmss(secs) {
  const m = Math.floor(secs / 60)
  const s = Math.round(secs % 60)
  return `${m}:${String(s).padStart(2, '0')}`
}

// Distinct colors per exercise for the rep markers on the HR chart.
const EX_COLORS = ['#f472b6', '#60a5fa', '#34d399', '#fbbf24', '#a78bfa', '#22d3ee', '#fb923c', '#4ade80']
const exColor = i => EX_COLORS[i % EX_COLORS.length]

// Line dot colored by the exercise it belongs to (payload.color).
const ExerciseDot = ({ cx, cy, payload, r = 5 }) => {
  if (cx == null || cy == null) return null
  return <circle cx={cx} cy={cy} r={r} fill={payload?.color || '#06b6d4'} stroke="#0a0a0a" strokeWidth={1.5} />
}

const HrTooltip = ({ active, payload }) => {
  if (!active || !payload?.length) return null
  // A rep marker carries { exercise, rep }; the line just has bpm.
  const marker = payload.find(p => p.payload?.exercise)
  const t = payload[0].payload?.t ?? 0
  const bpm = marker ? marker.payload.bpm : payload[0].value
  return (
    <div className="bg-gray-900 border border-white/10 rounded-xl px-3 py-2 shadow-xl text-sm">
      <p className="text-gray-400 text-xs mb-0.5">{mmss(t)}</p>
      <p className="text-red-400 font-bold">{bpm} bpm</p>
      {marker && (
        <p className="text-white text-xs mt-1 flex items-center gap-1.5">
          <span className="w-2 h-2 rounded-full inline-block" style={{ background: marker.color }} />
          {marker.payload.exercise} · rep {marker.payload.rep}
        </p>
      )}
    </div>
  )
}

// Expandable per-exercise detail: tap to reveal a per-rep table with time, rest
// and start/avg/max heart rate.
function ExerciseDetailCard({ ex, color }) {
  const [open, setOpen] = useState(false)
  const repsTotal = ex.sets.reduce((s, set) => s + (set.reps || 0), 0)
  const hasHr = ex.sets.some(s => s.avgHr != null)
  const hasWeight = ex.sets.some(s => s.weight != null)
  const exAvg = hasHr
    ? Math.round(ex.sets.filter(s => s.avgHr != null).reduce((a, s) => a + s.avgHr, 0) /
        ex.sets.filter(s => s.avgHr != null).length)
    : null
  const exMax = hasHr ? Math.max(...ex.sets.filter(s => s.maxHr != null).map(s => s.maxHr)) : null
  const exWeight = hasWeight ? Math.max(...ex.sets.filter(s => s.weight != null).map(s => s.weight)) : null

  return (
    <div className="bg-white/5 border border-white/5 rounded-2xl overflow-hidden">
      <button onClick={() => setOpen(o => !o)} className="w-full px-4 py-3 text-left">
        <div className="flex justify-between items-center gap-2">
          <span className="flex items-center gap-2 min-w-0">
            <span className="w-2.5 h-2.5 rounded-full flex-shrink-0" style={{ background: color }} />
            <span className="text-white text-sm font-medium truncate">{ex.name}</span>
          </span>
          <div className="flex items-center gap-3 flex-shrink-0">
            {exWeight != null && (
              <span className="text-amber-400/90 text-xs font-mono font-semibold">{exWeight}kg</span>
            )}
            {exAvg != null && (
              <span className="text-red-400/80 text-xs font-mono flex items-center gap-1">
                <HeartPulse size={11} />{exAvg}<span className="text-gray-600">/{exMax}</span>
              </span>
            )}
            <span className="text-cyan-400 font-mono text-sm font-bold">{setNotation(ex.sets)}</span>
            <span className="text-gray-600 text-xs">{repsTotal} reps</span>
            {open ? <ChevronUp size={15} className="text-gray-600" /> : <ChevronDown size={15} className="text-gray-600" />}
          </div>
        </div>
      </button>

      {open && (
        <div className="px-3 pb-3 pt-1 border-t border-white/6 animate-fadeIn overflow-x-auto">
          <table className="w-full text-[11px] whitespace-nowrap">
            <thead>
              <tr className="text-gray-600">
                <th className="text-left font-medium py-1.5 pl-1">Reps</th>
                {hasWeight && <th className="text-right font-medium px-2">Weight</th>}
                <th className="text-right font-medium px-2">Time</th>
                <th className="text-right font-medium px-2">Rest</th>
                {hasHr && <th className="text-right font-medium px-2 text-red-400/70">Start</th>}
                {hasHr && <th className="text-right font-medium px-2 text-red-400/70">Avg</th>}
                {hasHr && <th className="text-right font-medium px-2 pr-1 text-red-400/70">Max</th>}
              </tr>
            </thead>
            <tbody>
              {ex.sets.map((set, i) => (
                <tr key={i} className="text-gray-400 border-t border-white/4">
                  <td className="text-left py-1.5 pl-1 font-mono">{set.reps ?? 0}</td>
                  {hasWeight && <td className="text-right px-2 font-mono text-gray-300">{set.weight != null ? `${set.weight}kg` : '—'}</td>}
                  <td className="text-right px-2 font-mono">{fmtDuration(set.duration ?? 0)}</td>
                  <td className="text-right px-2 font-mono text-amber-400/70">{set.restDuration ? fmtDuration(set.restDuration) : '—'}</td>
                  {hasHr && <td className="text-right px-2 font-mono text-red-400/80">{set.startHr ?? '—'}</td>}
                  {hasHr && <td className="text-right px-2 font-mono text-red-400/80">{set.avgHr ?? '—'}</td>}
                  {hasHr && <td className="text-right px-2 pr-1 font-mono text-red-400/80">{set.maxHr ?? '—'}</td>}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}

export default function SessionSummary({ session, allData, onClose, token, heading = 'Session complete' }) {
  const chartData = useMemo(() => {
    const pastSessions = (allData.sessions || []).filter(s => s.id !== session.id)
    return session.exercises.map((ex, i) => {
      const totalReps = ex.sets.reduce((sum, s) => sum + (s.reps || 0), 0)
      const prevEx = [...pastSessions].reverse()
        .map(s => s.exercises?.find(e => e.name === ex.name))
        .find(Boolean)
      const prevReps = prevEx
        ? prevEx.sets.reduce((sum, s) => sum + (s.reps || 0), 0)
        : 0
      return {
        name: ex.name.length > 14 ? ex.name.slice(0, 14) + '…' : ex.name,
        fullName: ex.name,
        Today: totalReps,
        Previous: prevReps,
        sets: ex.sets.length,
        color: exColor(i),
      }
    })
  }, [session, allData])

  const totalReps = session.exercises.reduce(
    (sum, ex) => sum + ex.sets.reduce((s, set) => s + (set.reps || 0), 0), 0
  )
  const totalSets = session.exercises.reduce((sum, ex) => sum + ex.sets.length, 0)

  // Rep markers for the HR chart: one point per set, positioned at the second it
  // started, colored by exercise, so tapping it reveals which exercise/rep it is.
  const hrChart = useMemo(() => {
    const samples = session.hrSamples || []
    if (samples.length < 2) return null
    const startMs = new Date(session.startTime).getTime()
    const maxT = samples[samples.length - 1].t
    const bpmAt = t => {
      let best = samples[0]
      for (const s of samples) if (Math.abs(s.t - t) < Math.abs(best.t - t)) best = s
      return best.bpm
    }
    const series = session.exercises.map((ex, ei) => {
      const points = (ex.sets || [])
        .filter(set => set.startedAt)
        .map((set, si) => {
          const t = Math.min(maxT, Math.max(0, Math.round((new Date(set.startedAt).getTime() - startMs) / 1000)))
          return { t, bpm: set.startHr ?? bpmAt(t), exercise: ex.name, rep: si + 1 }
        })
      return { name: ex.name, color: exColor(ei), points }
    }).filter(s => s.points.length)
    return { samples, maxT, series }
  }, [session])

  return (
    <div className="fixed inset-0 bg-black/75 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4 animate-fadeIn">
      <div className="bg-gray-950 border border-white/10 rounded-t-3xl sm:rounded-2xl w-full sm:max-w-2xl max-h-[92vh] overflow-y-auto shadow-2xl">

        <div className="flex items-center justify-between px-5 py-4 border-b border-white/10 sticky top-0 bg-gray-950 z-10">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-green-500/20 flex items-center justify-center">
              <CheckCircle className="text-green-400" size={18} />
            </div>
            <div>
              <h2 className="text-white font-bold text-base">{heading}</h2>
              <p className="text-gray-500 text-xs">
                {format(new Date(session.startTime), "EEEE d MMM · HH:mm")}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-gray-600 hover:text-white p-2 rounded-lg transition-colors"
          >
            <X size={18} />
          </button>
        </div>

        <div className="px-5 py-5 space-y-6">
          {token && (session.photos?.length ?? 0) > 0 && (
            <div className="flex gap-2 overflow-x-auto -mx-1 px-1">
              {session.photos.map((p, i) => (
                <a
                  key={i}
                  href={photoUrl(token, p)}
                  target="_blank"
                  rel="noreferrer"
                  className="flex-shrink-0"
                >
                  <img
                    src={photoUrl(token, p)}
                    alt=""
                    className={`h-52 rounded-2xl object-cover border border-white/10 ${session.photos.length === 1 ? 'w-full' : ''}`}
                  />
                </a>
              ))}
            </div>
          )}

          <div className="grid grid-cols-3 gap-3">
            {[
              { icon: Clock, label: 'Duration', value: fmtDuration(session.durationSeconds), color: 'text-cyan-400' },
              { icon: Layers, label: 'Sets',    value: totalSets,                            color: 'text-purple-400' },
              { icon: Zap,    label: 'Reps',    value: totalReps,                            color: 'text-orange-400' },
            ].map(({ icon: Icon, label, value, color }) => (
              <div key={label} className="bg-white/5 rounded-2xl p-4 text-center border border-white/5">
                <Icon size={18} className={`${color} mx-auto mb-2`} />
                <div className={`text-xl font-bold ${color}`}>{value}</div>
                <div className="text-gray-600 text-xs mt-0.5">{label}</div>
              </div>
            ))}
          </div>

          {session.avgHr != null && (
            <div className="bg-red-500/10 border border-red-500/25 rounded-2xl px-4 py-3 flex items-center gap-4">
              <HeartPulse size={20} className="text-red-400 flex-shrink-0" />
              <div className="flex items-baseline gap-1">
                <span className="text-2xl font-bold text-red-400 font-mono">{session.avgHr}</span>
                <span className="text-red-300/70 text-xs">bpm avg</span>
              </div>
              <div className="flex-1 flex justify-end gap-4 text-xs text-gray-500">
                {session.maxHr != null && <span>max <b className="text-gray-300">{session.maxHr}</b></span>}
                {session.minHr != null && <span>min <b className="text-gray-300">{session.minHr}</b></span>}
              </div>
            </div>
          )}

          {chartData.length > 0 && (
            <div>
              <h3 className="text-white font-semibold mb-3 text-sm">Reps per exercise vs previous session</h3>
              <div className="bg-white/3 rounded-2xl p-4 border border-white/5">
                <ResponsiveContainer width="100%" height={180}>
                  <LineChart data={chartData} margin={{ top: 10, right: 10, left: -28, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                    <XAxis
                      dataKey="name"
                      tick={{ fill: '#6b7280', fontSize: 10 }}
                      axisLine={false}
                      tickLine={false}
                    />
                    <YAxis
                      tick={{ fill: '#6b7280', fontSize: 10 }}
                      axisLine={false}
                      tickLine={false}
                    />
                    <Tooltip content={<CustomTooltip />} />
                    <Legend
                      wrapperStyle={{ fontSize: '11px', paddingTop: '8px' }}
                      formatter={v => <span style={{ color: '#9ca3af' }}>{v}</span>}
                    />
                    {/* Previous first so Today's colored dots render on top */}
                    <Line dataKey="Previous" stroke="#374151" strokeWidth={2}   dot={{ fill: '#374151', r: 3, strokeWidth: 0 }} activeDot={{ r: 5, strokeWidth: 0 }} />
                    <Line dataKey="Today"    stroke="#06b6d4" strokeWidth={2.5} dot={(p) => <ExerciseDot key={p.key ?? p.index} {...p} r={7} />} activeDot={(p) => <ExerciseDot key={p.key ?? p.index} {...p} r={9} />} />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}

          {hrChart && (
            <div>
              <h3 className="text-white font-semibold mb-3 text-sm flex items-center gap-1.5">
                <HeartPulse size={15} className="text-red-400" />
                Heart rate over the session
              </h3>
              <div className="bg-white/3 rounded-2xl p-4 border border-white/5">
                <ResponsiveContainer width="100%" height={190}>
                  <ComposedChart margin={{ top: 10, right: 10, left: -4, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                    <XAxis
                      dataKey="t"
                      type="number"
                      domain={[0, hrChart.maxT]}
                      tickFormatter={mmss}
                      tick={{ fill: '#6b7280', fontSize: 10 }}
                      axisLine={false}
                      tickLine={false}
                      allowDuplicatedCategory={false}
                    />
                    <YAxis
                      domain={['dataMin - 5', 'dataMax + 5']}
                      tick={{ fill: '#6b7280', fontSize: 10 }}
                      axisLine={false}
                      tickLine={false}
                      width={40}
                    />
                    <Tooltip content={<HrTooltip />} />
                    <Line
                      data={hrChart.samples}
                      dataKey="bpm"
                      stroke="#f87171"
                      strokeWidth={2.5}
                      dot={false}
                      activeDot={{ r: 5, strokeWidth: 0 }}
                      isAnimationActive={false}
                    />
                    {hrChart.series.map(s => (
                      <Scatter
                        key={s.name}
                        name={s.name}
                        data={s.points}
                        dataKey="bpm"
                        fill={s.color}
                        line={false}
                        isAnimationActive={false}
                      />
                    ))}
                  </ComposedChart>
                </ResponsiveContainer>
                {/* Legend: color per exercise */}
                <div className="flex flex-wrap gap-x-4 gap-y-1 mt-3 px-1">
                  {hrChart.series.map(s => (
                    <span key={s.name} className="flex items-center gap-1.5 text-xs text-gray-400">
                      <span className="w-2.5 h-2.5 rounded-full inline-block" style={{ background: s.color }} />
                      {s.name}
                    </span>
                  ))}
                </div>
                <p className="text-gray-600 text-[11px] mt-2 px-1">Each dot marks the start of a rep — tap it for the exercise.</p>
              </div>
            </div>
          )}

          <div>
            <h3 className="text-white font-semibold mb-3 text-sm">Details</h3>
            <div className="space-y-2">
              {session.exercises.map((ex, i) => (
                <ExerciseDetailCard key={`${ex.name}_${i}`} ex={ex} color={exColor(i)} />
              ))}
            </div>
          </div>

          <button
            onClick={() => exportCSV(allData)}
            className="w-full flex items-center justify-center gap-2 py-3.5 bg-white/5 hover:bg-white/8 border border-white/10 rounded-2xl text-gray-400 hover:text-white transition-colors text-sm"
          >
            <Download size={15} />
            Export CSV (compatible with Google Sheets)
          </button>
        </div>
      </div>
    </div>
  )
}
