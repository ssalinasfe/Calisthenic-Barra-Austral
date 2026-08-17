// Diagnostic timeline of a session. Internal: nothing here is shown to the user.
//
// Why it exists: a hole in hrSamples only says "no data", never why. There are
// exactly four ways a session can stop recording heart rate, and none of them
// is distinguishable from the samples alone:
//   · the belt disconnected              → belt-off / belt-on
//   · the browser was backgrounded and   → hidden / visible
//     its timers throttled
//   · the page reloaded (samples and     → reload
//     the running set are lost)
//   · the belt stayed connected but      → stall-start / stall-end
//     stopped emitting (out of range,
//     lost skin contact)
// Plus context that helps read the trace afterwards: auto-pilot on/off and
// whether the screen was actually being held awake.
//
// Times are whole seconds from the session start — the same axis as
// hrSamples[].t, so the chart can line them up directly.

const STORAGE_KEY = 'gym_session_log'

let startMs = null
let events = []

// Flushed on every single event rather than on some outer save cycle: a reload
// is one of the things this log exists to record, so it cannot afford to wait.
function persist() {
  try { localStorage.setItem(STORAGE_KEY, JSON.stringify(events)) } catch { /* best effort */ }
}

// Repeats of the same event collapse: hr.status flips through 'connecting' on
// its way back, and the visibility API fires more often than it changes state.
function log(type) {
  if (startMs == null) return
  const last = events[events.length - 1]
  if (last && last.type === type) return
  events.push({ t: Math.max(0, Math.round((Date.now() - startMs) / 1000)), type })
  persist()
}

// The page going away is itself one of the things worth recording, so this
// listener lives at module level and starts working the moment a session does.
if (typeof document !== 'undefined') {
  document.addEventListener('visibilitychange', () => {
    log(document.visibilityState === 'visible' ? 'visible' : 'hidden')
  })
}

export const sessionLog = {
  start(startedAtIso) {
    startMs = new Date(startedAtIso).getTime()
    events = []
    persist()
  },
  // After a reload: pick the clock back up and recover what was already logged.
  restore(startedAtIso) {
    startMs = new Date(startedAtIso).getTime()
    try {
      const raw = localStorage.getItem(STORAGE_KEY)
      const saved = raw ? JSON.parse(raw) : null
      events = Array.isArray(saved) ? saved : []
    } catch { events = [] }
    log('reload')
  },
  // Rebinds instead of mutating, so a session object already holding the array
  // (finalizeSession reads it just before this) keeps its own copy.
  stop() {
    startMs = null
    events = []
    try { localStorage.removeItem(STORAGE_KEY) } catch { /* best effort */ }
  },
  log,
  events: () => events,
}
