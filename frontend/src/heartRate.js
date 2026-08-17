// Web Bluetooth connection to a BLE heart-rate belt (e.g. Decathlon HRM BELT).
// Uses the standard GATT Heart Rate profile (service 0x180D, measurement 0x2A37),
// so any Bluetooth Smart / BLE 4.0 chest strap works the same way.
//
// This is a tiny external store (subscribe / getSnapshot) shared by both the
// Heart Rate menu screen and the active-session recorder in Dashboard. Consume
// it with the useHeartRate() hook below.
//
// NOTE: ANT+ is NOT reachable from a browser — only the Bluetooth side of a
// dual-band belt works here. Requires a secure context (HTTPS or localhost).
// Brave ships Web Bluetooth disabled by default: enable it at
// brave://flags/#brave-web-bluetooth-api and restart the browser.

import { useSyncExternalStore } from 'react'

const HR_SERVICE = 'heart_rate'                 // 0x180D
const HR_MEASUREMENT = 'heart_rate_measurement' // 0x2A37
const BODY_LOCATION = 'body_sensor_location'    // 0x2A38
// Optional services. They must be declared at requestDevice() time or the
// browser refuses access to them later, so they are listed even though plenty
// of belts expose neither.
const BATTERY_SERVICE = 'battery_service'       // 0x180F
const BATTERY_LEVEL = 'battery_level'           // 0x2A19
const DEVICE_INFO = 'device_information'        // 0x180A
const STORAGE_KEY = 'gym_hr_device'

// 0x2A38 body sensor location, per the GATT spec.
const BODY_LOCATIONS = ['Other', 'Chest', 'Wrist', 'Finger', 'Hand', 'Ear Lobe', 'Foot']

const listeners = new Set()

function loadStored() {
  try { return JSON.parse(localStorage.getItem(STORAGE_KEY) || 'null') }
  catch { return null }
}

let device = null
let characteristic = null
let manualDisconnect = false   // true after the user taps Disconnect/Forget
let reconnectTimer = null

let state = {
  supported: typeof navigator !== 'undefined' && !!navigator.bluetooth,
  status: 'disconnected', // 'disconnected' | 'connecting' | 'connected'
  bpm: null,
  deviceName: loadStored()?.name || null,
  paired: !!loadStored(),   // a belt has been added/remembered
  error: null,
  lastAt: null,             // ms timestamp of the last measurement
  contact: null,            // strap touching skin; null if the belt won't say
  rr: [],                   // RR intervals (ms) from the last packet, for HRV
  energy: null,             // energy expended (kJ), cumulative, if reported
  // Read once on connect; any of these may stay null on a belt that doesn't
  // expose the optional services.
  battery: null,            // %
  sensorLocation: null,
  manufacturer: null,
  model: null,
  firmware: null,
}
let snapshot = { ...state }

function emit() {
  snapshot = { ...state }
  listeners.forEach(l => l())
}

function set(patch) {
  state = { ...state, ...patch }
  emit()
}

function humanError(e) {
  const msg = String(e?.message || e || '')
  if (e?.name === 'SecurityError' || /secure context|https/i.test(msg))
    return 'Bluetooth needs HTTPS (or localhost). Open the app over its secure URL.'
  if (e?.name === 'NotSupportedError' || /globally disabled|not.*support/i.test(msg))
    return 'Web Bluetooth is off. In Brave, enable it at brave://flags/#brave-web-bluetooth-api and restart.'
  if (e?.name === 'NetworkError')
    return 'Could not reach the belt. Make sure it is on your chest (moist the strap) and nearby.'
  return msg || 'Bluetooth error'
}

