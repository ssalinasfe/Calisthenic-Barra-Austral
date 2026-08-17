// Rest-timer beep: plays when a set's rest reaches the routine's target
// (exercise.restSeconds). Same external-store pattern as heartRate.js so the
// on/off toggle in the header and the timer that plays the beep stay in sync.

import { useSyncExternalStore } from 'react'

const STORAGE_KEY = 'gym_rest_beep'
const listeners = new Set()

function loadEnabled() {
  const v = localStorage.getItem(STORAGE_KEY)
  return v === null ? true : v === '1'
}

let enabled = loadEnabled()
let snapshot = { enabled }

function emit() {
  snapshot = { enabled }
  listeners.forEach(l => l())
}

function setEnabled(on) {
  enabled = on
  try { localStorage.setItem(STORAGE_KEY, on ? '1' : '0') } catch { /* best effort */ }
  emit()
}

function toggle() {
  setEnabled(!enabled)
}

let audioCtx = null

// Three short beeps, loud and square-wave (more piercing than a sine) so it
// cuts through even if the phone is face-down or in a noisy gym.
function playBeep() {
  if (!enabled) return
  try {
    audioCtx = audioCtx || new (window.AudioContext || window.webkitAudioContext)()
    if (audioCtx.state === 'suspended') audioCtx.resume()
    const now = audioCtx.currentTime
    ;[0, 0.3, 0.6].forEach(offset => {
      const osc = audioCtx.createOscillator()
      const gain = audioCtx.createGain()
      osc.type = 'square'
      osc.frequency.value = 1000
      gain.gain.setValueAtTime(0, now + offset)
      gain.gain.linearRampToValueAtTime(0.9, now + offset + 0.015)
      gain.gain.linearRampToValueAtTime(0, now + offset + 0.25)
      osc.connect(gain).connect(audioCtx.destination)
      osc.start(now + offset)
      osc.stop(now + offset + 0.26)
    })
  } catch { /* some browsers block audio before a user gesture */ }
}

// Single short beep — used for the isometric-hold "go" cue and the every-10s
// tick, so they read as distinct from the triple rest-complete beep above.
function playTick() {
  if (!enabled) return
  try {
    audioCtx = audioCtx || new (window.AudioContext || window.webkitAudioContext)()
    if (audioCtx.state === 'suspended') audioCtx.resume()
    const now = audioCtx.currentTime
    const osc = audioCtx.createOscillator()
    const gain = audioCtx.createGain()
    osc.type = 'square'
    osc.frequency.value = 1200
    gain.gain.setValueAtTime(0, now)
    gain.gain.linearRampToValueAtTime(0.8, now + 0.015)
    gain.gain.linearRampToValueAtTime(0, now + 0.13)
    osc.connect(gain).connect(audioCtx.destination)
    osc.start(now)
    osc.stop(now + 0.14)
  } catch { /* some browsers block audio before a user gesture */ }
}

export const soundStore = {
  subscribe(cb) { listeners.add(cb); return () => listeners.delete(cb) },
  getSnapshot() { return snapshot },
  setEnabled,
  toggle,
  playBeep,
  playTick,
}

export function useRestSound() {
  return useSyncExternalStore(soundStore.subscribe, soundStore.getSnapshot, soundStore.getSnapshot)
}
