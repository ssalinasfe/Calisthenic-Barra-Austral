"""SQLAlchemy engine + ORM models for Barra Austral."""
import os
from datetime import datetime
from sqlalchemy import (
    create_engine, Column, Integer, BigInteger, String, Float, Boolean,
    DateTime, Text, ForeignKey, JSON, UniqueConstraint, Index,
)
from sqlalchemy.orm import declarative_base, sessionmaker, relationship


DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://calistia:calistia_pw@db:5432/calistia")

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()


class User(Base):
    __tablename__ = 'users'
    id        = Column(Integer, primary_key=True)
    username  = Column(String(64), unique=True, nullable=False, index=True)
    password  = Column(String(255), nullable=False)
    token     = Column(String(64), unique=True, nullable=False, index=True)

    routines  = relationship('Routine',  back_populates='user', cascade='all, delete-orphan')
    locations = relationship('Location', back_populates='user', cascade='all, delete-orphan')
    sessions  = relationship('Session',  back_populates='user', cascade='all, delete-orphan')


class Exercise(Base):
    __tablename__ = 'exercises'
    id       = Column(Integer, primary_key=True)
    name     = Column(String(120), unique=True, nullable=False, index=True)
    name_es  = Column(String(120))
    category = Column(String(40), nullable=False)
    muscles  = Column(JSON, default=list)
    type     = Column(String(20), default='reps')   # 'reps' | 'machine'


class Location(Base):
    __tablename__ = 'locations'
    id      = Column(String(64), primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    name    = Column(String(120), nullable=False)
    address = Column(String(255), default='')

    user = relationship('User', back_populates='locations')


class Routine(Base):
    __tablename__ = 'routines'
    id          = Column(String(64), primary_key=True)
    user_id     = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    name        = Column(String(120), nullable=False)
    description = Column(String(255), default='')
    weekdays    = Column(JSON, default=list)        # [0..6]
    categories  = Column(JSON, default=list)        # e.g. ['Push', 'Pull']

    user      = relationship('User', back_populates='routines')
    exercises = relationship('RoutineExercise', back_populates='routine',
                              cascade='all, delete-orphan',
                              order_by='RoutineExercise.position')


class RoutineExercise(Base):
    __tablename__ = 'routine_exercises'
    id              = Column(Integer, primary_key=True)
    routine_id      = Column(String(64), ForeignKey('routines.id', ondelete='CASCADE'), nullable=False, index=True)
    position        = Column(Integer, nullable=False)
    name            = Column(String(120), nullable=False)
    category        = Column(String(40), nullable=False)
    type            = Column(String(20), default='reps')
    tempo           = Column(String(8))
    target_reps     = Column(Integer)
    target_sets     = Column(Integer)
    rest_seconds    = Column(Integer)
    time_seconds    = Column(Integer)
    resistance      = Column(Float)
    superset_group  = Column(Integer)

    routine = relationship('Routine', back_populates='exercises')


class Session(Base):
    __tablename__ = 'sessions'
    id               = Column(String(64), primary_key=True)
    user_id          = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    title            = Column(String(255), default='')
    date             = Column(String(10), nullable=False, index=True)
    start_time       = Column(DateTime, nullable=False)
    end_time         = Column(DateTime)
    duration_seconds = Column(Integer)
    notes            = Column(Text, default='')
    categories       = Column(JSON, default=list)   # muscle groups trained, chosen by the user
    location_id      = Column(String(64), ForeignKey('locations.id', ondelete='SET NULL'))
    routine_id       = Column(String(64))   # weak reference (no FK so deleting a routine doesn't cascade)

    user      = relationship('User', back_populates='sessions')
    exercises = relationship('SessionExercise', back_populates='session',
                              cascade='all, delete-orphan',
                              order_by='SessionExercise.position')
    photos    = relationship('Photo', back_populates='session',
                              cascade='all, delete-orphan')


class SessionExercise(Base):
    __tablename__ = 'session_exercises'
    id         = Column(Integer, primary_key=True)
    session_id = Column(String(64), ForeignKey('sessions.id', ondelete='CASCADE'), nullable=False, index=True)
    position   = Column(Integer, nullable=False)
    name       = Column(String(120), nullable=False)
    category   = Column(String(40), nullable=False)

    session = relationship('Session', back_populates='exercises')
    sets    = relationship('SessionSet', back_populates='exercise',
                            cascade='all, delete-orphan',
                            order_by='SessionSet.position')


class SessionSet(Base):
    __tablename__ = 'session_sets'
    id                  = Column(Integer, primary_key=True)
    session_exercise_id = Column(Integer, ForeignKey('session_exercises.id', ondelete='CASCADE'), nullable=False, index=True)
    position            = Column(Integer, nullable=False)
    started_at          = Column(DateTime)
    duration            = Column(Integer)
    reps                = Column(Integer)
    weight              = Column(Float)
    rest_duration       = Column(Integer)

    exercise = relationship('SessionExercise', back_populates='sets')


class Photo(Base):
    __tablename__ = 'photos'
    id         = Column(Integer, primary_key=True)
    session_id = Column(String(64), ForeignKey('sessions.id', ondelete='CASCADE'), nullable=False, index=True)
    filename   = Column(String(255), nullable=False)

    session = relationship('Session', back_populates='photos')


def init_db():
    """Create all tables, then run lightweight ALTER TABLE migrations."""
    Base.metadata.create_all(bind=engine)
    from sqlalchemy import text
    with engine.begin() as conn:
        # idempotent column additions
        conn.execute(text("ALTER TABLE sessions ADD COLUMN IF NOT EXISTS title VARCHAR(255) DEFAULT ''"))
        conn.execute(text("ALTER TABLE sessions ADD COLUMN IF NOT EXISTS categories JSON DEFAULT '[]'"))
        conn.execute(text("ALTER TABLE routines ADD COLUMN IF NOT EXISTS categories JSON DEFAULT '[]'"))


def get_session():
    return SessionLocal()
