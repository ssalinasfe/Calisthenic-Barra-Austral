"""Translation between DB rows and the JSON shape the frontend speaks."""
from datetime import datetime
from db import (
    User, Exercise, Location, Routine, RoutineExercise,
    Session as SessionRow, SessionExercise, SessionSet, Photo,
)


def _iso(dt: datetime) -> str | None:
    if dt is None:
        return None
    if dt.tzinfo is None:
        return dt.isoformat() + 'Z'
    return dt.isoformat().replace('+00:00', 'Z')


def parse_iso(s: str | None) -> datetime | None:
    if not s:
        return None
    return datetime.fromisoformat(s.replace('Z', '+00:00'))


def routine_to_json(r: Routine) -> dict:
    return {
        'id':           r.id,
        'name':         r.name,
        'description':  r.description or '',
        'weekdays':     list(r.weekdays or []),
        'categories':   list(r.categories or []),
        'exercises':    [routine_exercise_to_json(re) for re in r.exercises],
    }


def routine_exercise_to_json(re: RoutineExercise) -> dict:
    out = {
        'name':           re.name,
        'category':       re.category,
        'type':           re.type or 'reps',
        'tempo':          re.tempo,
        'targetReps':     re.target_reps,
        'targetSets':     re.target_sets,
        'restSeconds':    re.rest_seconds,
        'timeSeconds':    re.time_seconds,
        'resistance':     re.resistance,
        'supersetGroup':  re.superset_group,
    }
    return out


def location_to_json(l: Location) -> dict:
    return {'id': l.id, 'name': l.name, 'address': l.address or ''}


def session_to_json(s: SessionRow) -> dict:
    return {
        'id':              s.id,
        'title':           s.title or '',
        'date':            s.date,
        'startTime':       _iso(s.start_time),
        'endTime':         _iso(s.end_time),
        'durationSeconds': s.duration_seconds,
        'notes':           s.notes or '',
        'categories':      list(s.categories or []),
        'locationId':      s.location_id,
        'routineId':       s.routine_id,
        'avgHr':           s.avg_hr,
        'maxHr':           s.max_hr,
        'minHr':           s.min_hr,
        'hrSamples':       list(s.hr_samples or []),
        'events':          list(s.events or []),
        'photos':          [p.filename for p in s.photos],
        'exercises':       [session_exercise_to_json(se) for se in s.exercises],
    }


def session_exercise_to_json(se: SessionExercise) -> dict:
    return {
        'name':     se.name,
        'category': se.category,
        'sets':     [session_set_to_json(st) for st in se.sets],
    }


def session_set_to_json(st: SessionSet) -> dict:
    out = {
        'startedAt':    _iso(st.started_at),
        'duration':     st.duration,
        'reps':         st.reps if st.reps is not None else 0,
    }
    if st.weight is not None:
        out['weight'] = st.weight
    if st.rest_duration:
        out['restDuration'] = st.rest_duration
    if st.start_hr is not None:
        out['startHr'] = st.start_hr
    if st.avg_hr is not None:
        out['avgHr'] = st.avg_hr
    if st.max_hr is not None:
        out['maxHr'] = st.max_hr
    return out


def user_data_to_json(user: User) -> dict:
    """Build the full {sessions, locations, routines} blob for a user."""
    return {
        'sessions':  [session_to_json(s) for s in
                      sorted(user.sessions, key=lambda x: x.start_time or datetime.min)],
        'locations': [location_to_json(l) for l in user.locations],
        'routines':  [routine_to_json(r) for r in user.routines],
    }


# ── Replace user data from the JSON shape ────────────────────────────────────

def replace_user_data(db, user: User, payload: dict) -> None:
    """Wipe and rewrite this user's locations, routines, and sessions
    from the provided JSON blob. Photos already on disk are preserved
    (filenames re-attached if still referenced).
    """
    # Delete existing rows for this user via cascading FKs.
    for s in list(user.sessions):
        db.delete(s)
    for r in list(user.routines):
        db.delete(r)
    for l in list(user.locations):
        db.delete(l)
    db.flush()

    # Locations first (sessions reference them).
    locations = payload.get('locations') or []
    for l in locations:
        if not l.get('id') or not l.get('name'):
            continue
        db.add(Location(id=l['id'], user_id=user.id, name=l['name'], address=l.get('address') or ''))

    # Routines.
    for r in payload.get('routines') or []:
        if not r.get('id') or not r.get('name'):
            continue
        rt = Routine(
            id=r['id'], user_id=user.id, name=r['name'],
            description=r.get('description') or '',
            weekdays=list(r.get('weekdays') or []),
            categories=list(r.get('categories') or []),
        )
        db.add(rt)
        for i, re in enumerate(r.get('exercises') or []):
            db.add(RoutineExercise(
                routine_id=rt.id,
                position=i,
                name=re.get('name') or '',
                category=re.get('category') or 'Custom',
                type=re.get('type') or 'reps',
                tempo=re.get('tempo'),
                target_reps=re.get('targetReps'),
                target_sets=re.get('targetSets'),
                rest_seconds=re.get('restSeconds'),
                time_seconds=re.get('timeSeconds'),
                resistance=re.get('resistance'),
                superset_group=re.get('supersetGroup'),
            ))

    # Sessions.
    for s in payload.get('sessions') or []:
        if not s.get('id'):
            continue
        sess = SessionRow(
            id=s['id'],
            user_id=user.id,
            title=s.get('title') or '',
            date=s.get('date') or '',
            start_time=parse_iso(s.get('startTime')),
            end_time=parse_iso(s.get('endTime')),
            duration_seconds=s.get('durationSeconds') or 0,
            notes=s.get('notes') or '',
            categories=list(s.get('categories') or []),
            location_id=s.get('locationId'),
            routine_id=s.get('routineId'),
            avg_hr=s.get('avgHr'),
            max_hr=s.get('maxHr'),
            min_hr=s.get('minHr'),
            hr_samples=list(s.get('hrSamples') or []),
            events=list(s.get('events') or []),
        )
        db.add(sess)
        for i, ex in enumerate(s.get('exercises') or []):
            se = SessionExercise(
                session_id=sess.id,
                position=i,
                name=ex.get('name') or '',
                category=ex.get('category') or 'Custom',
            )
            db.add(se)
            db.flush()  # ensure se.id is available
            for j, st in enumerate(ex.get('sets') or []):
                db.add(SessionSet(
                    session_exercise_id=se.id,
                    position=j,
                    started_at=parse_iso(st.get('startedAt')),
                    duration=st.get('duration'),
                    reps=st.get('reps'),
                    weight=st.get('weight'),
                    rest_duration=st.get('restDuration'),
                    start_hr=st.get('startHr'),
                    avg_hr=st.get('avgHr'),
                    max_hr=st.get('maxHr'),
                ))
        for p in s.get('photos') or []:
            if not p:
                continue
            db.add(Photo(session_id=sess.id, filename=p))

    db.commit()
