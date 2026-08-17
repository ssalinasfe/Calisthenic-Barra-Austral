import { useState } from 'react'
import { MapPin, Plus, Pencil, Trash2, Save, X, AlertTriangle } from 'lucide-react'
import { saveData } from '../api'

function newId() {
  return `loc_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 6)}`
}

export default function Locations({ allData, token, onDataChange }) {
  const [editing, setEditing] = useState(null)   // { id?, name, address }
  const [confirmDelete, setConfirmDelete] = useState(null)
  const [error, setError] = useState('')
  const [saving, setSaving] = useState(false)

  const locations = allData.locations || []

  function startNew() {
    setEditing({ name: '', address: '' })
    setError('')
  }

  function startEdit(loc) {
    setEditing({ ...loc })
    setError('')
  }

  async function handleSave() {
    const name = (editing.name || '').trim()
    if (!name) { setError('Name is required'); return }

    setSaving(true)
    try {
      const id = editing.id || newId()
      const newLoc = { id, name, address: (editing.address || '').trim() }
      const exists = locations.some(l => l.id === id)
      const newLocations = exists
        ? locations.map(l => (l.id === id ? newLoc : l))   // keep position
        : [...locations, newLoc]
      const newData = { ...allData, locations: newLocations }
      await saveData(token, newData)
      onDataChange(newData)
      setEditing(null)
    } catch {
      setError('Failed to save')
    }
    setSaving(false)
  }

  async function handleDelete(loc) {
    setSaving(true)
    try {
      // Clear locationId from any session that references this location
      const sessions = (allData.sessions || []).map(s =>
        s.locationId === loc.id ? { ...s, locationId: null } : s
      )
      const newData = {
        ...allData,
        sessions,
        locations: locations.filter(l => l.id !== loc.id),
      }
      await saveData(token, newData)
      onDataChange(newData)
      setConfirmDelete(null)
    } catch {
      setError('Failed to delete')
    }
    setSaving(false)
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2 text-gray-500 text-xs">
        <MapPin size={13} />
        <span>Places where you train</span>
      </div>

      {error && (
        <div className="bg-red-500/15 border border-red-500/30 rounded-xl px-4 py-2 text-red-300 text-sm">
          {error}
        </div>
      )}

      {locations.length === 0 && !editing && (
        <p className="text-gray-600 text-sm text-center py-6">No locations yet</p>
      )}

      <div className="space-y-2">
        {locations.map(loc => {
          const sessionCount = (allData.sessions || []).filter(s => s.locationId === loc.id).length
          return (
            <div key={loc.id} className="bg-white/5 border border-white/8 rounded-2xl px-4 py-3 flex items-center gap-3">
              <MapPin size={15} className="text-cyan-400 flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <p className="text-white text-sm font-medium truncate">{loc.name}</p>
                {loc.address && <p className="text-gray-600 text-xs truncate">{loc.address}</p>}
                <p className="text-gray-700 text-xs">{sessionCount} {sessionCount === 1 ? 'session' : 'sessions'}</p>
              </div>
              <button
                onClick={() => startEdit(loc)}
                className="text-gray-500 hover:text-cyan-400 p-2 rounded-lg transition-colors"
                title="Edit"
              >
                <Pencil size={14} />
              </button>
              <button
                onClick={() => setConfirmDelete(loc)}
                className="text-gray-500 hover:text-red-400 p-2 rounded-lg transition-colors"
                title="Delete"
              >
                <Trash2 size={14} />
              </button>
            </div>
          )
        })}
      </div>

      {/* Add new */}
      {!editing && (
        <button
          onClick={startNew}
          className="w-full flex items-center justify-center gap-2 py-3 border border-dashed border-white/15 rounded-2xl text-gray-500 hover:text-cyan-400 hover:border-cyan-500/40 transition-colors text-sm"
        >
          <Plus size={15} />
          Add location
        </button>
      )}

      {/* Editor */}
      {editing && (
        <div className="bg-white/5 border border-white/10 rounded-2xl p-4 space-y-3">
          <div className="flex items-center justify-between">
            <p className="text-white font-semibold text-sm">{editing.id ? 'Edit location' : 'New location'}</p>
            <button onClick={() => setEditing(null)} className="text-gray-500 hover:text-white p-1">
              <X size={16} />
            </button>
          </div>
          <div>
            <label className="text-gray-600 text-xs mb-1 block">Name</label>
            <input
              autoFocus
              value={editing.name}
              onChange={e => setEditing(s => ({ ...s, name: e.target.value }))}
              placeholder="Home gym"
              className="w-full bg-white/8 text-white rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-cyan-500"
            />
          </div>
          <div>
            <label className="text-gray-600 text-xs mb-1 block">Address (optional)</label>
            <input
              value={editing.address}
              onChange={e => setEditing(s => ({ ...s, address: e.target.value }))}
              placeholder="123 Main St"
              className="w-full bg-white/8 text-white rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-cyan-500"
            />
          </div>
          <button
            onClick={handleSave}
            disabled={saving}
            className="w-full flex items-center justify-center gap-2 bg-cyan-500 hover:bg-cyan-400 disabled:opacity-50 text-white font-semibold py-2.5 rounded-xl text-sm transition-colors"
          >
            <Save size={14} />
            {saving ? 'Saving...' : 'Save'}
          </button>
        </div>
      )}

      {/* Confirm delete */}
      {confirmDelete && (
        <div className="fixed inset-0 bg-black/75 flex items-end sm:items-center justify-center z-50 p-4">
          <div className="bg-gray-950 border border-white/10 rounded-2xl max-w-sm w-full p-5 space-y-3">
            <div className="flex items-center gap-2 text-red-300">
              <AlertTriangle size={16} />
              <p className="font-semibold text-sm">Delete this location?</p>
            </div>
            <p className="text-gray-500 text-xs">
              "{confirmDelete.name}" will be removed. Sessions that referenced it will keep their data but will no longer have a location.
            </p>
            <div className="flex gap-2">
              <button
                onClick={() => setConfirmDelete(null)}
                className="flex-1 py-2 rounded-xl border border-white/10 text-gray-400 text-sm hover:bg-white/5 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={() => handleDelete(confirmDelete)}
                disabled={saving}
                className="flex-1 py-2 rounded-xl bg-red-500 hover:bg-red-400 text-white text-sm font-semibold disabled:opacity-50"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
