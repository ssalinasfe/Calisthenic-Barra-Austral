"""Seed a year of demo data for the demo user."""
import random
from datetime import datetime, timedelta, timezone

# Subset of canonical exercises (English names matching frontend EXERCISES).
EXERCISES = {
    "Push": [
        "Push-ups", "Wide Push-ups", "Diamond Push-ups",
        "Tricep Extensions", "Archer Push-ups", "Plank Hold",
    ],
    "Pull": [
        "Banded Overhead Pull-aparts", "Banded Horizontal Pull-aparts",
        "Bent Over Barbell Rows", "Australian Pull-ups",
        "Band Assisted Pull-ups", "Pull-ups",
    ],
    "Piernas": [
        "Bodyweight Squats", "Deep Squats", "Bulgarian Split Squats",
        "Cossack Squats", "Pistol Squats (assisted)",
    ],
    "Remo": ["Rowing Machine"],
}

ROUTINE_TEMPLATES = {
    "Push day": ["Push", "Push", "Push", "Push"],
    "Pull day": ["Pull", "Pull", "Pull", "Pull"],
    "Leg day":  ["Piernas", "Piernas", "Piernas", "Piernas"],
    "Full body":["Push", "Pull", "Piernas", "Remo"],
    "Cardio":   ["Remo", "Remo"],
}

# Map weekdays (0=Mon..6=Sun) to a routine, for the demo schedule.
WEEKDAY_ROUTINE = {
    0: "Push day",   # Mon
    2: "Pull day",   # Wed
    4: "Leg day",    # Fri
    5: "Full body",  # Sat
}

LOCATIONS = [
    {"id": "loc_demo_home",  "name": "Home gym",  "address": "Living room"},
    {"id": "loc_demo_park",  "name": "Park",      "address": "Local outdoor park"},
    {"id": "loc_demo_box",   "name": "Calisthenics box", "address": "Downtown"},
]

NOTES_POOL = [
    "Felt strong today.",
    "A bit tired, kept the volume.",
    "Tested a new tempo on the eccentric.",
    "Warm-up took longer than usual.",
    "Sleep was great, set a small PR.",
    "Lower back tight, kept loads light.",
    "Quick session before work.",
    "Pulled the kids' bands by mistake.",
    "Focus on form over reps.",
    "",
    "",
    "",
]


def _iso(dt: datetime) -> str:
    return dt.replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _pick_exercises(category_pattern, week_progress: float):
    """Pick concrete exercises for a session given a category sequence."""
    chosen = []
    seen = set()
    for cat in category_pattern:
        pool = [n for n in EXERCISES[cat] if n not in seen]
        if not pool:
            pool = EXERCISES[cat]
        name = random.choice(pool)
        seen.add(name)
        # Generate sets with mild progression over the year
        n_sets = random.choice([3, 3, 4]) if cat != "Remo" else 1
        base_reps = {
            "Push": 10, "Pull": 6, "Piernas": 12, "Remo": 1,
        }[cat]
        sets = []
        prev_dur = 0
        for i in range(n_sets):
            reps = max(1, int(base_reps * (0.85 + 0.5 * week_progress) + random.randint(-2, 2)))
            duration = random.randint(45, 130)
            rest = random.randint(60, 180) if i < n_sets - 1 else 0
            sets.append({
                "startedAt": None,  # filled in later
                "duration":  duration,
                "reps":      reps,
                "restDuration": rest,
            })
            prev_dur = duration
        chosen.append({"name": name, "category": cat, "sets": sets})
    return chosen


def generate(seed: int = 42) -> dict:
    random.seed(seed)
    now = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    end_day = now
    start_day = end_day - timedelta(days=365)

    sessions = []
    routine_ids_by_name = {}

    # Build routines (mirrors frontend schema: name, description, exercises, weekdays)
    routines = []
    for rname, pattern in ROUTINE_TEMPLATES.items():
        rid = f"rt_demo_{rname.replace(' ', '_').lower()}"
        routine_ids_by_name[rname] = rid
        # Pick a representative exercise list (use first option per category)
        exs = []
        seen = set()
        for cat in pattern:
            for name in EXERCISES[cat]:
                if name not in seen:
                    exs.append({"name": name, "category": cat})
                    seen.add(name)
                    break
        weekdays = [wd for wd, name in WEEKDAY_ROUTINE.items() if name == rname]
        routines.append({
            "id": rid,
            "name": rname,
            "description": f"Auto-generated demo routine ({rname})",
            "exercises": exs,
            "weekdays": weekdays,
        })

    cur = start_day
    week_idx = 0
    while cur <= end_day:
        wd = cur.weekday()  # 0=Mon..6=Sun
        # Train if weekday matches a routine assignment, with some skip chance
        if wd in WEEKDAY_ROUTINE and random.random() > 0.20:
            rname = WEEKDAY_ROUTINE[wd]
            pattern = ROUTINE_TEMPLATES[rname]
            week_progress = week_idx / 52.0
            exs = _pick_exercises(pattern, week_progress)

            # Build session timestamps
            start_hour = random.choice([8, 9, 17, 18, 19])
            start_min = random.randint(0, 59)
            start = cur.replace(hour=start_hour, minute=start_min)
            t = start
            total_dur = 0
            for ex in exs:
                for s in ex["sets"]:
                    s["startedAt"] = _iso(t)
                    advance = s["duration"] + (s.get("restDuration") or 0)
                    t += timedelta(seconds=advance)
                    total_dur += advance
            end = start + timedelta(seconds=total_dur)

            session = {
                "id":              _iso(start),
                "date":            start.strftime("%Y-%m-%d"),
                "startTime":       _iso(start),
                "endTime":         _iso(end),
                "durationSeconds": total_dur,
                "exercises":       exs,
                "routineId":       routine_ids_by_name[rname],
                "locationId":      random.choice(LOCATIONS)["id"] if random.random() > 0.2 else None,
                "notes":           random.choice(NOTES_POOL),
                "photos":          [],
            }
            sessions.append(session)

        cur += timedelta(days=1)
        if wd == 6:
            week_idx += 1

    return {
        "sessions":  sessions,
        "locations": LOCATIONS,
        "routines":  routines,
    }


if __name__ == "__main__":
    import json, sys
    out = generate()
    json.dump(out, sys.stdout, indent=2, ensure_ascii=False)
