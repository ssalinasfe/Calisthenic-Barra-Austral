import { useState, useMemo } from 'react'
import {
  format, startOfMonth, endOfMonth, eachDayOfInterval,
  addMonths, getDay, isToday,
} from 'date-fns'
import { ChevronLeft, ChevronRight, CalendarDays, ListChecks } from 'lucide-react'
import {
  CATEGORY_LABEL, CATEGORY_FILL, CATEGORY_PILL, categoryColorStyle,
  MUSCLE_ORDER, isFullBody, groupLabel, FULL_BODY_STYLE,
} from '../exercises'
import { totalReps as sumReps, sessionCategories } from '../utils'
import { photoUrl } from '../api'

function tallyByDay(sessions) {
  const map = new Map() // 'yyyy-MM-dd' → { cats, reps, sessions, photo }
  sessions.forEach(s => {
    const day = format(new Date(s.startTime), 'yyyy-MM-dd')
    if (!map.has(day)) map.set(day, { cats: [], reps: 0, sessions: 0, photo: null })
    const entry = map.get(day)
    entry.sessions++
    entry.reps += (s.exercises || []).reduce((sum, ex) => sum + sumReps(ex.sets), 0)
    // Union of each session's selected (or inferred) muscle groups.
    sessionCategories(s).forEach(c => { if (!entry.cats.includes(c)) entry.cats.push(c) })
    if (!entry.photo && s.photos && s.photos.length > 0) {
      entry.photo = s.photos[0]
    }
  })
  // Keep categories in canonical order.
  map.forEach(e => { e.cats = MUSCLE_ORDER.filter(c => e.cats.includes(c)) })
  return map
}

