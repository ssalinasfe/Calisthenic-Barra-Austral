// Screen Wake Lock: keeps the phone's screen on while a session is running.
// Without it Android locks the screen after a minute and the browser throttles
// the timers, so the auto-pilot's work interval (autoRun.js) and the rest beep
// fire late or not at all — exactly when the phone is on the floor and nobody
// is touching it.
//
// The system takes the lock back every time the page stops being visible
// (switching apps, power button), so it has to be re-requested on
// visibilitychange. That re-request is the part that is easy to forget.
//
// External-store pattern like sound.js. The user preference IS persisted
// (gym_wake_lock, default on); "a session is running" obviously is not.

import { useSyncExternalStore } from 'react'

const STORAGE_KEY = 'gym_wake_lock'
const supported = typeof navigator !== 'undefined' && 'wakeLock' in navigator
const listeners = new Set()

function loadEnabled() {
  const v = localStorage.getItem(STORAGE_KEY)
  return v === null ? true : v === '1'
}

let enabled = loadEnabled()   // user preference
let wanted = false            // is a session active right now
let sentinel = null           // the live WakeLockSentinel, when we hold one
let requesting = false        // guards two overlapping requests
let snapshot = { enabled, supported, held: false }

function emit() {
  snapshot = { enabled, supported, held: sentinel != null }
  listeners.forEach(l => l())
}

async function acquire() {
  if (!supported || !enabled || !wanted || sentinel || requesting) return
  // Requesting while the page is hidden throws; visibilitychange retries.
  if (document.visibilityState !== 'visible') return
  requesting = true
  try {
    const s = await navigator.wakeLock.request('screen')
    // Things may have changed while the request was in flight.
    if (!enabled || !wanted) { try { await s.release() } catch { /* noop */ } return }
    s.addEventListener('release', () => {
      if (sentinel === s) { sentinel = null; emit() }
    })
    sentinel = s
    emit()
  } catch {
    // Denied (battery saver, permissions policy…). The app works fine without.
  } finally {
    requesting = false
  }
}

async function release() {
  const s = sentinel
  if (!s) return
  sentinel = null
  emit()
  try { await s.release() } catch { /* already gone */ }
}

function sync() {
  if (enabled && wanted) acquire()
  else release()
}

if (typeof document !== 'undefined') {
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') sync()
  })
}

// Called by Dashboard: true while status === 'active'.
function setWanted(on) {
  if (wanted === on) return
  wanted = on
  sync()
}

function setEnabled(on) {
  if (enabled === on) return
  enabled = on
  try { localStorage.setItem(STORAGE_KEY, on ? '1' : '0') } catch { /* best effort */ }
  emit()
  sync()
}

export const wakeLockStore = {
  subscribe(cb) { listeners.add(cb); return () => listeners.delete(cb) },
  getSnapshot() { return snapshot },
  setWanted,
  setEnabled,
  toggle() { setEnabled(!enabled) },
}

export function useWakeLock() {
  return useSyncExternalStore(wakeLockStore.subscribe, wakeLockStore.getSnapshot, wakeLockStore.getSnapshot)
}
