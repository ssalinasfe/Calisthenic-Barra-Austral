import { useState, useEffect } from 'react'
import LockScreen from './components/LockScreen'
import Dashboard from './components/Dashboard'

// Old external preset URLs (rendered black due to hotlink protection) → the
// local copies now bundled in /public. Migrates a stale localStorage choice.
const BG_MIGRATION = {
  'https://w.wallhaven.cc/full/k9/wallhaven-k91jxd.jpg': '/anime-01.jpg',
  'https://w.wallhaven.cc/full/1k/wallhaven-1k7961.jpg': '/anime-02.png',
  'https://w.wallhaven.cc/full/vm/wallhaven-vmo98l.jpg': '/anime-03.jpg',
  'https://w.wallhaven.cc/full/q2/wallhaven-q2x655.jpg': '/anime-04.jpg',
  'https://w.wallhaven.cc/full/j5/wallhaven-j55k3p.jpg': '/anime-05.jpg',
  'https://w.wallhaven.cc/full/o3/wallhaven-o33qo5.jpg': '/anime-06.jpg',
  'https://w.wallhaven.cc/full/kx/wallhaven-kx7z7d.jpg': '/anime-07.jpg',
  'https://w.wallhaven.cc/full/ox/wallhaven-ox2q5p.jpg': '/anime-08.jpg',
  'https://images7.alphacoders.com/104/thumb-1920-1043655.jpg': '/anime-09.jpg',
  'https://images8.alphacoders.com/104/thumb-1920-1043653.jpg': '/anime-10.jpg',
  'https://images2.alphacoders.com/111/thumb-1920-1119258.jpg': '/anime-11.jpg',
  'https://images2.alphacoders.com/104/thumb-1920-1043656.jpg': '/anime-12.jpg',
  'https://images3.alphacoders.com/100/thumb-1920-1004612.jpg': '/anime-13.jpg',
  'https://images7.alphacoders.com/130/thumb-1920-1300550.jpg': '/anime-14.jpg',
}

// The v1 fitness set shipped as /fit-XX.jpg (landscape); the curated portrait
// set replaced it under /cw-XX.jpg so phones don't serve the stale cached file.
function migrateBg(url) {
  if (!url) return url
  if (BG_MIGRATION[url]) return BG_MIGRATION[url]
  const m = url.match(/^\/fit-(\d{2})\.jpg$/)
  if (m && Number(m[1]) >= 1 && Number(m[1]) <= 21) return `/cw-${m[1]}.jpg`
  return url
}

export default function App() {
  const [token, setToken] = useState(() => localStorage.getItem('gym_token') || '')
  const [username, setUsername] = useState(() => localStorage.getItem('gym_user') || '')
  const [bgImage, setBgImage] = useState(() => {
    const stored = localStorage.getItem('gym_bg')
    const migrated = migrateBg(stored)
    if (migrated !== stored && migrated) {
      localStorage.setItem('gym_bg', migrated)
      return migrated
    }
    return stored !== null ? stored : ''
  })

  // 'cover' when the image's orientation matches the screen's; 'blurfill' when
  // they differ (portrait wallpaper on a desktop, landscape one on a phone):
  // the full image is shown centered over a blurred copy that fills the edges.
  const [bgFit, setBgFit] = useState('cover')
  useEffect(() => {
    if (!bgImage) return
    let alive = true
    const img = new Image()
    const decide = () => {
      if (!alive || !img.naturalWidth) return
      const imgPortrait = img.naturalHeight > img.naturalWidth
      const vpPortrait = window.innerHeight > window.innerWidth
      // Phone (portrait viewport): ALWAYS fill the screen, never letterbox.
      // Desktop (landscape viewport): blur-fill only for portrait wallpapers.
      setBgFit(!vpPortrait && imgPortrait ? 'blurfill' : 'cover')
    }
    img.onload = decide
    img.src = bgImage
    window.addEventListener('resize', decide)
    return () => { alive = false; window.removeEventListener('resize', decide) }
  }, [bgImage])

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
          {bgFit === 'blurfill' && (
            <div className="backdrop-app backdrop-blur-fill" style={{ backgroundImage: `url(${bgImage})` }} />
          )}
          <div
            className={`backdrop-app ${bgFit === 'blurfill' ? 'backdrop-contain' : ''}`}
            style={{ backgroundImage: `url(${bgImage})` }}
          />
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
