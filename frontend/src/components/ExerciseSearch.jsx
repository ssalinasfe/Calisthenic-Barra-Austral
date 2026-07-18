import { useState, useRef } from 'react'
import { EXERCISES, CATEGORY_LABEL, CATEGORY_PILL } from '../exercises'
import { Search, Plus } from 'lucide-react'

export default function ExerciseSearch({ onAdd, addedExercises }) {
  const [query, setQuery] = useState('')
  const [open, setOpen] = useState(false)
  const inputRef = useRef(null)

  const addedNames = new Set(addedExercises.map(e => e.name))

  const filtered = query.trim().length >= 1
    ? EXERCISES.filter(ex =>
        ex.name.toLowerCase().includes(query.toLowerCase()) ||
        (ex.es && ex.es.toLowerCase().includes(query.toLowerCase())) ||
        ex.category.toLowerCase().includes(query.toLowerCase())
      ).slice(0, 8)
    : []

  const showCustom = query.trim().length >= 2 && !EXERCISES.some(
    ex => ex.name.toLowerCase() === query.trim().toLowerCase()
  ) && !addedNames.has(query.trim())

  function handleSelect(ex) {
    onAdd(ex)
    setQuery('')
    setOpen(false)
    inputRef.current?.blur()
  }

  function handleCustom() {
    handleSelect({
      id: `custom_${Date.now()}`,
      name: query.trim(),
      category: 'Custom',
    })
  }

  return (
    <div className="relative">
      <div className="flex items-center bg-white/5 border border-white/10 rounded-xl px-4 py-3 gap-3 focus-within:border-cyan-500/70 transition-colors">
        <Search size={17} className="text-gray-500 flex-shrink-0" />
        <input
          ref={inputRef}
          type="text"
          value={query}
          onChange={e => { setQuery(e.target.value); setOpen(true) }}
          onFocus={() => setOpen(true)}
          onBlur={() => setTimeout(() => setOpen(false), 180)}
          placeholder="Search exercise..."
          className="flex-1 bg-transparent text-white placeholder-gray-600 outline-none text-sm"
        />
      </div>

      {open && (filtered.length > 0 || showCustom) && (
        <div className="absolute top-full mt-2 left-0 right-0 bg-gray-900 border border-white/10 rounded-xl shadow-2xl z-50 overflow-hidden animate-fadeIn">
          {filtered.map(ex => {
            const alreadyAdded = addedNames.has(ex.name)
            return (
              <button
                key={ex.id}
                onClick={() => handleSelect(ex)}
                className="w-full text-left px-4 py-3 hover:bg-white/5 transition-colors flex items-center gap-3"
              >
                <div className="flex-1 min-w-0">
                  <span className="text-white text-sm font-medium">{ex.name}</span>
                  {ex.es && (
                    <span className="text-gray-500 text-xs ml-2">{ex.es}</span>
                  )}
                  {alreadyAdded && (
                    <span className="text-amber-400 text-xs ml-2">· already added</span>
                  )}
                </div>
                <span className={`text-xs px-2 py-0.5 rounded-full border flex-shrink-0 ${CATEGORY_PILL[ex.category] || CATEGORY_PILL.Custom}`}>
                  {CATEGORY_LABEL[ex.category] || ex.category}
                </span>
              </button>
            )
          })}

          {showCustom && (
            <button
              onClick={handleCustom}
              className="w-full text-left px-4 py-3 hover:bg-white/5 transition-colors flex items-center gap-3 border-t border-white/5"
            >
              <Plus size={15} className="text-cyan-400 flex-shrink-0" />
              <span className="text-cyan-300 text-sm">Add &ldquo;{query.trim()}&rdquo;</span>
              <span className="text-xs text-cyan-500 bg-cyan-500/10 px-2 py-0.5 rounded-full ml-auto">
                custom
              </span>
            </button>
          )}
        </div>
      )}
    </div>
  )
}