export default function Calendar({ allData, token }) {
  const [refDate, setRefDate] = useState(new Date())

  const dayMap = useMemo(
    () => tallyByDay(allData.sessions || []),
    [allData]
  )

  const routines = allData.routines || []
  // Build map: weekday (Mon=0..Sun=6) → routine name
  const routineByWeekday = useMemo(() => {
    const m = {}
    routines.forEach(r => {
      ;(r.weekdays || []).forEach(wd => { if (!m[wd]) m[wd] = r })
    })
    return m
  }, [routines])

  const monthStart = startOfMonth(refDate)
  const monthEnd = endOfMonth(refDate)
  const days = eachDayOfInterval({ start: monthStart, end: monthEnd })

  // Pad so the grid starts on Monday
  const firstWeekday = (getDay(monthStart) + 6) % 7  // Mon=0 ... Sun=6
  const padding = Array.from({ length: firstWeekday }, () => null)
  const cells = [...padding, ...days]

  // Month summary: count each muscle group for every day it was trained
  // (cardio excluded). A Push+Legs day adds 1 to each; Full Body adds 1 to all.
  const monthSummary = useMemo(() => {
    const counts = {}
    let daysTrained = 0
    days.forEach(d => {
      const key = format(d, 'yyyy-MM-dd')
      const data = dayMap.get(key)
      if (!data) return
      const cats = data.cats
      if (cats.length === 0) return
      daysTrained++
      cats.forEach(c => { counts[c] = (counts[c] || 0) + 1 })
    })
    return { entries: Object.entries(counts).sort((a, b) => b[1] - a[1]), daysTrained }
  }, [days, dayMap])

  const totalDays = monthSummary.daysTrained

  if ((allData.sessions || []).length === 0 && routines.length === 0) {
    return (
      <div className="text-center py-20">
        <CalendarDays className="text-gray-700 mx-auto mb-3" size={32} />
        <p className="text-gray-600 text-sm">No data yet</p>
      </div>
    )
  }

  return (
    <div className="space-y-3">
      {/* Month navigator */}
      <div className="flex items-center gap-2 bg-white/5 border border-white/8 rounded-xl px-2 py-1.5">
        <button
          onClick={() => setRefDate(d => addMonths(d, -1))}
          className="text-gray-500 hover:text-white p-1.5 rounded-lg transition-colors"
          title="Previous month"
        >
          <ChevronLeft size={16} />
        </button>
        <p className="text-white text-sm font-medium flex-1 text-center capitalize">
          {format(refDate, "MMMM yyyy")}
        </p>
        <button
          onClick={() => setRefDate(d => addMonths(d, 1))}
          className="text-gray-500 hover:text-white p-1.5 rounded-lg transition-colors"
          title="Next month"
        >
          <ChevronRight size={16} />
        </button>
      </div>

      {/* Calendar grid */}
      <div className="bg-white/3 border border-white/8 rounded-2xl p-3">
        <div className="grid grid-cols-7 gap-1.5 mb-2">
          {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map(d => (
            <div key={d} className="text-center text-gray-600 text-[10px] font-semibold uppercase">{d}</div>
          ))}
        </div>

        <div className="grid grid-cols-7 gap-1.5">
          {cells.map((day, i) => {
            if (!day) return <div key={`pad_${i}`} className="aspect-square" />
            const key = format(day, 'yyyy-MM-dd')
            const data = dayMap.get(key)
            // Only completed sessions color a day. A day that spans several
            // categories gets their blended color; the label reads "Full Body"
            // when it covers Push + Pull + Legs.
            const cats = data ? data.cats : []
            const label = groupLabel(cats)
            const fullBody = isFullBody(cats)
            const single = cats.length === 1
            let fillClass = ''
            let fillStyle
            if (cats.length === 0) {
              fillClass = 'bg-white/3 text-gray-700 border-white/5'
            } else if (fullBody) {
              fillStyle = FULL_BODY_STYLE
            } else if (single) {
              fillClass = CATEGORY_FILL[cats[0]] || CATEGORY_FILL.Custom
            } else {
              fillStyle = categoryColorStyle(cats, 'fill')
            }
            const today = isToday(day)
            const totalReps = data ? data.reps : 0
            const titleParts = [format(day, "d MMM")]
            if (data) {
              titleParts.push(`${data.sessions} ${data.sessions === 1 ? 'session' : 'sessions'}`)
              titleParts.push(`${totalReps} reps`)
              if (cats.length) titleParts.push(cats.map(c => CATEGORY_LABEL[c] || c).join(' + '))
            }

            const photo = data?.photo
            return (
              <div
                key={key}
                title={titleParts.join(' · ')}
                style={fillStyle}
                className={`aspect-square border rounded-lg flex flex-col items-center justify-center px-1 relative overflow-hidden ${fillClass} ${today ? 'ring-1 ring-white/40' : ''}`}
              >
                {photo && token && (
                  <>
                    <img
                      src={photoUrl(token, photo)}
                      alt=""
                      loading="lazy"
                      className="absolute inset-0 w-full h-full object-cover opacity-60"
                    />
                    <div className="absolute inset-0 bg-black/40" />
                  </>
                )}
                <span className="text-xs font-semibold leading-none relative z-10">{format(day, 'd')}</span>
                {label && (
                  <span className="text-[9px] font-bold uppercase mt-0.5 leading-none truncate max-w-full relative z-10">
                    {label}
                  </span>
                )}
              </div>
            )
          })}
        </div>
      </div>

      {/* Month summary */}
      {totalDays > 0 && (
        <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-4">
          <p className="text-gray-500 text-xs font-medium mb-3">
            Month summary · {totalDays} {totalDays === 1 ? 'day trained' : 'days trained'}
          </p>
          <div className="flex flex-wrap gap-2">
            {monthSummary.entries.map(([cat, n]) => (
              <span
                key={cat}
                className={`text-xs px-2 py-1 rounded-full border ${CATEGORY_PILL[cat] || CATEGORY_PILL.Custom}`}
              >
                {CATEGORY_LABEL[cat] || cat} · {n} {n === 1 ? 'day' : 'days'}
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Routine schedule */}
      {routines.length > 0 && (
        <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-4">
          <div className="flex items-center gap-2 mb-3">
            <ListChecks size={13} className="text-cyan-400" />
            <p className="text-gray-500 text-xs font-medium">Weekly routine schedule</p>
          </div>
          <div className="space-y-1.5">
            {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((label, wd) => {
              const r = routineByWeekday[wd]
              return (
                <div key={label} className="flex items-center gap-3 text-xs">
                  <span className="text-gray-600 w-10">{label}</span>
                  {r ? (
                    <span
                      className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full border font-medium"
                      style={categoryColorStyle(r.categories, 'pill')}
                    >
                      {r.name}
                    </span>
                  ) : (
                    <span className="text-gray-700">— rest day</span>
                  )}
                </div>
              )
            })}
          </div>
        </div>
      )}

      {/* Legend */}
      <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-3">
        <p className="text-gray-600 text-[10px] font-medium uppercase mb-2">Legend</p>
        <div className="flex flex-wrap gap-2">
          {Object.entries(CATEGORY_LABEL).filter(([cat]) => cat !== 'Remo').map(([cat, label]) => (
            <span
              key={cat}
              className={`text-xs px-2 py-0.5 rounded-full border ${CATEGORY_PILL[cat]}`}
            >
              {label}
            </span>
          ))}
        </div>
      </div>
    </div>
  )
}
