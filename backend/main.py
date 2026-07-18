"""Barra Austral FastAPI app — backed by PostgreSQL via SQLAlchemy."""
from fastapi import FastAPI, HTTPException, Header, Depends, Request, Query, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse, FileResponse
from pydantic import BaseModel
import io
import csv
import os
import secrets
import time
from pathlib import Path
from typing import Optional

from sqlalchemy.exc import OperationalError

import db as dbmod
from db import (
    SessionLocal, init_db, User, Exercise, Photo, Session as SessionRow,
)
import seeds
from serializers import user_data_to_json, replace_user_data


app = FastAPI(title="Barra Austral API")

PHOTO_DIR = Path(os.getenv("PHOTO_DIR", "/app/data/photos"))

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

ALLOWED_PHOTO_EXT = {".jpg", ".jpeg", ".png", ".webp", ".heic"}
MAX_PHOTO_BYTES = 20 * 1024 * 1024  # 20 MB


# Wait for the DB, then init schema and seed data.
def _wait_for_db_and_seed():
    last_err = None
    for _ in range(30):
        try:
            init_db()
            seeds.run_seeds()
            return
        except OperationalError as e:
            last_err = e
            time.sleep(1)
    raise RuntimeError(f"Database not reachable: {last_err}")


_wait_for_db_and_seed()


# ── Auth helpers ─────────────────────────────────────────────────────────────

def _get_db():
    s = SessionLocal()
    try:
        yield s
    finally:
        s.close()


class LoginReq(BaseModel):
    username: str
    password: str


_failed_attempts = 0
_lockout_active = False
MAX_FAILED_ATTEMPTS = 6


@app.post("/api/login")
def login(req: LoginReq):
    global _failed_attempts, _lockout_active
    if _lockout_active:
        raise HTTPException(status_code=423, detail="App locked. Restart the Docker container to continue.")
    s = SessionLocal()
    try:
        user = s.query(User).filter_by(username=req.username).one_or_none()
        if not user or user.password != req.password:
            _failed_attempts += 1
            if _failed_attempts >= MAX_FAILED_ATTEMPTS:
                _lockout_active = True
            raise HTTPException(status_code=401, detail="Invalid credentials")
        _failed_attempts = 0
        return {"token": user.token, "username": user.username}
    finally:
        s.close()


def current_user(x_api_token: Optional[str] = Header(None)) -> str:
    if _lockout_active:
        raise HTTPException(status_code=423, detail="App locked.")
    if not x_api_token:
        raise HTTPException(status_code=401, detail="Invalid token")
    s = SessionLocal()
    try:
        u = s.query(User).filter_by(token=x_api_token).one_or_none()
        if not u:
            raise HTTPException(status_code=401, detail="Invalid token")
        return u.username
    finally:
        s.close()


def query_user(token: str = Query(...)) -> str:
    s = SessionLocal()
    try:
        u = s.query(User).filter_by(token=token).one_or_none()
        if not u:
            raise HTTPException(status_code=401, detail="Invalid token")
        return u.username
    finally:
        s.close()


# ── Data endpoints (full blob in/out) ────────────────────────────────────────

@app.get("/api/data")
def get_data(username: str = Depends(current_user)):
    s = SessionLocal()
    try:
        user = s.query(User).filter_by(username=username).one()
        return user_data_to_json(user, s)
    finally:
        s.close()


@app.post("/api/data")
async def save_data(request: Request, username: str = Depends(current_user)):
    payload = await request.json()
    s = SessionLocal()
    try:
        user = s.query(User).filter_by(username=username).one()
        replace_user_data(s, user, payload)
        return {"status": "ok"}
    finally:
        s.close()


@app.get("/api/me")
def me(username: str = Depends(current_user)):
    return {"username": username}


@app.get("/api/exercises")
def list_exercises(username: str = Depends(current_user)):
    s = SessionLocal()
    try:
        return [{
            'id': e.id,
            'name': e.name,
            'es': e.name_es,
            'category': e.category,
            'muscles': e.muscles or [],
            'type': e.type or 'reps',
        } for e in s.query(Exercise).order_by(Exercise.id).all()]
    finally:
        s.close()


