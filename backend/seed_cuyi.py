"""Predefined cuyi routines based on the PDF (one-day-one-routine concept).

The PDF defines push-ups / pull-ups / squats routines across 5 levels each.
Push and squat routines append a rowing-machine cooldown.
Pull routines append a 30-minute treadmill cooldown.

Tempo notation: '2010' = 2s eccentric, 0s pause, 1s concentric, 0s pause.
For static holds (Plank, Passive Hang) we store a `timeSeconds`.
"""

# weekday indices (Mon=0..Sun=6) used in the "One day, one routine" plan from the PDF:
#   Mon=Push, Tue=Pull, Wed=Squat, Thu=Push, Fri=Pull, Sat=Squat, Sun=rest.
# We attach Level 1 of each group to those weekdays. Higher levels are saved
# without a weekday, ready for the user to assign manually.
_PUSH_DAYS = [0, 3]    # Mon, Thu
_PULL_DAYS = [1, 4]    # Tue, Fri
_SQUAT_DAYS = [2, 5]   # Wed, Sat


def _ex(name, category, *,
        type='reps',
        tempo=None, target_reps=None, target_sets=None, rest=None,
        time_seconds=None, resistance=None, superset=None):
    out = {'name': name, 'category': category, 'type': type, 'supersetGroup': superset}
    if type == 'machine':
        out['timeSeconds'] = time_seconds
        out['resistance'] = resistance
        out['targetSets'] = target_sets or 1
        out['restSeconds'] = rest or 0
    else:
        out['tempo'] = tempo or '2010'
        out['targetReps'] = target_reps
        out['targetSets'] = target_sets
        out['restSeconds'] = rest
        if time_seconds is not None:
            out['timeSeconds'] = time_seconds
    return out


def _row_cooldown():
    return _ex('Rowing Machine', 'Remo', type='machine',
               time_seconds=600, resistance=5, target_sets=1, rest=0)


def _treadmill_cooldown():
    return _ex('Treadmill', 'Remo', type='machine',
               time_seconds=1800, resistance=4, target_sets=1, rest=0)


# ──── PUSH-UPS ROUTINES ──────────────────────────────────────────────────────
def _push_level_1():
    return [
        _ex('Negative Push-ups', 'Push', tempo='4000', target_reps=8, target_sets=3, rest=120),
        _ex('Scapula Push-ups',  'Push', tempo='2010', target_reps=8, target_sets=4, rest=120),
        _ex('Plank Hold',        'Push', tempo=None,   time_seconds=60, target_sets=4, rest=120),
        _row_cooldown(),
    ]


def _push_level_2():
    return [
        _ex('Push-ups',          'Push', tempo='2010', target_reps=12, target_sets=3, rest=120),
        _ex('Negative Push-ups', 'Push', tempo='4000', target_reps=8,  target_sets=3, rest=120),
        # Superset: scapula + plank
        _ex('Scapula Push-ups',  'Push', tempo='2010', target_reps=8,  target_sets=4, rest=180, superset=1),
        _ex('Plank Hold',        'Push', tempo=None,   time_seconds=60, target_sets=4, rest=180, superset=1),
        _row_cooldown(),
    ]


def _push_level_3():
    return [
        _ex('Diamond Push-ups',     'Push', tempo='2010', target_reps=15, target_sets=3, rest=120),
        # Superset: normal push-ups + tricep extensions
        _ex('Push-ups',             'Push', tempo='2010', target_reps=8,  target_sets=3, rest=120, superset=1),
        _ex('Tricep Extensions',    'Push', tempo='2010', target_reps=8,  target_sets=3, rest=120, superset=1),
        _ex('Wide Push-ups',        'Push', tempo='2010', target_reps=6,  target_sets=3, rest=90),
        _ex('Negative Push-ups',    'Push', tempo='4000', target_reps=4,  target_sets=3, rest=180),
        _row_cooldown(),
    ]


def _push_level_4():
    return [
        _ex('Explosive Push-ups',   'Push', tempo='1010', target_reps=6,  target_sets=2, rest=120),
        # Superset: normal push-ups + plank
        _ex('Push-ups',             'Push', tempo='2010', target_reps=10, target_sets=3, rest=180, superset=1),
        _ex('Plank Hold',           'Push', tempo=None,   time_seconds=60, target_sets=3, rest=180, superset=1),
        _ex('Archer Push-ups',      'Push', tempo='2010', target_reps=2,  target_sets=3, rest=120),
        _ex('Diamond Push-ups',     'Push', tempo='2010', target_reps=10, target_sets=2, rest=120),
        _row_cooldown(),
    ]


