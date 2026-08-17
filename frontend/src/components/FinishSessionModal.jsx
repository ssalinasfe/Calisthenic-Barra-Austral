import { useRef, useState } from 'react'
import { Camera, Image as ImageIcon, Check, X, Square } from 'lucide-react'
import { uploadPhoto, deletePhoto, photoUrl } from '../api'

export default function FinishSessionModal({ token, onCancel, onConfirm }) {
  const cameraRef = useRef(null)
  const galleryRef = useRef(null)
  const [photos, setPhotos] = useState([])     // filenames
  const [uploading, setUploading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  async function handleFiles(files) {
    if (!files?.length) return
    setUploading(true)
    setError('')
    try {
      const out = []
      for (const f of files) {
        const { filename } = await uploadPhoto(token, f)
        out.push(filename)
      }
      setPhotos(p => [...p, ...out])
    } catch {
      setError('Upload failed')
    }
    setUploading(false)
  }

  function removePhoto(filename) {
    setPhotos(p => p.filter(n => n !== filename))
    deletePhoto(token, filename).catch(() => { /* leave file orphaned */ })
  }

  // Skip/Cancel drop the uploaded photos from the session, so delete the files
  // too — otherwise they linger on disk unreferenced.
  function discardUploads(next) {
    photos.forEach(p => deletePhoto(token, p).catch(() => { /* best effort */ }))
    next()
  }

  async function finish() {
    setSaving(true)
    try { await onConfirm(photos) } finally { setSaving(false) }
  }

  return (
    <div className="fixed inset-0 bg-black/80 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4 animate-fadeIn">
      <div className="bg-gray-950 border border-white/10 rounded-t-3xl sm:rounded-2xl w-full sm:max-w-md shadow-2xl">

        <div className="flex items-center justify-between px-5 py-4 border-b border-white/10">
          <h2 className="text-white font-bold text-base">Finish session</h2>
          <button onClick={() => discardUploads(onCancel)} className="text-gray-600 hover:text-white p-2 rounded-lg transition-colors">
            <X size={18} />
          </button>
        </div>

        <div className="px-5 py-5 space-y-4">
          <p className="text-gray-400 text-sm">Add a photo to remember this session (optional).</p>

          {photos.length > 0 && (
            <div className="grid grid-cols-3 gap-2">
              {photos.map(p => (
                <div key={p} className="relative aspect-square bg-white/5 rounded-lg overflow-hidden">
                  <img src={photoUrl(token, p)} alt="" className="w-full h-full object-cover" loading="lazy" />
                  <button
                    onClick={() => removePhoto(p)}
                    className="absolute top-1 right-1 bg-black/70 text-white rounded-full p-1 hover:bg-red-500/90 transition-colors"
                    title="Remove"
                  >
                    <X size={11} />
                  </button>
                </div>
              ))}
            </div>
          )}

          <input
            ref={cameraRef}
            type="file"
            accept="image/*"
            capture="environment"
            multiple
            onChange={e => { handleFiles([...e.target.files]); e.target.value = '' }}
            className="hidden"
          />
          <input
            ref={galleryRef}
            type="file"
            accept="image/*"
            multiple
            onChange={e => { handleFiles([...e.target.files]); e.target.value = '' }}
            className="hidden"
          />

          <div className="grid grid-cols-2 gap-2">
            <button
              onClick={() => cameraRef.current?.click()}
              disabled={uploading}
              className="flex items-center justify-center gap-2 bg-white/5 border border-white/10 text-white py-3 rounded-xl text-sm font-medium hover:bg-white/8 disabled:opacity-50 transition-colors"
            >
              <Camera size={15} />
              {uploading ? 'Uploading…' : 'Take photo'}
            </button>
            <button
              onClick={() => galleryRef.current?.click()}
              disabled={uploading}
              className="flex items-center justify-center gap-2 bg-white/5 border border-white/10 text-white py-3 rounded-xl text-sm font-medium hover:bg-white/8 disabled:opacity-50 transition-colors"
            >
              <ImageIcon size={15} />
              From gallery
            </button>
          </div>

          {error && (
            <p className="text-red-400 text-xs text-center">{error}</p>
          )}

          <div className="grid grid-cols-2 gap-2 pt-2">
            <button
              onClick={() => discardUploads(() => onConfirm([]))}
              disabled={saving}
              className="flex items-center justify-center gap-2 bg-white/5 border border-white/10 text-gray-300 py-3 rounded-xl text-sm font-medium hover:bg-white/8 disabled:opacity-50 transition-colors"
            >
              Skip
            </button>
            <button
              onClick={finish}
              disabled={saving || uploading}
              className="flex items-center justify-center gap-2 bg-green-500 hover:bg-green-400 disabled:opacity-50 text-white font-semibold py-3 rounded-xl text-sm transition-colors"
            >
              <Check size={15} />
              {saving ? 'Saving…' : (photos.length ? `Save with ${photos.length} photo${photos.length===1?'':'s'}` : 'Save session')}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
