import { useState, useMemo } from 'react'
import { ChevronDown, ChevronRight, BookOpen } from 'lucide-react'
import { EXERCISES, CATEGORY_LABEL, CATEGORY_LABEL_ES, CATEGORY_PILL, MUSCLE_ES } from '../exercises'
import Muscle from './Muscle'

function MuscleChip({ name }) {
  const es = MUSCLE_ES[name]
  return (
    <span className="inline-flex items-baseline gap-1.5 bg-white/5 border border-white/8 rounded-full px-2.5 py-1">
      <span className="text-white text-xs font-semibold">{name}</span>
      {es && es !== name && (
        <span className="text-gray-500 text-[10px]">{es}</span>
      )}
    </span>
  )
}

export default function Documentation() {
  const [mode, setMode] = useState('group')   // 'group' | 'exercise'
  const [openGroup, setOpenGroup] = useState(null)
  const [openExercise, setOpenExercise] = useState(null)

  const groups = useMemo(() => {
    const map = {}
    EXERCISES.forEach(ex => {
      if (!map[ex.category]) map[ex.category] = { exercises: [], muscles: new Set() }
      map[ex.category].exercises.push(ex)
      ex.muscles.forEach(m => map[ex.category].muscles.add(m))
    })
    return Object.entries(map).map(([cat, data]) => ({
      category: cat,
      exercises: data.exercises,
      muscles: [...data.muscles].sort((a, b) => a.localeCompare(b)),
    }))
  }, [])

  const sortedExercises = useMemo(
    () => [...EXERCISES].sort((a, b) => a.name.localeCompare(b.name)),
    []
  )

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2 text-gray-500 text-xs mb-2">
        <BookOpen size={13} />
        <span>Reference for groups, exercises and muscles</span>
      </div>

      {/* Mode switch */}
      <div className="flex bg-white/5 border border-white/8 rounded-xl p-1">
        {[
          { id: 'group',    label: 'By group' },
          { id: 'exercise', label: 'By exercise' },
        ].map(t => (
          <button
            key={t.id}
            onClick={() => setMode(t.id)}
            className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${
              mode === t.id ? 'bg-cyan-500 text-white' : 'text-gray-500 hover:text-white'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {/* By group */}
      {mode === 'group' && (
        <div className="space-y-2">
          {groups.map(g => {
            const open = openGroup === g.category
            const pill = CATEGORY_PILL[g.category] || CATEGORY_PILL.Custom
            return (
              <div key={g.category} className="bg-white/5 border border-white/8 rounded-2xl overflow-hidden">
                <button
                  onClick={() => setOpenGroup(open ? null : g.category)}
                  className="w-full flex items-center gap-3 px-4 py-3 text-left"
                >
                  <span className={`text-xs px-2 py-0.5 rounded-full border ${pill}`}>
                    {CATEGORY_LABEL[g.category] || g.category}
                  </span>
                  <span className="text-gray-500 text-xs">{CATEGORY_LABEL_ES[g.category]}</span>
                  <span className="text-gray-600 text-xs ml-auto">
                    {g.exercises.length} ex · {g.muscles.length} muscles
                  </span>
                  {open
                    ? <ChevronDown size={16} className="text-gray-500" />
                    : <ChevronRight size={16} className="text-gray-500" />}
                </button>
                {open && (
                  <div className="px-4 pb-4 border-t border-white/6 animate-fadeIn space-y-3 pt-3">
                    <div>
                      <p className="text-gray-600 text-[10px] uppercase font-semibold mb-2">Muscles trained</p>
                      <div className="flex flex-wrap gap-1.5">
                        {g.muscles.map(m => <MuscleChip key={m} name={m} />)}
                      </div>
                    </div>
                    <div>
                      <p className="text-gray-600 text-[10px] uppercase font-semibold mb-2">Exercises</p>
                      <ul className="space-y-1">
                        {g.exercises.map(ex => (
                          <li key={ex.id} className="text-sm">
                            <span className="text-white">{ex.name}</span>
                            {ex.es && <span className="text-gray-500 text-xs ml-2">{ex.es}</span>}
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                )}
              </div>
            )
          })}
        </div>
      )}

      {/* By exercise */}
      {mode === 'exercise' && (
        <div className="space-y-2">
          {sortedExercises.map(ex => {
            const open = openExercise === ex.id
            const pill = CATEGORY_PILL[ex.category] || CATEGORY_PILL.Custom
            return (
              <div key={ex.id} className="bg-white/5 border border-white/8 rounded-2xl overflow-hidden">
                <button
                  onClick={() => setOpenExercise(open ? null : ex.id)}
                  className="w-full flex items-center gap-2 px-4 py-3 text-left"
                >
                  <span className={`text-[10px] px-1.5 py-0.5 rounded-full border flex-shrink-0 ${pill}`}>
                    {CATEGORY_LABEL[ex.category] || ex.category}
                  </span>
                  <div className="flex-1 min-w-0">
                    <p className="text-white text-sm font-medium truncate">{ex.name}</p>
                    {ex.es && <p className="text-gray-500 text-xs truncate">{ex.es}</p>}
                  </div>
                  {open
                    ? <ChevronDown size={15} className="text-gray-500 flex-shrink-0" />
                    : <ChevronRight size={15} className="text-gray-500 flex-shrink-0" />}
                </button>
                {open && (
                  <div className="px-4 pb-4 border-t border-white/6 animate-fadeIn pt-3">
                    <p className="text-gray-600 text-[10px] uppercase font-semibold mb-2">Muscles trained</p>
                    <div className="flex flex-wrap gap-1.5">
                      {ex.muscles.map(m => <MuscleChip key={m} name={m} />)}
                    </div>
                  </div>
                )}
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}
