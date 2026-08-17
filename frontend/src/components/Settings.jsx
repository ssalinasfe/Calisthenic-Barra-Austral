import { useState } from 'react'
import { X, Image, Trash2, Smartphone } from 'lucide-react'
import { useWakeLock, wakeLockStore } from '../wakeLock'

// Todos los fondos viven en /public (locales): las URLs externas de wallhaven/
// alphacoders salían NEGRAS por su protección anti-hotlink (bloquean el Referer
// de otros sitios), así que se descargaron una vez y se sirven desde la app.
const range = (prefix, n, ext = 'jpg', pad = 2) =>
  Array.from({ length: n }, (_, i) => `/${prefix}${String(i + 1).padStart(pad, '0')}.${ext}`)

const SECTIONS = [
  {
    // 21 fotos verticales curadas (calistenia/bodyweight, sin pesas)
    label: 'Fitness · Calistenia',
    urls: range('cw-', 21),
  },
  {
    // Paisajes y ciudades de Chile (Wikimedia Commons), apaisadas sin recortar:
    // en el celu se adaptan con el modo blur-fill del App.
    label: 'Chile',
    urls: range('chile-', 18),
  },
  {
    label: 'Calistenia',
    urls: [
      '/cal-wp12050262.jpg', '/cal-wp12050265.jpg', '/cal-wp12050287.jpg',
      '/cal-wp12050429.jpg', '/cal-wp12050440.jpg', '/cal-wp4896705.jpg',
      '/cal-wp4896741.jpg',  '/cal-wp4896800.jpg',  '/cal-wp4896805.jpg',
      '/cal-wp4896808.jpg',  '/cal-wp4896817.jpg',  '/cal-wp5734384.jpg',
      '/cal-wp5734442.jpg',  '/cal-wp6714534.jpg',  '/cal-wp7932827.jpg',
      '/cal-wp8385902.jpg',  '/cal-wp8385927.jpg',  '/cal-wp8386397.jpg',
    ],
  },
  {
    label: 'Zero Two',
    urls: [
      '/zt-1.jpg', '/zt-2.webp', '/zt-3.jpg', '/zt-4.jpg',
      '/zt-5.png', '/zt-6.jpg', '/zt-7.jpg', '/zt-8-clean.jpg',
    ],
  },
  {
    label: 'Anime gym',
    urls: [
      '/wallpaper-default.jpg',
      '/anime-01.jpg', '/anime-02.png', '/anime-03.jpg', '/anime-04.jpg',
      '/anime-05.jpg', '/anime-06.jpg', '/anime-07.jpg', '/anime-08.jpg',
      '/anime-09.jpg', '/anime-10.jpg', '/anime-11.jpg', '/anime-12.jpg',
      '/anime-13.jpg', '/anime-14.jpg',
    ],
  },
]

export default function Settings({ bgImage, onBgChange, onClose }) {
  const [urlInput, setUrlInput] = useState(bgImage)
  const wl = useWakeLock()
  const wlOn = wl.enabled && wl.supported

  function apply(url) {
    setUrlInput(url)
    onBgChange(url)
  }

  return (
    <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4 animate-fadeIn">
      <div className="bg-gray-950 border border-white/10 rounded-2xl w-full max-w-2xl shadow-2xl">
        <div className="flex items-center justify-between px-5 py-4 border-b border-white/10">
          <h2 className="text-white font-bold text-base">Settings</h2>
          <button onClick={onClose} className="text-gray-600 hover:text-white p-1.5 rounded-lg transition-colors">
            <X size={18} />
          </button>
        </div>

        <div className="px-5 py-5 space-y-4">
          <div>
            <label className="flex items-center gap-2 text-sm text-gray-300 font-medium mb-3">
              <Image size={15} />
              Background image
            </label>

            <div className="flex gap-2 mb-3">
              <input
                type="url"
                value={urlInput}
                onChange={e => setUrlInput(e.target.value)}
                placeholder="Image URL..."
                className="flex-1 bg-white/5 border border-white/10 text-white rounded-xl px-3 py-2 text-sm outline-none focus:border-cyan-500 transition-colors placeholder-gray-700"
              />
              <button
                onClick={() => apply(urlInput)}
                className="bg-cyan-500 hover:bg-cyan-400 text-white px-4 py-2 rounded-xl text-sm font-medium transition-colors flex-shrink-0"
              >
                Apply
              </button>
            </div>

            <div className="max-h-96 overflow-y-auto pr-1 space-y-3">
              {SECTIONS.map(section => (
                <div key={section.label}>
                  <p className="text-[10px] text-gray-500 font-semibold uppercase tracking-wide mb-1.5">
                    {section.label}
                  </p>
                  <div className="grid grid-cols-5 gap-1.5">
                    {section.urls.map((url, i) => (
                      <button
                        key={url}
                        onClick={() => apply(url)}
                        title={`${section.label} ${i + 1}`}
                        className={`aspect-[3/4] rounded-lg overflow-hidden border-2 transition-all hover:scale-105 hover:z-10 relative ${
                          bgImage === url ? 'border-cyan-500 ring-1 ring-cyan-500/50' : 'border-white/10'
                        }`}
                        style={{ backgroundImage: `url(${url})`, backgroundSize: 'cover', backgroundPosition: 'center' }}
                      />
                    ))}
                  </div>
                </div>
              ))}
            </div>

            {bgImage && (
              <button
                onClick={() => apply('')}
                className="mt-3 flex items-center gap-1.5 text-xs text-red-400 hover:text-red-300 transition-colors"
              >
                <Trash2 size={12} />
                Remove background image
              </button>
            )}
          </div>

          <div className="border-t border-white/10 pt-4">
            <label className="flex items-center gap-2 text-sm text-gray-300 font-medium mb-3">
              <Smartphone size={15} />
              Pantalla
            </label>
            <button
              onClick={() => wakeLockStore.toggle()}
              disabled={!wl.supported}
              className={`w-full flex items-center justify-between gap-3 bg-white/5 border rounded-xl px-3 py-2.5 text-left transition-colors ${
                wl.supported ? 'border-white/10 hover:border-white/20' : 'border-white/5 opacity-60 cursor-not-allowed'
              }`}
            >
              <span className="min-w-0">
                <span className="block text-sm text-white">Mantener la pantalla encendida</span>
                <span className="block text-xs text-gray-500 mt-0.5">
                  {wl.supported
                    ? 'Durante la sesión, para que los cronómetros y los pitos no se atrasen'
                    : 'Este navegador no soporta Wake Lock — la app funciona igual'}
                </span>
              </span>
              <span className={`w-10 h-6 rounded-full flex-shrink-0 relative transition-colors ${wlOn ? 'bg-emerald-500' : 'bg-white/15'}`}>
                <span className={`absolute top-0.5 w-5 h-5 rounded-full bg-white transition-all ${wlOn ? 'left-[18px]' : 'left-0.5'}`} />
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