# ── Photo endpoints ──────────────────────────────────────────────────────────

@app.post("/api/photos")
async def upload_photo(file: UploadFile = File(...), username: str = Depends(current_user)):
    ext = Path(file.filename or "").suffix.lower()
    if ext not in ALLOWED_PHOTO_EXT:
        raise HTTPException(status_code=400, detail=f"Unsupported file type: {ext}")
    user_dir = PHOTO_DIR / username
    user_dir.mkdir(parents=True, exist_ok=True)
    name = f"{secrets.token_hex(12)}{ext}"
    target = user_dir / name
    size = 0
    with open(target, "wb") as out:
        while True:
            chunk = await file.read(1024 * 64)
            if not chunk:
                break
            size += len(chunk)
            if size > MAX_PHOTO_BYTES:
                out.close()
                target.unlink(missing_ok=True)
                raise HTTPException(status_code=413, detail="File too large")
            out.write(chunk)
    return {"filename": name, "url": f"/api/photos/{name}"}


@app.get("/api/photos/{name}")
def get_photo(name: str, username: str = Depends(query_user)):
    if "/" in name or "\\" in name or ".." in name:
        raise HTTPException(status_code=400, detail="Invalid filename")
    target = PHOTO_DIR / username / name
    if not target.exists():
        raise HTTPException(status_code=404, detail="Not found")
    return FileResponse(target)


@app.delete("/api/photos/{name}")
def delete_photo(name: str, username: str = Depends(current_user)):
    if "/" in name or "\\" in name or ".." in name:
        raise HTTPException(status_code=400, detail="Invalid filename")
    target = PHOTO_DIR / username / name
    if target.exists():
        target.unlink()
    return {"status": "ok"}


# ── Export endpoints ─────────────────────────────────────────────────────────

@app.get("/api/export/json")
def export_json(username: str = Depends(query_user)):
    s = SessionLocal()
    try:
        user = s.query(User).filter_by(username=username).one()
        return user_data_to_json(user, s)
    finally:
        s.close()


@app.get("/api/export/flat")
def export_flat(username: str = Depends(query_user)):
    s = SessionLocal()
    try:
        user = s.query(User).filter_by(username=username).one()
        data = user_data_to_json(user, s)
    finally:
        s.close()
    rows = []
    for session in data.get("sessions", []):
        for ex in session.get("exercises", []):
            for i, st in enumerate(ex.get("sets", []), 1):
                rows.append({
                    "date":               session.get("date"),
                    "start_time":         session.get("startTime"),
                    "duration_session_s": session.get("durationSeconds"),
                    "exercise":           ex.get("name"),
                    "category":           ex.get("category"),
                    "set_number":         i,
                    "reps":               st.get("reps", 0),
                    "weight_kg":          st.get("weight"),
                    "duration_s":         st.get("duration", 0),
                })
    return rows


@app.get("/api/export/csv")
def export_csv(username: str = Depends(query_user)):
    s = SessionLocal()
    try:
        user = s.query(User).filter_by(username=username).one()
        data = user_data_to_json(user, s)
    finally:
        s.close()
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow([
        "Date", "Start time", "Session duration (s)",
        "Exercise", "Category", "Set", "Reps", "Weight (kg)", "Set duration (s)",
    ])
    for session in data.get("sessions", []):
        for ex in session.get("exercises", []):
            for i, st in enumerate(ex.get("sets", []), 1):
                writer.writerow([
                    session.get("date"),
                    session.get("startTime"),
                    session.get("durationSeconds"),
                    ex.get("name"),
                    ex.get("category"),
                    i,
                    st.get("reps", 0),
                    st.get("weight", ""),
                    st.get("duration", 0),
                ])
    output.seek(0)
    return StreamingResponse(
        iter(["﻿" + output.read()]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=workouts.csv"},
    )


@app.get("/api/health")
def health():
    return {"status": "ok"}