def _push_level_5():
    return [
        # Superset: archer + diamond
        _ex('Archer Push-ups',  'Push', tempo='2010', target_reps=4, target_sets=4, rest=180, superset=1),
        _ex('Diamond Push-ups', 'Push', tempo='2010', target_reps=5, target_sets=4, rest=180, superset=1),
        _ex('One-arm Push-up',  'Push', tempo='2010', target_reps=1, target_sets=3, rest=120),
        # Superset: normal + wide
        _ex('Push-ups',         'Push', tempo='2010', target_reps=6, target_sets=5, rest=120, superset=2),
        _ex('Wide Push-ups',    'Push', tempo='2010', target_reps=5, target_sets=5, rest=180, superset=2),
        _row_cooldown(),
    ]


# ──── PULL-UPS ROUTINES ──────────────────────────────────────────────────────
def _pull_level_1():
    return [
        # Superset: barbell rows + passive hang
        _ex('Bent Over Barbell Rows', 'Pull', tempo='2010', target_reps=15, target_sets=3, rest=180, superset=1),
        _ex('Passive Hang',           'Pull', tempo=None,   time_seconds=60, target_sets=3, rest=180, superset=1),
        _treadmill_cooldown(),
    ]


def _pull_level_2():
    return [
        # Superset: australian + scapula
        _ex('Australian Pull-ups', 'Pull', tempo='2010', target_reps=12, target_sets=3, rest=180, superset=1),
        _ex('Scapula Pull-ups',    'Pull', tempo='2010', target_reps=12, target_sets=3, rest=180, superset=1),
        _treadmill_cooldown(),
    ]


def _pull_level_3():
    return [
        _ex('Band Assisted Pull-ups', 'Pull', tempo='2010', target_reps=6,  target_sets=3, rest=180),
        # Superset: australian + scapula
        _ex('Australian Pull-ups',    'Pull', tempo='2010', target_reps=12, target_sets=4, rest=180, superset=1),
        _ex('Scapula Pull-ups',       'Pull', tempo='2010', target_reps=12, target_sets=4, rest=180, superset=1),
        _treadmill_cooldown(),
    ]


def _pull_level_4():
    return [
        _ex('Negative Pull-ups',      'Pull', tempo='10000', target_reps=1, target_sets=5, rest=60),
        _ex('Band Assisted Pull-ups', 'Pull', tempo='2010',  target_reps=6, target_sets=3, rest=180),
        # Superset: australian + scapula + passive hang
        _ex('Australian Pull-ups',    'Pull', tempo='2010',  target_reps=8,  target_sets=3, rest=180, superset=1),
        _ex('Scapula Pull-ups',       'Pull', tempo='2010',  target_reps=5,  target_sets=3, rest=180, superset=1),
        _ex('Passive Hang',           'Pull', tempo=None,    time_seconds=30, target_sets=3, rest=180, superset=1),
        _treadmill_cooldown(),
    ]


def _pull_level_5():
    return [
        _ex('Pull-ups',               'Pull', tempo='2010', target_reps=3,  target_sets=3, rest=180),
        _ex('Band Assisted Pull-ups', 'Pull', tempo='2010', target_reps=10, target_sets=3, rest=180),
        # Superset: australian + scapula + passive hang
        _ex('Australian Pull-ups',    'Pull', tempo='2010', target_reps=8, target_sets=3, rest=180, superset=1),
        _ex('Scapula Pull-ups',       'Pull', tempo='2010', target_reps=5, target_sets=3, rest=180, superset=1),
        _ex('Passive Hang',           'Pull', tempo=None,   time_seconds=30, target_sets=3, rest=180, superset=1),
        _treadmill_cooldown(),
    ]


# ──── SQUATS ROUTINES ────────────────────────────────────────────────────────
def _squat_level_1():
    return [
        _ex('Narrow Stance Squats', 'Piernas', tempo='2010', target_reps=12, target_sets=3, rest=120),
        _ex('Deep Squats',          'Piernas', tempo='2010', target_reps=12, target_sets=3, rest=120),
        _ex('Bodyweight Squats',    'Piernas', tempo='2010', target_reps=15, target_sets=3, rest=120),
        _row_cooldown(),
    ]


def _squat_level_2():
    return [
        _ex('Bulgarian Split Squats', 'Piernas', tempo='3010', target_reps=6,  target_sets=3, rest=180),
        # Superset: narrow + deep
        _ex('Narrow Stance Squats',   'Piernas', tempo='2010', target_reps=10, target_sets=3, rest=180, superset=1),
        _ex('Deep Squats',            'Piernas', tempo='3010', target_reps=10, target_sets=3, rest=180, superset=1),
        _row_cooldown(),
    ]


