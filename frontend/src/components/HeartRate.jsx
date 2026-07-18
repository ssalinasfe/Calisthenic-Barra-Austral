import { useEffect, useState } from 'react'
import { Heart, HeartPulse, Bluetooth, BluetoothConnected, Trash2, AlertTriangle, Check, X } from 'lucide-react'
import { useHeartRate, hrStore } from '../heartRate'

export default function HeartRate() {
  const hr = useHeartRate()
  const [remembered, setRemembered] = useState(null)   // null=unknown, true/false

  // Try a silent reconnect to the remembered belt when opening this screen, and
  // probe whether the browser can silently reconnect (needs the permission flag +
  // having paired *after* enabling it).
  useEffect(() => {
    hrStore.autoConnect()
    if (hr.paired) hrStore.probeRemembered().then(setRemembered)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [hr.paired, hr.status])

  const connected = hr.status === 'connected'
  const connecting = hr.status === 'connecting'
  const fresh = hr.lastAt && Date.now() - hr.lastAt < 5000

  if (!hr.supported) {
    return (
      <div className="space-y-3">
        <div className="bg-amber-500/10 border border-amber-500/25 rounded-2xl px-4 py-4 space-y-2">
          <div className="flex items-center gap-2 text-amber-300 font-semibold text-sm">
            <AlertTriangle size={16} /> Bluetooth not available
          </div>
          <p className="text-amber-200/80 text-xs leading-relaxed">
            This browser can't reach Bluetooth devices. Use <b>Brave</b> or Chrome and make
            sure the app is open over its <b>HTTPS</b> address (or localhost).
          </p>
          <p className="text-amber-200/80 text-xs leading-relaxed">
            In <b>Brave</b>, Web Bluetooth is off by default: open{' '}
            <code className="text-amber-100">brave://flags/#brave-web-bluetooth-api</code>,
            set it to <b>Enabled</b>, and restart the browser.
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      {/* Live reading */}
      <div className={`rounded-3xl border px-6 py-8 text-center transition-colors ${
        connected ? 'bg-red-500/10 border-red-500/30' : 'bg-white/4 border-white/8'
      }`}>
        <div className="flex items-center justify-center gap-2 mb-3">
          {connected
            ? <HeartPulse className={`text-red-400 ${fresh ? 'animate-pulse' : ''}`} size={22} />
            : <Heart className="text-gray-600" size={22} />}
          <span className={`text-xs font-medium uppercase tracking-wide ${connected ? 'text-red-300' : 'text-gray-600'}`}>
            {connecting ? 'Connecting…' : connected ? 'Live' : 'Not connected'}
          </span>
        </div>
        <div className={`font-bold leading-none ${connected && hr.bpm ? 'text-red-400' : 'text-gray-700'}`}>
          <span className="text-6xl font-mono">{connected && hr.bpm != null ? hr.bpm : '––'}</span>
          <span className="text-lg font-semibold ml-1 text-gray-500">bpm</span>
        </div>
        {hr.deviceName && (
          <p className="text-gray-500 text-xs mt-4 flex items-center justify-center gap-1.5">
            {connected ? <BluetoothConnected size={12} className="text-cyan-400" /> : <Bluetooth size={12} />}
            {hr.deviceName}
          </p>
        )}
      </div>

      {hr.error && (
        <div className="bg-red-500/10 border border-red-500/25 rounded-2xl px-4 py-3 text-red-300 text-xs leading-relaxed">
          {hr.error}
        </div>
      )}

      {/* Actions */}
      <div className="space-y-2">
        {connected ? (
          <button
            onClick={() => hrStore.disconnect()}
            className="w-full flex items-center justify-center gap-2 bg-white/5 hover:bg-white/8 border border-white/10 text-gray-300 font-semibold py-3.5 rounded-2xl transition-colors text-sm"
          >
            <Bluetooth size={16} /> Disconnect
          </button>
        ) : (
          <button
            onClick={() => hrStore.connect()}
            disabled={connecting}
            className="w-full flex items-center justify-center gap-2 bg-cyan-500 hover:bg-cyan-400 disabled:opacity-50 text-white font-semibold py-3.5 rounded-2xl transition-colors text-sm shadow-lg shadow-cyan-500/20"
          >
            <Bluetooth size={16} />
            {connecting ? 'Connecting…' : hr.paired ? 'Reconnect belt' : 'Add heart-rate belt'}
          </button>
        )}

        {hr.paired && !connected && (
          <button
            onClick={() => hrStore.connect()}
            disabled={connecting}
            className="w-full flex items-center justify-center gap-2 text-gray-500 hover:text-white text-xs font-medium py-2 transition-colors"
          >
            Pick a different belt
          </button>
        )}

        {hr.paired && (
          <button
            onClick={() => hrStore.forget()}
            className="w-full flex items-center justify-center gap-2 text-gray-600 hover:text-red-400 text-xs font-medium py-2 transition-colors"
          >
            <Trash2 size={12} /> Forget belt
          </button>
        )}
      </div>

      {/* Auto-reconnect diagnostic */}
      {hr.paired && remembered !== null && (
        remembered ? (
          <div className="bg-green-500/8 border border-green-500/25 rounded-2xl px-4 py-3 text-xs leading-relaxed">
            <p className="text-green-300 font-medium flex items-center gap-1.5">
              <Check size={13} /> Auto-reconnect is on
            </p>
            <p className="text-green-200/70 mt-1">
              The browser remembers this belt, so it reconnects by itself after a reload
              (wear it and give it a couple of seconds).
            </p>
          </div>
        ) : (
          <div className="bg-amber-500/10 border border-amber-500/25 rounded-2xl px-4 py-3 text-xs leading-relaxed">
            <p className="text-amber-300 font-medium flex items-center gap-1.5">
              <X size={13} /> Auto-reconnect not available yet
            </p>
            <p className="text-amber-200/80 mt-1">
              The browser doesn't remember this belt for silent reconnect. To fix it once:
            </p>
            <ol className="text-amber-200/80 mt-1.5 ml-4 list-decimal space-y-0.5">
              <li>Make sure <code className="text-amber-100">brave://flags/#enable-web-bluetooth-new-permissions-backend</code> is <b>Enabled</b> and Brave was restarted.</li>
              <li>Tap <b>Forget belt</b>, then <b>Add heart-rate belt</b> and pick it again.</li>
              <li>Reload the page — it should reconnect on its own.</li>
            </ol>
          </div>
        )
      )}

      {/* Help */}
      <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-4 space-y-2 text-xs text-gray-500 leading-relaxed">
        <p className="text-gray-400 font-medium">How it works</p>
        <p>
          Moisten the strap and wear the belt on your chest, then tap <b>Add heart-rate belt</b> and
          pick it from the list (it's shown by its Bluetooth name, e.g. <i>HRM</i>).
        </p>
        <p>
          While it's connected during a workout, your <b>average, max and min heart rate</b> are
          saved automatically with that session.
        </p>
        <p className="text-gray-600">
          Only the Bluetooth side of the belt is used — ANT+ can't be read from a browser.
        </p>
      </div>
    </div>
  )
}
