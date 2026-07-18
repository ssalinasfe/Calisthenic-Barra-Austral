import { useState } from 'react'
import { X, Play, ListChecks, Plus } from 'lucide-react'
import { CATEGORY_LABEL, CATEGORY_PILL } from '../exercises'

const WEEKDAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

// Muscle groups the user can tag a session with (cardio is not a coloring group).
const GROUP_OPTIONS = ['Push', 'Pull', 'Piernas', 'Custom']

export default function RoutineChooser({ routines, todayWeekday, onChoose, onClose }) {
  const [picked, setPicked] = useState('')
  const [groups, setGroups] = useState([])

  function toggleGroup(cat) {
    setGroups(g => g.includes(cat) ? g.filter(c => c !== cat) : [...g, cat])
  }

  // Empty sessions need at least one muscle group selected.
  const emptyReady = picked === 'empty' && groups.length > 0
  const canStart = (picked !== '' && picked !== 'empty') || emptyReady

  function start() {
    if (!canStart) return
    if (picked === 'empty') {
      // Preserve canonical group order.
      onChoose(null, GROUP_OPTIONS.filter(c => groups.includes(c)))
    } else {
      const r = routines.find(r => r.id === picked) || null
      onChoose(r, r?.categories || [])
    }
  }

  // Sort: today's first, then alphabetical
  const sorted = [...routines].sort((a, b) => {
    const aToday = (a.weekdays || []).includes(todayWeekday) ? 0 : 1
    const bToday = (b.weekdays || []).includes(todayWeekday) ? 0 : 1
    if (aToday !== bToday) return aToday - bToday
    return a.name.localeCompare(b.name)
  })

  return (
    <div className="fixed inset-0 bg-black/75 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4 animate-fadeIn">
      <div className="bg-gray-950 border border-white/10 rounded-t-3xl sm:rounded-2xl w-full sm:max-w-lg max-h-[88vh] overflow-y-auto shadow-2xl">

        <div className="flex items-center justify-between px-5 py-4 border-b border-white/10 sticky top-0 bg-gray-950 z-10">
          <h2 className="text-white font-bold text-base">Start a session</h2>
          <button onClick={onClose} className="text-gray-600 hover:text-white p-2 rounded-lg transition-colors">
            <X size={18} />
          </button>
        </div>

        <div className="px-5 py-4 space-y-2">
          <p className="text-gray-500 text-xs">Pick a routine or start an empty session.</p>

          <button
            onClick={() => setPicked('empty')}
            className={`w-full text-left bg-white/5 border rounded-2xl px-4 py-3 flex items-center gap-3 transition-colors ${
              picked === 'empty' ? 'border-cyan-500 ring-1 ring-cyan-500/40' : 'border-white/8 hover:bg-white/8'
            }`}
          >
            <div className="w-9 h-9 rounded-xl bg-cyan-500/15 flex items-center justify-center flex-shrink-0">
              <Plus size={16} className="text-cyan-400" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-white text-sm font-semibold">Empty session</p>
              <p className="text-gray-600 text-xs">Add exercises as you go</p>
            </div>
          </button>

          {picked === 'empty' && (
            <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-3 space-y-2">
              <p className="text-gray-500 text-xs">
                Which muscle groups are you training? <span className="text-gray-600">(pick at least one)</span>
              </p>
              <div className="flex flex-wrap gap-1.5">
                {GROUP_OPTIONS.map(cat => {
                  const active = groups.includes(cat)
                  return (
                    <button
                      key={cat}
                      type="button"
                      onClick={() => toggleGroup(cat)}
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
          )}

          {sorted.length === 0 && (
            <p className="text-gray-600 text-xs text-center py-4">
              You have no routines yet. Create one in More → Routines.
            </p>
          )}

          {sorted.map(r => {
            const isToday = (r.weekdays || []).includes(todayWeekday)
            const days = r.weekdays?.length ? r.weekdays.map(i => WEEKDAYS[i]).join(' · ') : 'Unscheduled'
            return (
              <button
                key={r.id}
                onClick={() => setPicked(r.id)}
                className={`w-full text-left bg-white/5 border rounded-2xl px-4 py-3 flex items-center gap-3 transition-colors ${
                  picked === r.id ? 'border-cyan-500 ring-1 ring-cyan-500/40' : 'border-white/8 hover:bg-white/8'
                }`}
              >
                <div className="w-9 h-9 rounded-xl bg-purple-500/15 flex items-center justify-center flex-shrink-0">
                  <ListChecks size={16} className="text-purple-300" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-white text-sm font-semibold truncate">{r.name}</p>
                    {isToday && (
                      <span className="text-[10px] px-1.5 py-0.5 rounded-full bg-cyan-500/20 text-cyan-300 border border-cyan-500/30 flex-shrink-0">
                        Today
                      </span>
                    )}
                  </div>
                  <p className="text-gray-600 text-xs">
                    {r.exercises.length} {r.exercises.length === 1 ? 'exercise' : 'exercises'} · {days}
                  </p>
                </div>
              </button>
            )
          })}
        </div>

        <div className="sticky bottom-0 bg-gray-950 border-t border-white/10 px-5 py-3">
          <button
            onClick={start}
            disabled={!canStart}
            className="w-full flex items-center justify-center gap-2 bg-cyan-500 hover:bg-cyan-400 disabled:opacity-40 text-white font-semibold py-3 rounded-2xl text-sm transition-colors"
          >
            <Play size={15} fill="white" />
            {picked === 'empty'
              ? (emptyReady ? 'Start empty' : 'Pick a muscle group')
              : picked ? 'Start with routine' : 'Choose an option'}
          </button>
        </div>
      </div>
    </div>
  )
}
