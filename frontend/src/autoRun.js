// Circuit auto-pilot ("modo automático"): runs a timed routine hands-free.
// Work interval ends → beep → the set stops itself → rest runs → beep → the
// next set starts on its own. Built for weighted-cardio circuits like the
// kettlebell "Misión Rusa" (10 exercises, 40s work / 20s rest, 2 rounds).
//
// The running set and the rest timer are state INSIDE each ExerciseCard, so
// this module is the only place that sees every card at once. It has two jobs:
//   1. Always (auto on or off): only ONE rest may run at a time — starting a
//      set anywhere finalises the rest of every other card.
//   2. Auto on: chain set → rest → next set, rotating through supersets.
//
// Same external-store pattern as sound.js. NOT persisted: it's a per-workout
// mode, and defaulting to on after a reload would start timers by surprise.

import { useSyncExternalStore } from 'react'

// Gap between one set ending and the next one starting. Doubles as the beat
// React needs to flush the finished set into state before we count how many
// sets an exercise has left.
const ADVANCE_DELAY_MS = 400

let enabled = false
let snapshot = { enabled }
const listeners = new Set()

// Registered cards, keyed by an opaque per-mount token. Each value is a live
// descriptor the card overwrites on every render, so what we read here is
// always current: { order, group, targetSets, completed, running, resting,
// startSet(), finishRest() }.
const cards = new Map()
let advanceTimer = null

function emit() {
  snapshot = { enabled }
  listeners.forEach(l => l())
}

export function registerCard(owner, card) {
  cards.set(owner, card)
  return () => { cards.delete(owner) }
}

// A set starting on `owner` ends the rest running on any OTHER card: that rest
// is saved to its own last completed set, exactly as if Stop had been pressed.
export function announceSetStart(owner) {
  cards.forEach((card, key) => { if (key !== owner) card.finishRest() })
}

function ordered() {
  return [...cards.values()].sort((a, b) => a.order - b.order)
}

function pending(card) {
  return card.completed < card.targetSets
}

// The contiguous run of cards sharing `from`'s superset group. Mirrors how the
// Train view draws superset blocks: only ADJACENT exercises group together.
function blockOf(list, from) {
  if (from.group == null) return [from]
  const i = list.indexOf(from)
  let a = i
  let b = i
  while (a > 0 && list[a - 1].group === from.group) a--
  while (b < list.length - 1 && list[b + 1].group === from.group) b++
  return list.slice(a, b + 1)
}

// Which card runs the next set after `from` just finished one.
function nextCard(from) {
  const list = ordered()
  if (list.indexOf(from) < 0) return null
  const block = blockOf(list, from)

  if (block.length > 1) {
    // Superset: hop to the next exercise of the block, wrapping around to the
    // first one for the next round. Leave the block only once every exercise
    // in it has hit its target sets.
    const bi = block.indexOf(from)
    for (let n = 1; n <= block.length; n++) {
      const cand = block[(bi + n) % block.length]
      if (pending(cand)) return cand
    }
    const after = list.indexOf(block[block.length - 1]) + 1
    return list.slice(after).find(pending) || null
  }

  // Single exercise: repeat it until it hits its target sets, then move on.
  if (pending(from)) return from
  return list.slice(list.indexOf(from) + 1).find(pending) || null
}

// Called when a set (and its rest) finished on `from`. Queues the next start.
export function scheduleAdvance(from) {
  if (!enabled) return
  clearTimeout(advanceTimer)
  advanceTimer = setTimeout(() => {
    advanceTimer = null
    if (!enabled) return
    // A set was started by hand meanwhile → don't fight the user.
    if ([...cards.values()].some(c => c.running)) return
    const next = nextCard(from)
    if (next) next.startSet()
    else setEnabled(false)   // nothing left to do: the routine is done
  }, ADVANCE_DELAY_MS)
}

function setEnabled(on) {
  if (enabled === on) return
  enabled = on
  if (!on) { clearTimeout(advanceTimer); advanceTimer = null }
  emit()
  // Switched on with nothing running → kick off the first pending exercise.
  // If a set or a rest is already running, that one carries the chain instead.
  if (on && ![...cards.values()].some(c => c.running || c.resting)) {
    const first = ordered().find(pending)
    if (first) {
      advanceTimer = setTimeout(() => {
        advanceTimer = null
        if (enabled) first.startSet()
      }, ADVANCE_DELAY_MS)
    }
  }
}

export const autoRunStore = {
  subscribe(cb) { listeners.add(cb); return () => listeners.delete(cb) },
  getSnapshot() { return snapshot },
  setEnabled,
  toggle() { setEnabled(!enabled) },
}

export function useAutoRun() {
  return useSyncExternalStore(autoRunStore.subscribe, autoRunStore.getSnapshot, autoRunStore.getSnapshot)
}
