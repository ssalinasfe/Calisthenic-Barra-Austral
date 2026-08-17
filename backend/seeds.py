"""Seed users, exercises, cuyi's predefined routines, and the demo year of data."""
import os
import secrets
from datetime import datetime, timedelta, timezone
import random

from db import (
    SessionLocal, User, Exercise, Location, Routine, RoutineExercise,
    Session as SessionRow, SessionExercise, SessionSet, Photo,
)
import seed_cuyi


API_TOKEN = os.getenv("API_TOKEN", "gym_secret_token")


# ───── Static exercise catalogue (mirrors frontend EXERCISES) ────────────────
CATALOG = [
    # Push
    {'id': 1,  'name': 'Plank Hold',                    'name_es': 'Plancha',                       'category': 'Push',    'muscles': ['Core', 'Shoulders']},
    {'id': 2,  'name': 'Scapula Push-ups',              'name_es': 'Flexiones escapulares',         'category': 'Push',    'muscles': ['Serratus', 'Traps', 'Shoulders']},
    {'id': 3,  'name': 'Negative Push-ups',             'name_es': 'Flexiones negativas',           'category': 'Push',    'muscles': ['Chest', 'Triceps', 'Shoulders']},
    {'id': 4,  'name': 'Push-ups',                      'name_es': 'Flexión estándar',              'category': 'Push',    'muscles': ['Chest', 'Triceps', 'Shoulders']},
    {'id': 5,  'name': 'Wide Push-ups',                 'name_es': 'Flexión amplia',                'category': 'Push',    'muscles': ['Chest', 'Shoulders']},
    {'id': 6,  'name': 'Diamond Push-ups',              'name_es': 'Flexión diamante',              'category': 'Push',    'muscles': ['Triceps', 'Chest']},
    {'id': 7,  'name': 'Tricep Extensions',             'name_es': 'Extensiones de tríceps',        'category': 'Push',    'muscles': ['Triceps']},
    {'id': 8,  'name': 'Explosive Push-ups',            'name_es': 'Flexión explosiva',             'category': 'Push',    'muscles': ['Chest', 'Triceps', 'Shoulders']},
    {'id': 9,  'name': 'Archer Push-ups',               'name_es': 'Flexión de arquero',            'category': 'Push',    'muscles': ['Chest', 'Triceps', 'Shoulders']},
    {'id': 10, 'name': 'One-arm Push-up',               'name_es': 'Flexión a una mano',            'category': 'Push',    'muscles': ['Chest', 'Triceps', 'Core']},
    {'id': 36, 'name': 'Bench Press',                   'name_es': 'Press de banca',                'category': 'Push',    'muscles': ['Chest', 'Triceps', 'Shoulders']},
    # Pull
    {'id': 11, 'name': 'Banded Overhead Pull-aparts',   'name_es': 'Aperturas superiores con banda', 'category': 'Pull',   'muscles': ['Rear Delts', 'Traps']},
    {'id': 12, 'name': 'Banded Horizontal Pull-aparts', 'name_es': 'Aperturas horizontales con banda','category': 'Pull',  'muscles': ['Rear Delts', 'Rhomboids']},
    {'id': 13, 'name': 'Banded Pull-downs',             'name_es': 'Jalones con banda',             'category': 'Pull',    'muscles': ['Lats', 'Mid Back']},
    {'id': 14, 'name': 'Bent Over Barbell Rows',        'name_es': 'Remo inclinado con barra',      'category': 'Pull',    'muscles': ['Lats', 'Mid Back', 'Biceps']},
    {'id': 15, 'name': 'Passive Hang',                  'name_es': 'Colgado pasivo',                'category': 'Pull',    'muscles': ['Forearms']},
    {'id': 16, 'name': 'Scapula Pull-ups',              'name_es': 'Dominadas escapulares',         'category': 'Pull',    'muscles': ['Traps', 'Lats']},
    {'id': 17, 'name': 'Australian Pull-ups',           'name_es': 'Dominadas australianas',        'category': 'Pull',    'muscles': ['Lats', 'Mid Back', 'Biceps']},
    {'id': 18, 'name': 'Negative Pull-ups',             'name_es': 'Dominadas negativas',           'category': 'Pull',    'muscles': ['Lats', 'Biceps', 'Forearms']},
    {'id': 19, 'name': 'Band Assisted Pull-ups',        'name_es': 'Dominadas asistidas con banda', 'category': 'Pull',    'muscles': ['Lats', 'Biceps', 'Forearms']},
    {'id': 20, 'name': 'Pull-ups',                      'name_es': 'Dominada',                      'category': 'Pull',    'muscles': ['Lats', 'Biceps', 'Forearms']},
    # Legs
    {'id': 21, 'name': 'Bodyweight Squats',             'name_es': 'Sentadilla con peso corporal',  'category': 'Piernas', 'muscles': ['Quads', 'Glutes']},
    {'id': 22, 'name': 'Narrow Stance Squats',          'name_es': 'Sentadilla postura cerrada',    'category': 'Piernas', 'muscles': ['Quads']},
    {'id': 23, 'name': 'Deep Squats',                   'name_es': 'Sentadilla profunda',           'category': 'Piernas', 'muscles': ['Quads', 'Glutes']},
    {'id': 24, 'name': 'Bulgarian Split Squats',        'name_es': 'Sentadilla búlgara',            'category': 'Piernas', 'muscles': ['Quads', 'Glutes', 'Hamstrings']},
    {'id': 25, 'name': 'Cossack Squats',                'name_es': 'Sentadilla cosaca',             'category': 'Piernas', 'muscles': ['Quads', 'Glutes', 'Adductors']},
    {'id': 26, 'name': 'Pistol Squats (assisted)',      'name_es': 'Sentadilla pistola (variante)', 'category': 'Piernas', 'muscles': ['Quads', 'Glutes', 'Core']},
    {'id': 27, 'name': 'Pistol Squats',                 'name_es': 'Sentadilla pistola',            'category': 'Piernas', 'muscles': ['Quads', 'Glutes', 'Core']},
    {'id': 37, 'name': 'Barbell Squat',                 'name_es': 'Sentadilla con barra',          'category': 'Piernas', 'muscles': ['Quads', 'Glutes', 'Hamstrings']},
    # Kettlebell ("Misión Rusa": 10 ejercicios x 2 rondas). Bloque por implemento,
    # cada uno con su propia category (Push / Piernas / Custom).
    {'id': 38, 'name': 'Kettlebell Swings',              'name_es': 'Swing con pesa rusa',                        'category': 'Piernas', 'muscles': ['Glutes', 'Hamstrings', 'Core', 'Shoulders']},
    {'id': 39, 'name': 'Kettlebell Single-arm Swings',   'name_es': 'Swing a una mano con pesa rusa',             'category': 'Piernas', 'muscles': ['Glutes', 'Hamstrings', 'Core', 'Forearms']},
    {'id': 40, 'name': 'Kettlebell Clean and Press',     'name_es': 'Cargada y press con pesa rusa',              'category': 'Push',    'muscles': ['Shoulders', 'Triceps', 'Traps', 'Core']},
    {'id': 41, 'name': 'Kettlebell Squat + Halo',        'name_es': 'Sentadilla con pesa rusa y giro sobre la cabeza', 'category': 'Piernas', 'muscles': ['Quads', 'Glutes', 'Shoulders', 'Core']},
    {'id': 42, 'name': 'Kettlebell Thrusters',           'name_es': 'Thruster con pesa rusa',                     'category': 'Push',    'muscles': ['Quads', 'Glutes', 'Shoulders', 'Triceps']},
    {'id': 43, 'name': 'Kettlebell Deadlift + Around the Body', 'name_es': 'Peso muerto con pesa rusa y giro a la cintura', 'category': 'Piernas', 'muscles': ['Hamstrings', 'Glutes', 'Core', 'Forearms']},
    {'id': 44, 'name': 'Kettlebell Lunges + Pass Through', 'name_es': 'Estocada con pesa rusa y paso bajo la pierna', 'category': 'Piernas', 'muscles': ['Quads', 'Glutes', 'Hamstrings', 'Core']},
    {'id': 45, 'name': 'Kettlebell Sumo Squat + Upright Row', 'name_es': 'Sentadilla sumo con pesa rusa y remo al mentón', 'category': 'Piernas', 'muscles': ['Quads', 'Glutes', 'Adductors', 'Traps']},
    {'id': 46, 'name': 'Kettlebell Kneeling Twists',     'name_es': 'Giro de torso de rodillas con pesa rusa',    'category': 'Custom',  'muscles': ['Core', 'Obliques']},
    {'id': 47, 'name': 'Kettlebell Russian Twists',      'name_es': 'Giro ruso con pesa rusa',                    'category': 'Custom',  'muscles': ['Core', 'Obliques']},
    # Cardio / Machines
    {'id': 28, 'name': 'Rowing Machine',                'name_es': 'Máquina de remos',              'category': 'Remo',    'muscles': ['Heart'], 'type': 'machine'},
    {'id': 29, 'name': 'Treadmill',                     'name_es': 'Trotadora',                     'category': 'Remo',    'muscles': ['Heart'], 'type': 'machine'},
    {'id': 30, 'name': 'Air Bike',                      'name_es': 'Bicicleta de aire',             'category': 'Remo',    'muscles': ['Heart'], 'type': 'machine'},
    {'id': 31, 'name': 'Spin Bike',                     'name_es': 'Bicicleta de spinning',         'category': 'Remo',    'muscles': ['Heart'], 'type': 'machine'},
    {'id': 32, 'name': 'Jogging',                       'name_es': 'Trotar',                        'category': 'Remo',    'muscles': ['Heart']},
    {'id': 33, 'name': 'Burpees',                       'name_es': 'Burpees',                       'category': 'Remo',    'muscles': ['Heart']},
    {'id': 34, 'name': 'Warm-up',                       'name_es': 'Calentamiento',                 'category': 'Remo',    'muscles': ['Heart']},
    {'id': 35, 'name': 'Cool-down',                     'name_es': 'Enfriamiento',                  'category': 'Remo',    'muscles': ['Heart']},
]


