import { MUSCLE_ES } from '../exercises'

// Renders an English muscle name with the Spanish translation in muted gray.
export default function Muscle({ name, size = 'sm' }) {
  const es = MUSCLE_ES[name]
  const sizeClass = size === 'xs' ? 'text-xs' : size === 'md' ? 'text-base' : 'text-sm'
  return (
    <span className={`${sizeClass} inline-flex items-baseline gap-1.5`}>
      <span className="text-white font-semibold">{name}</span>
      {es && es !== name && (
        <span className="text-gray-500 text-[0.85em]">{es}</span>
      )}
    </span>
  )
}
