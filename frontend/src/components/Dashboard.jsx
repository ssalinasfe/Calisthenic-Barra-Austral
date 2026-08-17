import { useState, useEffect, useRef } from 'react'
import { fetchData, saveData, saveSession } from '../api'
import { useHeartRate, hrStore } from '../heartRate'
import { useRestSound, soundStore } from '../sound'
import { useAutoRun, autoRunStore } from '../autoRun'
import { wakeLockStore, useWakeLock } from '../wakeLock'
import { sessionLog } from '../sessionLog'
import ExerciseSearch from './ExerciseSearch'
import ExerciseCard from './ExerciseCard'
import SessionSummary from './SessionSummary'
import Settings from './Settings'
import Calendar from './Calendar'
import MuscleStats from './MuscleStats'
import ExerciseProgress from './ExerciseProgress'
import More from './More'
import RoutineChooser from './RoutineChooser'
import FinishSessionModal from './FinishSessionModal'
import SessionLogModal from './SessionLogModal'
import { Play, Square, Settings as SettingsIcon, LogOut, PersonStanding, CalendarDays, MoreHorizontal, MapPin, Trash2, HeartPulse, HeartOff, Activity, TrendingUp, Bell, BellOff, Zap, ScrollText } from 'lucide-react'
import { format } from 'date-fns'
import { totalReps as sumReps } from '../utils'
import { migrateData } from '../exercises'

const ACTIVE_SESSION_KEY = 'gym_active_session'
// Heart-rate samples get their own key, written as they arrive. Folding them
// into the blob above would tie them to its save cadence, which only fires when
// a set changes — a reload during a long rest would drop minutes of readings.
const ACTIVE_HR_KEY = 'gym_active_hr'

function loadActiveSession() {
  try {
    const raw = localStorage.getItem(ACTIVE_SESSION_KEY)
    return raw ? JSON.parse(raw) : null
  } catch { return null }
}

function useElapsed(startTime, active) {
  const [elapsed, setElapsed] = useState(0)
  useEffect(() => {
    if (!active || !startTime) { setElapsed(0); return }
    const tick = () => setElapsed(Math.floor((Date.now() - new Date(startTime).getTime()) / 1000))
    tick()
    const id = setInterval(tick, 1000)
    return () => clearInterval(id)
  }, [startTime, active])
  return elapsed
}

function fmtElapsed(secs) {
  const h = Math.floor(secs / 3600)
  const m = Math.floor((secs % 3600) / 60)
  const s = secs % 60
  if (h > 0) return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
}

const NAV = [
  { id: 'train',    label: 'Train',    Icon: PersonStanding },
  { id: 'calendar', label: 'Calendar', Icon: CalendarDays },
  { id: 'muscles',  label: 'Muscles',  Icon: Activity },
  { id: 'progress', label: 'Progress', Icon: TrendingUp },
  { id: 'more',     label: 'More',     Icon: MoreHorizontal },
]

