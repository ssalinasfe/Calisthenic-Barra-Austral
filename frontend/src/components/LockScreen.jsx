import { useState } from 'react'
import { login } from '../api'
import { Lock, User, PersonStanding, ShieldOff } from 'lucide-react'

export default function LockScreen({ onUnlock }) {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [locked, setLocked] = useState(false)

  async function handleSubmit(e) {
    e.preventDefault()
    if (!password || !username || locked) return
    setLoading(true)
    setError('')
    try {
      const { token, username: u } = await login(username.trim(), password)
      onUnlock(token, u)
    } catch (err) {
      if (err.status === 423) setLocked(true)
      else setError('Invalid credentials')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="w-full max-w-sm animate-fadeIn">
        <div className="text-center mb-8">
          <div className={`inline-flex items-center justify-center w-20 h-20 rounded-2xl mb-4 overflow-hidden ${
            locked
              ? 'bg-red-500/20 border border-red-500/30'
              : 'bg-black border border-white/10'
          }`}>
            {locked
              ? <ShieldOff className="text-red-400" size={32} />
              : <img src="/logo.png" alt="Barra Austral" className="w-full h-full object-contain" />
            }
          </div>
          <h1 className="text-white text-2xl font-bold tracking-tight">Barra Austral</h1>
          <p className="text-gray-500 text-sm mt-1">
            {locked ? 'Access blocked' : 'Sign in to continue'}
          </p>
        </div>

        {locked ? (
          <div className="bg-red-900/20 border border-red-500/30 rounded-2xl p-6 text-center shadow-2xl">
            <p className="text-red-400 font-semibold text-sm mb-2">Too many failed attempts</p>
            <p className="text-gray-400 text-sm leading-relaxed">
              The app is locked.<br />
              Restart the Docker container to continue.
            </p>
            <p className="text-gray-600 text-xs mt-4 font-mono">docker compose restart</p>
          </div>
        ) : (
          <form
            onSubmit={handleSubmit}
            className="bg-white/5 border border-white/10 rounded-2xl p-6 shadow-2xl backdrop-blur-sm space-y-3"
          >
            <div className="relative">
              <User size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500" />
              <input
                type="text"
                value={username}
                onChange={e => setUsername(e.target.value)}
                placeholder="Username"
                autoCapitalize="off"
                autoCorrect="off"
                className="w-full bg-white/5 border border-white/10 text-white rounded-xl pl-9 pr-4 py-3 outline-none focus:border-cyan-500 focus:ring-1 focus:ring-cyan-500/50 transition-colors placeholder-gray-600 text-sm"
                autoFocus
              />
            </div>

            <div className="relative">
              <Lock size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500" />
              <input
                type="password"
                value={password}
                onChange={e => setPassword(e.target.value)}
                placeholder="Password"
                className="w-full bg-white/5 border border-white/10 text-white rounded-xl pl-9 pr-4 py-3 outline-none focus:border-cyan-500 focus:ring-1 focus:ring-cyan-500/50 transition-colors placeholder-gray-600 text-sm"
              />
            </div>

            {error && (
              <p className="text-red-400 text-sm text-center animate-fadeIn">{error}</p>
            )}

            <button
              type="submit"
              disabled={loading || !password || !username}
              className="w-full bg-cyan-500 hover:bg-cyan-400 disabled:opacity-40 disabled:cursor-not-allowed text-white font-semibold py-3 rounded-xl transition-colors text-sm"
            >
              {loading ? 'Signing in...' : 'Sign in'}
            </button>

            <p className="text-gray-600 text-xs text-center pt-2">
              Try the demo: <span className="text-gray-400 font-mono">demo</span> / <span className="text-gray-400 font-mono">1234</span>
            </p>
          </form>
        )}
      </div>
    </div>
  )
}
