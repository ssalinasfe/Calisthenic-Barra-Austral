import { useState } from 'react'
import { X, Image, Trash2 } from 'lucide-react'

// Row 1-2: Zero Two (descargadas localmente)
// Row 3-4: Anime gym / calisthenics
const PRESETS = [
  // — Zero Two —
  '/zt-1.jpg',
  '/zt-2.webp',
  '/zt-3.jpg',
  '/zt-4.jpg',
  '/zt-5.png',
  '/zt-6.jpg',
  '/zt-7.jpg',
  '/zt-8-clean.jpg',

  // — Anime gym / calisthenics —
  '/wallpaper-default.jpg',
  'https://w.wallhaven.cc/full/k9/wallhaven-k91jxd.jpg',
  'https://w.wallhaven.cc/full/1k/wallhaven-1k7961.jpg',
  'https://w.wallhaven.cc/full/vm/wallhaven-vmo98l.jpg',
  'https://w.wallhaven.cc/full/q2/wallhaven-q2x655.jpg',
  'https://w.wallhaven.cc/full/j5/wallhaven-j55k3p.jpg',
  'https://w.wallhaven.cc/full/o3/wallhaven-o33qo5.jpg',
  'https://w.wallhaven.cc/full/kx/wallhaven-kx7z7d.jpg',
  'https://w.wallhaven.cc/full/ox/wallhaven-ox2q5p.jpg',
  'https://images7.alphacoders.com/104/thumb-1920-1043655.jpg',
  'https://images8.alphacoders.com/104/thumb-1920-1043653.jpg',
  'https://images2.alphacoders.com/111/thumb-1920-1119258.jpg',
  'https://images2.alphacoders.com/104/thumb-1920-1043656.jpg',
  'https://images3.alphacoders.com/100/thumb-1920-1004612.jpg',
  'https://images7.alphacoders.com/130/thumb-1920-1300550.jpg',
]

export default function Settings({ bgImage, onBgChange, onClose }) {
  const [urlInput, setUrlInput] = useState(bgImage)

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

            <div className="grid grid-cols-6 gap-1.5 max-h-72 overflow-y-auto pr-1">
              {PRESETS.map((url, i) => (
                <button
                  key={i}
                  onClick={() => apply(url)}
                  title={i < 8 ? `Zero Two ${i + 1}` : `Anime gym ${i - 7}`}
                  className={`aspect-video rounded-lg overflow-hidden border-2 transition-all hover:scale-105 hover:z-10 relative ${
                    bgImage === url ? 'border-cyan-500 ring-1 ring-cyan-500/50' : 'border-white/10'
                  }`}
                  style={{ backgroundImage: `url(${url})`, backgroundSize: 'cover', backgroundPosition: 'center top' }}
                />
              ))}
            </div>

            <p className="text-xs text-gray-600 mt-2">Rows 1-2: Zero Two · Rows 3-4: Anime gym</p>

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
        </div>
      </div>
    </div>
  )
}