def _gen_token() -> str:
    return secrets.token_urlsafe(24)


def seed_users(db) -> None:
    """Create cuyi and demo users if missing. Tokens are stable across restarts."""
    have_cuyi = db.query(User).filter_by(username='cuyi').one_or_none()
    if not have_cuyi:
        db.add(User(username='cuyi', password=API_TOKEN, token=_gen_token()))
    have_demo = db.query(User).filter_by(username='demo').one_or_none()
    if not have_demo:
        db.add(User(username='demo', password='1234', token=_gen_token()))
    db.commit()


def seed_exercises(db) -> None:
    """Insert/update the static catalogue."""
    existing = {e.name: e for e in db.query(Exercise).all()}
    for ex in CATALOG:
        row = existing.get(ex['name'])
        if row:
            row.name_es = ex.get('name_es')
            row.category = ex['category']
            row.muscles = ex['muscles']
            row.type = ex.get('type', 'reps')
        else:
            db.add(Exercise(
                name=ex['name'],
                name_es=ex.get('name_es'),
                category=ex['category'],
                muscles=ex['muscles'],
                type=ex.get('type', 'reps'),
            ))
    db.commit()


def seed_cuyi_routines(db) -> None:
    """Add cuyi's predefined PDF routines if cuyi has none yet."""
    cuyi = db.query(User).filter_by(username='cuyi').one()
    if cuyi.routines:
        return
    for r in seed_cuyi.routines_for_cuyi():
        rt = Routine(
            id=r['id'], user_id=cuyi.id, name=r['name'],
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
    db.commit()


# ───── Demo year of data (only if demo user has no sessions) ─────────────────

_DEMO_EXERCISES = {
    'Push':    ['Push-ups', 'Wide Push-ups', 'Diamond Push-ups',
                'Tricep Extensions', 'Archer Push-ups', 'Plank Hold'],
    'Pull':    ['Banded Overhead Pull-aparts', 'Banded Horizontal Pull-aparts',
                'Bent Over Barbell Rows', 'Australian Pull-ups',
                'Band Assisted Pull-ups', 'Pull-ups'],
    'Piernas': ['Bodyweight Squats', 'Deep Squats', 'Bulgarian Split Squats',
                'Cossack Squats', 'Pistol Squats (assisted)'],
    'Remo':    ['Rowing Machine'],
}

_DEMO_PATTERNS = {
    'Push day':  ['Push', 'Push', 'Push', 'Push'],
    'Pull day':  ['Pull', 'Pull', 'Pull', 'Pull'],
    'Leg day':   ['Piernas', 'Piernas', 'Piernas', 'Piernas'],
    'Full body': ['Push', 'Pull', 'Piernas', 'Remo'],
}

_DEMO_WEEKDAY = {0: 'Push day', 2: 'Pull day', 4: 'Leg day', 5: 'Full body'}

_DEMO_LOCATIONS = [
    ('loc_demo_home', 'Home gym',  'Living room'),
    ('loc_demo_park', 'Park',      'Local outdoor park'),
    ('loc_demo_box',  'Calisthenics box', 'Downtown'),
]

_NOTES = [
    'Felt strong today.',
    'A bit tired, kept the volume.',
    'Quick session before work.',
    'Sleep was great, set a small PR.',
    '', '', '',
]


def seed_demo_data(db) -> None:
    demo = db.query(User).filter_by(username='demo').one()
    if demo.sessions:
        return

    rnd = random.Random(42)

    # Locations
    for lid, name, addr in _DEMO_LOCATIONS:
        if not db.query(Location).filter_by(id=lid).one_or_none():
            db.add(Location(id=lid, user_id=demo.id, name=name, address=addr))
    db.flush()

    # Demo routines
    routine_id_by_name = {}
    for rname, pattern in _DEMO_PATTERNS.items():
        rid = f"rt_demo_{rname.replace(' ', '_').lower()}"
        routine_id_by_name[rname] = rid
        rt = Routine(
            id=rid, user_id=demo.id, name=rname,
            description=f"Auto-generated demo routine ({rname})",
            weekdays=[wd for wd, n in _DEMO_WEEKDAY.items() if n == rname],
            # unique muscle-group categories (cardio is not a coloring category)
            categories=[c for c in dict.fromkeys(pattern) if c != 'Remo'],
        )
        db.add(rt)
        seen = set()
        pos = 0
        for cat in pattern:
            for ex_name in _DEMO_EXERCISES[cat]:
                if ex_name not in seen:
                    seen.add(ex_name)
                    db.add(RoutineExercise(
                        routine_id=rid, position=pos, name=ex_name, category=cat,
                        type='machine' if cat == 'Remo' else 'reps',
                        tempo=None if cat == 'Remo' else '2010',
                        target_reps=None if cat == 'Remo' else 10,
                        target_sets=1 if cat == 'Remo' else 3,
                        rest_seconds=0 if cat == 'Remo' else 120,
                        time_seconds=600 if cat == 'Remo' else None,
                        resistance=5 if cat == 'Remo' else None,
                    ))
                    pos += 1
                    break
    db.flush()

    # Sessions (one year)
    now = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    end_day = now
    start_day = end_day - timedelta(days=365)
    cur = start_day
    week_idx = 0
    while cur <= end_day:
        wd = cur.weekday()
        if wd in _DEMO_WEEKDAY and rnd.random() > 0.20:
            rname = _DEMO_WEEKDAY[wd]
            pattern = _DEMO_PATTERNS[rname]
            week_progress = week_idx / 52.0
            start_hour = rnd.choice([8, 9, 17, 18, 19])
            start_min = rnd.randint(0, 59)
            start = cur.replace(hour=start_hour, minute=start_min)
            t = start
            sid = start.replace(microsecond=0).isoformat().replace('+00:00', 'Z')
            sess = SessionRow(
                id=sid, user_id=demo.id,
                title=rname,
                date=start.strftime('%Y-%m-%d'),
                start_time=start, duration_seconds=0,
                notes=rnd.choice(_NOTES),
                location_id=rnd.choice([l[0] for l in _DEMO_LOCATIONS] + [None, None]),
                routine_id=routine_id_by_name[rname],
            )
            db.add(sess)
            db.flush()
            total_dur = 0
            seen = set()
            ex_pos = 0
            for cat in pattern:
                pool = [n for n in _DEMO_EXERCISES[cat] if n not in seen]
                if not pool:
                    pool = _DEMO_EXERCISES[cat]
                ex_name = rnd.choice(pool)
                seen.add(ex_name)
                se = SessionExercise(session_id=sid, position=ex_pos, name=ex_name, category=cat)
                db.add(se)
                db.flush()
                ex_pos += 1
                base_reps = {'Push': 10, 'Pull': 6, 'Piernas': 12, 'Remo': 1}[cat]
                n_sets = 1 if cat == 'Remo' else rnd.choice([3, 3, 4])
                for i in range(n_sets):
                    reps = max(1, int(base_reps * (0.85 + 0.5 * week_progress) + rnd.randint(-2, 2)))
                    duration = rnd.randint(45, 130)
                    rest = rnd.randint(60, 180) if i < n_sets - 1 else 0
                    db.add(SessionSet(
                        session_exercise_id=se.id, position=i,
                        started_at=t, duration=duration, reps=reps, rest_duration=rest,
                    ))
                    t = t + timedelta(seconds=duration + rest)
                    total_dur += duration + rest
            sess.end_time = t
            sess.duration_seconds = total_dur
        cur += timedelta(days=1)
        if wd == 6:
            week_idx += 1
    db.commit()


def backfill_titles(db) -> None:
    """Give every existing session a title: prefer its routine name, fall back to date."""
    rows = db.query(SessionRow).filter((SessionRow.title == None) | (SessionRow.title == '')).all()
    if not rows:
        return
    routine_name = {r.id: r.name for r in db.query(Routine).all()}
    for s in rows:
        if s.routine_id and s.routine_id in routine_name:
            s.title = routine_name[s.routine_id]
        else:
            s.title = ''
    db.commit()


_ROUTINE_CATEGORIES = {}
for _lvl in range(1, 6):
    _ROUTINE_CATEGORIES[f'rt_cuyi_push_l{_lvl}'] = ['Push']
    _ROUTINE_CATEGORIES[f'rt_cuyi_pull_l{_lvl}'] = ['Pull']
    _ROUTINE_CATEGORIES[f'rt_cuyi_squat_l{_lvl}'] = ['Piernas']
_ROUTINE_CATEGORIES['rt_cuyi_combo_push3_pull2_squat3'] = ['Push', 'Pull', 'Piernas']
_ROUTINE_CATEGORIES['rt_demo_push_day'] = ['Push']
_ROUTINE_CATEGORIES['rt_demo_pull_day'] = ['Pull']
_ROUTINE_CATEGORIES['rt_demo_leg_day'] = ['Piernas']
# Cardio (Remo) is never part of a routine's coloring categories.
_ROUTINE_CATEGORIES['rt_demo_full_body'] = ['Push', 'Pull', 'Piernas']


def backfill_routine_categories(db) -> None:
    """Give known pre-defined routines their category (for calendar colors)
    if they were created before the `categories` field existed. Routines the
    user made freely keep an empty list, which renders as gray/'Other'."""
    # `categories` is a plain JSON column (not JSONB), which Postgres can't
    # compare with `=` in SQL — filter for "empty" in Python instead.
    changed = False
    for r in db.query(Routine).all():
        if r.categories:
            continue
        cats = _ROUTINE_CATEGORIES.get(r.id)
        if cats:
            r.categories = cats
            changed = True
    if changed:
        db.commit()


def strip_cardio_from_routine_categories(db) -> None:
    """Cardio (Remo) is a cooldown, not a coloring category. Remove it from any
    routine's stored categories so combined routines don't blend in cyan."""
    changed = False
    for r in db.query(Routine).all():
        if r.categories and 'Remo' in r.categories:
            r.categories = [c for c in r.categories if c != 'Remo']
            changed = True
    if changed:
        db.commit()


def run_seeds() -> None:
    db = SessionLocal()
    try:
        seed_users(db)
        seed_exercises(db)
        seed_cuyi_routines(db)
        seed_demo_data(db)
        backfill_titles(db)
        backfill_routine_categories(db)
        strip_cardio_from_routine_categories(db)
    finally:
        db.close()
