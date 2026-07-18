import { useMemo } from 'react'
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip,
  Legend, ResponsiveContainer,
} from 'recharts'
import { X, Download, CheckCircle, Clock, Layers, Zap } from 'lucide-react'
import { format } from 'date-fns'
import { setNotation } from '../utils'

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

export default function SessionSummary({ session, allData, onClose }) {
  const chartData = useMemo(() => {
    const pastSessions = (allData.sessions || []).filter(s => s.id !== session.id)
    return session.exercises.map(ex => {
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
      }
    })
  }, [session, allData])

  const totalReps = session.exercises.reduce(
    (sum, ex) => sum + ex.sets.reduce((s, set) => s + (set.reps || 0), 0), 0
  )
  const totalSets = session.exercises.reduce((sum, ex) => sum + ex.sets.length, 0)

  return (
    <div className="fixed inset-0 bg-black/75 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4 animate-fadeIn">
      <div className="bg-gray-950 border border-white/10 rounded-t-3xl sm:rounded-2xl w-full sm:max-w-2xl max-h-[92vh] overflow-y-auto shadow-2xl">

        <div className="flex items-center justify-between px-5 py-4 border-b border-white/10 sticky top-0 bg-gray-950 z-10">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-green-500/20 flex items-center justify-center">
              <CheckCircle className="text-green-400" size={18} />
            </div>
            <div>
              <h2 className="text-white font-bold text-base">Session complete</h2>
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
                    <Line dataKey="Today"    stroke="#06b6d4" strokeWidth={2.5} dot={{ fill: '#06b6d4', r: 5, strokeWidth: 0 }} activeDot={{ r: 7, strokeWidth: 0 }} />
                    <Line dataKey="Previous" stroke="#374151" strokeWidth={2}   dot={{ fill: '#374151', r: 4, strokeWidth: 0 }} activeDot={{ r: 6, strokeWidth: 0 }} />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}

          <div>
            <h3 className="text-white font-semibold mb-3 text-sm">Details</h3>
            <div className="space-y-2">
              {session.exercises.map(ex => {
                const repsTotal = ex.sets.reduce((s, set) => s + (set.reps || 0), 0)
                return (
                  <div key={ex.name} className="bg-white/5 border border-white/5 rounded-2xl px-4 py-3">
                    <div className="flex justify-between items-center">
                      <span className="text-white text-sm font-medium">{ex.name}</span>
                      <div className="flex items-center gap-3">
                        <span className="text-cyan-400 font-mono text-sm font-bold">{setNotation(ex.sets)}</span>
                        <span className="text-gray-600 text-xs">{repsTotal} reps</span>
                      </div>
                    </div>
                    <div className="flex flex-wrap gap-x-3 gap-y-0.5 mt-1.5">
                      {ex.sets.map((set, i) => (
                        <span key={i} className="text-gray-600 text-xs">
                          S{i + 1}: {set.reps ?? 0}r{set.weight != null ? ` · ${set.weight}kg` : ''} · {fmtDuration(set.duration ?? 0)}
                        </span>
                      ))}
                    </div>
                  </div>
                )
              })}
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
