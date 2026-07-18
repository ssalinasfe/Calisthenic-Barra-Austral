import { useState } from 'react'
import { format } from 'date-fns'
import { ChevronDown, ChevronUp, Clock, Pencil, Copy, Check, ExternalLink, MapPin, FileText, Image as ImageIcon, HeartPulse } from 'lucide-react'
import { setNotation, fmtDuration, totalReps, sessionCategories } from '../utils'
import {
  CATEGORY_LABEL, CATEGORY_PILL, comboCategoryStyle,
  isFullBody, groupLabel, FULL_BODY_STYLE,
} from '../exercises'
import SessionEditor from './SessionEditor'

function ExportPanel({ token }) {
  const [copied, setCopied] = useState(null)
  const base = window.location.origin

  const links = [
    { label: 'Full JSON',  desc: 'For Python / pandas',         url: `${base}/api/export/json?token=${token}` },
    { label: 'Flat JSON',  desc: 'Normalised set list',         url: `${base}/api/export/flat?token=${token}` },
    { label: 'CSV',        desc: 'Excel / Google Sheets',       url: `${base}/api/export/csv?token=${token}` },
  ]

  function copy(url, key) {
    navigator.clipboard.writeText(url)
    setCopied(key)
    setTimeout(() => setCopied(null), 2000)
  }

  return (
    <div className="bg-white/3 border border-white/8 rounded-2xl px-4 py-4 space-y-2">
      <p className="text-gray-500 text-xs font-medium mb-3">Export data</p>
      {links.map(({ label, desc, url }) => (
        <div key={label} className="flex items-center gap-3">
          <div className="flex-1 min-w-0">
            <p className="text-white text-xs font-medium">{label}</p>
            <p className="text-gray-600 text-xs">{desc}</p>
          </div>
          <a
            href={url}
            target="_blank"
            rel="noreferrer"
            className="text-gray-600 hover:text-cyan-400 p-1.5 rounded-lg transition-colors"
            title="Open"
          >
            <ExternalLink size={14} />
          </a>
          <button
            onClick={() => copy(url, label)}
            className="text-gray-600 hover:text-cyan-400 p-1.5 rounded-lg transition-colors"
            title="Copy URL"
          >
            {copied === label ? <Check size={14} className="text-green-400" /> : <Copy size={14} />}
          </button>
        </div>
      ))}
      <p className="text-gray-700 text-xs pt-1">
        Python: <code className="text-gray-500">requests.get(url).json()</code>
      </p>
    </div>
  )
}