// Parse the whole Heart Rate Measurement characteristic per the GATT spec, not
// just the bpm. The same packet also carries whether the strap is actually
// touching skin — the one thing that tells a real dropout apart from a belt
// that is connected but reading nothing — and the RR intervals, the
// beat-to-beat times that heart-rate variability is derived from.
function parseHeartRate(dv) {
  const flags = dv.getUint8(0)
  const is16bit = flags & 0x01
  let i = 1
  const bpm = is16bit ? dv.getUint16(i, /* littleEndian */ true) : dv.getUint8(i)
  i += is16bit ? 2 : 1

  // Bit 2 says the belt reports contact at all; bit 1 is the state itself.
  const contact = (flags >> 2) & 0x01 ? Boolean((flags >> 1) & 0x01) : null

  // Energy expended in kJ, cumulative since the belt last reset it.
  let energy = null
  if ((flags >> 3) & 0x01) {
    energy = dv.getUint16(i, true)
    i += 2
  }

  // RR intervals come in 1/1024 s units; kept as whole milliseconds.
  const rr = []
  if ((flags >> 4) & 0x01) {
    for (; i + 2 <= dv.byteLength; i += 2) {
      rr.push(Math.round((dv.getUint16(i, true) / 1024) * 1000))
    }
  }
  return { bpm, contact, rr, energy }
}

function onMeasurement(e) {
  const { bpm, contact, rr, energy } = parseHeartRate(e.target.value)
  if (Number.isFinite(bpm) && bpm > 0) set({ bpm, contact, rr, energy, lastAt: Date.now() })
}

function onDisconnected() {
  set({ status: 'disconnected', bpm: null })
  // Belt dropped (out of range, took it off) but page is still open → keep trying
  // to reconnect silently unless the user asked to disconnect.
  if (!manualDisconnect && loadStored()) scheduleReconnect(0)
}

// Retry a silent reconnect with a gentle backoff while the belt is out of reach.
function scheduleReconnect(attempt) {
  clearTimeout(reconnectTimer)
  if (manualDisconnect || !loadStored() || attempt > 20) return
  reconnectTimer = setTimeout(async () => {
    if (manualDisconnect || state.status === 'connected') return
    const res = await reconnect({ silent: true })
    // Only keep retrying when the belt is known but momentarily unreachable
    // (out of range). If the browser doesn't remember it, retrying is futile.
    if (state.status !== 'connected' && res?.retriable) scheduleReconnect(attempt + 1)
  }, Math.min(500 + attempt * 1500, 10000))
}

// Everything the belt can tell us beyond the beat itself. All of it is
// optional — a strap that exposes none of these still works exactly as before,
// so every read is individually guarded and simply leaves its field null.
//
// Battery matters most: a belt running low drops out, and without this the only
// evidence of that is a hole in the samples with no explanation.
async function readExtras(server, service) {
  try {
    const c = await service.getCharacteristic(BODY_LOCATION)
    const v = await c.readValue()
    set({ sensorLocation: BODY_LOCATIONS[v.getUint8(0)] ?? `Unknown (${v.getUint8(0)})` })
  } catch { /* not exposed */ }

  try {
    const batt = await server.getPrimaryService(BATTERY_SERVICE)
    const c = await batt.getCharacteristic(BATTERY_LEVEL)
    set({ battery: (await c.readValue()).getUint8(0) })
    // Not every belt supports notifying on it; the initial read already landed.
    try {
      c.addEventListener('characteristicvaluechanged', e => set({ battery: e.target.value.getUint8(0) }))
      await c.startNotifications()
    } catch { /* read-only battery */ }
  } catch { /* no battery service, or not granted at pairing time */ }

  try {
    const info = await server.getPrimaryService(DEVICE_INFO)
    const dec = new TextDecoder()
    const read = async uuid => {
      try { return dec.decode(await (await info.getCharacteristic(uuid)).readValue()).replace(/\0+$/, '') }
      catch { return null }
    }
    set({
      manufacturer: await read('manufacturer_name_string'),
      model: await read('model_number_string'),
      firmware: await read('firmware_revision_string'),
    })
  } catch { /* no device information service */ }
}

async function attach(dev) {
  device = dev
  device.removeEventListener?.('gattserverdisconnected', onDisconnected)
  device.addEventListener('gattserverdisconnected', onDisconnected)
  const server = await device.gatt.connect()
  const service = await server.getPrimaryService(HR_SERVICE)
  characteristic = await service.getCharacteristic(HR_MEASUREMENT)
  characteristic.addEventListener('characteristicvaluechanged', onMeasurement)
  await characteristic.startNotifications()
  set({ status: 'connected', deviceName: device.name || state.deviceName, error: null })
  // After the beat is flowing: losing these must never cost us the connection.
  readExtras(server, service).catch(() => { /* all of it is optional */ })
}

