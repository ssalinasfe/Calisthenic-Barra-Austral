import { useState } from 'react'
import { ChevronRight, ListChecks, MapPin, BookOpen, TrendingUp, Activity, ArrowLeft } from 'lucide-react'
import Routines from './Routines'
import Locations from './Locations'
import Documentation from './Documentation'
import ExerciseProgress from './ExerciseProgress'
import MuscleStats from './MuscleStats'

const ITEMS = [
  { id: 'routines',  label: 'Routines',      desc: 'Build training plans + schedule',  Icon: ListChecks },
  { id: 'locations', label: 'Locations',     desc: 'Where you train',                  Icon: MapPin },
  { id: 'docs',      label: 'Documentation', desc: 'Groups, exercises, muscles',       Icon: BookOpen },
  { id: 'progress',  label: 'Progress',      desc: 'Per exercise charts',              Icon: TrendingUp },
  { id: 'muscles',   label: 'Muscles',       desc: 'By session, week, month',          Icon: Activity },
]

export default function More({ allData, token, onDataChange }) {
  const [section, setSection] = useState(null)

  if (section) {
    const item = ITEMS.find(i => i.id === section)
    return (
      <div className="space-y-3">
        <button
          onClick={() => setSection(null)}
          className="flex items-center gap-2 text-gray-500 hover:text-white text-sm transition-colors"
        >
          <ArrowLeft size={14} />
          Back to More
        </button>
        <h2 className="text-white font-bold text-base">{item?.label}</h2>
        {section === 'routines'  && <Routines allData={allData} token={token} onDataChange={onDataChange} />}
        {section === 'locations' && <Locations allData={allData} token={token} onDataChange={onDataChange} />}
        {section === 'docs'      && <Documentation />}
        {section === 'progress'  && <ExerciseProgress allData={allData} />}
        {section === 'muscles'   && <MuscleStats allData={allData} />}
      </div>
    )
  }

  return (
    <div className="space-y-2">
      {ITEMS.map(({ id, label, desc, Icon }) => (
        <button
          key={id}
          onClick={() => setSection(id)}
          className="w-full bg-white/5 border border-white/8 rounded-2xl px-4 py-4 flex items-center gap-3 hover:bg-white/8 transition-colors text-left"
        >
          <div className="w-10 h-10 rounded-xl bg-cyan-500/15 flex items-center justify-center flex-shrink-0">
            <Icon size={18} className="text-cyan-400" />
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-white text-sm font-semibold">{label}</p>
            <p className="text-gray-600 text-xs">{desc}</p>
          </div>
          <ChevronRight size={16} className="text-gray-600 flex-shrink-0" />
        </button>
      ))}
    </div>
  )
}