function SessionRow({ session, locations, onEdit }) {
  const [expanded, setExpanded] = useState(false)
  const repsTotal = session.exercises.reduce((sum, ex) => sum + totalReps(ex.sets), 0)
  // Muscle groups for this session (user's selection, or inferred for legacy
  // sessions) → blended pill / "Full Body". Cardio excluded.
  const cats = sessionCategories(session)
  const label = groupLabel(cats)
  const fullBody = isFullBody(cats)
  const pillClass = cats.length === 1 ? (CATEGORY_PILL[cats[0]] || CATEGORY_PILL.Custom) : ''
  const pillStyle = fullBody
    ? FULL_BODY_STYLE
    : (cats.length > 1 ? comboCategoryStyle(cats, 'pill') : undefined)
  const location = session.locationId
    ? locations.find(l => l.id === session.locationId)
    : null
  const photoCount = (session.photos || []).length
  const hasNotes = !!(session.notes && session.notes.trim())
  const dateStr = format(new Date(session.startTime), "EEEE d MMM")
  const title = (session.title || '').trim()
  const showTitle = title && title.toLowerCase() !== dateStr.toLowerCase()

  return (
    <div className="bg-white/5 border border-white/8 rounded-2xl overflow-hidden">
      <div className="flex items-center gap-2 px-4 py-4">
        <button
          onClick={() => setExpanded(e => !e)}
          className="flex-1 text-left flex items-center gap-3 min-w-0"
        >
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              {label && (
                <span
                  className={`text-[10px] px-1.5 py-0.5 rounded-full border flex-shrink-0 ${pillClass}`}
                  style={pillStyle}
                >
                  {label}
                </span>
              )}
              <p className="text-white font-semibold text-sm truncate">{dateStr}</p>
            </div>
            {showTitle && (
              <p className="text-cyan-300 text-xs mt-0.5 truncate">{title}</p>
            )}
            <div className="flex items-center gap-3 mt-0.5 flex-wrap">
              <span className="text-gray-600 text-xs flex items-center gap-1">
                <Clock size={10} />
                {format(new Date(session.startTime), 'HH:mm')}
              </span>
              <span className="text-gray-600 text-xs">{fmtDuration(session.durationSeconds)}</span>
              <span className="text-gray-600 text-xs">{session.exercises.length} ex</span>
              <span className="text-gray-600 text-xs">{repsTotal} reps</span>
              {session.avgHr != null && (
                <span className="text-red-400/80 text-xs flex items-center gap-1">
                  <HeartPulse size={10} />{session.avgHr} bpm
                </span>
              )}
              {location && (
                <span className="text-gray-600 text-xs flex items-center gap-1">
                  <MapPin size={10} />{location.name}
                </span>
              )}
              {photoCount > 0 && (
                <span className="text-gray-600 text-xs flex items-center gap-1">
                  <ImageIcon size={10} />{photoCount}
                </span>
              )}
              {hasNotes && (
                <span className="text-gray-600 text-xs flex items-center gap-1">
                  <FileText size={10} />notes
                </span>
              )}
            </div>
          </div>
          {expanded
            ? <ChevronUp size={15} className="text-gray-700 flex-shrink-0" />
            : <ChevronDown size={15} className="text-gray-700 flex-shrink-0" />}
        </button>

        <button
          onClick={() => onEdit(session)}
          className="text-gray-600 hover:text-cyan-400 p-2 rounded-lg transition-colors flex-shrink-0"
          title="Edit session"
        >
          <Pencil size={15} />
        </button>
      </div>

      {expanded && (
        <div className="px-4 pb-4 pt-2 space-y-2 border-t border-white/6 animate-fadeIn">
          {session.exercises.map((ex, i) => {
            const cat = ex.category || 'Custom'
            return (
              <div key={`${ex.name}_${i}`} className="flex items-center justify-between gap-2">
                <div className="flex items-center gap-2 flex-1 min-w-0">
                  <span className={`text-[10px] px-1.5 py-0.5 rounded border flex-shrink-0 ${CATEGORY_PILL[cat] || CATEGORY_PILL.Custom}`}>
                    {CATEGORY_LABEL[cat] || cat}
                  </span>
                  <span className="text-gray-400 text-sm truncate">{ex.name}</span>
                </div>
                <div className="flex items-center gap-3 flex-shrink-0">
                  <span className="text-cyan-400 font-mono text-sm font-semibold">
                    {setNotation(ex.sets)}
                  </span>
                  <span className="text-gray-600 text-xs w-14 text-right">
                    {totalReps(ex.sets)} reps
                  </span>
                </div>
              </div>
            )
          })}
          {hasNotes && (
            <div className="mt-2 bg-white/3 border border-white/8 rounded-xl px-3 py-2 text-gray-400 text-xs whitespace-pre-wrap">
              {session.notes}
            </div>
          )}
        </div>
      )}
    </div>
  )
}

export default function History({ allData, token, onDataChange }) {
  const [editing, setEditing] = useState(null)
  const sessions = [...(allData.sessions || [])].reverse()
  const locations = allData.locations || []

  if (sessions.length === 0) {
    return (
      <div className="text-center py-20">
        <p className="text-gray-600 text-sm">No sessions recorded yet</p>
      </div>
    )
  }

  return (
    <>
      <div className="space-y-3">
        <ExportPanel token={token} />
        <p className="text-gray-700 text-xs font-medium">
          {sessions.length} {sessions.length === 1 ? 'session' : 'sessions'} recorded
        </p>
        {sessions.map(s => (
          <SessionRow key={s.id} session={s} locations={locations} onEdit={setEditing} />
        ))}
      </div>

      {editing && (
        <SessionEditor
          session={editing}
          allData={allData}
          token={token}
          onSave={newData => { onDataChange(newData); setEditing(null) }}
          onClose={() => setEditing(null)}
        />
      )}
    </>
  )
}
