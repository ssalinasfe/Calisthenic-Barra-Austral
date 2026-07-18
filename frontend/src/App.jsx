import { useState } from 'react'
import LockScreen from './components/LockScreen'
import Dashboard from './components/Dashboard'

export default function App() {
  const [token, setToken] = useState(() => localStorage.getItem('gym_token') || '')
  const [username, setUsername] = useState(() => localStorage.getItem('gym_user') || '')
  const [bgImage, setBgImage] = useState(() => {
    const stored = localStorage.getItem('gym_bg')
    return stored !== null ? stored : ''
  })

  function handleUnlock(t, u) {
    localStorage.setItem('gym_token', t)
    localStorage.setItem('gym_user', u || '')
    setToken(t)
    setUsername(u || '')
  }

  function handleLock() {
    localStorage.removeItem('gym_token')
    localStorage.removeItem('gym_user')
    setToken('')
    setUsername('')
  }

  function handleBgChange(url) {
    setBgImage(url)
    localStorage.setItem('gym_bg', url)
  }

  return (
    <>
      {bgImage && (
        <>
          <div className="backdrop-app" style={{ backgroundImage: `url(${bgImage})` }} />
          <div className="backdrop-overlay" />
        </>
      )}
      {!token ? (
        <LockScreen onUnlock={handleUnlock} />
      ) : (
        <Dashboard
          token={token}
          username={username}
          onLock={handleLock}
          bgImage={bgImage}
          onBgChange={handleBgChange}
        />
      )}
    </>
  )
}
