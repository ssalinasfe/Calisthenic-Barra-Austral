// Heart-rate variability from the RR intervals the belt reports — the
// beat-to-beat times in milliseconds, captured in heartRate.js.
//
// Every metric here is time-domain: they need far fewer beats than frequency
// analysis and survive the short, broken windows a workout actually gives you.
// Frequency-domain measures (LF/HF) would need several minutes of stationary
// signal, which a session between sets never provides.

// Physiologically plausible bounds: 300 ms is 200 bpm, 2000 ms is 30 bpm.
const RR_MIN = 300
const RR_MAX = 2000
// A real beat doesn't jump more than ~20% from the one before it. Anything that
// does is an ectopic beat or a motion artifact — common with a chest strap
// under load, and it would inflate RMSSD badly if left in.
const MAX_JUMP = 0.2
// Below this there aren't enough beats for the numbers to mean anything.
const MIN_BEATS = 20

export function computeHrv(rr) {
  // Split into runs of consecutive accepted beats. A rejected beat BREAKS the
  // run rather than closing over it: RMSSD is built from successive
  // differences, and bridging a discarded beat would invent a difference
  // between two beats that were never neighbours.
  const runs = []
  let run = []
  let prev = null
  for (const v of rr) {
    const ok = v >= RR_MIN && v <= RR_MAX &&
      (prev === null || Math.abs(v - prev) <= prev * MAX_JUMP)
    if (ok) {
      run.push(v)
      prev = v
    } else {
      if (run.length) runs.push(run)
      run = []
      prev = null
    }
  }
  if (run.length) runs.push(run)

  const all = runs.flat()
  if (all.length < MIN_BEATS) return null

  let sumSq = 0
  let pairs = 0
  let over50 = 0
  for (const r of runs) {
    for (let i = 1; i < r.length; i++) {
      const d = r[i] - r[i - 1]
      sumSq += d * d
      pairs++
      if (Math.abs(d) > 50) over50++
    }
  }
  if (!pairs) return null

  const mean = all.reduce((a, b) => a + b, 0) / all.length
  const variance = all.reduce((a, b) => a + (b - mean) ** 2, 0) / all.length

  return {
    rmssd: Math.round(Math.sqrt(sumSq / pairs)),   // vagal tone, the short-term standard
    sdnn: Math.round(Math.sqrt(variance)),         // overall variability
    pnn50: Math.round((over50 / pairs) * 100),     // % of successive pairs differing >50 ms
    meanRr: Math.round(mean),
    meanBpm: Math.round(60000 / mean),
    beats: all.length,
    dropped: rr.length - all.length,               // artifacts filtered out
  }
}
