import { useMemo, useState } from 'react'
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip,
  Legend, ResponsiveContainer, ComposedChart, Scatter,
  ReferenceArea,
} from 'recharts'
import { X, Download, CheckCircle, Clock, Layers, Zap, HeartPulse, ChevronDown, ChevronUp, Maximize2, ScrollText, Activity } from 'lucide-react'
import { format } from 'date-fns'
import { setNotation, fmtDuration } from '../utils'
import { photoUrl } from '../api'
import SessionLogModal from './SessionLogModal'
import { computeHrv } from '../hrv'

// Same columns as the backend's /api/export/csv, so both CSV paths match.
function exportCSV(allData) {
  const rows = [[
    'Date', 'Start time', 'Session duration (s)',
    'Exercise', 'Category', 'Set', 'Reps', 'Weight (kg)', 'Set duration (s)',
  ]]
  ;(allData.sessions || []).forEach(session => {
    ;(session.exercises || []).forEach(ex => {
      ;(ex.sets || []).forEach((set, i) => {
        rows.push([
          session.date, session.startTime ?? '', session.durationSeconds ?? '',
          ex.name, ex.category ?? '', i + 1, set.reps ?? 0, set.weight ?? '', set.duration ?? 0,
        ])
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

// Ideal fat-burning heart-rate zone (60–70% of max HR ≈ 220 − age). Age 33 → 112–131.
const FAT_BURN_ZONE = { low: 112, high: 131 }

// The belt is sampled every ~5s, so a hole longer than this is a dropout, not
// jitter. The chart cuts the line there instead of drawing a straight line
// across minutes of data that was never measured.
const HR_GAP_S = 20

// Rest windows in seconds from the session start: each set's rest runs from the
// moment that set ended until restDuration later. Shared by the chart, which
// draws them dashed, and the HRV panel, which only measures inside them.
function restWindows(session) {
  const startMs = new Date(session.startTime).getTime()
  const out = []
  ;(session.exercises || []).forEach(ex => (ex.sets || []).forEach(set => {
    if (!set.startedAt || !set.restDuration) return
    const from = Math.round((new Date(set.startedAt).getTime() - startMs) / 1000) + (set.duration || 0)
    out.push([from, from + set.restDuration])
  }))
  return out
}

// Line dot colored by the exercise it belongs to (payload.color).
const ExerciseDot = ({ cx, cy, payload, r = 5 }) => {
  if (cx == null || cy == null) return null
  return <circle cx={cx} cy={cy} r={r} fill={payload?.color || '#06b6d4'} stroke="#0a0a0a" strokeWidth={1.5} />
}

// The heart-rate chart body. `width`/`height` are injected by ResponsiveContainer
// for the inline version, or passed explicitly (fixed px) for the scrollable
// expanded view.
function HrComposedChart({ chart, width, height }) {
  return (
    <ComposedChart width={width} height={height} margin={{ top: 10, right: 12, left: -4, bottom: 0 }}>
      <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
      <XAxis
        dataKey="t" type="number" domain={[0, chart.maxT]} tickFormatter={mmss}
        tick={{ fill: '#6b7280', fontSize: 10 }} axisLine={false} tickLine={false} allowDuplicatedCategory={false}
      />
      <YAxis
        domain={[
          (dataMin) => Math.min(Math.floor(dataMin - 5), FAT_BURN_ZONE.low - 5),
          (dataMax) => Math.max(Math.ceil(dataMax + 5), FAT_BURN_ZONE.high + 5),
        ]}
        tick={{ fill: '#6b7280', fontSize: 10 }}
        axisLine={false} tickLine={false} width={40}
      />
      <Tooltip content={<HrTooltip />} />
      {/* Ideal fat-burning zone: the shading alone marks it. Its edges used to
          be drawn as dashed yellow lines, dropped once the trace itself started
          using dashes for rest — two dashed styles in one chart just compete. */}
      <ReferenceArea y1={FAT_BURN_ZONE.low} y2={FAT_BURN_ZONE.high} fill="#fbbf24" fillOpacity={0.08} />
      <Line data={chart.work} dataKey="bpm" stroke="#f87171" strokeWidth={2.5} dot={false}
        activeDot={{ r: 5, strokeWidth: 0 }} connectNulls={false} isAnimationActive={false} />
      <Line data={chart.rest} dataKey="bpm" stroke="#f87171" strokeOpacity={0.65} strokeWidth={2}
        strokeDasharray="4 5" dot={false} activeDot={false} connectNulls={false} isAnimationActive={false} />
      {chart.series.map(s => (
        <Scatter key={s.name} name={s.name} data={s.points} dataKey="bpm" fill={s.color} line={false} isAnimationActive={false} />
      ))}
    </ComposedChart>
  )
}

const HrTooltip = ({ active, payload }) => {
  if (!active || !payload?.length) return null
  // A rep marker carries { exercise, rep }; the line just has bpm.
  const marker = payload.find(p => p.payload?.exercise)
  const t = payload[0].payload?.t ?? 0
  // The trace is split into a solid (work) and a dashed (rest) line, so at any
  // given second one of the two carries a null.
  const bpm = marker ? marker.payload.bpm : payload.find(p => p.value != null)?.value
  if (bpm == null) return null
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
        {/* Row 1: color + full name */}
        <div className="flex items-center gap-2">
          <span className="w-2.5 h-2.5 rounded-full flex-shrink-0" style={{ background: color }} />
          <span className="text-white text-sm font-medium flex-1 min-w-0 truncate">{ex.name}</span>
          {open ? <ChevronUp size={15} className="text-gray-600 flex-shrink-0" /> : <ChevronDown size={15} className="text-gray-600 flex-shrink-0" />}
        </div>
        {/* Row 2: data, aligned under the name */}
        <div className="flex items-center gap-3 mt-1.5 pl-[18px] flex-wrap">
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
  const [hrExpanded, setHrExpanded] = useState(false)
  const [showLog, setShowLog] = useState(false)
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

    const rests = restWindows(session)
    const isResting = t => rests.some(([a, b]) => t >= a && t <= b)

    // The trace is drawn as two overlapping lines — solid for work, dashed for
    // rest — by nulling out each other's samples, because Recharts can't dash
    // part of a single Line.
    //
    // Classify each SEGMENT by its midpoint (not each point), so every segment
    // belongs to exactly one line: no gaps, and nothing drawn twice. Doing it
    // per point and extending to the neighbours swallowed short work windows —
    // a 47s set holding only 2 samples has both of them on a boundary, so the
    // dashed line covered the whole thing.
    const segRest = []
    for (let i = 0; i < samples.length - 1; i++) {
      segRest[i] = isResting((samples[i].t + samples[i + 1].t) / 2)
    }
    // Walk the segments and emit only the runs this line owns, separated by an
    // explicit null so Recharts breaks the path there. Tagging the shared points
    // in a sample-aligned array can't work: a lone rest segment between two work
    // segments needs both its endpoints in the solid line, which would draw it
    // twice — the dashes then sit on top of a solid stroke and hide it.
    // Stretches the session log says had no data: the belt was down, the page
    // was in the background with its timers throttled, or the belt was silent.
    // (sessionLog.js). Everything else in the log is context, not a hole.
    const ENDS = { 'belt-off': 'belt-on', hidden: 'visible', 'stall-start': 'stall-end' }
    const blind = []
    for (const e of session.events || []) {
      const open = blind[blind.length - 1]
      if (open && open.to == null && ENDS[open.type] === e.type) open.to = e.t
      else if (ENDS[e.type] && (!open || open.to != null)) blind.push({ type: e.type, from: e.t, to: null })
    }
    // Ignore blips shorter than one sample interval, and close whatever was
    // still open when the session ended.
    const dark = blind
      .map(b => ({ ...b, to: b.to ?? maxT }))
      .filter(b => b.to - b.from >= 5)

    // A segment is dropped by BOTH lines when nothing was measured across it, so
    // the hole stays visible instead of a straight line inventing the reading.
    // The sample-gap rule stays as the safety net: the log can miss a cause it
    // has no event for, but a hole in the samples is missing data by definition.
    const isGap = i => samples[i + 1].t - samples[i].t > HR_GAP_S ||
      dark.some(d => d.from < samples[i + 1].t && d.to > samples[i].t)

    const lineFor = wantRest => {
      const out = []
      let open = false
      for (let i = 0; i < segRest.length; i++) {
        if (segRest[i] !== wantRest || isGap(i)) { open = false; continue }
        if (!open) {
          if (out.length) out.push({ t: samples[i].t, bpm: null })
          out.push(samples[i])
          open = true
        }
        out.push(samples[i + 1])
      }
      return out
    }
    const work = lineFor(false)
    const rest = lineFor(true)
    const gaps = segRest.filter((_, i) => isGap(i)).length
    return { samples, maxT, series, work, rest, hasRest: rests.length > 0, gaps }
  }, [session])

  // Heart-rate variability, from the RR intervals the belt sends with each
  // packet. Only sessions recorded after RR capture was added carry them.
  //
  // Reported for the REST stretches, not the whole session: variability
  // collapses under effort by design, so an all-in number mostly measures how
  // much of the session was hard rather than anything about recovery. Rest is
  // where the comparison between sessions actually means something.
  const hrv = useMemo(() => {
    const samples = (session.hrSamples || []).filter(s => s.rr?.length)
    if (!samples.length) return null
    const rests = restWindows(session)
    const inRest = t => rests.some(([a, b]) => t >= a && t <= b)
    const rest = []
    const all = []
    for (const s of samples) {
      all.push(...s.rr)
      if (inRest(s.t)) rest.push(...s.rr)
    }
    const restHrv = computeHrv(rest)
    const allHrv = computeHrv(all)
    if (!restHrv && !allHrv) return null
    // Fall back to the whole session when rest alone is too thin to be worth
    // reporting, and say so rather than passing one off as the other.
    return restHrv
      ? { ...restHrv, scope: 'rest' }
      : { ...allHrv, scope: 'session' }
  }, [session])

  // Distribution vs the fat-burning zone: below / inside / above 112–131.
  // One vote per reading. Weighting each reading by the seconds it covers was
  // tried and reverted: readings land every 5s, so the two come out the same
  // (identical in 3 of 5 recorded sessions, 1–2 points apart in the others).
  //
  // `coveragePct` is the part that matters. These are shares of the time the
  // belt actually measured, and it drops out far more during the hard sets than
  // during rest, so what survives is biased towards the low end.
  const hrZone = useMemo(() => {
    const s = session.hrSamples || []
    if (s.length < 2) return null
    let below = 0, inside = 0, above = 0
    s.forEach(p => {
      if (p.bpm > FAT_BURN_ZONE.high) above++
      else if (p.bpm >= FAT_BURN_ZONE.low) inside++
      else below++
    })
    const n = s.length
    // Seconds actually covered by readings: a jump longer than HR_GAP_S is a
    // hole with no data, not slow sampling.
    let measured = 0
    for (let i = 0; i < s.length - 1; i++) {
      const dt = s[i + 1].t - s[i].t
      if (dt <= HR_GAP_S) measured += dt
    }
    // Against the whole session, not just up to the last reading: a belt that
    // died early left everything after it unmeasured too.
    const total = session.durationSeconds || s[s.length - 1].t || measured
    return {
      inPct: Math.round((inside / n) * 100),
      abovePct: Math.round((above / n) * 100),
      belowPct: Math.round((below / n) * 100),
      coveragePct: Math.round((measured / total) * 100),
    }
  }, [session])

  return (
    <>
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
            <div className="bg-red-500/10 border border-red-500/25 rounded-2xl px-4 py-3">
              <div className="flex items-center gap-4">
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

              {hrZone && (
                <div className="mt-3 pt-3 border-t border-red-500/15">
                  <div className="flex items-center justify-between text-xs mb-1.5">
                    <span className="text-gray-500">Below <b>{hrZone.belowPct}%</b></span>
                    <span className="text-amber-300">In zone <b>{hrZone.inPct}%</b></span>
                    <span className="text-red-300">Above <b>{hrZone.abovePct}%</b></span>
                  </div>
                  {/* Stacked bar: below · in-zone · above */}
                  <div className="flex h-2 rounded-full overflow-hidden bg-white/5">
                    <div style={{ width: `${hrZone.belowPct}%` }} className="bg-gray-500/50" />
                    <div style={{ width: `${hrZone.inPct}%` }} className="bg-amber-400/80" />
                    <div style={{ width: `${hrZone.abovePct}%` }} className="bg-red-500/70" />
                  </div>
                  <p className="text-gray-600 text-[10px] mt-1.5">
                    vs fat-burning zone {FAT_BURN_ZONE.low}–{FAT_BURN_ZONE.high} bpm
                    {/* Without this the split reads as covering the whole session */}
                    {hrZone.coveragePct < 98 && (
                      <span className="text-amber-500/60"> · of the {hrZone.coveragePct}% of the session the belt measured</span>
                    )}
                  </p>
                </div>
              )}
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
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-white font-semibold text-sm flex items-center gap-1.5">
                  <HeartPulse size={15} className="text-red-400" />
                  Heart rate over the session
                </h3>
                <button
                  onClick={() => setHrExpanded(true)}
                  className="flex items-center gap-1 text-gray-500 hover:text-white text-xs font-medium px-2 py-1 rounded-lg hover:bg-white/5 transition-colors"
                >
                  <Maximize2 size={13} /> Expand
                </button>
              </div>
              <div className="bg-white/3 rounded-2xl p-4 border border-white/5">
                <ResponsiveContainer width="100%" height={190}>
                  <HrComposedChart chart={hrChart} />
                </ResponsiveContainer>
                {/* Legend: color per exercise */}
                <div className="flex flex-wrap gap-x-4 gap-y-1 mt-3 px-1">
                  {hrChart.hasRest && (
                    <span className="flex items-center gap-1.5 text-[11px] text-gray-500 w-full mb-0.5">
                      <svg width="22" height="4" className="flex-shrink-0">
                        <line x1="0" y1="2" x2="22" y2="2" stroke="#f87171" strokeOpacity="0.65" strokeWidth="2" strokeDasharray="4 5" />
                      </svg>
                      línea punteada = descanso
                      {hrChart.gaps > 0 && ' · cortes = sin señal de la banda'}
                    </span>
                  )}
                  {hrChart.series.map(s => (
                    <span key={s.name} className="flex items-center gap-1.5 text-xs text-gray-400">
                      <span className="w-2.5 h-2.5 rounded-full inline-block" style={{ background: s.color }} />
                      {s.name}
                    </span>
                  ))}
                </div>
                <p className="text-gray-600 text-[11px] mt-2 px-1">
                  Amber band ({FAT_BURN_ZONE.low}–{FAT_BURN_ZONE.high}) = fat-burning zone · tap Expand to scroll & inspect.
                </p>
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

          {hrv && (
            <div>
              <h3 className="text-white font-semibold text-sm flex items-center gap-1.5 mb-3">
                <Activity size={15} className="text-violet-400" />
                Heart rate variability
              </h3>
              <div className="bg-white/3 rounded-2xl p-4 border border-white/5">
                <div className="flex items-end gap-2">
                  <span className="text-3xl font-bold text-violet-300 font-mono">{hrv.rmssd}</span>
                  <span className="text-gray-500 text-sm mb-1">ms RMSSD</span>
                </div>
                <p className="text-gray-500 text-xs mt-1">
                  {hrv.scope === 'rest'
                    ? 'measured during the rests between sets'
                    : 'measured across the whole session — not enough beats during the rests alone'}
                </p>

                <div className="grid grid-cols-3 gap-3 mt-4 pt-3 border-t border-white/5">
                  <div>
                    <p className="text-gray-500 text-[10px] uppercase tracking-wide">SDNN</p>
                    <p className="text-white font-mono text-sm">{hrv.sdnn} <span className="text-gray-600">ms</span></p>
                  </div>
                  <div>
                    <p className="text-gray-500 text-[10px] uppercase tracking-wide">pNN50</p>
                    <p className="text-white font-mono text-sm">{hrv.pnn50}<span className="text-gray-600">%</span></p>
                  </div>
                  <div>
                    <p className="text-gray-500 text-[10px] uppercase tracking-wide">Mean RR</p>
                    <p className="text-white font-mono text-sm">{hrv.meanRr} <span className="text-gray-600">ms</span></p>
                  </div>
                </div>

                {/* How much data is behind the numbers, and how much was thrown
                    out as artifacts — a strap that shifts produces plenty. */}
                <p className="text-gray-600 text-[10px] mt-3">
                  from {hrv.beats} beats
                  {hrv.dropped > 0 && ` · ${hrv.dropped} discarded as artifacts`}
                  {' · compare against your own sessions, not against a reference value'}
                </p>
              </div>
            </div>
          )}

          <button
            onClick={() => exportCSV(allData)}
            className="w-full flex items-center justify-center gap-2 py-3.5 bg-white/5 hover:bg-white/8 border border-white/10 rounded-2xl text-gray-400 hover:text-white transition-colors text-sm"
          >
            <Download size={15} />
            Export CSV (compatible with Google Sheets)
          </button>

          <button
            onClick={() => setShowLog(true)}
            className="w-full flex items-center justify-center gap-2 text-gray-600 hover:text-white text-xs font-medium py-2 transition-colors"
          >
            <ScrollText size={12} />
            View logs
          </button>
        </div>
      </div>
    </div>

    {showLog && (
      <SessionLogModal
        events={session.events}
        startTime={session.startTime}
        onClose={() => setShowLog(false)}
      />
    )}

    {/* Expanded, scrollable heart-rate chart */}
    {hrExpanded && hrChart && (
      <div className="fixed inset-0 bg-gray-950 z-[60] flex flex-col animate-fadeIn">
        <div className="flex items-center justify-between px-4 py-3 border-b border-white/10 flex-shrink-0">
          <h3 className="text-white font-semibold text-sm flex items-center gap-1.5">
            <HeartPulse size={15} className="text-red-400" /> Heart rate over the session
          </h3>
          <button onClick={() => setHrExpanded(false)} className="text-gray-400 hover:text-white p-2 rounded-lg">
            <X size={20} />
          </button>
        </div>
        <p className="text-gray-500 text-xs px-4 py-2 flex-shrink-0">
          Swipe sideways to inspect · tap a dot for the exercise
          {hrChart.hasRest && ' · línea punteada = descanso'}
          {hrChart.gaps > 0 && ' · cortes = sin señal de la banda'}
        </p>
        <div className="flex-1 overflow-x-auto overflow-y-hidden overscroll-contain">
          <HrComposedChart
            chart={hrChart}
            width={Math.max(typeof window !== 'undefined' ? window.innerWidth - 8 : 700, Math.round(hrChart.maxT * 0.7))}
            height={typeof window !== 'undefined' ? Math.round(window.innerHeight * 0.62) : 420}
          />
        </div>
        <div className="flex flex-wrap gap-x-4 gap-y-1 p-4 border-t border-white/10 flex-shrink-0">
          {hrChart.series.map(s => (
            <span key={s.name} className="flex items-center gap-1.5 text-xs text-gray-400">
              <span className="w-2.5 h-2.5 rounded-full inline-block" style={{ background: s.color }} />
              {s.name}
            </span>
          ))}
        </div>
      </div>
    )}
    </>
  )
}