def _squat_level_3():
    return [
        _ex('Cossack Squats',         'Piernas', tempo='2010', target_reps=6, target_sets=3, rest=120),
        _ex('Bulgarian Split Squats', 'Piernas', tempo='2010', target_reps=8, target_sets=3, rest=120),
        # Superset: narrow + deep
        _ex('Narrow Stance Squats',   'Piernas', tempo='2010', target_reps=8, target_sets=3, rest=180, superset=1),
        _ex('Deep Squats',            'Piernas', tempo='3010', target_reps=8, target_sets=3, rest=180, superset=1),
        _row_cooldown(),
    ]


def _squat_level_4():
    return [
        _ex('Pistol Squats (assisted)','Piernas', tempo='3010', target_reps=10, target_sets=3, rest=120),
        _ex('Cossack Squats',          'Piernas', tempo='2010', target_reps=8,  target_sets=3, rest=100),
        _ex('Bulgarian Split Squats',  'Piernas', tempo='2010', target_reps=10, target_sets=3, rest=100),
        _ex('Deep Squats',             'Piernas', tempo='3010', target_reps=12, target_sets=3, rest=100),
        _row_cooldown(),
    ]


def _squat_level_5():
    return [
        _ex('Pistol Squats',           'Piernas', tempo='2020', target_reps=3,  target_sets=3, rest=120),
        _ex('Pistol Squats (assisted)','Piernas', tempo='3010', target_reps=6,  target_sets=2, rest=120),
        _ex('Cossack Squats',          'Piernas', tempo='2010', target_reps=8,  target_sets=3, rest=120),
        # Superset: bulgarian + deep
        _ex('Bulgarian Split Squats',  'Piernas', tempo='2010', target_reps=10, target_sets=3, rest=120, superset=1),
        _ex('Deep Squats',             'Piernas', tempo='3010', target_reps=10, target_sets=3, rest=120, superset=1),
        _row_cooldown(),
    ]


def routines_for_cuyi():
    """Return the catalogue of routines for cuyi.

    Level 1 of each group is assigned to default weekdays from the PDF;
    higher levels start unscheduled.
    """
    routines = []
    _add = lambda rid, name, exs, weekdays=None, desc='', categories=None: routines.append({
        'id':         f'rt_cuyi_{rid}',
        'name':       name,
        'description': desc,
        'exercises':  exs,
        'weekdays':   weekdays or [],
        'categories': categories or [],
    })

    _add('push_l1', 'Push-ups Level 1', _push_level_1(), weekdays=_PUSH_DAYS, desc='Push-ups routine, Level 1', categories=['Push'])
    _add('push_l2', 'Push-ups Level 2', _push_level_2(), desc='Push-ups routine, Level 2', categories=['Push'])
    _add('push_l3', 'Push-ups Level 3', _push_level_3(), desc='Push-ups routine, Level 3', categories=['Push'])
    _add('push_l4', 'Push-ups Level 4', _push_level_4(), desc='Push-ups routine, Level 4', categories=['Push'])
    _add('push_l5', 'Push-ups Level 5', _push_level_5(), desc='Push-ups routine, Level 5', categories=['Push'])

    _add('pull_l1', 'Pull-ups Level 1', _pull_level_1(), weekdays=_PULL_DAYS, desc='Pull-ups routine, Level 1', categories=['Pull'])
    _add('pull_l2', 'Pull-ups Level 2', _pull_level_2(), desc='Pull-ups routine, Level 2', categories=['Pull'])
    _add('pull_l3', 'Pull-ups Level 3', _pull_level_3(), desc='Pull-ups routine, Level 3', categories=['Pull'])
    _add('pull_l4', 'Pull-ups Level 4', _pull_level_4(), desc='Pull-ups routine, Level 4', categories=['Pull'])
    _add('pull_l5', 'Pull-ups Level 5', _pull_level_5(), desc='Pull-ups routine, Level 5', categories=['Pull'])

    _add('squat_l1', 'Squats Level 1', _squat_level_1(), weekdays=_SQUAT_DAYS, desc='Squats routine, Level 1', categories=['Piernas'])
    _add('squat_l2', 'Squats Level 2', _squat_level_2(), desc='Squats routine, Level 2', categories=['Piernas'])
    _add('squat_l3', 'Squats Level 3', _squat_level_3(), desc='Squats routine, Level 3', categories=['Piernas'])
    _add('squat_l4', 'Squats Level 4', _squat_level_4(), desc='Squats routine, Level 4', categories=['Piernas'])
    _add('squat_l5', 'Squats Level 5', _squat_level_5(), desc='Squats routine, Level 5', categories=['Piernas'])

    return routines
