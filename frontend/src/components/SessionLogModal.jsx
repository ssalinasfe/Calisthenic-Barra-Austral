import { X, ScrollText } from 'lucide-react'

// Reader for the diagnostic event log (sessionLog.js). Used from the live
// session and from a saved session's summary — same events either way, the
// live one just hasn't been written to the server yet.

// Meaning of each recorded type. `tone` splits the ones that explain missing
// heart-rate data from the merely contextual ones.
const EVENTS = {
  'belt-off':    { label: 'Belt disconnected',          tone: 'bad' },
  'belt-on':     { label: 'Belt reconnected',           tone: 'good' },
  'hidden':      { label: 'App sent to background',     tone: 'bad' },
  'visible':     { label: 'App back in foreground',     tone: 'good' },
  'stall-start': { label: 'Belt connected but silent',  tone: 'bad' },
  'stall-end':   { label: 'Belt emitting again',        tone: 'good' },
  'contact-lost':{ label: 'Strap lost skin contact',    tone: 'bad' },
  'contact-ok':  { label: 'Strap contact restored',     tone: 'good' },
  'battery-low': { label: 'Belt battery low (≤15%)',    tone: 'warn' },
  'reload':      { label: 'Page reloaded',              tone: 'warn' },
  'auto-on':     { label: 'Auto mode on',               tone: 'info' },
  'auto-off':    { label: 'Auto mode off',              tone: 'info' },
  'wake-on':     { label: 'Screen held awake',          tone: 'info' },
  'wake-off':    { label: 'Screen wake lock released',  tone: 'warn' },
}

const TONE = {
  bad:  'text-red-400',
  good: 'text-emerald-400',
  warn: 'text-amber-400',
  info: 'text-gray-500',
}

function mmss(secs) {
  const m = Math.floor(secs / 60)
  const s = secs % 60
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
}

// Wall-clock time of an event, so it can be matched against what actually
// happened in the gym. Only available when the session start is known.
function clockAt(startTime, t) {
  if (!startTime) return null
  const d = new Date(new Date(startTime).getTime() + t * 1000)
  return d.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit', second: '2-digit' })
}

export default function SessionLogModal({ events, startTime, onClose }) {
  const list = events || []

  return (
    <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-[70] p-4 animate-fadeIn">
      <div className="bg-gray-950 border border-white/10 rounded-2xl w-full max-w-lg max-h-[85vh] flex flex-col shadow-2xl">
        <div className="flex items-center justify-between px-5 py-4 border-b border-white/10 flex-shrink-0">
          <h2 className="text-white font-bold text-base flex items-center gap-2">
            <ScrollText size={16} className="text-cyan-400" />
            Session log
          </h2>
          <button onClick={onClose} className="text-gray-600 hover:text-white p-1.5 rounded-lg transition-colors">
            <X size={18} />
          </button>
        </div>

        <p className="text-gray-500 text-xs px-5 pt-3 flex-shrink-0">
          {list.length} {list.length === 1 ? 'event' : 'events'} · time from the start of the session
        </p>

        <div className="overflow-y-auto px-5 py-3 flex-1">
          {list.length === 0 ? (
            <p className="text-gray-600 text-sm py-6 text-center">
              Nothing recorded — the belt stayed connected and the app stayed in the foreground.
            </p>
          ) : (
            <table className="w-full text-sm">
              <tbody>
                {list.map((e, i) => {
                  const meta = EVENTS[e.type] || { label: e.type, tone: 'info' }
                  const clock = clockAt(startTime, e.t)
                  return (
                    <tr key={i} className="border-b border-white/5 last:border-0">
                      <td className="py-1.5 pr-3 font-mono text-cyan-400/80 whitespace-nowrap align-top">{mmss(e.t)}</td>
                      {clock && <td className="py-1.5 pr-3 font-mono text-gray-600 text-xs whitespace-nowrap align-top">{clock}</td>}
                      <td className={`py-1.5 ${TONE[meta.tone]}`}>
                        {meta.label}
                        {/* Backfilled from holes in the samples, not measured */}
                        {e.inferred && <span className="text-gray-600 text-xs ml-1.5">(inferred)</span>}
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  )
}
