export async function login(username, password) {
  const res = await fetch('/api/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password }),
  })
  if (!res.ok) {
    const err = new Error(`HTTP ${res.status}`)
    err.status = res.status
    throw err
  }
  return res.json()  // { token, username }
}

export async function fetchData(token) {
  const res = await fetch('/api/data', {
    headers: { 'x-api-token': token },
  })
  if (!res.ok) {
    const err = new Error(`HTTP ${res.status}`)
    err.status = res.status
    throw err
  }
  return res.json()
}

export async function saveData(token, data) {
  const res = await fetch('/api/data', {
    method: 'POST',
    headers: {
      'x-api-token': token,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  })
  if (!res.ok) {
    const err = new Error(`HTTP ${res.status}`)
    err.status = res.status
    throw err
  }
  return res.json()
}

// Write one session. Preferred over saveData for anything session-shaped: the
// rest of the history stays in the DB instead of making a round trip just to be
// re-inserted unchanged, and a stale tab can't overwrite what it doesn't hold.
export async function saveSession(token, session) {
  const res = await fetch('/api/sessions', {
    method: 'POST',
    headers: {
      'x-api-token': token,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(session),
  })
  if (!res.ok) {
    const err = new Error(`HTTP ${res.status}`)
    err.status = res.status
    throw err
  }
  return res.json()
}

export async function deleteSession(token, id) {
  const res = await fetch(`/api/sessions/${encodeURIComponent(id)}`, {
    method: 'DELETE',
    headers: { 'x-api-token': token },
  })
  if (!res.ok) {
    const err = new Error(`HTTP ${res.status}`)
    err.status = res.status
    throw err
  }
  return res.json()
}

export async function uploadPhoto(token, file) {
  const fd = new FormData()
  fd.append('file', file)
  const res = await fetch('/api/photos', {
    method: 'POST',
    headers: { 'x-api-token': token },
    body: fd,
  })
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return res.json()  // { filename, url }
}

export async function deletePhoto(token, filename) {
  const res = await fetch(`/api/photos/${filename}`, {
    method: 'DELETE',
    headers: { 'x-api-token': token },
  })
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return res.json()
}

export function photoUrl(token, filename) {
  return `/api/photos/${filename}?token=${encodeURIComponent(token)}`
}