// Open the browser chooser to pair a belt (must run from a user gesture).
async function connect() {
  if (!state.supported) { set({ error: humanError({ name: 'NotSupportedError' }) }); return }
  manualDisconnect = false
  clearTimeout(reconnectTimer)
  set({ status: 'connecting', error: null })
  try {
    const dev = await navigator.bluetooth.requestDevice({
      filters: [{ services: [HR_SERVICE] }],
      // Access to these is decided HERE, at pairing time. A belt paired before
      // this line existed will keep being refused them until it is forgotten
      // and paired again.
      optionalServices: [BATTERY_SERVICE, DEVICE_INFO],
    })
    await attach(dev)
    const name = dev.name || 'HR belt'
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify({ id: dev.id, name })) } catch { /* best effort */ }
    set({ paired: true, deviceName: name })
  } catch (e) {
    // User dismissing the chooser throws NotFoundError — not a real error.
    if (e?.name === 'NotFoundError') set({ status: 'disconnected', error: null })
    else set({ status: 'disconnected', error: humanError(e) })
  }
}

// Reconnect to the already-remembered belt without showing the chooser.
// `silent` suppresses error messages (used by auto-reconnect on load / retries).
async function reconnect({ silent = false } = {}) {
  if (!state.supported || !loadStored()) return { retriable: false }
  const stored = loadStored()
  manualDisconnect = false
  if (state.status !== 'connecting') set({ status: 'connecting', error: null })
  try {
    let dev = device
    if (!dev && navigator.bluetooth.getDevices) {
      const devs = await navigator.bluetooth.getDevices()
      dev = devs.find(d => d.id === stored.id) || null
    }
    if (!dev) {
      // Browser doesn't remember the belt (permission not persisted) — the chooser
      // is required. Retrying silently won't help.
      set({ status: 'disconnected', error: silent ? null : 'Tap Connect to select your belt again.' })
      return { retriable: false }
    }
    await attach(dev)
    return { retriable: false }   // connected
  } catch (e) {
    // Belt is known but couldn't connect right now (out of range / not worn) — retry.
    set({ status: 'disconnected', error: silent ? null : humanError(e) })
    return { retriable: true }
  }
}

// Does the browser remember this belt for silent reconnect? (diagnostic)
async function probeRemembered() {
  try {
    const stored = loadStored()
    if (!stored || !navigator.bluetooth?.getDevices) return false
    const devs = await navigator.bluetooth.getDevices()
    return devs.some(d => d.id === stored.id)
  } catch { return false }
}

// Called once on app load: quietly bring the remembered belt back if possible.
function autoConnect() {
  if (state.supported && loadStored() && state.status === 'disconnected') {
    manualDisconnect = false
    scheduleReconnect(0)
  }
}

function disconnect() {
  manualDisconnect = true
  clearTimeout(reconnectTimer)
  try { characteristic?.removeEventListener('characteristicvaluechanged', onMeasurement) } catch { /* noop */ }
  try { if (device?.gatt?.connected) device.gatt.disconnect() } catch { /* noop */ }
  characteristic = null
  set({ status: 'disconnected', bpm: null })
}

// Forget the remembered belt entirely.
function forget() {
  disconnect()
  try { device?.forget?.() } catch { /* noop */ }
  device = null
  try { localStorage.removeItem(STORAGE_KEY) } catch { /* noop */ }
  set({ paired: false, deviceName: null, error: null })
}

export const hrStore = {
  subscribe(cb) { listeners.add(cb); return () => listeners.delete(cb) },
  getSnapshot() { return snapshot },
  connect,
  reconnect,
  autoConnect,
  probeRemembered,
  disconnect,
  forget,
}

export function useHeartRate() {
  return useSyncExternalStore(hrStore.subscribe, hrStore.getSnapshot, hrStore.getSnapshot)
}