export default function Dashboard({ token, username, onLock, bgImage, onBgChange }) {
  const [allData, setAllData] = useState({ sessions: [], locations: [], routines: [] })
  const [view, setView] = useState('train')
  const [status, setStatus] = useState(() => loadActiveSession() ? 'active' : 'idle')   // idle | active | saving
  const [sessionStart, setSessionStart] = useState(() => loadActiveSession()?.sessionStart ?? null)
  const [exercises, setExercises] = useState(() => loadActiveSession()?.exercises ?? [])
  const [activeRoutineId, setActiveRoutineId] = useState(() => loadActiveSession()?.activeRoutineId ?? null)
  const [activeRoutineName, setActiveRoutineName] = useState(() => loadActiveSession()?.activeRoutineName ?? '')
  const [activeCategories, setActiveCategories] = useState(() => loadActiveSession()?.activeCategories ?? [])
  const [activeLocationId, setActiveLocationId] = useState(() => loadActiveSession()?.activeLocationId ?? '')
  const [navWarning, setNavWarning] = useState(false)
  const [showSummary, setShowSummary] = useState(false)
  const [lastSession, setLastSession] = useState(null)
  const [showSettings, setShowSettings] = useState(false)
  const [showChooser, setShowChooser] = useState(false)
  const [showFinish, setShowFinish] = useState(false)
  const [showLog, setShowLog] = useState(false)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const elapsed = useElapsed(sessionStart, status === 'active')

  // Heart rate: while a session is active, record every reading the (optional)
  // BLE belt sends — bpm, and where the belt reports them, skin contact and the
  // RR intervals. Summary stats get saved with the session.
  const hr = useHeartRate()
  const hrSamplesRef = useRef([])
  const hrFlushRef = useRef(0)      // last localStorage mirror, ms
  const hrBatteryRef = useRef([])   // [{t, pct}] appended only when it changes
  const restSound = useRestSound()
  const autoRun = useAutoRun()
  const wakeLock = useWakeLock()

  // Rebuild what only lived in memory when the page reloaded mid-session: the
  // heart-rate series collected so far, and the diagnostic log (sessionLog.js),
  // which then records the reload itself.
  useEffect(() => {
    const saved = loadActiveSession()
    if (!saved?.sessionStart) return
    try {
      const raw = localStorage.getItem(ACTIVE_HR_KEY)
      const arr = raw ? JSON.parse(raw) : null
      if (Array.isArray(arr)) hrSamplesRef.current = arr
    } catch { /* corrupt entry — start the series over rather than fail */ }
    sessionLog.restore(saved.sessionStart)
  }, [])

  // The belt dropping is the most common reason the trace goes blank. Only
  // logged once a belt is paired, otherwise every beltless session opens with a
  // permanent "belt-off".
  useEffect(() => {
    if (status !== 'active' || !hr.paired) return
    sessionLog.log(hr.status === 'connected' ? 'belt-on' : 'belt-off')
  }, [hr.status, hr.paired, status])

  // A belt can report "connected" and quietly stop emitting (out of range, dry
  // strap). Nothing in hr.status catches that — only the silence does.
  const stalledRef = useRef(false)
  useEffect(() => {
    if (status !== 'active' || hr.status !== 'connected') { stalledRef.current = false; return }
    const id = setInterval(() => {
      const silentFor = hr.lastAt ? Date.now() - hr.lastAt : 0
      if (!stalledRef.current && silentFor > 20000) {
        stalledRef.current = true
        sessionLog.log('stall-start')
      } else if (stalledRef.current && silentFor < 20000) {
        stalledRef.current = false
        sessionLog.log('stall-end')
      }
    }, 5000)
    return () => clearInterval(id)
  }, [status, hr.status, hr.lastAt])

  // Belt battery, sampled only on change: it moves in whole percent over an
  // hour, and a belt running low is a prime suspect for the dropouts.
  useEffect(() => {
    if (status !== 'active' || !sessionStart || hr.battery == null) return
    const arr = hrBatteryRef.current
    if (arr.length && arr[arr.length - 1].pct === hr.battery) return
    const t = Math.max(0, Math.round((Date.now() - new Date(sessionStart).getTime()) / 1000))
    arr.push({ t, pct: hr.battery })
    // A belt this low is the prime suspect for the dropouts that follow, and the
    // series alone doesn't say it out loud in the log.
    if (hr.battery <= 15) sessionLog.log('battery-low')
  }, [hr.battery, status, sessionStart])

  // The belt can tell us the strap stopped touching skin — the direct cause
  // behind most "connected but silent" stretches.
  useEffect(() => {
    if (status !== 'active' || hr.contact == null) return
    sessionLog.log(hr.contact ? 'contact-ok' : 'contact-lost')
  }, [hr.contact, status])

  // Context for reading the trace later: which stretch ran hands-free, and
  // whether the screen was really being held awake while it did.
  useEffect(() => {
    if (status === 'active') sessionLog.log(autoRun.enabled ? 'auto-on' : 'auto-off')
  }, [autoRun.enabled, status])
  useEffect(() => {
    if (status === 'active') sessionLog.log(wakeLock.held ? 'wake-on' : 'wake-off')
  }, [wakeLock.held, status])

  // Auto mode is a per-workout thing: never leave it armed once the session ends.
  useEffect(() => { if (status !== 'active') autoRunStore.setEnabled(false) }, [status])

  // Keep the screen awake while training, so the browser doesn't throttle the
  // set/rest timers. Released as soon as the session ends or the view unmounts.
  useEffect(() => { wakeLockStore.setWanted(status === 'active') }, [status])
  useEffect(() => () => wakeLockStore.setWanted(false), [])

  // On load, silently bring the remembered belt back (the connection can't survive
  // a page reload, but we can reconnect without prompting).
  useEffect(() => { hrStore.autoConnect() }, [])
  useEffect(() => {
    if (status !== 'active' || !sessionStart) return
    if (hr.status !== 'connected' || hr.bpm == null || !hr.lastAt) return
    const t = Math.max(0, Math.round((hr.lastAt - new Date(sessionStart).getTime()) / 1000))
    const arr = hrSamplesRef.current
    const last = arr[arr.length - 1]
    // The series is keyed by whole seconds, but a belt can send two packets
    // inside one. Merge instead of dropping: the bpm is refreshed and the RR
    // intervals are appended, so no individual beat is ever lost.
    if (last && t <= last.t) {
      last.bpm = hr.bpm
      if (hr.contact != null) last.contact = hr.contact
      if (hr.energy != null) last.energy = hr.energy
      if (hr.rr?.length) last.rr = [...(last.rr || []), ...hr.rr]
      return
    }
    // Every reading now, not a 5s digest. The old digest threw away 4 of every
    // 5 beats, which is why the session max could miss the actual peak. Sessions
    // upload one at a time now, so the extra size costs a single request.
    const sample = { t, bpm: hr.bpm }
    // Everything the packet carried, recorded as-is. Storing only the anomalies
    // would be smaller, but future charts would have to know the convention to
    // read it back — and a reading not written down now is gone for good.
    if (hr.contact != null) sample.contact = hr.contact   // strap on skin
    if (hr.energy != null) sample.energy = hr.energy      // kJ, cumulative
    if (hr.rr?.length) sample.rr = hr.rr                  // beat-to-beat, for HRV
    arr.push(sample)
    // Mirrored at most every 5s: at full resolution this array reaches tens of
    // KB, and stringifying it every second on a phone is not worth the 4 extra
    // seconds of crash protection.
    if (Date.now() - hrFlushRef.current > 5000) {
      hrFlushRef.current = Date.now()
      try { localStorage.setItem(ACTIVE_HR_KEY, JSON.stringify(arr)) } catch { /* best effort */ }
    }
  }, [hr.lastAt, hr.status, hr.bpm, hr.contact, hr.rr, hr.energy, status, sessionStart])

  useEffect(() => {
    fetchData(token)
      .then(raw => {
        const { data, changed } = migrateData(raw)
        setAllData(data)
        setLoading(false)
        if (changed) {
          // Full blob on purpose: a shape migration rewrites everything at once.
          saveData(token, data).catch(() => { /* best-effort */ })
        }
      })
      .catch(() => { setError('Could not connect to the server'); setLoading(false) })
  }, [token])

  // Persist active session so it survives reloads / accidental back navigation
  useEffect(() => {
    if (status === 'active' && sessionStart) {
      try {
        localStorage.setItem(ACTIVE_SESSION_KEY, JSON.stringify({
          sessionStart,
          exercises,
          activeRoutineId,
          activeRoutineName,
          activeCategories,
          activeLocationId,
        }))
      } catch { /* quota / disabled — best effort */ }
    }
  }, [status, sessionStart, exercises, activeRoutineId, activeRoutineName, activeCategories, activeLocationId])

  // Warn before closing/reloading the tab during an active session
  useEffect(() => {
    if (status !== 'active') return
    const handler = e => { e.preventDefault(); e.returnValue = '' }
    window.addEventListener('beforeunload', handler)
    return () => window.removeEventListener('beforeunload', handler)
  }, [status])

  // Block accidental browser-back during an active session
  useEffect(() => {
    if (status !== 'active') return
    window.history.pushState({ gymActiveSession: true }, '')
    let timer
    const onPop = () => {
      window.history.pushState({ gymActiveSession: true }, '')
      setNavWarning(true)
      clearTimeout(timer)
      timer = setTimeout(() => setNavWarning(false), 2500)
    }
    window.addEventListener('popstate', onPop)
    return () => {
      clearTimeout(timer)
      window.removeEventListener('popstate', onPop)
    }
  }, [status])

  const todayWeekday = (new Date().getDay() + 6) % 7  // Mon=0..Sun=6

  function startSession(routine, categories) {
    hrSamplesRef.current = []
    hrBatteryRef.current = []
    // Drop the previous session's series now: without a belt connected nothing
    // would overwrite it, and a reload would resurrect it into this session.
    localStorage.removeItem(ACTIVE_HR_KEY)
    const startedAt = new Date().toISOString()
    sessionLog.start(startedAt)
    setSessionStart(startedAt)
    setActiveRoutineId(routine?.id || null)
    setActiveRoutineName(routine?.name || '')
    setActiveCategories(categories || routine?.categories || [])
    setActiveLocationId('')
    if (routine && routine.exercises?.length) {
      setExercises(routine.exercises.map((ex, i) => ({
        ...ex,
        instanceId: `${Date.now()}_${i}`,
        sets: [],
      })))
    } else {
      setExercises([])
    }
    setStatus('active')
    setError('')
    setView('train')
  }

  function requestFinish() {
    const completed = exercises.some(ex => ex.sets.some(s => s.duration !== null))
    if (!completed) {
      setError('Add at least one completed set before finishing')
      return
    }
    setShowFinish(true)
  }

  async function finalizeSession(photos) {
    const now = new Date().toISOString()
    const hrSamples = hrSamplesRef.current
    const hrFields = {}
    if (hrSamples.length) {
      const bpms = hrSamples.map(s => s.bpm)
      hrFields.avgHr = Math.round(bpms.reduce((a, b) => a + b, 0) / bpms.length)
      hrFields.maxHr = Math.max(...bpms)
      hrFields.minHr = Math.min(...bpms)
      hrFields.hrSamples = hrSamples
    }
    // What produced these numbers. Worth keeping per session: belts get
    // replaced, firmware changes, and a battery series explains a lot of holes.
    if (hr.paired) {
      hrFields.hrDevice = {
        name: hr.deviceName || null,
        manufacturer: hr.manufacturer || null,
        model: hr.model || null,
        firmware: hr.firmware || null,
        sensorLocation: hr.sensorLocation || null,
        battery: hrBatteryRef.current,
      }
    }
    const session = {
      id: sessionStart,
      title: activeRoutineName || '',
      date: format(new Date(sessionStart), 'yyyy-MM-dd'),
      startTime: sessionStart,
      endTime: now,
      durationSeconds: Math.floor((new Date(now) - new Date(sessionStart)) / 1000),
      events: sessionLog.events(),
      exercises: exercises
        .map(ex => ({
          name: ex.name,
          category: ex.category,
          sets: ex.sets
            .filter(s => s.duration !== null)
            .map(s => ({
              startedAt: s.startedAt,
              duration: s.duration,
              reps: s.reps ?? 0,
              ...(s.weight != null ? { weight: s.weight } : {}),
              ...(s.restDuration ? { restDuration: s.restDuration } : {}),
              ...(s.startHr != null ? { startHr: s.startHr } : {}),
              ...(s.avgHr != null ? { avgHr: s.avgHr } : {}),
              ...(s.maxHr != null ? { maxHr: s.maxHr } : {}),
            })),
        }))
        .filter(ex => ex.sets.length > 0),
      notes: '',
      categories: activeCategories || [],
      photos: photos || [],
      locationId: activeLocationId || null,
      routineId: activeRoutineId || null,
      ...hrFields,
    }

    setStatus('saving')
    const newData = { ...allData, sessions: [...(allData.sessions || []), session] }
    try {
      // Just this session goes up; the rest of the history stays in the DB.
      await saveSession(token, session)
      setAllData(newData)
      setLastSession(session)
      setShowFinish(false)
      setShowSummary(true)
      setStatus('idle')
      setSessionStart(null)
      setExercises([])
      setActiveRoutineId(null)
      setActiveRoutineName('')
      setActiveCategories([])
      setActiveLocationId('')
      hrSamplesRef.current = []
      sessionLog.stop()
      localStorage.removeItem(ACTIVE_SESSION_KEY)
      localStorage.removeItem(ACTIVE_HR_KEY)
    } catch {
      setError('Failed to save the session')
      setStatus('active')
      setShowFinish(false)
    }
  }

  function discardSession() {
    if (!window.confirm('Discard this session? Your in-progress sets will be lost.')) return
    hrSamplesRef.current = []
    sessionLog.stop()
    localStorage.removeItem(ACTIVE_SESSION_KEY)
    localStorage.removeItem(ACTIVE_HR_KEY)
    setStatus('idle')
    setSessionStart(null)
    setExercises([])
    setActiveRoutineId(null)
    setActiveRoutineName('')
    setActiveCategories([])
    setActiveLocationId('')
    setError('')
  }

  const today = format(new Date(), "EEEE d MMM")
  const totalSessions = allData.sessions?.length ?? 0
  const locations = allData.locations || []

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-gray-600 text-sm animate-pulse">Loading...</div>
      </div>
    )
  }

  return (
    <div className="min-h-screen pb-24">

      {/* Top header */}
      <header className="sticky top-0 z-40 bg-gray-950/80 backdrop-blur-md border-b border-white/8">
        <div className="max-w-xl mx-auto px-4 py-3 flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-black border border-white/10 flex items-center justify-center flex-shrink-0 overflow-hidden">
            <img src="/logo.png" alt="" className="w-full h-full object-contain" />
          </div>
          {status !== 'active' && (
            <div className="flex-1 min-w-0">
              <span className="text-white font-semibold text-sm">Barra Austral</span>
              {username && (
                <span className="text-cyan-400 text-xs ml-2">@{username}</span>
              )}
              <span className="text-gray-600 text-xs ml-2 hidden sm:inline">{today}</span>
            </div>
          )}
          {status === 'active' && <div className="flex-1 min-w-0" />}

          {/* Heart-rate belt status — always visible once a belt is paired */}
          {hr.paired && (
            hr.status === 'connected' ? (
              <div
                className="flex items-center gap-1 text-red-400 font-bold text-base font-mono tracking-wider"
                title={`Belt connected — ${hr.deviceName || 'HR belt'}`}
              >
                <HeartPulse size={15} className="animate-pulse" />
                {hr.bpm != null ? hr.bpm : '··'}
              </div>
            ) : hr.status === 'connecting' ? (
              <div className="flex items-center gap-1 text-amber-400/80 text-xs" title="Reconnecting to belt…">
                <HeartPulse size={15} className="animate-pulse" />
                <span className="hidden sm:inline">…</span>
              </div>
            ) : (
              <button
                onClick={() => hrStore.connect()}
                className="flex items-center gap-1 text-gray-600 hover:text-red-400 transition-colors"
                title="Belt disconnected — tap to reconnect"
              >
                <HeartOff size={15} />
              </button>
            )
          )}

          {status === 'active' && (
            <div className="font-mono text-cyan-400 font-bold text-base tracking-wider">
              {fmtElapsed(elapsed)}
            </div>
          )}

          {status === 'active' && (
            <button
              onClick={() => autoRunStore.toggle()}
              className={`p-2 rounded-lg transition-colors ${autoRun.enabled ? 'text-emerald-400 bg-emerald-500/15 hover:text-emerald-300' : 'text-gray-600 hover:text-white'}`}
              title={autoRun.enabled
                ? 'Modo automático ON — la rutina corre sola; toca para apagar'
                : 'Modo automático — encadena serie, descanso y siguiente ejercicio solo'}
            >
              <Zap size={17} fill={autoRun.enabled ? 'currentColor' : 'none'} />
            </button>
          )}

          {status === 'active' && (
            <button
              onClick={() => soundStore.toggle()}
              className={`p-2 rounded-lg transition-colors ${restSound.enabled ? 'text-amber-400 hover:text-amber-300' : 'text-gray-600 hover:text-white'}`}
              title={restSound.enabled ? 'Rest beep on — tap to mute' : 'Rest beep muted — tap to enable'}
            >
              {restSound.enabled ? <Bell size={17} /> : <BellOff size={17} />}
            </button>
          )}

          <button onClick={() => setShowSettings(true)} className="text-gray-600 hover:text-white p-2 rounded-lg transition-colors">
            <SettingsIcon size={17} />
          </button>
          <button onClick={onLock} className="text-gray-600 hover:text-red-400 p-2 rounded-lg transition-colors">
            <LogOut size={17} />
          </button>
        </div>
      </header>

      {/* Main content */}
      <main className="max-w-xl mx-auto px-4 pt-6 space-y-4">
        {error && (
          <div className="bg-red-500/15 border border-red-500/30 rounded-2xl px-4 py-3 text-red-300 text-sm animate-fadeIn">
            {error}
          </div>
        )}

        {navWarning && (
          <div className="bg-amber-500/15 border border-amber-500/30 rounded-2xl px-4 py-3 text-amber-200 text-sm animate-fadeIn">
            Session in progress — finish or discard before leaving.
          </div>
        )}

        {/* ── TRAIN VIEW ── */}
        {view === 'train' && (
          <>
            {status === 'idle' && (
              <div className="text-center py-14 animate-fadeIn">
                <div className="inline-flex items-center justify-center w-20 h-20 rounded-3xl bg-cyan-500/10 border border-cyan-500/20 mb-6">
                  <PersonStanding className="text-cyan-400" size={36} />
                </div>
                <h2 className="text-white text-xl font-bold mb-2">Ready to train?</h2>
                <p className="text-gray-600 text-sm mb-6">
                  {totalSessions > 0
                    ? `${totalSessions} ${totalSessions === 1 ? 'session recorded' : 'sessions recorded'}`
                    : 'No sessions recorded yet'}
                </p>

                <button
                  onClick={() => setShowChooser(true)}
                  className="inline-flex items-center gap-2.5 bg-cyan-500 hover:bg-cyan-400 text-white font-semibold px-8 py-4 rounded-2xl text-base transition-all hover:scale-105 shadow-lg shadow-cyan-500/20"
                >
                  <Play size={18} fill="white" />
                  Start session
                </button>

                {totalSessions > 0 && (
                  <div className="mt-10 text-left">
                    <p className="text-gray-700 text-xs font-medium mb-3">Recent sessions</p>
                    <div className="space-y-2">
                      {[...allData.sessions].reverse().slice(0, 3).map(s => {
                        const reps = (s.exercises || []).reduce(
                          (sum, ex) => sum + sumReps(ex.sets), 0
                        )
                        return (
                          <div key={s.id} className="bg-white/4 border border-white/8 rounded-xl px-4 py-3 flex justify-between items-center">
                            <div>
                              <p className="text-white text-sm font-medium">
                                {format(new Date(s.startTime), "EEEE d MMM · HH:mm")}
                              </p>
                              <p className="text-gray-600 text-xs mt-0.5">
                                {(s.exercises || []).length} exercises · {reps} reps
                              </p>
                            </div>
                            <span className="text-gray-600 text-xs font-mono">
                              {Math.floor((s.durationSeconds || 0) / 60)}m
                            </span>
                          </div>
                        )
                      })}
                    </div>
                  </div>
                )}
              </div>
            )}

            {(status === 'active' || status === 'saving') && (
              <div className="space-y-4 animate-fadeIn">
                {/* Active session location selector */}
                {locations.length > 0 && (
                  <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-3 flex items-center gap-2">
                    <MapPin size={14} className="text-gray-500 flex-shrink-0" />
                    <select
                      value={activeLocationId}
                      onChange={e => setActiveLocationId(e.target.value)}
                      className="flex-1 bg-transparent text-white text-sm outline-none"
                    >
                      <option value="" className="bg-gray-900">— No location —</option>
                      {locations.map(l => (
                        <option key={l.id} value={l.id} className="bg-gray-900">{l.name}</option>
                      ))}
                    </select>
                  </div>
                )}

                <ExerciseSearch
                  onAdd={ex => {
                    setExercises(prev => [...prev, { ...ex, instanceId: Date.now() + Math.random(), sets: [] }])
                  }}
                  addedExercises={exercises}
                />

                {exercises.length === 0 && (
                  <div className="text-center py-12 text-gray-700 text-sm">
                    Search for an exercise to start
                  </div>
                )}

                {(() => {
                  // Group adjacent exercises with the same supersetGroup into a wrapper
                  const blocks = []
                  let cur = null
                  exercises.forEach((ex, idx) => {
                    const g = ex.supersetGroup
                    if (g != null && cur && cur.group === g) {
                      cur.items.push({ ex, idx })
                    } else {
                      if (cur) blocks.push(cur)
                      cur = { group: g, items: [{ ex, idx }] }
                    }
                  })
                  if (cur) blocks.push(cur)

                  const renderCard = ({ ex, idx }) => (
                    <ExerciseCard
                      key={ex.instanceId ?? idx}
                      exercise={ex}
                      order={idx}
                      onChange={updated =>
                        setExercises(prev => prev.map((e, i) => (i === idx ? updated : e)))
                      }
                      onRemove={() =>
                        setExercises(prev => prev.filter((_, i) => i !== idx))
                      }
                    />
                  )

                  return blocks.map((b, bi) => {
                    if (b.group != null && b.items.length > 1) {
                      return (
                        <div key={`ss_${bi}`} className="border-2 border-purple-500/40 bg-purple-500/5 rounded-3xl p-2 space-y-2">
                          <div className="flex items-center gap-2 px-2 pt-1">
                            <span className="text-[10px] uppercase tracking-wide font-bold text-purple-300">Superset</span>
                            <span className="text-purple-200/70 text-xs">do all back-to-back</span>
                          </div>
                          {b.items.map(renderCard)}
                        </div>
                      )
                    }
                    return b.items.map(renderCard)
                  })
                })()}

                {exercises.length > 0 && (
                  <button
                    onClick={requestFinish}
                    disabled={status === 'saving'}
                    className="w-full flex items-center justify-center gap-2.5 bg-green-500 hover:bg-green-400 disabled:opacity-50 text-white font-semibold py-4 rounded-2xl transition-colors mt-2 shadow-lg shadow-green-500/15"
                  >
                    <Square size={16} fill="white" />
                    {status === 'saving' ? 'Saving...' : 'Finish session'}
                  </button>
                )}

                {status === 'active' && (
                  <button
                    onClick={() => setShowLog(true)}
                    className="w-full flex items-center justify-center gap-2 text-gray-600 hover:text-white text-xs font-medium py-2 transition-colors"
                  >
                    <ScrollText size={12} />
                    View logs
                  </button>
                )}

                {status === 'active' && (
                  <button
                    onClick={discardSession}
                    className="w-full flex items-center justify-center gap-2 text-gray-600 hover:text-red-400 text-xs font-medium py-2 transition-colors"
                  >
                    <Trash2 size={12} />
                    Discard session
                  </button>
                )}
              </div>
            )}
          </>
        )}

        {/* ── CALENDAR VIEW ── */}
        {view === 'calendar' && <Calendar allData={allData} token={token} />}

        {/* ── MUSCLES VIEW ── */}
        {view === 'muscles' && <MuscleStats allData={allData} />}

        {/* ── PROGRESS VIEW ── */}
        {view === 'progress' && <ExerciseProgress allData={allData} />}

        {/* ── MORE VIEW ── */}
        {view === 'more' && (
          <More allData={allData} token={token} onDataChange={setAllData} />
        )}
      </main>

      {/* Bottom navigation */}
      <nav className="fixed bottom-0 left-0 right-0 z-40 bg-gray-950/90 backdrop-blur-md border-t border-white/8">
        <div className="max-w-xl mx-auto flex">
          {NAV.map(({ id, label, Icon }) => {
            const active = view === id
            const isTrainActive = id === 'train' && status === 'active'
            return (
              <button
                key={id}
                onClick={() => setView(id)}
                className={`flex-1 flex flex-col items-center py-3 gap-1 transition-colors ${
                  active ? 'text-cyan-400' : 'text-gray-600 hover:text-gray-400'
                }`}
              >
                <div className="relative">
                  <Icon size={20} />
                  {isTrainActive && (
                    <span className="absolute -top-0.5 -right-0.5 w-2 h-2 bg-green-400 rounded-full" />
                  )}
                </div>
                <span className="text-xs font-medium">{label}</span>
              </button>
            )
          })}
        </div>
      </nav>

      {showChooser && (
        <RoutineChooser
          routines={allData.routines || []}
          todayWeekday={todayWeekday}
          onChoose={(routine, categories) => { setShowChooser(false); startSession(routine, categories) }}
          onClose={() => setShowChooser(false)}
        />
      )}

      {showLog && (
        <SessionLogModal
          events={sessionLog.events()}
          startTime={sessionStart}
          onClose={() => setShowLog(false)}
        />
      )}

      {showFinish && (
        <FinishSessionModal
          token={token}
          onCancel={() => setShowFinish(false)}
          onConfirm={finalizeSession}
        />
      )}

      {showSummary && lastSession && (
        <SessionSummary
          session={lastSession}
          allData={allData}
          onClose={() => setShowSummary(false)}
        />
      )}

      {showSettings && (
        <Settings
          bgImage={bgImage}
          onBgChange={onBgChange}
          onClose={() => setShowSettings(false)}
        />
      )}
    </div>
  )
}
