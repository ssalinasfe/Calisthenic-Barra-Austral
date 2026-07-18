--
-- PostgreSQL database dump
--

\restrict h04CtFecfqRzZI2pwBr6vwDpW2nTCNNQfFngI02Px8VwSKpDkjOWL2JRPyz89pS

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: exercises; Type: TABLE; Schema: public; Owner: calistia
--

CREATE TABLE public.exercises (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    name_es character varying(120),
    category character varying(40) NOT NULL,
    muscles json,
    type character varying(20)
);


ALTER TABLE public.exercises OWNER TO calistia;

--
-- Name: exercises_id_seq; Type: SEQUENCE; Schema: public; Owner: calistia
--

CREATE SEQUENCE public.exercises_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exercises_id_seq OWNER TO calistia;

--
-- Name: exercises_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calistia
--

ALTER SEQUENCE public.exercises_id_seq OWNED BY public.exercises.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: calistia
--

CREATE TABLE public.locations (
    id character varying(64) NOT NULL,
    user_id integer NOT NULL,
    name character varying(120) NOT NULL,
    address character varying(255)
);


ALTER TABLE public.locations OWNER TO calistia;

--
-- Name: photos; Type: TABLE; Schema: public; Owner: calistia
--

CREATE TABLE public.photos (
    id integer NOT NULL,
    session_id character varying(64) NOT NULL,
    filename character varying(255) NOT NULL
);


ALTER TABLE public.photos OWNER TO calistia;

--
-- Name: photos_id_seq; Type: SEQUENCE; Schema: public; Owner: calistia
--

CREATE SEQUENCE public.photos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.photos_id_seq OWNER TO calistia;

--
-- Name: photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calistia
--

ALTER SEQUENCE public.photos_id_seq OWNED BY public.photos.id;


--
-- Name: routine_exercises; Type: TABLE; Schema: public; Owner: calistia
--

CREATE TABLE public.routine_exercises (
    id integer NOT NULL,
    routine_id character varying(64) NOT NULL,
    "position" integer NOT NULL,
    name character varying(120) NOT NULL,
    category character varying(40) NOT NULL,
    type character varying(20),
    tempo character varying(8),
    target_reps integer,
    target_sets integer,
    rest_seconds integer,
    time_seconds integer,
    resistance double precision,
    superset_group integer
);


ALTER TABLE public.routine_exercises OWNER TO calistia;

--
-- Name: routine_exercises_id_seq; Type: SEQUENCE; Schema: public; Owner: calistia
--

CREATE SEQUENCE public.routine_exercises_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.routine_exercises_id_seq OWNER TO calistia;

--
-- Name: routine_exercises_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calistia
--

ALTER SEQUENCE public.routine_exercises_id_seq OWNED BY public.routine_exercises.id;


--
-- Name: routines; Type: TABLE; Schema: public; Owner: calistia
--

CREATE TABLE public.routines (
    id character varying(64) NOT NULL,
    user_id integer NOT NULL,
    name character varying(120) NOT NULL,
    description character varying(255),
    weekdays json
);


ALTER TABLE public.routines OWNER TO calistia;

--
-- Name: session_exercises; Type: TABLE; Schema: public; Owner: calistia
--

CREATE TABLE public.session_exercises (
    id integer NOT NULL,
    session_id character varying(64) NOT NULL,
    "position" integer NOT NULL,
    name character varying(120) NOT NULL,
    category character varying(40) NOT NULL
);


ALTER TABLE public.session_exercises OWNER TO calistia;

--
-- Name: session_exercises_id_seq; Type: SEQUENCE; Schema: public; Owner: calistia
--

CREATE SEQUENCE public.session_exercises_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.session_exercises_id_seq OWNER TO calistia;

--
-- Name: session_exercises_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calistia
--

ALTER SEQUENCE public.session_exercises_id_seq OWNED BY public.session_exercises.id;


--
-- Name: session_sets; Type: TABLE; Schema: public; Owner: calistia
--

CREATE TABLE public.session_sets (
    id integer NOT NULL,
    session_exercise_id integer NOT NULL,
    "position" integer NOT NULL,
    started_at timestamp without time zone,
    duration integer,
    reps integer,
    weight double precision,
    rest_duration integer
);


ALTER TABLE public.session_sets OWNER TO calistia;

--
-- Name: session_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: calistia
--

CREATE SEQUENCE public.session_sets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.session_sets_id_seq OWNER TO calistia;

--
-- Name: session_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calistia
--

ALTER SEQUENCE public.session_sets_id_seq OWNED BY public.session_sets.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: calistia
--

CREATE TABLE public.sessions (
    id character varying(64) NOT NULL,
    user_id integer NOT NULL,
    date character varying(10) NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    duration_seconds integer,
    notes text,
    location_id character varying(64),
    routine_id character varying(64),
    title character varying(255) DEFAULT ''::character varying
);


ALTER TABLE public.sessions OWNER TO calistia;

--
-- Name: users; Type: TABLE; Schema: public; Owner: calistia
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(64) NOT NULL,
    password character varying(255) NOT NULL,
    token character varying(64) NOT NULL
);


ALTER TABLE public.users OWNER TO calistia;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: calistia
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO calistia;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: calistia
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: exercises id; Type: DEFAULT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.exercises ALTER COLUMN id SET DEFAULT nextval('public.exercises_id_seq'::regclass);


--
-- Name: photos id; Type: DEFAULT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.photos ALTER COLUMN id SET DEFAULT nextval('public.photos_id_seq'::regclass);


--
-- Name: routine_exercises id; Type: DEFAULT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.routine_exercises ALTER COLUMN id SET DEFAULT nextval('public.routine_exercises_id_seq'::regclass);


--
-- Name: session_exercises id; Type: DEFAULT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.session_exercises ALTER COLUMN id SET DEFAULT nextval('public.session_exercises_id_seq'::regclass);


--
-- Name: session_sets id; Type: DEFAULT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.session_sets ALTER COLUMN id SET DEFAULT nextval('public.session_sets_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: exercises; Type: TABLE DATA; Schema: public; Owner: calistia
--

COPY public.exercises (id, name, name_es, category, muscles, type) FROM stdin;
1	Plank Hold	Plancha	Push	["Core", "Shoulders"]	reps
2	Scapula Push-ups	Flexiones escapulares	Push	["Serratus", "Traps", "Shoulders"]	reps
3	Negative Push-ups	Flexiones negativas	Push	["Chest", "Triceps", "Shoulders"]	reps
4	Push-ups	Flexión estándar	Push	["Chest", "Triceps", "Shoulders"]	reps
5	Wide Push-ups	Flexión amplia	Push	["Chest", "Shoulders"]	reps
6	Diamond Push-ups	Flexión diamante	Push	["Triceps", "Chest"]	reps
7	Tricep Extensions	Extensiones de tríceps	Push	["Triceps"]	reps
8	Explosive Push-ups	Flexión explosiva	Push	["Chest", "Triceps", "Shoulders"]	reps
9	Archer Push-ups	Flexión de arquero	Push	["Chest", "Triceps", "Shoulders"]	reps
10	One-arm Push-up	Flexión a una mano	Push	["Chest", "Triceps", "Core"]	reps
11	Banded Overhead Pull-aparts	Aperturas superiores con banda	Pull	["Rear Delts", "Traps"]	reps
12	Banded Horizontal Pull-aparts	Aperturas horizontales con banda	Pull	["Rear Delts", "Rhomboids"]	reps
13	Banded Pull-downs	Jalones con banda	Pull	["Lats", "Back"]	reps
14	Bent Over Barbell Rows	Remo inclinado con barra	Pull	["Lats", "Mid Back", "Biceps"]	reps
15	Passive Hang	Colgado pasivo	Pull	["Forearms", "Lats"]	reps
16	Scapula Pull-ups	Dominadas escapulares	Pull	["Traps", "Lats"]	reps
17	Australian Pull-ups	Dominadas australianas	Pull	["Lats", "Mid Back", "Biceps"]	reps
18	Negative Pull-ups	Dominadas negativas	Pull	["Lats", "Biceps", "Forearms"]	reps
19	Band Assisted Pull-ups	Dominadas asistidas con banda	Pull	["Lats", "Biceps", "Forearms"]	reps
20	Pull-ups	Dominada	Pull	["Lats", "Biceps", "Forearms"]	reps
21	Bodyweight Squats	Sentadilla con peso corporal	Piernas	["Quads", "Glutes"]	reps
22	Narrow Stance Squats	Sentadilla postura cerrada	Piernas	["Quads"]	reps
23	Deep Squats	Sentadilla profunda	Piernas	["Quads", "Glutes", "Hamstrings"]	reps
24	Bulgarian Split Squats	Sentadilla búlgara	Piernas	["Quads", "Glutes", "Hamstrings"]	reps
25	Cossack Squats	Sentadilla cosaca	Piernas	["Quads", "Glutes", "Adductors"]	reps
26	Pistol Squats (assisted)	Sentadilla pistola (variante)	Piernas	["Quads", "Glutes", "Core"]	reps
27	Pistol Squats	Sentadilla pistola	Piernas	["Quads", "Glutes", "Core"]	reps
28	Rowing Machine	Máquina de remos	Remo	["Heart"]	machine
29	Treadmill	Trotadora	Remo	["Heart"]	machine
30	Air Bike	Bicicleta de aire	Remo	["Heart"]	machine
31	Spin Bike	Bicicleta de spinning	Remo	["Heart"]	machine
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: calistia
--

COPY public.locations (id, user_id, name, address) FROM stdin;
loc_demo_home	2	Home gym	Living room
loc_demo_park	2	Park	Local outdoor park
loc_demo_box	2	Calisthenics box	Downtown
loc_moug854i_aitp	1	Gym piso 3	
loc_moug8aqx_qb92	1	Gym piso 1	
\.


--
-- Data for Name: photos; Type: TABLE DATA; Schema: public; Owner: calistia
--

COPY public.photos (id, session_id, filename) FROM stdin;
762	2026-05-06T16:21:49.842Z	5678d35309597d974d72913b.jpg
763	2026-05-07T16:13:24.136Z	545b2c233c66a3253084ba0b.jpg
764	2026-05-09T16:16:50.919Z	89ea9ede0b9e5235ff6aa656.jpg
765	2026-05-11T16:28:02.992Z	6ba07b7bce99dfffb1015281.jpg
766	2026-05-12T15:16:12.252Z	fdb35e58d3e91c7a53e01348.jpg
767	2026-05-13T16:31:24.573Z	0eee3d9285f5b10d38b0a810.jpg
768	2026-05-14T16:18:21.291Z	c4e1960fba8441be5f0f0781.jpg
769	2026-05-18T16:33:30.887Z	210657175c88924ed124a1d0.jpg
770	2026-05-19T16:19:21.255Z	0f0ea10d2840e7e7815c4e67.jpg
771	2026-05-20T16:23:01.321Z	6adb569fa58bf3910bdec4a7.jpg
772	2026-05-21T16:14:10.883Z	5b8e572627a554f003ed2879.jpg
773	2026-05-25T16:25:22.317Z	554b03938cf2c7c37ac67c5f.jpg
774	2026-05-26T16:12:03.158Z	98c56c6bd98baf9d2ff20a58.jpg
775	2026-05-28T01:07:21.153Z	1f74d2cdc048bc6d88aa67d7.jpg
776	2026-05-28T16:13:41.156Z	f0647ba62f8abd581fe70ee7.jpg
777	2026-05-29T16:21:06.809Z	dce5e31d2b96b99d240362fc.jpg
778	2026-05-30T15:17:00.374Z	bd0a3850eaaa68ee8e55ee7d.jpg
779	2026-06-01T16:22:56.752Z	1ad485ec14b7a64064b2fda0.jpg
780	2026-06-02T16:27:50.084Z	1513cebbbfc9af57c53af904.jpg
781	2026-06-03T16:14:15.660Z	45f419e5727ff476f746444b.jpg
782	2026-06-04T16:30:37.675Z	c9a8f03dd58fcd9f07e642f8.jpg
783	2026-06-05T16:19:15.145Z	9256d867d29517be7a9960d3.jpg
784	2026-06-06T16:27:21.439Z	95619fc32b3bf6ae476da31b.jpg
785	2026-06-08T18:06:28.356Z	55599c68c64d4fa75672740b.jpg
786	2026-06-09T16:16:35.866Z	3e750d6a7b3eb4977e942ad5.jpg
787	2026-06-16T17:19:26.989Z	b6674e7c8f5c293e6d081ace.jpg
788	2026-06-18T18:13:15.627Z	a22656620d2f2faa7f8877fd.jpg
789	2026-06-19T16:21:01.333Z	da6806b527e151dbc0c57578.jpg
790	2026-06-30T16:13:50.668Z	c501073db385c7d6b7e52d65.jpg
791	2026-07-11T15:05:43.256Z	b00fd340f579470180b2c0d7.jpg
792	2026-07-14T01:06:43.231Z	13163b5afceea9579f7aeead.jpg
\.


--
-- Data for Name: routine_exercises; Type: TABLE DATA; Schema: public; Owner: calistia
--

COPY public.routine_exercises (id, routine_id, "position", name, category, type, tempo, target_reps, target_sets, rest_seconds, time_seconds, resistance, superset_group) FROM stdin;
5565	rt_cuyi_push_l3	0	Diamond Push-ups	Push	reps	2010	15	3	120	\N	\N	\N
5566	rt_cuyi_push_l3	1	Push-ups	Push	reps	2010	8	3	120	\N	\N	1
5567	rt_cuyi_push_l3	2	Tricep Extensions	Push	reps	2010	8	3	120	\N	\N	1
5568	rt_cuyi_push_l3	3	Wide Push-ups	Push	reps	2010	6	3	90	\N	\N	\N
5569	rt_cuyi_push_l3	4	Negative Push-ups	Push	reps	4000	4	3	180	\N	\N	\N
5570	rt_cuyi_push_l3	5	Rowing Machine	Remo	machine	\N	\N	1	0	600	5	\N
5571	rt_cuyi_push_l4	0	Explosive Push-ups	Push	reps	1010	6	2	120	\N	\N	\N
5572	rt_cuyi_push_l4	1	Push-ups	Push	reps	2010	10	3	180	\N	\N	1
5573	rt_cuyi_push_l4	2	Plank Hold	Push	reps	2010	\N	3	180	60	\N	1
5574	rt_cuyi_push_l4	3	Archer Push-ups	Push	reps	2010	2	3	120	\N	\N	\N
5575	rt_cuyi_push_l4	4	Diamond Push-ups	Push	reps	2010	10	2	120	\N	\N	\N
5576	rt_cuyi_push_l4	5	Rowing Machine	Remo	machine	\N	\N	1	0	600	5	\N
5577	rt_cuyi_push_l5	0	Archer Push-ups	Push	reps	2010	4	4	180	\N	\N	1
5578	rt_cuyi_push_l5	1	Diamond Push-ups	Push	reps	2010	5	4	180	\N	\N	1
5579	rt_cuyi_push_l5	2	One-arm Push-up	Push	reps	2010	1	3	120	\N	\N	\N
5580	rt_cuyi_push_l5	3	Push-ups	Push	reps	2010	6	5	120	\N	\N	2
5581	rt_cuyi_push_l5	4	Wide Push-ups	Push	reps	2010	5	5	180	\N	\N	2
5582	rt_cuyi_push_l5	5	Rowing Machine	Remo	machine	\N	\N	1	0	600	5	\N
5583	rt_cuyi_pull_l2	0	Australian Pull-ups	Pull	reps	2010	12	3	180	\N	\N	1
5584	rt_cuyi_pull_l2	1	Scapula Pull-ups	Pull	reps	2010	12	3	180	\N	\N	1
5585	rt_cuyi_pull_l2	2	Air Bike	Remo	machine	\N	\N	1	0	1800	4	\N
5586	rt_cuyi_pull_l3	0	Band Assisted Pull-ups	Pull	reps	2010	6	3	180	\N	\N	\N
5587	rt_cuyi_pull_l3	1	Australian Pull-ups	Pull	reps	2010	12	4	180	\N	\N	1
5588	rt_cuyi_pull_l3	2	Scapula Pull-ups	Pull	reps	2010	12	4	180	\N	\N	1
5589	rt_cuyi_pull_l3	3	Air Bike	Remo	machine	\N	\N	1	0	1800	4	\N
5590	rt_cuyi_pull_l4	0	Negative Pull-ups	Pull	reps	10000	1	5	60	\N	\N	\N
5591	rt_cuyi_pull_l4	1	Band Assisted Pull-ups	Pull	reps	2010	6	3	180	\N	\N	\N
5592	rt_cuyi_pull_l4	2	Australian Pull-ups	Pull	reps	2010	8	3	180	\N	\N	1
5593	rt_cuyi_pull_l4	3	Scapula Pull-ups	Pull	reps	2010	5	3	180	\N	\N	1
5594	rt_cuyi_pull_l4	4	Passive Hang	Pull	reps	2010	\N	3	180	30	\N	1
5595	rt_cuyi_pull_l4	5	Air Bike	Remo	machine	\N	\N	1	0	1800	4	\N
5596	rt_cuyi_pull_l5	0	Pull-ups	Pull	reps	2010	3	3	180	\N	\N	\N
5597	rt_cuyi_pull_l5	1	Band Assisted Pull-ups	Pull	reps	2010	10	3	180	\N	\N	\N
5598	rt_cuyi_pull_l5	2	Australian Pull-ups	Pull	reps	2010	8	3	180	\N	\N	1
5599	rt_cuyi_pull_l5	3	Scapula Pull-ups	Pull	reps	2010	5	3	180	\N	\N	1
5600	rt_cuyi_pull_l5	4	Passive Hang	Pull	reps	2010	\N	3	180	30	\N	1
5601	rt_cuyi_pull_l5	5	Air Bike	Remo	machine	\N	\N	1	0	1800	4	\N
5602	rt_cuyi_squat_l3	0	Cossack Squats	Piernas	reps	2010	6	3	120	\N	\N	\N
5603	rt_cuyi_squat_l3	1	Bulgarian Split Squats	Piernas	reps	2010	8	3	120	\N	\N	\N
5604	rt_cuyi_squat_l3	2	Narrow Stance Squats	Piernas	reps	2010	8	3	180	\N	\N	1
5605	rt_cuyi_squat_l3	3	Deep Squats	Piernas	reps	3010	8	3	180	\N	\N	1
5606	rt_cuyi_squat_l3	4	Rowing Machine	Remo	machine	\N	\N	1	0	600	5	\N
5607	rt_cuyi_squat_l4	0	Pistol Squats (assisted)	Piernas	reps	3010	10	3	120	\N	\N	\N
5608	rt_cuyi_squat_l4	1	Cossack Squats	Piernas	reps	2010	8	3	100	\N	\N	\N
5609	rt_cuyi_squat_l4	2	Bulgarian Split Squats	Piernas	reps	2010	10	3	100	\N	\N	\N
5610	rt_cuyi_squat_l4	3	Deep Squats	Piernas	reps	3010	12	3	100	\N	\N	\N
5611	rt_cuyi_squat_l4	4	Rowing Machine	Remo	machine	\N	\N	1	0	600	5	\N
5612	rt_cuyi_squat_l5	0	Pistol Squats	Piernas	reps	2020	3	3	120	\N	\N	\N
5613	rt_cuyi_squat_l5	1	Pistol Squats (assisted)	Piernas	reps	3010	6	2	120	\N	\N	\N
5614	rt_cuyi_squat_l5	2	Cossack Squats	Piernas	reps	2010	8	3	120	\N	\N	\N
5615	rt_cuyi_squat_l5	3	Bulgarian Split Squats	Piernas	reps	2010	10	3	120	\N	\N	1
5616	rt_cuyi_squat_l5	4	Deep Squats	Piernas	reps	3010	10	3	120	\N	\N	1
5617	rt_cuyi_squat_l5	5	Rowing Machine	Remo	machine	\N	\N	1	0	600	5	\N
5618	rt_cuyi_squat_l1	0	Deep Squats	Piernas	reps	2010	12	3	120	\N	\N	\N
5619	rt_cuyi_squat_l1	1	Narrow Stance Squats	Piernas	reps	2010	12	3	120	\N	\N	\N
5620	rt_cuyi_squat_l1	2	Bodyweight Squats	Piernas	reps	2010	15	3	120	\N	\N	\N
5621	rt_cuyi_squat_l1	3	Rowing Machine	Remo	machine	\N	\N	1	0	600	5	\N
5622	rt_cuyi_squat_l2	0	Bulgarian Split Squats	Piernas	reps	3010	6	3	180	\N	\N	\N
5623	rt_cuyi_squat_l2	1	Narrow Stance Squats	Piernas	reps	2010	10	3	180	\N	\N	1
5624	rt_cuyi_squat_l2	2	Deep Squats	Piernas	reps	3010	10	3	180	\N	\N	1
5625	rt_cuyi_squat_l2	3	Spin Bike	Remo	machine	\N	\N	1	0	600	5	\N
5626	rt_cuyi_pull_l1	0	Bent Over Barbell Rows	Pull	reps	2010	15	3	180	\N	\N	1
5627	rt_cuyi_pull_l1	1	Passive Hang	Pull	reps	2010	\N	3	180	60	\N	1
5628	rt_cuyi_pull_l1	2	Air Bike	Remo	machine	\N	\N	1	0	1800	4	\N
5629	rt_cuyi_push_l1	0	Negative Push-ups	Push	reps	4000	8	3	120	\N	\N	\N
5630	rt_cuyi_push_l1	1	Scapula Push-ups	Push	reps	2010	8	4	120	\N	\N	\N
5631	rt_cuyi_push_l1	2	Plank Hold	Push	reps	2010	\N	4	120	60	\N	\N
5632	rt_cuyi_push_l1	3	Rowing Machine	Remo	machine	\N	\N	1	0	600	5	\N
5633	rt_cuyi_push_l2	0	Push-ups	Push	reps	2010	12	3	120	\N	\N	\N
5634	rt_cuyi_push_l2	1	Negative Push-ups	Push	reps	4000	8	3	120	\N	\N	\N
5635	rt_cuyi_push_l2	2	Scapula Push-ups	Push	reps	2010	8	4	180	\N	\N	1
5636	rt_cuyi_push_l2	3	Plank Hold	Push	reps	2010	\N	4	180	60	\N	1
5637	rt_cuyi_push_l2	4	Rowing Machine	Remo	machine	\N	\N	1	0	600	5	\N
74	rt_demo_push_day	0	Push-ups	Push	reps	2010	10	3	120	\N	\N	\N
75	rt_demo_push_day	1	Wide Push-ups	Push	reps	2010	10	3	120	\N	\N	\N
76	rt_demo_push_day	2	Diamond Push-ups	Push	reps	2010	10	3	120	\N	\N	\N
77	rt_demo_push_day	3	Tricep Extensions	Push	reps	2010	10	3	120	\N	\N	\N
78	rt_demo_pull_day	0	Banded Overhead Pull-aparts	Pull	reps	2010	10	3	120	\N	\N	\N
79	rt_demo_pull_day	1	Banded Horizontal Pull-aparts	Pull	reps	2010	10	3	120	\N	\N	\N
80	rt_demo_pull_day	2	Bent Over Barbell Rows	Pull	reps	2010	10	3	120	\N	\N	\N
81	rt_demo_pull_day	3	Australian Pull-ups	Pull	reps	2010	10	3	120	\N	\N	\N
82	rt_demo_leg_day	0	Bodyweight Squats	Piernas	reps	2010	10	3	120	\N	\N	\N
83	rt_demo_leg_day	1	Deep Squats	Piernas	reps	2010	10	3	120	\N	\N	\N
84	rt_demo_leg_day	2	Bulgarian Split Squats	Piernas	reps	2010	10	3	120	\N	\N	\N
85	rt_demo_leg_day	3	Cossack Squats	Piernas	reps	2010	10	3	120	\N	\N	\N
86	rt_demo_full_body	0	Push-ups	Push	reps	2010	10	3	120	\N	\N	\N
87	rt_demo_full_body	1	Banded Overhead Pull-aparts	Pull	reps	2010	10	3	120	\N	\N	\N
88	rt_demo_full_body	2	Bodyweight Squats	Piernas	reps	2010	10	3	120	\N	\N	\N
89	rt_demo_full_body	3	Rowing Machine	Remo	machine	\N	\N	1	0	600	5	\N
\.


--
-- Data for Name: routines; Type: TABLE DATA; Schema: public; Owner: calistia
--

COPY public.routines (id, user_id, name, description, weekdays) FROM stdin;
rt_cuyi_push_l3	1	Push-ups Level 3	Push-ups routine, Level 3	[]
rt_cuyi_push_l4	1	Push-ups Level 4	Push-ups routine, Level 4	[]
rt_cuyi_push_l5	1	Push-ups Level 5	Push-ups routine, Level 5	[]
rt_cuyi_pull_l2	1	Pull-ups Level 2	Pull-ups routine, Level 2	[]
rt_cuyi_pull_l3	1	Pull-ups Level 3	Pull-ups routine, Level 3	[]
rt_cuyi_pull_l4	1	Pull-ups Level 4	Pull-ups routine, Level 4	[]
rt_cuyi_pull_l5	1	Pull-ups Level 5	Pull-ups routine, Level 5	[]
rt_cuyi_squat_l3	1	Squats Level 3	Squats routine, Level 3	[]
rt_cuyi_squat_l4	1	Squats Level 4	Squats routine, Level 4	[]
rt_cuyi_squat_l5	1	Squats Level 5	Squats routine, Level 5	[]
rt_cuyi_squat_l1	1	Squats Level 1	Squats routine, Level 1	[]
rt_cuyi_squat_l2	1	Squats Level 2	Squats routine, Level 2	[2, 5]
rt_cuyi_pull_l1	1	Pull-ups Level 1	Pull-ups routine, Level 1	[1, 4]
rt_cuyi_push_l1	1	Push-ups Level 1	Push-ups routine, Level 1	[]
rt_cuyi_push_l2	1	Push-ups Level 2	Push-ups routine, Level 2	[0, 3]
rt_demo_push_day	2	Push day	Auto-generated demo routine (Push day)	[0]
rt_demo_pull_day	2	Pull day	Auto-generated demo routine (Pull day)	[2]
rt_demo_leg_day	2	Leg day	Auto-generated demo routine (Leg day)	[4]
rt_demo_full_body	2	Full body	Auto-generated demo routine (Full body)	[5]
\.


--
-- Data for Name: session_exercises; Type: TABLE DATA; Schema: public; Owner: calistia
--

COPY public.session_exercises (id, session_id, "position", name, category) FROM stdin;
1	2025-05-07T08:47:00Z	0	Banded Horizontal Pull-aparts	Pull
2	2025-05-07T08:47:00Z	1	Bent Over Barbell Rows	Pull
3	2025-05-07T08:47:00Z	2	Australian Pull-ups	Pull
4	2025-05-07T08:47:00Z	3	Band Assisted Pull-ups	Pull
5	2025-05-09T08:46:00Z	0	Bodyweight Squats	Piernas
6	2025-05-09T08:46:00Z	1	Deep Squats	Piernas
7	2025-05-09T08:46:00Z	2	Cossack Squats	Piernas
8	2025-05-09T08:46:00Z	3	Bulgarian Split Squats	Piernas
9	2025-05-10T08:51:00Z	0	Diamond Push-ups	Push
10	2025-05-10T08:51:00Z	1	Pull-ups	Pull
11	2025-05-10T08:51:00Z	2	Cossack Squats	Piernas
12	2025-05-10T08:51:00Z	3	Rowing Machine	Remo
13	2025-05-14T18:33:00Z	0	Banded Overhead Pull-aparts	Pull
14	2025-05-14T18:33:00Z	1	Banded Horizontal Pull-aparts	Pull
15	2025-05-14T18:33:00Z	2	Australian Pull-ups	Pull
16	2025-05-14T18:33:00Z	3	Bent Over Barbell Rows	Pull
17	2025-05-17T08:48:00Z	0	Wide Push-ups	Push
18	2025-05-17T08:48:00Z	1	Pull-ups	Pull
19	2025-05-17T08:48:00Z	2	Bodyweight Squats	Piernas
20	2025-05-17T08:48:00Z	3	Rowing Machine	Remo
21	2025-05-19T08:14:00Z	0	Diamond Push-ups	Push
22	2025-05-19T08:14:00Z	1	Plank Hold	Push
23	2025-05-19T08:14:00Z	2	Archer Push-ups	Push
24	2025-05-19T08:14:00Z	3	Wide Push-ups	Push
25	2025-05-21T08:28:00Z	0	Banded Overhead Pull-aparts	Pull
26	2025-05-21T08:28:00Z	1	Bent Over Barbell Rows	Pull
27	2025-05-21T08:28:00Z	2	Pull-ups	Pull
28	2025-05-21T08:28:00Z	3	Banded Horizontal Pull-aparts	Pull
29	2025-05-23T08:38:00Z	0	Cossack Squats	Piernas
30	2025-05-23T08:38:00Z	1	Bulgarian Split Squats	Piernas
31	2025-05-23T08:38:00Z	2	Pistol Squats (assisted)	Piernas
32	2025-05-23T08:38:00Z	3	Bodyweight Squats	Piernas
33	2025-05-24T17:39:00Z	0	Push-ups	Push
34	2025-05-24T17:39:00Z	1	Bent Over Barbell Rows	Pull
35	2025-05-24T17:39:00Z	2	Cossack Squats	Piernas
36	2025-05-24T17:39:00Z	3	Rowing Machine	Remo
37	2025-05-26T19:45:00Z	0	Push-ups	Push
38	2025-05-26T19:45:00Z	1	Archer Push-ups	Push
39	2025-05-26T19:45:00Z	2	Wide Push-ups	Push
40	2025-05-26T19:45:00Z	3	Tricep Extensions	Push
41	2025-05-30T18:55:00Z	0	Deep Squats	Piernas
42	2025-05-30T18:55:00Z	1	Cossack Squats	Piernas
43	2025-05-30T18:55:00Z	2	Bodyweight Squats	Piernas
44	2025-05-30T18:55:00Z	3	Pistol Squats (assisted)	Piernas
45	2025-06-02T19:43:00Z	0	Diamond Push-ups	Push
46	2025-06-02T19:43:00Z	1	Plank Hold	Push
47	2025-06-02T19:43:00Z	2	Archer Push-ups	Push
48	2025-06-02T19:43:00Z	3	Tricep Extensions	Push
49	2025-06-04T19:21:00Z	0	Pull-ups	Pull
50	2025-06-04T19:21:00Z	1	Banded Overhead Pull-aparts	Pull
51	2025-06-04T19:21:00Z	2	Bent Over Barbell Rows	Pull
52	2025-06-04T19:21:00Z	3	Banded Horizontal Pull-aparts	Pull
53	2025-06-06T19:27:00Z	0	Cossack Squats	Piernas
54	2025-06-06T19:27:00Z	1	Deep Squats	Piernas
55	2025-06-06T19:27:00Z	2	Pistol Squats (assisted)	Piernas
56	2025-06-06T19:27:00Z	3	Bulgarian Split Squats	Piernas
57	2025-06-07T19:44:00Z	0	Tricep Extensions	Push
58	2025-06-07T19:44:00Z	1	Banded Horizontal Pull-aparts	Pull
59	2025-06-07T19:44:00Z	2	Cossack Squats	Piernas
60	2025-06-07T19:44:00Z	3	Rowing Machine	Remo
61	2025-06-09T18:11:00Z	0	Tricep Extensions	Push
62	2025-06-09T18:11:00Z	1	Push-ups	Push
63	2025-06-09T18:11:00Z	2	Wide Push-ups	Push
64	2025-06-09T18:11:00Z	3	Archer Push-ups	Push
65	2025-06-11T09:19:00Z	0	Banded Overhead Pull-aparts	Pull
66	2025-06-11T09:19:00Z	1	Australian Pull-ups	Pull
67	2025-06-11T09:19:00Z	2	Band Assisted Pull-ups	Pull
68	2025-06-11T09:19:00Z	3	Bent Over Barbell Rows	Pull
69	2025-06-13T19:17:00Z	0	Bodyweight Squats	Piernas
70	2025-06-13T19:17:00Z	1	Deep Squats	Piernas
71	2025-06-13T19:17:00Z	2	Cossack Squats	Piernas
72	2025-06-13T19:17:00Z	3	Pistol Squats (assisted)	Piernas
73	2025-06-14T17:30:00Z	0	Diamond Push-ups	Push
74	2025-06-14T17:30:00Z	1	Banded Overhead Pull-aparts	Pull
75	2025-06-14T17:30:00Z	2	Pistol Squats (assisted)	Piernas
76	2025-06-14T17:30:00Z	3	Rowing Machine	Remo
77	2025-06-16T19:18:00Z	0	Plank Hold	Push
78	2025-06-16T19:18:00Z	1	Wide Push-ups	Push
79	2025-06-16T19:18:00Z	2	Push-ups	Push
80	2025-06-16T19:18:00Z	3	Archer Push-ups	Push
81	2025-06-18T19:03:00Z	0	Banded Horizontal Pull-aparts	Pull
82	2025-06-18T19:03:00Z	1	Band Assisted Pull-ups	Pull
83	2025-06-18T19:03:00Z	2	Banded Overhead Pull-aparts	Pull
84	2025-06-18T19:03:00Z	3	Pull-ups	Pull
85	2025-06-20T19:58:00Z	0	Bodyweight Squats	Piernas
86	2025-06-20T19:58:00Z	1	Deep Squats	Piernas
87	2025-06-20T19:58:00Z	2	Bulgarian Split Squats	Piernas
88	2025-06-20T19:58:00Z	3	Pistol Squats (assisted)	Piernas
89	2025-06-21T18:18:00Z	0	Archer Push-ups	Push
90	2025-06-21T18:18:00Z	1	Banded Overhead Pull-aparts	Pull
91	2025-06-21T18:18:00Z	2	Cossack Squats	Piernas
92	2025-06-21T18:18:00Z	3	Rowing Machine	Remo
93	2025-06-23T17:35:00Z	0	Tricep Extensions	Push
94	2025-06-23T17:35:00Z	1	Diamond Push-ups	Push
95	2025-06-23T17:35:00Z	2	Wide Push-ups	Push
96	2025-06-23T17:35:00Z	3	Plank Hold	Push
97	2025-06-25T19:48:00Z	0	Australian Pull-ups	Pull
98	2025-06-25T19:48:00Z	1	Bent Over Barbell Rows	Pull
99	2025-06-25T19:48:00Z	2	Pull-ups	Pull
100	2025-06-25T19:48:00Z	3	Banded Horizontal Pull-aparts	Pull
101	2025-06-27T17:40:00Z	0	Pistol Squats (assisted)	Piernas
102	2025-06-27T17:40:00Z	1	Bodyweight Squats	Piernas
103	2025-06-27T17:40:00Z	2	Bulgarian Split Squats	Piernas
104	2025-06-27T17:40:00Z	3	Cossack Squats	Piernas
105	2025-06-28T18:57:00Z	0	Wide Push-ups	Push
106	2025-06-28T18:57:00Z	1	Bent Over Barbell Rows	Pull
107	2025-06-28T18:57:00Z	2	Bulgarian Split Squats	Piernas
108	2025-06-28T18:57:00Z	3	Rowing Machine	Remo
109	2025-06-30T09:40:00Z	0	Diamond Push-ups	Push
110	2025-06-30T09:40:00Z	1	Push-ups	Push
111	2025-06-30T09:40:00Z	2	Archer Push-ups	Push
112	2025-06-30T09:40:00Z	3	Wide Push-ups	Push
113	2025-07-02T08:29:00Z	0	Band Assisted Pull-ups	Pull
114	2025-07-02T08:29:00Z	1	Bent Over Barbell Rows	Pull
115	2025-07-02T08:29:00Z	2	Australian Pull-ups	Pull
116	2025-07-02T08:29:00Z	3	Pull-ups	Pull
117	2025-07-05T18:28:00Z	0	Push-ups	Push
118	2025-07-05T18:28:00Z	1	Pull-ups	Pull
119	2025-07-05T18:28:00Z	2	Bodyweight Squats	Piernas
120	2025-07-05T18:28:00Z	3	Rowing Machine	Remo
121	2025-07-07T08:42:00Z	0	Wide Push-ups	Push
122	2025-07-07T08:42:00Z	1	Diamond Push-ups	Push
123	2025-07-07T08:42:00Z	2	Tricep Extensions	Push
124	2025-07-07T08:42:00Z	3	Plank Hold	Push
125	2025-07-11T19:35:00Z	0	Cossack Squats	Piernas
126	2025-07-11T19:35:00Z	1	Pistol Squats (assisted)	Piernas
127	2025-07-11T19:35:00Z	2	Deep Squats	Piernas
128	2025-07-11T19:35:00Z	3	Bulgarian Split Squats	Piernas
129	2025-07-12T18:22:00Z	0	Plank Hold	Push
130	2025-07-12T18:22:00Z	1	Banded Horizontal Pull-aparts	Pull
131	2025-07-12T18:22:00Z	2	Deep Squats	Piernas
132	2025-07-12T18:22:00Z	3	Rowing Machine	Remo
133	2025-07-14T17:00:00Z	0	Archer Push-ups	Push
134	2025-07-14T17:00:00Z	1	Diamond Push-ups	Push
135	2025-07-14T17:00:00Z	2	Wide Push-ups	Push
136	2025-07-14T17:00:00Z	3	Plank Hold	Push
137	2025-07-16T19:31:00Z	0	Banded Overhead Pull-aparts	Pull
138	2025-07-16T19:31:00Z	1	Australian Pull-ups	Pull
139	2025-07-16T19:31:00Z	2	Bent Over Barbell Rows	Pull
140	2025-07-16T19:31:00Z	3	Band Assisted Pull-ups	Pull
141	2025-07-18T17:05:00Z	0	Deep Squats	Piernas
142	2025-07-18T17:05:00Z	1	Bulgarian Split Squats	Piernas
143	2025-07-18T17:05:00Z	2	Cossack Squats	Piernas
144	2025-07-18T17:05:00Z	3	Pistol Squats (assisted)	Piernas
145	2025-07-19T17:09:00Z	0	Tricep Extensions	Push
146	2025-07-19T17:09:00Z	1	Australian Pull-ups	Pull
147	2025-07-19T17:09:00Z	2	Pistol Squats (assisted)	Piernas
148	2025-07-19T17:09:00Z	3	Rowing Machine	Remo
149	2025-07-21T18:06:00Z	0	Plank Hold	Push
150	2025-07-21T18:06:00Z	1	Archer Push-ups	Push
151	2025-07-21T18:06:00Z	2	Diamond Push-ups	Push
152	2025-07-21T18:06:00Z	3	Wide Push-ups	Push
153	2025-07-23T08:19:00Z	0	Pull-ups	Pull
154	2025-07-23T08:19:00Z	1	Bent Over Barbell Rows	Pull
155	2025-07-23T08:19:00Z	2	Banded Horizontal Pull-aparts	Pull
156	2025-07-23T08:19:00Z	3	Banded Overhead Pull-aparts	Pull
157	2025-07-25T08:26:00Z	0	Cossack Squats	Piernas
158	2025-07-25T08:26:00Z	1	Pistol Squats (assisted)	Piernas
159	2025-07-25T08:26:00Z	2	Bodyweight Squats	Piernas
160	2025-07-25T08:26:00Z	3	Deep Squats	Piernas
161	2025-07-26T09:52:00Z	0	Push-ups	Push
162	2025-07-26T09:52:00Z	1	Banded Horizontal Pull-aparts	Pull
163	2025-07-26T09:52:00Z	2	Cossack Squats	Piernas
164	2025-07-26T09:52:00Z	3	Rowing Machine	Remo
165	2025-07-28T08:03:00Z	0	Plank Hold	Push
166	2025-07-28T08:03:00Z	1	Wide Push-ups	Push
167	2025-07-28T08:03:00Z	2	Push-ups	Push
168	2025-07-28T08:03:00Z	3	Diamond Push-ups	Push
169	2025-07-30T17:08:00Z	0	Band Assisted Pull-ups	Pull
170	2025-07-30T17:08:00Z	1	Australian Pull-ups	Pull
171	2025-07-30T17:08:00Z	2	Pull-ups	Pull
172	2025-07-30T17:08:00Z	3	Banded Horizontal Pull-aparts	Pull
173	2025-08-01T19:17:00Z	0	Cossack Squats	Piernas
174	2025-08-01T19:17:00Z	1	Bodyweight Squats	Piernas
175	2025-08-01T19:17:00Z	2	Bulgarian Split Squats	Piernas
176	2025-08-01T19:17:00Z	3	Pistol Squats (assisted)	Piernas
177	2025-08-04T17:23:00Z	0	Push-ups	Push
178	2025-08-04T17:23:00Z	1	Archer Push-ups	Push
179	2025-08-04T17:23:00Z	2	Wide Push-ups	Push
180	2025-08-04T17:23:00Z	3	Diamond Push-ups	Push
181	2025-08-06T08:35:00Z	0	Bent Over Barbell Rows	Pull
182	2025-08-06T08:35:00Z	1	Band Assisted Pull-ups	Pull
183	2025-08-06T08:35:00Z	2	Banded Overhead Pull-aparts	Pull
184	2025-08-06T08:35:00Z	3	Banded Horizontal Pull-aparts	Pull
185	2025-08-09T19:40:00Z	0	Wide Push-ups	Push
186	2025-08-09T19:40:00Z	1	Banded Horizontal Pull-aparts	Pull
187	2025-08-09T19:40:00Z	2	Deep Squats	Piernas
188	2025-08-09T19:40:00Z	3	Rowing Machine	Remo
189	2025-08-11T19:21:00Z	0	Push-ups	Push
190	2025-08-11T19:21:00Z	1	Archer Push-ups	Push
191	2025-08-11T19:21:00Z	2	Plank Hold	Push
192	2025-08-11T19:21:00Z	3	Tricep Extensions	Push
193	2025-08-13T17:15:00Z	0	Bent Over Barbell Rows	Pull
194	2025-08-13T17:15:00Z	1	Banded Horizontal Pull-aparts	Pull
195	2025-08-13T17:15:00Z	2	Pull-ups	Pull
196	2025-08-13T17:15:00Z	3	Banded Overhead Pull-aparts	Pull
197	2025-08-15T17:46:00Z	0	Bulgarian Split Squats	Piernas
198	2025-08-15T17:46:00Z	1	Bodyweight Squats	Piernas
199	2025-08-15T17:46:00Z	2	Deep Squats	Piernas
200	2025-08-15T17:46:00Z	3	Cossack Squats	Piernas
201	2025-08-16T19:57:00Z	0	Diamond Push-ups	Push
202	2025-08-16T19:57:00Z	1	Australian Pull-ups	Pull
203	2025-08-16T19:57:00Z	2	Bodyweight Squats	Piernas
204	2025-08-16T19:57:00Z	3	Rowing Machine	Remo
205	2025-08-20T08:12:00Z	0	Bent Over Barbell Rows	Pull
206	2025-08-20T08:12:00Z	1	Banded Overhead Pull-aparts	Pull
207	2025-08-20T08:12:00Z	2	Pull-ups	Pull
208	2025-08-20T08:12:00Z	3	Banded Horizontal Pull-aparts	Pull
209	2025-08-22T17:18:00Z	0	Pistol Squats (assisted)	Piernas
210	2025-08-22T17:18:00Z	1	Bulgarian Split Squats	Piernas
211	2025-08-22T17:18:00Z	2	Bodyweight Squats	Piernas
212	2025-08-22T17:18:00Z	3	Deep Squats	Piernas
213	2025-08-23T09:26:00Z	0	Tricep Extensions	Push
214	2025-08-23T09:26:00Z	1	Pull-ups	Pull
215	2025-08-23T09:26:00Z	2	Bodyweight Squats	Piernas
216	2025-08-23T09:26:00Z	3	Rowing Machine	Remo
217	2025-08-25T09:51:00Z	0	Wide Push-ups	Push
218	2025-08-25T09:51:00Z	1	Plank Hold	Push
219	2025-08-25T09:51:00Z	2	Diamond Push-ups	Push
220	2025-08-25T09:51:00Z	3	Archer Push-ups	Push
221	2025-08-27T17:44:00Z	0	Bent Over Barbell Rows	Pull
222	2025-08-27T17:44:00Z	1	Pull-ups	Pull
223	2025-08-27T17:44:00Z	2	Banded Overhead Pull-aparts	Pull
224	2025-08-27T17:44:00Z	3	Band Assisted Pull-ups	Pull
225	2025-08-29T18:08:00Z	0	Cossack Squats	Piernas
226	2025-08-29T18:08:00Z	1	Bodyweight Squats	Piernas
227	2025-08-29T18:08:00Z	2	Deep Squats	Piernas
228	2025-08-29T18:08:00Z	3	Pistol Squats (assisted)	Piernas
229	2025-09-01T19:08:00Z	0	Push-ups	Push
230	2025-09-01T19:08:00Z	1	Diamond Push-ups	Push
231	2025-09-01T19:08:00Z	2	Wide Push-ups	Push
232	2025-09-01T19:08:00Z	3	Tricep Extensions	Push
233	2025-09-03T19:20:00Z	0	Pull-ups	Pull
234	2025-09-03T19:20:00Z	1	Bent Over Barbell Rows	Pull
235	2025-09-03T19:20:00Z	2	Band Assisted Pull-ups	Pull
236	2025-09-03T19:20:00Z	3	Banded Overhead Pull-aparts	Pull
237	2025-09-05T09:51:00Z	0	Pistol Squats (assisted)	Piernas
238	2025-09-05T09:51:00Z	1	Bulgarian Split Squats	Piernas
239	2025-09-05T09:51:00Z	2	Cossack Squats	Piernas
240	2025-09-05T09:51:00Z	3	Bodyweight Squats	Piernas
241	2025-09-06T09:25:00Z	0	Diamond Push-ups	Push
242	2025-09-06T09:25:00Z	1	Australian Pull-ups	Pull
243	2025-09-06T09:25:00Z	2	Bodyweight Squats	Piernas
244	2025-09-06T09:25:00Z	3	Rowing Machine	Remo
245	2025-09-08T19:53:00Z	0	Archer Push-ups	Push
246	2025-09-08T19:53:00Z	1	Wide Push-ups	Push
247	2025-09-08T19:53:00Z	2	Push-ups	Push
248	2025-09-08T19:53:00Z	3	Diamond Push-ups	Push
249	2025-09-12T08:01:00Z	0	Pistol Squats (assisted)	Piernas
250	2025-09-12T08:01:00Z	1	Deep Squats	Piernas
251	2025-09-12T08:01:00Z	2	Bulgarian Split Squats	Piernas
252	2025-09-12T08:01:00Z	3	Bodyweight Squats	Piernas
253	2025-09-15T17:36:00Z	0	Archer Push-ups	Push
254	2025-09-15T17:36:00Z	1	Diamond Push-ups	Push
255	2025-09-15T17:36:00Z	2	Tricep Extensions	Push
256	2025-09-15T17:36:00Z	3	Plank Hold	Push
257	2025-09-17T19:38:00Z	0	Banded Overhead Pull-aparts	Pull
258	2025-09-17T19:38:00Z	1	Band Assisted Pull-ups	Pull
259	2025-09-17T19:38:00Z	2	Pull-ups	Pull
260	2025-09-17T19:38:00Z	3	Banded Horizontal Pull-aparts	Pull
261	2025-09-22T19:38:00Z	0	Tricep Extensions	Push
262	2025-09-22T19:38:00Z	1	Plank Hold	Push
263	2025-09-22T19:38:00Z	2	Push-ups	Push
264	2025-09-22T19:38:00Z	3	Diamond Push-ups	Push
265	2025-09-26T19:24:00Z	0	Cossack Squats	Piernas
266	2025-09-26T19:24:00Z	1	Pistol Squats (assisted)	Piernas
267	2025-09-26T19:24:00Z	2	Deep Squats	Piernas
268	2025-09-26T19:24:00Z	3	Bodyweight Squats	Piernas
269	2025-09-29T17:42:00Z	0	Tricep Extensions	Push
270	2025-09-29T17:42:00Z	1	Plank Hold	Push
271	2025-09-29T17:42:00Z	2	Diamond Push-ups	Push
272	2025-09-29T17:42:00Z	3	Push-ups	Push
273	2025-10-01T18:29:00Z	0	Pull-ups	Pull
274	2025-10-01T18:29:00Z	1	Bent Over Barbell Rows	Pull
275	2025-10-01T18:29:00Z	2	Band Assisted Pull-ups	Pull
276	2025-10-01T18:29:00Z	3	Banded Overhead Pull-aparts	Pull
277	2025-10-03T09:11:00Z	0	Cossack Squats	Piernas
278	2025-10-03T09:11:00Z	1	Deep Squats	Piernas
279	2025-10-03T09:11:00Z	2	Bulgarian Split Squats	Piernas
280	2025-10-03T09:11:00Z	3	Pistol Squats (assisted)	Piernas
281	2025-10-04T09:20:00Z	0	Diamond Push-ups	Push
282	2025-10-04T09:20:00Z	1	Banded Horizontal Pull-aparts	Pull
283	2025-10-04T09:20:00Z	2	Deep Squats	Piernas
284	2025-10-04T09:20:00Z	3	Rowing Machine	Remo
285	2025-10-06T18:26:00Z	0	Tricep Extensions	Push
286	2025-10-06T18:26:00Z	1	Plank Hold	Push
287	2025-10-06T18:26:00Z	2	Push-ups	Push
288	2025-10-06T18:26:00Z	3	Wide Push-ups	Push
289	2025-10-08T19:44:00Z	0	Pull-ups	Pull
290	2025-10-08T19:44:00Z	1	Bent Over Barbell Rows	Pull
291	2025-10-08T19:44:00Z	2	Banded Overhead Pull-aparts	Pull
292	2025-10-08T19:44:00Z	3	Banded Horizontal Pull-aparts	Pull
293	2025-10-10T08:25:00Z	0	Bulgarian Split Squats	Piernas
294	2025-10-10T08:25:00Z	1	Cossack Squats	Piernas
295	2025-10-10T08:25:00Z	2	Deep Squats	Piernas
296	2025-10-10T08:25:00Z	3	Bodyweight Squats	Piernas
297	2025-10-11T09:56:00Z	0	Wide Push-ups	Push
298	2025-10-11T09:56:00Z	1	Australian Pull-ups	Pull
299	2025-10-11T09:56:00Z	2	Deep Squats	Piernas
300	2025-10-11T09:56:00Z	3	Rowing Machine	Remo
301	2025-10-15T17:08:00Z	0	Pull-ups	Pull
302	2025-10-15T17:08:00Z	1	Banded Horizontal Pull-aparts	Pull
303	2025-10-15T17:08:00Z	2	Banded Overhead Pull-aparts	Pull
304	2025-10-15T17:08:00Z	3	Band Assisted Pull-ups	Pull
305	2025-10-18T08:50:00Z	0	Tricep Extensions	Push
306	2025-10-18T08:50:00Z	1	Bent Over Barbell Rows	Pull
307	2025-10-18T08:50:00Z	2	Bodyweight Squats	Piernas
308	2025-10-18T08:50:00Z	3	Rowing Machine	Remo
309	2025-10-20T18:05:00Z	0	Archer Push-ups	Push
310	2025-10-20T18:05:00Z	1	Plank Hold	Push
311	2025-10-20T18:05:00Z	2	Tricep Extensions	Push
312	2025-10-20T18:05:00Z	3	Diamond Push-ups	Push
313	2025-10-22T17:45:00Z	0	Australian Pull-ups	Pull
314	2025-10-22T17:45:00Z	1	Bent Over Barbell Rows	Pull
315	2025-10-22T17:45:00Z	2	Banded Overhead Pull-aparts	Pull
316	2025-10-22T17:45:00Z	3	Pull-ups	Pull
317	2025-10-24T19:43:00Z	0	Deep Squats	Piernas
318	2025-10-24T19:43:00Z	1	Bodyweight Squats	Piernas
319	2025-10-24T19:43:00Z	2	Pistol Squats (assisted)	Piernas
320	2025-10-24T19:43:00Z	3	Bulgarian Split Squats	Piernas
321	2025-10-25T18:31:00Z	0	Plank Hold	Push
322	2025-10-25T18:31:00Z	1	Pull-ups	Pull
323	2025-10-25T18:31:00Z	2	Pistol Squats (assisted)	Piernas
324	2025-10-25T18:31:00Z	3	Rowing Machine	Remo
325	2025-10-27T09:08:00Z	0	Push-ups	Push
326	2025-10-27T09:08:00Z	1	Tricep Extensions	Push
327	2025-10-27T09:08:00Z	2	Wide Push-ups	Push
328	2025-10-27T09:08:00Z	3	Plank Hold	Push
329	2025-11-01T08:00:00Z	0	Wide Push-ups	Push
330	2025-11-01T08:00:00Z	1	Banded Overhead Pull-aparts	Pull
331	2025-11-01T08:00:00Z	2	Bodyweight Squats	Piernas
332	2025-11-01T08:00:00Z	3	Rowing Machine	Remo
333	2025-11-05T09:17:00Z	0	Banded Horizontal Pull-aparts	Pull
334	2025-11-05T09:17:00Z	1	Pull-ups	Pull
335	2025-11-05T09:17:00Z	2	Bent Over Barbell Rows	Pull
336	2025-11-05T09:17:00Z	3	Australian Pull-ups	Pull
337	2025-11-08T19:22:00Z	0	Wide Push-ups	Push
338	2025-11-08T19:22:00Z	1	Band Assisted Pull-ups	Pull
339	2025-11-08T19:22:00Z	2	Bodyweight Squats	Piernas
340	2025-11-08T19:22:00Z	3	Rowing Machine	Remo
341	2025-11-10T09:01:00Z	0	Push-ups	Push
342	2025-11-10T09:01:00Z	1	Wide Push-ups	Push
343	2025-11-10T09:01:00Z	2	Diamond Push-ups	Push
344	2025-11-10T09:01:00Z	3	Plank Hold	Push
345	2025-11-12T19:52:00Z	0	Bent Over Barbell Rows	Pull
346	2025-11-12T19:52:00Z	1	Pull-ups	Pull
347	2025-11-12T19:52:00Z	2	Australian Pull-ups	Pull
348	2025-11-12T19:52:00Z	3	Banded Overhead Pull-aparts	Pull
349	2025-11-15T18:10:00Z	0	Tricep Extensions	Push
350	2025-11-15T18:10:00Z	1	Australian Pull-ups	Pull
351	2025-11-15T18:10:00Z	2	Deep Squats	Piernas
352	2025-11-15T18:10:00Z	3	Rowing Machine	Remo
353	2025-11-19T09:03:00Z	0	Banded Horizontal Pull-aparts	Pull
354	2025-11-19T09:03:00Z	1	Bent Over Barbell Rows	Pull
355	2025-11-19T09:03:00Z	2	Banded Overhead Pull-aparts	Pull
356	2025-11-19T09:03:00Z	3	Australian Pull-ups	Pull
357	2025-11-21T17:05:00Z	0	Cossack Squats	Piernas
358	2025-11-21T17:05:00Z	1	Pistol Squats (assisted)	Piernas
359	2025-11-21T17:05:00Z	2	Bulgarian Split Squats	Piernas
360	2025-11-21T17:05:00Z	3	Deep Squats	Piernas
361	2025-11-22T19:51:00Z	0	Wide Push-ups	Push
362	2025-11-22T19:51:00Z	1	Banded Overhead Pull-aparts	Pull
363	2025-11-22T19:51:00Z	2	Cossack Squats	Piernas
364	2025-11-22T19:51:00Z	3	Rowing Machine	Remo
365	2025-11-24T19:48:00Z	0	Archer Push-ups	Push
366	2025-11-24T19:48:00Z	1	Tricep Extensions	Push
367	2025-11-24T19:48:00Z	2	Plank Hold	Push
368	2025-11-24T19:48:00Z	3	Wide Push-ups	Push
369	2025-11-26T18:49:00Z	0	Bent Over Barbell Rows	Pull
370	2025-11-26T18:49:00Z	1	Australian Pull-ups	Pull
371	2025-11-26T18:49:00Z	2	Banded Overhead Pull-aparts	Pull
372	2025-11-26T18:49:00Z	3	Band Assisted Pull-ups	Pull
373	2025-11-28T09:55:00Z	0	Pistol Squats (assisted)	Piernas
374	2025-11-28T09:55:00Z	1	Bodyweight Squats	Piernas
375	2025-11-28T09:55:00Z	2	Cossack Squats	Piernas
376	2025-11-28T09:55:00Z	3	Deep Squats	Piernas
377	2025-11-29T09:29:00Z	0	Archer Push-ups	Push
378	2025-11-29T09:29:00Z	1	Pull-ups	Pull
379	2025-11-29T09:29:00Z	2	Bulgarian Split Squats	Piernas
380	2025-11-29T09:29:00Z	3	Rowing Machine	Remo
381	2025-12-01T18:25:00Z	0	Archer Push-ups	Push
382	2025-12-01T18:25:00Z	1	Wide Push-ups	Push
383	2025-12-01T18:25:00Z	2	Push-ups	Push
384	2025-12-01T18:25:00Z	3	Tricep Extensions	Push
385	2025-12-03T09:32:00Z	0	Band Assisted Pull-ups	Pull
386	2025-12-03T09:32:00Z	1	Pull-ups	Pull
387	2025-12-03T09:32:00Z	2	Banded Horizontal Pull-aparts	Pull
388	2025-12-03T09:32:00Z	3	Banded Overhead Pull-aparts	Pull
389	2025-12-05T18:00:00Z	0	Deep Squats	Piernas
390	2025-12-05T18:00:00Z	1	Cossack Squats	Piernas
391	2025-12-05T18:00:00Z	2	Bodyweight Squats	Piernas
392	2025-12-05T18:00:00Z	3	Bulgarian Split Squats	Piernas
393	2025-12-06T09:13:00Z	0	Archer Push-ups	Push
394	2025-12-06T09:13:00Z	1	Banded Overhead Pull-aparts	Pull
395	2025-12-06T09:13:00Z	2	Pistol Squats (assisted)	Piernas
396	2025-12-06T09:13:00Z	3	Rowing Machine	Remo
397	2025-12-08T18:53:00Z	0	Plank Hold	Push
398	2025-12-08T18:53:00Z	1	Wide Push-ups	Push
399	2025-12-08T18:53:00Z	2	Tricep Extensions	Push
400	2025-12-08T18:53:00Z	3	Diamond Push-ups	Push
401	2025-12-10T17:16:00Z	0	Banded Overhead Pull-aparts	Pull
402	2025-12-10T17:16:00Z	1	Banded Horizontal Pull-aparts	Pull
403	2025-12-10T17:16:00Z	2	Band Assisted Pull-ups	Pull
404	2025-12-10T17:16:00Z	3	Pull-ups	Pull
405	2025-12-13T18:51:00Z	0	Wide Push-ups	Push
406	2025-12-13T18:51:00Z	1	Banded Overhead Pull-aparts	Pull
407	2025-12-13T18:51:00Z	2	Deep Squats	Piernas
408	2025-12-13T18:51:00Z	3	Rowing Machine	Remo
409	2025-12-15T19:54:00Z	0	Wide Push-ups	Push
410	2025-12-15T19:54:00Z	1	Plank Hold	Push
411	2025-12-15T19:54:00Z	2	Archer Push-ups	Push
412	2025-12-15T19:54:00Z	3	Tricep Extensions	Push
413	2025-12-17T17:23:00Z	0	Banded Horizontal Pull-aparts	Pull
414	2025-12-17T17:23:00Z	1	Banded Overhead Pull-aparts	Pull
415	2025-12-17T17:23:00Z	2	Band Assisted Pull-ups	Pull
416	2025-12-17T17:23:00Z	3	Bent Over Barbell Rows	Pull
417	2025-12-19T19:07:00Z	0	Cossack Squats	Piernas
418	2025-12-19T19:07:00Z	1	Pistol Squats (assisted)	Piernas
419	2025-12-19T19:07:00Z	2	Deep Squats	Piernas
420	2025-12-19T19:07:00Z	3	Bodyweight Squats	Piernas
421	2025-12-20T09:39:00Z	0	Plank Hold	Push
422	2025-12-20T09:39:00Z	1	Bent Over Barbell Rows	Pull
423	2025-12-20T09:39:00Z	2	Cossack Squats	Piernas
424	2025-12-20T09:39:00Z	3	Rowing Machine	Remo
425	2025-12-22T17:13:00Z	0	Push-ups	Push
426	2025-12-22T17:13:00Z	1	Diamond Push-ups	Push
427	2025-12-22T17:13:00Z	2	Tricep Extensions	Push
428	2025-12-22T17:13:00Z	3	Archer Push-ups	Push
429	2025-12-24T17:08:00Z	0	Bent Over Barbell Rows	Pull
430	2025-12-24T17:08:00Z	1	Banded Overhead Pull-aparts	Pull
431	2025-12-24T17:08:00Z	2	Australian Pull-ups	Pull
432	2025-12-24T17:08:00Z	3	Band Assisted Pull-ups	Pull
433	2025-12-26T19:33:00Z	0	Bodyweight Squats	Piernas
434	2025-12-26T19:33:00Z	1	Pistol Squats (assisted)	Piernas
435	2025-12-26T19:33:00Z	2	Cossack Squats	Piernas
436	2025-12-26T19:33:00Z	3	Deep Squats	Piernas
437	2025-12-27T08:47:00Z	0	Push-ups	Push
438	2025-12-27T08:47:00Z	1	Banded Overhead Pull-aparts	Pull
439	2025-12-27T08:47:00Z	2	Bodyweight Squats	Piernas
440	2025-12-27T08:47:00Z	3	Rowing Machine	Remo
441	2025-12-29T17:48:00Z	0	Tricep Extensions	Push
442	2025-12-29T17:48:00Z	1	Diamond Push-ups	Push
443	2025-12-29T17:48:00Z	2	Plank Hold	Push
444	2025-12-29T17:48:00Z	3	Push-ups	Push
445	2025-12-31T08:54:00Z	0	Australian Pull-ups	Pull
446	2025-12-31T08:54:00Z	1	Banded Horizontal Pull-aparts	Pull
447	2025-12-31T08:54:00Z	2	Band Assisted Pull-ups	Pull
448	2025-12-31T08:54:00Z	3	Banded Overhead Pull-aparts	Pull
449	2026-01-02T17:49:00Z	0	Pistol Squats (assisted)	Piernas
450	2026-01-02T17:49:00Z	1	Deep Squats	Piernas
451	2026-01-02T17:49:00Z	2	Cossack Squats	Piernas
452	2026-01-02T17:49:00Z	3	Bulgarian Split Squats	Piernas
453	2026-01-05T08:42:00Z	0	Plank Hold	Push
454	2026-01-05T08:42:00Z	1	Wide Push-ups	Push
455	2026-01-05T08:42:00Z	2	Diamond Push-ups	Push
456	2026-01-05T08:42:00Z	3	Tricep Extensions	Push
457	2026-01-07T09:33:00Z	0	Bent Over Barbell Rows	Pull
458	2026-01-07T09:33:00Z	1	Banded Overhead Pull-aparts	Pull
459	2026-01-07T09:33:00Z	2	Band Assisted Pull-ups	Pull
460	2026-01-07T09:33:00Z	3	Banded Horizontal Pull-aparts	Pull
461	2026-01-09T09:03:00Z	0	Deep Squats	Piernas
462	2026-01-09T09:03:00Z	1	Pistol Squats (assisted)	Piernas
463	2026-01-09T09:03:00Z	2	Cossack Squats	Piernas
464	2026-01-09T09:03:00Z	3	Bodyweight Squats	Piernas
465	2026-01-12T19:38:00Z	0	Archer Push-ups	Push
466	2026-01-12T19:38:00Z	1	Tricep Extensions	Push
467	2026-01-12T19:38:00Z	2	Push-ups	Push
468	2026-01-12T19:38:00Z	3	Diamond Push-ups	Push
469	2026-01-16T17:26:00Z	0	Deep Squats	Piernas
470	2026-01-16T17:26:00Z	1	Cossack Squats	Piernas
471	2026-01-16T17:26:00Z	2	Bulgarian Split Squats	Piernas
472	2026-01-16T17:26:00Z	3	Pistol Squats (assisted)	Piernas
473	2026-01-17T08:51:00Z	0	Tricep Extensions	Push
474	2026-01-17T08:51:00Z	1	Band Assisted Pull-ups	Pull
475	2026-01-17T08:51:00Z	2	Deep Squats	Piernas
476	2026-01-17T08:51:00Z	3	Rowing Machine	Remo
477	2026-01-23T18:22:00Z	0	Cossack Squats	Piernas
478	2026-01-23T18:22:00Z	1	Bulgarian Split Squats	Piernas
479	2026-01-23T18:22:00Z	2	Bodyweight Squats	Piernas
480	2026-01-23T18:22:00Z	3	Pistol Squats (assisted)	Piernas
481	2026-01-24T19:55:00Z	0	Push-ups	Push
482	2026-01-24T19:55:00Z	1	Bent Over Barbell Rows	Pull
483	2026-01-24T19:55:00Z	2	Pistol Squats (assisted)	Piernas
484	2026-01-24T19:55:00Z	3	Rowing Machine	Remo
485	2026-01-26T17:13:00Z	0	Wide Push-ups	Push
486	2026-01-26T17:13:00Z	1	Plank Hold	Push
487	2026-01-26T17:13:00Z	2	Archer Push-ups	Push
488	2026-01-26T17:13:00Z	3	Diamond Push-ups	Push
489	2026-01-28T19:29:00Z	0	Banded Overhead Pull-aparts	Pull
490	2026-01-28T19:29:00Z	1	Bent Over Barbell Rows	Pull
491	2026-01-28T19:29:00Z	2	Pull-ups	Pull
492	2026-01-28T19:29:00Z	3	Banded Horizontal Pull-aparts	Pull
493	2026-01-30T09:57:00Z	0	Pistol Squats (assisted)	Piernas
494	2026-01-30T09:57:00Z	1	Bodyweight Squats	Piernas
495	2026-01-30T09:57:00Z	2	Bulgarian Split Squats	Piernas
496	2026-01-30T09:57:00Z	3	Cossack Squats	Piernas
497	2026-01-31T19:31:00Z	0	Push-ups	Push
498	2026-01-31T19:31:00Z	1	Pull-ups	Pull
499	2026-01-31T19:31:00Z	2	Bulgarian Split Squats	Piernas
500	2026-01-31T19:31:00Z	3	Rowing Machine	Remo
501	2026-02-06T17:47:00Z	0	Deep Squats	Piernas
502	2026-02-06T17:47:00Z	1	Pistol Squats (assisted)	Piernas
503	2026-02-06T17:47:00Z	2	Bulgarian Split Squats	Piernas
504	2026-02-06T17:47:00Z	3	Cossack Squats	Piernas
505	2026-02-07T19:19:00Z	0	Archer Push-ups	Push
506	2026-02-07T19:19:00Z	1	Banded Overhead Pull-aparts	Pull
507	2026-02-07T19:19:00Z	2	Cossack Squats	Piernas
508	2026-02-07T19:19:00Z	3	Rowing Machine	Remo
509	2026-02-09T18:25:00Z	0	Plank Hold	Push
510	2026-02-09T18:25:00Z	1	Diamond Push-ups	Push
511	2026-02-09T18:25:00Z	2	Archer Push-ups	Push
512	2026-02-09T18:25:00Z	3	Push-ups	Push
513	2026-02-14T18:19:00Z	0	Diamond Push-ups	Push
514	2026-02-14T18:19:00Z	1	Band Assisted Pull-ups	Pull
515	2026-02-14T18:19:00Z	2	Deep Squats	Piernas
516	2026-02-14T18:19:00Z	3	Rowing Machine	Remo
517	2026-02-16T17:59:00Z	0	Plank Hold	Push
518	2026-02-16T17:59:00Z	1	Wide Push-ups	Push
519	2026-02-16T17:59:00Z	2	Push-ups	Push
520	2026-02-16T17:59:00Z	3	Tricep Extensions	Push
521	2026-02-18T09:44:00Z	0	Banded Horizontal Pull-aparts	Pull
522	2026-02-18T09:44:00Z	1	Band Assisted Pull-ups	Pull
523	2026-02-18T09:44:00Z	2	Australian Pull-ups	Pull
524	2026-02-18T09:44:00Z	3	Banded Overhead Pull-aparts	Pull
525	2026-02-21T18:46:00Z	0	Archer Push-ups	Push
526	2026-02-21T18:46:00Z	1	Band Assisted Pull-ups	Pull
527	2026-02-21T18:46:00Z	2	Pistol Squats (assisted)	Piernas
528	2026-02-21T18:46:00Z	3	Rowing Machine	Remo
529	2026-02-23T18:42:00Z	0	Archer Push-ups	Push
530	2026-02-23T18:42:00Z	1	Tricep Extensions	Push
531	2026-02-23T18:42:00Z	2	Push-ups	Push
532	2026-02-23T18:42:00Z	3	Plank Hold	Push
533	2026-02-25T18:47:00Z	0	Bent Over Barbell Rows	Pull
534	2026-02-25T18:47:00Z	1	Banded Horizontal Pull-aparts	Pull
535	2026-02-25T18:47:00Z	2	Australian Pull-ups	Pull
536	2026-02-25T18:47:00Z	3	Band Assisted Pull-ups	Pull
537	2026-02-27T17:58:00Z	0	Pistol Squats (assisted)	Piernas
538	2026-02-27T17:58:00Z	1	Deep Squats	Piernas
539	2026-02-27T17:58:00Z	2	Cossack Squats	Piernas
540	2026-02-27T17:58:00Z	3	Bulgarian Split Squats	Piernas
541	2026-02-28T19:59:00Z	0	Push-ups	Push
542	2026-02-28T19:59:00Z	1	Pull-ups	Pull
543	2026-02-28T19:59:00Z	2	Pistol Squats (assisted)	Piernas
544	2026-02-28T19:59:00Z	3	Rowing Machine	Remo
545	2026-03-02T17:05:00Z	0	Tricep Extensions	Push
546	2026-03-02T17:05:00Z	1	Plank Hold	Push
547	2026-03-02T17:05:00Z	2	Push-ups	Push
548	2026-03-02T17:05:00Z	3	Wide Push-ups	Push
549	2026-03-04T09:48:00Z	0	Banded Overhead Pull-aparts	Pull
550	2026-03-04T09:48:00Z	1	Banded Horizontal Pull-aparts	Pull
551	2026-03-04T09:48:00Z	2	Pull-ups	Pull
552	2026-03-04T09:48:00Z	3	Australian Pull-ups	Pull
553	2026-03-06T17:42:00Z	0	Bodyweight Squats	Piernas
554	2026-03-06T17:42:00Z	1	Pistol Squats (assisted)	Piernas
555	2026-03-06T17:42:00Z	2	Bulgarian Split Squats	Piernas
556	2026-03-06T17:42:00Z	3	Cossack Squats	Piernas
557	2026-03-07T17:14:00Z	0	Tricep Extensions	Push
558	2026-03-07T17:14:00Z	1	Banded Horizontal Pull-aparts	Pull
559	2026-03-07T17:14:00Z	2	Pistol Squats (assisted)	Piernas
560	2026-03-07T17:14:00Z	3	Rowing Machine	Remo
561	2026-03-09T08:11:00Z	0	Plank Hold	Push
562	2026-03-09T08:11:00Z	1	Wide Push-ups	Push
563	2026-03-09T08:11:00Z	2	Diamond Push-ups	Push
564	2026-03-09T08:11:00Z	3	Archer Push-ups	Push
565	2026-03-11T08:59:00Z	0	Banded Horizontal Pull-aparts	Pull
566	2026-03-11T08:59:00Z	1	Bent Over Barbell Rows	Pull
567	2026-03-11T08:59:00Z	2	Banded Overhead Pull-aparts	Pull
568	2026-03-11T08:59:00Z	3	Band Assisted Pull-ups	Pull
569	2026-03-13T08:44:00Z	0	Cossack Squats	Piernas
570	2026-03-13T08:44:00Z	1	Bulgarian Split Squats	Piernas
571	2026-03-13T08:44:00Z	2	Deep Squats	Piernas
572	2026-03-13T08:44:00Z	3	Pistol Squats (assisted)	Piernas
573	2026-03-14T09:10:00Z	0	Wide Push-ups	Push
574	2026-03-14T09:10:00Z	1	Banded Overhead Pull-aparts	Pull
575	2026-03-14T09:10:00Z	2	Deep Squats	Piernas
576	2026-03-14T09:10:00Z	3	Rowing Machine	Remo
577	2026-03-18T08:09:00Z	0	Pull-ups	Pull
578	2026-03-18T08:09:00Z	1	Band Assisted Pull-ups	Pull
579	2026-03-18T08:09:00Z	2	Bent Over Barbell Rows	Pull
580	2026-03-18T08:09:00Z	3	Banded Overhead Pull-aparts	Pull
581	2026-03-20T19:05:00Z	0	Bulgarian Split Squats	Piernas
582	2026-03-20T19:05:00Z	1	Pistol Squats (assisted)	Piernas
583	2026-03-20T19:05:00Z	2	Deep Squats	Piernas
584	2026-03-20T19:05:00Z	3	Bodyweight Squats	Piernas
585	2026-03-21T08:07:00Z	0	Diamond Push-ups	Push
586	2026-03-21T08:07:00Z	1	Australian Pull-ups	Pull
587	2026-03-21T08:07:00Z	2	Cossack Squats	Piernas
588	2026-03-21T08:07:00Z	3	Rowing Machine	Remo
589	2026-03-23T08:21:00Z	0	Wide Push-ups	Push
590	2026-03-23T08:21:00Z	1	Archer Push-ups	Push
591	2026-03-23T08:21:00Z	2	Diamond Push-ups	Push
592	2026-03-23T08:21:00Z	3	Tricep Extensions	Push
593	2026-03-25T09:13:00Z	0	Australian Pull-ups	Pull
594	2026-03-25T09:13:00Z	1	Bent Over Barbell Rows	Pull
595	2026-03-25T09:13:00Z	2	Banded Horizontal Pull-aparts	Pull
596	2026-03-25T09:13:00Z	3	Banded Overhead Pull-aparts	Pull
597	2026-03-28T19:20:00Z	0	Plank Hold	Push
598	2026-03-28T19:20:00Z	1	Australian Pull-ups	Pull
599	2026-03-28T19:20:00Z	2	Cossack Squats	Piernas
600	2026-03-28T19:20:00Z	3	Rowing Machine	Remo
601	2026-03-30T19:05:00Z	0	Archer Push-ups	Push
602	2026-03-30T19:05:00Z	1	Wide Push-ups	Push
603	2026-03-30T19:05:00Z	2	Plank Hold	Push
604	2026-03-30T19:05:00Z	3	Diamond Push-ups	Push
605	2026-04-01T08:50:00Z	0	Australian Pull-ups	Pull
606	2026-04-01T08:50:00Z	1	Band Assisted Pull-ups	Pull
607	2026-04-01T08:50:00Z	2	Bent Over Barbell Rows	Pull
608	2026-04-01T08:50:00Z	3	Banded Horizontal Pull-aparts	Pull
609	2026-04-03T08:05:00Z	0	Pistol Squats (assisted)	Piernas
610	2026-04-03T08:05:00Z	1	Deep Squats	Piernas
611	2026-04-03T08:05:00Z	2	Cossack Squats	Piernas
612	2026-04-03T08:05:00Z	3	Bodyweight Squats	Piernas
613	2026-04-04T17:45:00Z	0	Tricep Extensions	Push
614	2026-04-04T17:45:00Z	1	Australian Pull-ups	Pull
615	2026-04-04T17:45:00Z	2	Bodyweight Squats	Piernas
616	2026-04-04T17:45:00Z	3	Rowing Machine	Remo
617	2026-04-06T18:35:00Z	0	Tricep Extensions	Push
618	2026-04-06T18:35:00Z	1	Plank Hold	Push
619	2026-04-06T18:35:00Z	2	Diamond Push-ups	Push
620	2026-04-06T18:35:00Z	3	Wide Push-ups	Push
621	2026-04-08T19:19:00Z	0	Bent Over Barbell Rows	Pull
622	2026-04-08T19:19:00Z	1	Banded Horizontal Pull-aparts	Pull
623	2026-04-08T19:19:00Z	2	Australian Pull-ups	Pull
624	2026-04-08T19:19:00Z	3	Band Assisted Pull-ups	Pull
625	2026-04-11T09:42:00Z	0	Wide Push-ups	Push
626	2026-04-11T09:42:00Z	1	Band Assisted Pull-ups	Pull
627	2026-04-11T09:42:00Z	2	Deep Squats	Piernas
628	2026-04-11T09:42:00Z	3	Rowing Machine	Remo
629	2026-04-13T19:14:00Z	0	Tricep Extensions	Push
630	2026-04-13T19:14:00Z	1	Diamond Push-ups	Push
631	2026-04-13T19:14:00Z	2	Archer Push-ups	Push
632	2026-04-13T19:14:00Z	3	Push-ups	Push
633	2026-04-15T18:22:00Z	0	Bent Over Barbell Rows	Pull
634	2026-04-15T18:22:00Z	1	Banded Horizontal Pull-aparts	Pull
635	2026-04-15T18:22:00Z	2	Band Assisted Pull-ups	Pull
636	2026-04-15T18:22:00Z	3	Pull-ups	Pull
637	2026-04-17T17:11:00Z	0	Cossack Squats	Piernas
638	2026-04-17T17:11:00Z	1	Deep Squats	Piernas
639	2026-04-17T17:11:00Z	2	Bodyweight Squats	Piernas
640	2026-04-17T17:11:00Z	3	Bulgarian Split Squats	Piernas
641	2026-04-18T08:24:00Z	0	Push-ups	Push
642	2026-04-18T08:24:00Z	1	Australian Pull-ups	Pull
643	2026-04-18T08:24:00Z	2	Cossack Squats	Piernas
644	2026-04-18T08:24:00Z	3	Rowing Machine	Remo
645	2026-04-20T08:50:00Z	0	Tricep Extensions	Push
646	2026-04-20T08:50:00Z	1	Plank Hold	Push
647	2026-04-20T08:50:00Z	2	Wide Push-ups	Push
648	2026-04-20T08:50:00Z	3	Push-ups	Push
649	2026-04-22T19:14:00Z	0	Australian Pull-ups	Pull
650	2026-04-22T19:14:00Z	1	Banded Overhead Pull-aparts	Pull
651	2026-04-22T19:14:00Z	2	Bent Over Barbell Rows	Pull
652	2026-04-22T19:14:00Z	3	Banded Horizontal Pull-aparts	Pull
653	2026-04-24T17:26:00Z	0	Deep Squats	Piernas
654	2026-04-24T17:26:00Z	1	Bodyweight Squats	Piernas
655	2026-04-24T17:26:00Z	2	Bulgarian Split Squats	Piernas
656	2026-04-24T17:26:00Z	3	Cossack Squats	Piernas
657	2026-04-25T09:42:00Z	0	Plank Hold	Push
658	2026-04-25T09:42:00Z	1	Banded Overhead Pull-aparts	Pull
659	2026-04-25T09:42:00Z	2	Pistol Squats (assisted)	Piernas
660	2026-04-25T09:42:00Z	3	Rowing Machine	Remo
661	2026-04-27T08:30:00Z	0	Push-ups	Push
662	2026-04-27T08:30:00Z	1	Diamond Push-ups	Push
663	2026-04-27T08:30:00Z	2	Wide Push-ups	Push
664	2026-04-27T08:30:00Z	3	Tricep Extensions	Push
665	2026-05-01T18:55:00Z	0	Cossack Squats	Piernas
666	2026-05-01T18:55:00Z	1	Deep Squats	Piernas
667	2026-05-01T18:55:00Z	2	Bulgarian Split Squats	Piernas
668	2026-05-01T18:55:00Z	3	Bodyweight Squats	Piernas
669	2026-05-02T19:47:00Z	0	Tricep Extensions	Push
670	2026-05-02T19:47:00Z	1	Banded Overhead Pull-aparts	Pull
671	2026-05-02T19:47:00Z	2	Pistol Squats (assisted)	Piernas
672	2026-05-02T19:47:00Z	3	Rowing Machine	Remo
673	2026-05-04T09:41:00Z	0	Archer Push-ups	Push
674	2026-05-04T09:41:00Z	1	Diamond Push-ups	Push
675	2026-05-04T09:41:00Z	2	Tricep Extensions	Push
676	2026-05-04T09:41:00Z	3	Wide Push-ups	Push
4150	2026-05-06T16:21:49.842Z	0	Narrow Stance Squats	Piernas
4151	2026-05-06T16:21:49.842Z	1	Deep Squats	Piernas
4152	2026-05-06T16:21:49.842Z	2	Bodyweight Squats	Piernas
4153	2026-05-06T16:21:49.842Z	3	Stationary bike	Custom
4154	2026-05-07T16:13:24.136Z	0	Negative Push-ups	Push
4155	2026-05-07T16:13:24.136Z	1	Scapula Push-ups	Push
4156	2026-05-07T16:13:24.136Z	2	Plank Hold	Push
4157	2026-05-07T16:13:24.136Z	3	Rowing Machine	Remo
4158	2026-05-08T16:15:23.955Z	0	Bent Over Barbell Rows	Pull
4159	2026-05-08T16:15:23.955Z	1	Passive Hang	Pull
4160	2026-05-08T16:15:23.955Z	2	Treadmill	Remo
4161	2026-05-09T16:16:50.919Z	0	Deep Squats	Piernas
4162	2026-05-09T16:16:50.919Z	1	Narrow Stance Squats	Piernas
4163	2026-05-09T16:16:50.919Z	2	Bodyweight Squats	Piernas
4164	2026-05-11T16:28:02.992Z	0	Negative Push-ups	Push
4165	2026-05-11T16:28:02.992Z	1	Scapula Push-ups	Push
4166	2026-05-11T16:28:02.992Z	2	Plank Hold	Push
4167	2026-05-11T16:28:02.992Z	3	Rowing Machine	Remo
4168	2026-05-12T15:16:12.252Z	0	Bent Over Barbell Rows	Pull
4169	2026-05-12T15:16:12.252Z	1	Passive Hang	Pull
4170	2026-05-12T15:16:12.252Z	2	Air Bike	Remo
4171	2026-05-13T16:31:24.573Z	0	Bulgarian Split Squats	Piernas
4172	2026-05-13T16:31:24.573Z	1	Narrow Stance Squats	Piernas
4173	2026-05-13T16:31:24.573Z	2	Deep Squats	Piernas
4174	2026-05-13T16:31:24.573Z	3	Spin Bike	Remo
4175	2026-05-14T16:18:21.291Z	0	Push-ups	Push
4176	2026-05-14T16:18:21.291Z	1	Negative Push-ups	Push
4177	2026-05-14T16:18:21.291Z	2	Scapula Push-ups	Push
4178	2026-05-14T16:18:21.291Z	3	Plank Hold	Push
4179	2026-05-18T16:33:30.887Z	0	Push-ups	Push
4180	2026-05-18T16:33:30.887Z	1	Negative Push-ups	Push
4181	2026-05-18T16:33:30.887Z	2	Scapula Push-ups	Push
4182	2026-05-18T16:33:30.887Z	3	Plank Hold	Push
4183	2026-05-18T16:33:30.887Z	4	Rowing Machine	Remo
4184	2026-05-19T16:19:21.255Z	0	Bent Over Barbell Rows	Pull
4185	2026-05-19T16:19:21.255Z	1	Passive Hang	Pull
4186	2026-05-19T16:19:21.255Z	2	Air Bike	Remo
4187	2026-05-20T16:23:01.321Z	0	Bulgarian Split Squats	Piernas
4188	2026-05-20T16:23:01.321Z	1	Narrow Stance Squats	Piernas
4189	2026-05-20T16:23:01.321Z	2	Deep Squats	Piernas
4190	2026-05-20T16:23:01.321Z	3	Spin Bike	Remo
4191	2026-05-21T16:14:10.883Z	0	Push-ups	Push
4192	2026-05-21T16:14:10.883Z	1	Negative Push-ups	Push
4193	2026-05-21T16:14:10.883Z	2	Scapula Push-ups	Push
4194	2026-05-21T16:14:10.883Z	3	Plank Hold	Push
4195	2026-05-21T16:14:10.883Z	4	Rowing Machine	Remo
4196	2026-05-22T18:18:14.812Z	0	Bent Over Barbell Rows	Pull
4197	2026-05-22T18:18:14.812Z	1	Passive Hang	Pull
4198	2026-05-22T18:18:14.812Z	2	Air Bike	Remo
4199	2026-05-25T16:25:22.317Z	0	Push-ups	Push
4200	2026-05-25T16:25:22.317Z	1	Negative Push-ups	Push
4201	2026-05-25T16:25:22.317Z	2	Scapula Push-ups	Push
4202	2026-05-25T16:25:22.317Z	3	Plank Hold	Push
4203	2026-05-25T16:25:22.317Z	4	Rowing Machine	Remo
4204	2026-05-26T16:12:03.158Z	0	Bent Over Barbell Rows	Pull
4205	2026-05-26T16:12:03.158Z	1	Passive Hang	Pull
4206	2026-05-26T16:12:03.158Z	2	Air Bike	Remo
4207	2026-05-28T01:07:21.153Z	0	Cossack Squats	Piernas
4208	2026-05-28T01:07:21.153Z	1	Bulgarian Split Squats	Piernas
4209	2026-05-28T01:07:21.153Z	2	Narrow Stance Squats	Piernas
4210	2026-05-28T01:07:21.153Z	3	Deep Squats	Piernas
4211	2026-05-28T01:07:21.153Z	4	Spin Bike	Remo
4212	2026-05-28T16:13:41.156Z	0	Diamond Push-ups	Push
4213	2026-05-28T16:13:41.156Z	1	Push-ups	Push
4214	2026-05-28T16:13:41.156Z	2	Tricep Extensions	Push
4215	2026-05-28T16:13:41.156Z	3	Wide Push-ups	Push
4216	2026-05-28T16:13:41.156Z	4	Negative Push-ups	Push
4217	2026-05-29T16:21:06.809Z	0	Bent Over Barbell Rows	Pull
4218	2026-05-29T16:21:06.809Z	1	Passive Hang	Pull
4219	2026-05-29T16:21:06.809Z	2	Air Bike	Remo
4220	2026-05-30T15:17:00.374Z	0	Cossack Squats	Piernas
4221	2026-05-30T15:17:00.374Z	1	Bulgarian Split Squats	Piernas
4222	2026-05-30T15:17:00.374Z	2	Narrow Stance Squats	Piernas
4223	2026-05-30T15:17:00.374Z	3	Deep Squats	Piernas
4224	2026-05-30T15:17:00.374Z	4	Spin Bike	Remo
4225	2026-06-01T16:22:56.752Z	0	Push-ups	Push
4226	2026-06-01T16:22:56.752Z	1	Negative Push-ups	Push
4227	2026-06-01T16:22:56.752Z	2	Scapula Push-ups	Push
4228	2026-06-01T16:22:56.752Z	3	Plank Hold	Push
4229	2026-06-01T16:22:56.752Z	4	Rowing Machine	Remo
4230	2026-06-02T16:27:50.084Z	0	Bent Over Barbell Rows	Pull
4231	2026-06-02T16:27:50.084Z	1	Passive Hang	Pull
4232	2026-06-02T16:27:50.084Z	2	Air Bike	Remo
4233	2026-06-03T16:14:15.660Z	0	Cossack Squats	Piernas
4234	2026-06-03T16:14:15.660Z	1	Bulgarian Split Squats	Piernas
4235	2026-06-03T16:14:15.660Z	2	Narrow Stance Squats	Piernas
4236	2026-06-03T16:14:15.660Z	3	Deep Squats	Piernas
4237	2026-06-03T16:14:15.660Z	4	Spin Bike	Remo
4238	2026-06-04T16:30:37.675Z	0	Diamond Push-ups	Push
4239	2026-06-04T16:30:37.675Z	1	Push-ups	Push
4240	2026-06-04T16:30:37.675Z	2	Tricep Extensions	Push
4241	2026-06-04T16:30:37.675Z	3	Wide Push-ups	Push
4242	2026-06-04T16:30:37.675Z	4	Negative Push-ups	Push
4243	2026-06-04T16:30:37.675Z	5	Rowing Machine	Remo
4244	2026-06-05T16:19:15.145Z	0	Bent Over Barbell Rows	Pull
4245	2026-06-05T16:19:15.145Z	1	Passive Hang	Pull
4246	2026-06-05T16:19:15.145Z	2	Air Bike	Remo
4247	2026-06-06T16:27:21.439Z	0	Cossack Squats	Piernas
4248	2026-06-06T16:27:21.439Z	1	Bulgarian Split Squats	Piernas
4249	2026-06-06T16:27:21.439Z	2	Narrow Stance Squats	Piernas
4250	2026-06-06T16:27:21.439Z	3	Deep Squats	Piernas
4251	2026-06-06T16:27:21.439Z	4	Air Bike	Remo
4252	2026-06-08T18:06:28.356Z	0	Diamond Push-ups	Push
4253	2026-06-08T18:06:28.356Z	1	Push-ups	Push
4254	2026-06-08T18:06:28.356Z	2	Tricep Extensions	Push
4255	2026-06-08T18:06:28.356Z	3	Wide Push-ups	Push
4256	2026-06-08T18:06:28.356Z	4	Negative Push-ups	Push
4257	2026-06-08T18:06:28.356Z	5	Air Bike	Remo
4258	2026-06-09T16:16:35.866Z	0	Bent Over Barbell Rows	Pull
4259	2026-06-09T16:16:35.866Z	1	Passive Hang	Pull
4260	2026-06-09T16:16:35.866Z	2	Air Bike	Remo
4261	2026-06-16T17:19:26.989Z	0	Bent Over Barbell Rows	Pull
4262	2026-06-16T17:19:26.989Z	1	Passive Hang	Pull
4263	2026-06-16T17:19:26.989Z	2	Air Bike	Remo
4264	2026-06-18T18:13:15.627Z	0	Diamond Push-ups	Push
4265	2026-06-18T18:13:15.627Z	1	Push-ups	Push
4266	2026-06-18T18:13:15.627Z	2	Tricep Extensions	Push
4267	2026-06-18T18:13:15.627Z	3	Wide Push-ups	Push
4268	2026-06-18T18:13:15.627Z	4	Negative Push-ups	Push
4269	2026-06-18T18:13:15.627Z	5	Air Bike	Remo
4270	2026-06-19T16:21:01.333Z	0	Cossack Squats	Piernas
4271	2026-06-19T16:21:01.333Z	1	Bulgarian Split Squats	Piernas
4272	2026-06-19T16:21:01.333Z	2	Narrow Stance Squats	Piernas
4273	2026-06-19T16:21:01.333Z	3	Deep Squats	Piernas
4274	2026-06-19T16:21:01.333Z	4	Air Bike	Remo
4275	2026-06-30T16:13:50.668Z	0	Cossack Squats	Piernas
4276	2026-06-30T16:13:50.668Z	1	Bulgarian Split Squats	Piernas
4277	2026-06-30T16:13:50.668Z	2	Narrow Stance Squats	Piernas
4278	2026-06-30T16:13:50.668Z	3	Deep Squats	Piernas
4279	2026-06-30T16:13:50.668Z	4	Spin Bike	Remo
4280	2026-07-11T15:05:43.256Z	0	Australian Pull-ups	Pull
4281	2026-07-11T15:05:43.256Z	1	Scapula Pull-ups	Pull
4282	2026-07-11T15:05:43.256Z	2	Pull-ups	Pull
4283	2026-07-11T15:05:43.256Z	3	Passive Hang	Pull
4284	2026-07-11T15:05:43.256Z	4	Treadmill	Remo
4285	2026-07-14T01:06:43.231Z	0	Cossack Squats	Piernas
4286	2026-07-14T01:06:43.231Z	1	Bulgarian Split Squats	Piernas
4287	2026-07-14T01:06:43.231Z	2	Narrow Stance Squats	Piernas
4288	2026-07-14T01:06:43.231Z	3	Deep Squats	Piernas
4289	2026-07-14T01:06:43.231Z	4	Tricep Extensions	Push
4290	2026-07-14T01:06:43.231Z	5	Diamond Push-ups	Push
4291	2026-07-14T01:06:43.231Z	6	Wide Push-ups	Push
4292	2026-07-14T01:06:43.231Z	7	Push-ups	Push
\.


--
-- Data for Name: session_sets; Type: TABLE DATA; Schema: public; Owner: calistia
--

COPY public.session_sets (id, session_exercise_id, "position", started_at, duration, reps, weight, rest_duration) FROM stdin;
1	1	0	2025-05-07 08:47:00	114	3	\N	71
2	1	1	2025-05-07 08:50:05	99	7	\N	64
3	1	2	2025-05-07 08:52:48	56	3	\N	0
4	2	0	2025-05-07 08:53:44	122	7	\N	63
5	2	1	2025-05-07 08:56:49	70	7	\N	151
6	2	2	2025-05-07 09:00:30	98	7	\N	0
7	3	0	2025-05-07 09:02:08	80	7	\N	163
8	3	1	2025-05-07 09:06:11	65	3	\N	149
9	3	2	2025-05-07 09:09:45	88	6	\N	0
10	4	0	2025-05-07 09:11:13	88	4	\N	73
11	4	1	2025-05-07 09:13:54	93	3	\N	72
12	4	2	2025-05-07 09:16:39	89	5	\N	0
13	5	0	2025-05-09 08:46:00	115	8	\N	97
14	5	1	2025-05-09 08:49:32	91	12	\N	133
15	5	2	2025-05-09 08:53:16	53	9	\N	0
16	6	0	2025-05-09 08:54:09	82	9	\N	70
17	6	1	2025-05-09 08:56:41	57	9	\N	108
18	6	2	2025-05-09 08:59:26	103	10	\N	141
19	6	3	2025-05-09 09:03:30	65	10	\N	0
20	7	0	2025-05-09 09:04:35	130	9	\N	94
21	7	1	2025-05-09 09:08:19	122	8	\N	141
22	7	2	2025-05-09 09:12:42	113	9	\N	0
23	8	0	2025-05-09 09:14:35	93	11	\N	94
24	8	1	2025-05-09 09:17:42	73	12	\N	147
25	8	2	2025-05-09 09:21:22	52	10	\N	0
26	9	0	2025-05-10 08:51:00	117	7	\N	172
27	9	1	2025-05-10 08:55:49	72	8	\N	143
28	9	2	2025-05-10 08:59:24	95	9	\N	0
29	10	0	2025-05-10 09:00:59	78	4	\N	77
30	10	1	2025-05-10 09:03:34	116	4	\N	128
31	10	2	2025-05-10 09:07:38	119	5	\N	0
32	11	0	2025-05-10 09:09:37	91	11	\N	88
33	11	1	2025-05-10 09:12:36	110	9	\N	123
34	11	2	2025-05-10 09:16:29	51	8	\N	170
35	11	3	2025-05-10 09:20:10	64	8	\N	0
36	12	0	2025-05-10 09:21:14	121	1	\N	0
37	13	0	2025-05-14 18:33:00	113	3	\N	156
38	13	1	2025-05-14 18:37:29	127	5	\N	103
39	13	2	2025-05-14 18:41:19	82	3	\N	115
40	13	3	2025-05-14 18:44:36	103	4	\N	0
41	14	0	2025-05-14 18:46:19	109	5	\N	157
42	14	1	2025-05-14 18:50:45	109	4	\N	176
43	14	2	2025-05-14 18:55:30	125	3	\N	98
44	14	3	2025-05-14 18:59:13	122	7	\N	0
45	15	0	2025-05-14 19:01:15	65	5	\N	129
46	15	1	2025-05-14 19:04:29	45	7	\N	136
47	15	2	2025-05-14 19:07:30	107	5	\N	0
48	16	0	2025-05-14 19:09:17	84	5	\N	90
49	16	1	2025-05-14 19:12:11	75	3	\N	172
50	16	2	2025-05-14 19:16:18	55	7	\N	0
51	17	0	2025-05-17 08:48:00	115	9	\N	81
52	17	1	2025-05-17 08:51:16	112	8	\N	171
53	17	2	2025-05-17 08:55:59	99	10	\N	87
54	17	3	2025-05-17 08:59:05	70	10	\N	0
55	18	0	2025-05-17 09:00:15	130	6	\N	143
56	18	1	2025-05-17 09:04:48	101	5	\N	175
57	18	2	2025-05-17 09:09:24	102	7	\N	0
58	19	0	2025-05-17 09:11:06	53	9	\N	103
59	19	1	2025-05-17 09:13:42	120	8	\N	130
60	19	2	2025-05-17 09:17:52	120	9	\N	0
61	20	0	2025-05-17 09:19:52	54	1	\N	0
62	21	0	2025-05-19 08:14:00	75	10	\N	95
63	21	1	2025-05-19 08:16:50	72	9	\N	129
64	21	2	2025-05-19 08:20:11	118	7	\N	0
65	22	0	2025-05-19 08:22:09	105	7	\N	163
66	22	1	2025-05-19 08:26:37	69	9	\N	72
67	22	2	2025-05-19 08:28:58	129	6	\N	0
68	23	0	2025-05-19 08:31:07	97	9	\N	119
69	23	1	2025-05-19 08:34:43	128	6	\N	142
70	23	2	2025-05-19 08:39:13	52	6	\N	0
71	24	0	2025-05-19 08:40:05	58	8	\N	91
72	24	1	2025-05-19 08:42:34	69	7	\N	128
73	24	2	2025-05-19 08:45:51	62	9	\N	114
74	24	3	2025-05-19 08:48:47	80	7	\N	0
75	25	0	2025-05-21 08:28:00	46	7	\N	71
76	25	1	2025-05-21 08:29:57	66	4	\N	112
77	25	2	2025-05-21 08:32:55	106	6	\N	0
78	26	0	2025-05-21 08:34:41	66	3	\N	108
79	26	1	2025-05-21 08:37:35	94	3	\N	93
80	26	2	2025-05-21 08:40:42	81	6	\N	0
81	27	0	2025-05-21 08:42:03	129	7	\N	151
82	27	1	2025-05-21 08:46:43	64	6	\N	84
83	27	2	2025-05-21 08:49:11	72	5	\N	67
84	27	3	2025-05-21 08:51:30	114	7	\N	0
85	28	0	2025-05-21 08:53:24	52	5	\N	66
86	28	1	2025-05-21 08:55:22	106	7	\N	124
87	28	2	2025-05-21 08:59:12	65	7	\N	67
88	28	3	2025-05-21 09:01:24	55	7	\N	0
89	29	0	2025-05-23 08:38:00	76	12	\N	134
90	29	1	2025-05-23 08:41:30	50	12	\N	139
91	29	2	2025-05-23 08:44:39	98	8	\N	0
92	30	0	2025-05-23 08:46:17	130	9	\N	151
93	30	1	2025-05-23 08:50:58	75	10	\N	93
94	30	2	2025-05-23 08:53:46	61	11	\N	0
95	31	0	2025-05-23 08:54:47	103	10	\N	100
96	31	1	2025-05-23 08:58:10	46	8	\N	118
97	31	2	2025-05-23 09:00:54	117	12	\N	72
98	31	3	2025-05-23 09:04:03	113	8	\N	0
99	32	0	2025-05-23 09:05:56	61	10	\N	179
100	32	1	2025-05-23 09:09:56	53	10	\N	172
101	32	2	2025-05-23 09:13:41	92	9	\N	96
102	32	3	2025-05-23 09:16:49	101	9	\N	0
103	33	0	2025-05-24 17:39:00	83	10	\N	179
104	33	1	2025-05-24 17:43:22	62	6	\N	93
105	33	2	2025-05-24 17:45:57	58	6	\N	155
106	33	3	2025-05-24 17:49:30	64	10	\N	0
107	34	0	2025-05-24 17:50:34	71	7	\N	151
108	34	1	2025-05-24 17:54:16	71	5	\N	147
109	34	2	2025-05-24 17:57:54	109	5	\N	0
110	35	0	2025-05-24 17:59:43	56	8	\N	141
111	35	1	2025-05-24 18:03:00	80	11	\N	65
112	35	2	2025-05-24 18:05:25	87	8	\N	0
113	36	0	2025-05-24 18:06:52	65	1	\N	0
114	37	0	2025-05-26 19:45:00	64	6	\N	129
115	37	1	2025-05-26 19:48:13	92	6	\N	134
116	37	2	2025-05-26 19:51:59	63	10	\N	0
117	38	0	2025-05-26 19:53:02	84	6	\N	106
118	38	1	2025-05-26 19:56:12	90	6	\N	86
119	38	2	2025-05-26 19:59:08	130	7	\N	0
120	39	0	2025-05-26 20:01:18	97	10	\N	139
121	39	1	2025-05-26 20:05:14	75	7	\N	170
122	39	2	2025-05-26 20:09:19	67	7	\N	0
123	40	0	2025-05-26 20:10:26	87	7	\N	160
124	40	1	2025-05-26 20:14:33	130	9	\N	170
125	40	2	2025-05-26 20:19:33	79	7	\N	0
126	41	0	2025-05-30 18:55:00	89	11	\N	99
127	41	1	2025-05-30 18:58:08	73	9	\N	63
128	41	2	2025-05-30 19:00:24	96	9	\N	0
129	42	0	2025-05-30 19:02:00	80	8	\N	104
130	42	1	2025-05-30 19:05:04	96	12	\N	146
131	42	2	2025-05-30 19:09:06	87	12	\N	0
132	43	0	2025-05-30 19:10:33	67	10	\N	134
133	43	1	2025-05-30 19:13:54	49	10	\N	73
134	43	2	2025-05-30 19:15:56	100	12	\N	0
135	44	0	2025-05-30 19:17:36	100	10	\N	137
136	44	1	2025-05-30 19:21:33	59	12	\N	109
137	44	2	2025-05-30 19:24:21	69	12	\N	92
138	44	3	2025-05-30 19:27:02	100	8	\N	0
139	45	0	2025-06-02 19:43:00	130	6	\N	177
140	45	1	2025-06-02 19:48:07	124	8	\N	100
141	45	2	2025-06-02 19:51:51	83	6	\N	0
142	46	0	2025-06-02 19:53:14	86	9	\N	111
143	46	1	2025-06-02 19:56:31	115	8	\N	76
144	46	2	2025-06-02 19:59:42	98	7	\N	0
145	47	0	2025-06-02 20:01:20	123	7	\N	132
146	47	1	2025-06-02 20:05:35	96	8	\N	130
147	47	2	2025-06-02 20:09:21	83	6	\N	96
148	47	3	2025-06-02 20:12:20	100	7	\N	0
149	48	0	2025-06-02 20:14:00	104	8	\N	116
150	48	1	2025-06-02 20:17:40	72	9	\N	125
151	48	2	2025-06-02 20:20:57	66	9	\N	144
152	48	3	2025-06-02 20:24:27	81	6	\N	0
153	49	0	2025-06-04 19:21:00	70	4	\N	78
154	49	1	2025-06-04 19:23:28	50	3	\N	91
155	49	2	2025-06-04 19:25:49	123	6	\N	0
156	50	0	2025-06-04 19:27:52	125	6	\N	133
157	50	1	2025-06-04 19:32:10	94	4	\N	123
158	50	2	2025-06-04 19:35:47	76	6	\N	0
159	51	0	2025-06-04 19:37:03	58	3	\N	159
160	51	1	2025-06-04 19:40:40	73	6	\N	82
161	51	2	2025-06-04 19:43:15	104	7	\N	66
162	51	3	2025-06-04 19:46:05	76	7	\N	0
163	52	0	2025-06-04 19:47:21	104	4	\N	145
164	52	1	2025-06-04 19:51:30	116	7	\N	136
165	52	2	2025-06-04 19:55:42	101	5	\N	0
166	53	0	2025-06-06 19:27:00	102	11	\N	93
167	53	1	2025-06-06 19:30:15	126	9	\N	95
168	53	2	2025-06-06 19:33:56	107	12	\N	0
169	54	0	2025-06-06 19:35:43	54	11	\N	151
170	54	1	2025-06-06 19:39:08	75	10	\N	94
171	54	2	2025-06-06 19:41:57	85	10	\N	0
172	55	0	2025-06-06 19:43:22	64	9	\N	89
173	55	1	2025-06-06 19:45:55	64	11	\N	150
174	55	2	2025-06-06 19:49:29	53	9	\N	0
175	56	0	2025-06-06 19:50:22	114	10	\N	119
176	56	1	2025-06-06 19:54:15	52	11	\N	86
177	56	2	2025-06-06 19:56:33	94	11	\N	0
178	57	0	2025-06-07 19:44:00	90	6	\N	98
179	57	1	2025-06-07 19:47:08	98	9	\N	128
180	57	2	2025-06-07 19:50:54	122	10	\N	0
181	58	0	2025-06-07 19:52:56	79	4	\N	115
182	58	1	2025-06-07 19:56:10	48	6	\N	109
183	58	2	2025-06-07 19:58:47	130	5	\N	0
184	59	0	2025-06-07 20:00:57	104	9	\N	177
185	59	1	2025-06-07 20:05:38	124	9	\N	128
186	59	2	2025-06-07 20:09:50	95	8	\N	135
187	59	3	2025-06-07 20:13:40	129	12	\N	0
188	60	0	2025-06-07 20:15:49	127	1	\N	0
189	61	0	2025-06-09 18:11:00	103	7	\N	101
190	61	1	2025-06-09 18:14:24	93	8	\N	95
191	61	2	2025-06-09 18:17:32	77	9	\N	0
192	62	0	2025-06-09 18:18:49	114	6	\N	66
193	62	1	2025-06-09 18:21:49	73	8	\N	143
194	62	2	2025-06-09 18:25:25	128	6	\N	0
195	63	0	2025-06-09 18:27:33	70	7	\N	167
196	63	1	2025-06-09 18:31:30	124	6	\N	79
197	63	2	2025-06-09 18:34:53	61	7	\N	0
198	64	0	2025-06-09 18:35:54	117	6	\N	87
199	64	1	2025-06-09 18:39:18	77	9	\N	158
200	64	2	2025-06-09 18:43:13	66	8	\N	137
201	64	3	2025-06-09 18:46:36	59	10	\N	0
202	65	0	2025-06-11 09:19:00	93	7	\N	110
203	65	1	2025-06-11 09:22:23	54	4	\N	135
204	65	2	2025-06-11 09:25:32	58	4	\N	0
205	66	0	2025-06-11 09:26:30	60	7	\N	161
206	66	1	2025-06-11 09:30:11	50	7	\N	104
207	66	2	2025-06-11 09:32:45	99	7	\N	144
208	66	3	2025-06-11 09:36:48	53	5	\N	0
209	67	0	2025-06-11 09:37:41	107	6	\N	73
210	67	1	2025-06-11 09:40:41	91	6	\N	141
211	67	2	2025-06-11 09:44:33	64	6	\N	0
212	68	0	2025-06-11 09:45:37	128	7	\N	94
213	68	1	2025-06-11 09:49:19	113	7	\N	159
214	68	2	2025-06-11 09:53:51	104	6	\N	0
215	69	0	2025-06-13 19:17:00	76	11	\N	156
216	69	1	2025-06-13 19:20:52	117	11	\N	138
217	69	2	2025-06-13 19:25:07	88	11	\N	0
218	70	0	2025-06-13 19:26:35	68	10	\N	122
219	70	1	2025-06-13 19:29:45	90	9	\N	162
220	70	2	2025-06-13 19:33:57	88	10	\N	0
221	71	0	2025-06-13 19:35:25	116	10	\N	61
222	71	1	2025-06-13 19:38:22	69	12	\N	70
223	71	2	2025-06-13 19:40:41	97	9	\N	122
224	71	3	2025-06-13 19:44:20	75	12	\N	0
225	72	0	2025-06-13 19:45:35	102	11	\N	161
226	72	1	2025-06-13 19:49:58	56	8	\N	97
227	72	2	2025-06-13 19:52:31	96	9	\N	148
228	72	3	2025-06-13 19:56:35	84	9	\N	0
229	73	0	2025-06-14 17:30:00	87	10	\N	105
230	73	1	2025-06-14 17:33:12	79	9	\N	99
231	73	2	2025-06-14 17:36:10	74	8	\N	0
232	74	0	2025-06-14 17:37:24	85	4	\N	75
233	74	1	2025-06-14 17:40:04	68	7	\N	84
234	74	2	2025-06-14 17:42:36	106	4	\N	95
235	74	3	2025-06-14 17:45:57	112	7	\N	0
236	75	0	2025-06-14 17:47:49	69	8	\N	97
237	75	1	2025-06-14 17:50:35	91	9	\N	82
238	75	2	2025-06-14 17:53:28	46	10	\N	0
239	76	0	2025-06-14 17:54:14	50	1	\N	0
240	77	0	2025-06-16 19:18:00	46	7	\N	133
241	77	1	2025-06-16 19:20:59	105	9	\N	121
242	77	2	2025-06-16 19:24:45	88	10	\N	0
243	78	0	2025-06-16 19:26:13	106	9	\N	74
244	78	1	2025-06-16 19:29:13	96	7	\N	122
245	78	2	2025-06-16 19:32:51	118	7	\N	0
246	79	0	2025-06-16 19:34:49	117	8	\N	98
247	79	1	2025-06-16 19:38:24	76	7	\N	75
248	79	2	2025-06-16 19:40:55	98	11	\N	0
249	80	0	2025-06-16 19:42:33	73	11	\N	159
250	80	1	2025-06-16 19:46:25	93	11	\N	117
251	80	2	2025-06-16 19:49:55	83	10	\N	170
252	80	3	2025-06-16 19:54:08	99	11	\N	0
253	81	0	2025-06-18 19:03:00	78	4	\N	144
254	81	1	2025-06-18 19:06:42	65	3	\N	90
255	81	2	2025-06-18 19:09:17	115	4	\N	69
256	81	3	2025-06-18 19:12:21	45	4	\N	0
257	82	0	2025-06-18 19:13:06	105	7	\N	97
258	82	1	2025-06-18 19:16:28	74	3	\N	96
259	82	2	2025-06-18 19:19:18	103	5	\N	0
260	83	0	2025-06-18 19:21:01	78	4	\N	160
261	83	1	2025-06-18 19:24:59	129	7	\N	162
262	83	2	2025-06-18 19:29:50	99	4	\N	74
263	83	3	2025-06-18 19:32:43	73	7	\N	0
264	84	0	2025-06-18 19:33:56	63	5	\N	69
265	84	1	2025-06-18 19:36:08	66	3	\N	161
266	84	2	2025-06-18 19:39:55	121	5	\N	0
267	85	0	2025-06-20 19:58:00	96	10	\N	180
268	85	1	2025-06-20 20:02:36	109	10	\N	129
269	85	2	2025-06-20 20:06:34	101	11	\N	0
270	86	0	2025-06-20 20:08:15	100	8	\N	154
271	86	1	2025-06-20 20:12:29	122	10	\N	92
272	86	2	2025-06-20 20:16:03	56	8	\N	89
273	86	3	2025-06-20 20:18:28	120	12	\N	0
274	87	0	2025-06-20 20:20:28	118	10	\N	65
275	87	1	2025-06-20 20:23:31	105	9	\N	126
276	87	2	2025-06-20 20:27:22	80	11	\N	83
277	87	3	2025-06-20 20:30:05	100	12	\N	0
278	88	0	2025-06-20 20:31:45	89	11	\N	112
279	88	1	2025-06-20 20:35:06	86	10	\N	145
280	88	2	2025-06-20 20:38:57	65	8	\N	0
281	89	0	2025-06-21 18:18:00	56	10	\N	100
282	89	1	2025-06-21 18:20:36	86	9	\N	74
283	89	2	2025-06-21 18:23:16	110	10	\N	0
284	90	0	2025-06-21 18:25:06	104	7	\N	112
285	90	1	2025-06-21 18:28:42	69	3	\N	126
286	90	2	2025-06-21 18:31:57	124	5	\N	156
287	90	3	2025-06-21 18:36:37	125	6	\N	0
288	91	0	2025-06-21 18:38:42	79	9	\N	130
289	91	1	2025-06-21 18:42:11	81	9	\N	116
290	91	2	2025-06-21 18:45:28	60	11	\N	0
291	92	0	2025-06-21 18:46:28	75	2	\N	0
292	93	0	2025-06-23 17:35:00	59	8	\N	119
293	93	1	2025-06-23 17:37:58	127	7	\N	166
294	93	2	2025-06-23 17:42:51	108	8	\N	0
295	94	0	2025-06-23 17:44:39	98	9	\N	166
296	94	1	2025-06-23 17:49:03	105	10	\N	91
297	94	2	2025-06-23 17:52:19	115	10	\N	78
298	94	3	2025-06-23 17:55:32	69	10	\N	0
299	95	0	2025-06-23 17:56:41	98	9	\N	103
300	95	1	2025-06-23 18:00:02	79	11	\N	165
301	95	2	2025-06-23 18:04:06	81	7	\N	0
302	96	0	2025-06-23 18:05:27	119	11	\N	144
303	96	1	2025-06-23 18:09:50	64	10	\N	117
304	96	2	2025-06-23 18:12:51	106	11	\N	0
305	97	0	2025-06-25 19:48:00	75	4	\N	133
306	97	1	2025-06-25 19:51:28	74	6	\N	169
307	97	2	2025-06-25 19:55:31	50	6	\N	0
308	98	0	2025-06-25 19:56:21	93	6	\N	109
309	98	1	2025-06-25 19:59:43	108	4	\N	64
310	98	2	2025-06-25 20:02:35	109	4	\N	135
311	98	3	2025-06-25 20:06:39	57	5	\N	0
312	99	0	2025-06-25 20:07:36	103	7	\N	61
313	99	1	2025-06-25 20:10:20	97	4	\N	171
314	99	2	2025-06-25 20:14:48	54	4	\N	0
315	100	0	2025-06-25 20:15:42	124	5	\N	148
316	100	1	2025-06-25 20:20:14	128	6	\N	70
317	100	2	2025-06-25 20:23:32	113	5	\N	0
318	101	0	2025-06-27 17:40:00	53	13	\N	90
319	101	1	2025-06-27 17:42:23	74	11	\N	155
320	101	2	2025-06-27 17:46:12	100	9	\N	0
321	102	0	2025-06-27 17:47:52	101	9	\N	81
322	102	1	2025-06-27 17:50:54	48	11	\N	65
323	102	2	2025-06-27 17:52:47	52	11	\N	97
324	102	3	2025-06-27 17:55:16	92	11	\N	0
325	103	0	2025-06-27 17:56:48	112	10	\N	112
326	103	1	2025-06-27 18:00:32	68	13	\N	81
327	103	2	2025-06-27 18:03:01	55	10	\N	0
328	104	0	2025-06-27 18:03:56	108	10	\N	176
329	104	1	2025-06-27 18:08:40	63	13	\N	89
330	104	2	2025-06-27 18:11:12	126	12	\N	92
331	104	3	2025-06-27 18:14:50	77	12	\N	0
332	105	0	2025-06-28 18:57:00	89	10	\N	135
333	105	1	2025-06-28 19:00:44	126	9	\N	114
334	105	2	2025-06-28 19:04:44	103	9	\N	0
335	106	0	2025-06-28 19:06:27	106	6	\N	73
336	106	1	2025-06-28 19:09:26	93	4	\N	133
337	106	2	2025-06-28 19:13:12	118	5	\N	0
338	107	0	2025-06-28 19:15:10	47	11	\N	166
339	107	1	2025-06-28 19:18:43	80	12	\N	61
340	107	2	2025-06-28 19:21:04	51	13	\N	176
341	107	3	2025-06-28 19:24:51	108	13	\N	0
342	108	0	2025-06-28 19:26:39	122	1	\N	0
343	109	0	2025-06-30 09:40:00	125	8	\N	72
344	109	1	2025-06-30 09:43:17	84	7	\N	160
345	109	2	2025-06-30 09:47:21	49	10	\N	134
346	109	3	2025-06-30 09:50:24	61	9	\N	0
347	110	0	2025-06-30 09:51:25	98	9	\N	82
348	110	1	2025-06-30 09:54:25	61	8	\N	160
349	110	2	2025-06-30 09:58:06	91	11	\N	0
350	111	0	2025-06-30 09:59:37	106	9	\N	163
351	111	1	2025-06-30 10:04:06	88	9	\N	162
352	111	2	2025-06-30 10:08:16	104	7	\N	0
353	112	0	2025-06-30 10:10:00	95	8	\N	168
354	112	1	2025-06-30 10:14:23	91	11	\N	71
355	112	2	2025-06-30 10:17:05	46	10	\N	0
356	113	0	2025-07-02 08:29:00	58	5	\N	146
357	113	1	2025-07-02 08:32:24	105	4	\N	63
358	113	2	2025-07-02 08:35:12	116	7	\N	0
359	114	0	2025-07-02 08:37:08	127	4	\N	68
360	114	1	2025-07-02 08:40:23	83	6	\N	143
361	114	2	2025-07-02 08:44:09	59	6	\N	77
362	114	3	2025-07-02 08:46:25	49	3	\N	0
363	115	0	2025-07-02 08:47:14	57	3	\N	90
364	115	1	2025-07-02 08:49:41	62	7	\N	109
365	115	2	2025-07-02 08:52:32	92	6	\N	0
366	116	0	2025-07-02 08:54:04	98	7	\N	135
367	116	1	2025-07-02 08:57:57	98	4	\N	143
368	116	2	2025-07-02 09:01:58	107	3	\N	138
369	116	3	2025-07-02 09:06:03	80	6	\N	0
370	117	0	2025-07-05 18:28:00	114	9	\N	175
371	117	1	2025-07-05 18:32:49	52	9	\N	110
372	117	2	2025-07-05 18:35:31	69	9	\N	75
373	117	3	2025-07-05 18:37:55	56	10	\N	0
374	118	0	2025-07-05 18:38:51	47	7	\N	66
375	118	1	2025-07-05 18:40:44	76	5	\N	76
376	118	2	2025-07-05 18:43:16	71	7	\N	0
377	119	0	2025-07-05 18:44:27	120	10	\N	87
378	119	1	2025-07-05 18:47:54	87	10	\N	159
379	119	2	2025-07-05 18:52:00	121	10	\N	60
380	119	3	2025-07-05 18:55:01	63	11	\N	0
381	120	0	2025-07-05 18:56:04	77	2	\N	0
382	121	0	2025-07-07 08:42:00	75	9	\N	135
383	121	1	2025-07-07 08:45:30	47	9	\N	82
384	121	2	2025-07-07 08:47:39	51	9	\N	0
385	122	0	2025-07-07 08:48:30	112	10	\N	74
386	122	1	2025-07-07 08:51:36	105	7	\N	117
387	122	2	2025-07-07 08:55:18	110	9	\N	135
388	122	3	2025-07-07 08:59:23	102	7	\N	0
389	123	0	2025-07-07 09:01:05	129	7	\N	126
390	123	1	2025-07-07 09:05:20	103	9	\N	142
391	123	2	2025-07-07 09:09:25	52	7	\N	121
392	123	3	2025-07-07 09:12:18	99	10	\N	0
393	124	0	2025-07-07 09:13:57	101	10	\N	69
394	124	1	2025-07-07 09:16:47	86	7	\N	137
395	124	2	2025-07-07 09:20:30	53	8	\N	0
396	125	0	2025-07-11 19:35:00	82	13	\N	118
397	125	1	2025-07-11 19:38:20	122	13	\N	115
398	125	2	2025-07-11 19:42:17	59	9	\N	169
399	125	3	2025-07-11 19:46:05	72	13	\N	0
400	126	0	2025-07-11 19:47:17	97	10	\N	103
401	126	1	2025-07-11 19:50:37	96	12	\N	113
402	126	2	2025-07-11 19:54:06	85	9	\N	0
403	127	0	2025-07-11 19:55:31	92	11	\N	79
404	127	1	2025-07-11 19:58:22	53	12	\N	71
405	127	2	2025-07-11 20:00:26	56	9	\N	0
406	128	0	2025-07-11 20:01:22	61	11	\N	131
407	128	1	2025-07-11 20:04:34	120	9	\N	131
408	128	2	2025-07-11 20:08:45	87	13	\N	0
409	129	0	2025-07-12 18:22:00	121	9	\N	99
410	129	1	2025-07-12 18:25:40	58	9	\N	133
411	129	2	2025-07-12 18:28:51	72	11	\N	0
412	130	0	2025-07-12 18:30:03	73	6	\N	168
413	130	1	2025-07-12 18:34:04	89	3	\N	168
414	130	2	2025-07-12 18:38:21	92	7	\N	74
415	130	3	2025-07-12 18:41:07	118	5	\N	0
416	131	0	2025-07-12 18:43:05	124	13	\N	138
417	131	1	2025-07-12 18:47:27	48	13	\N	137
418	131	2	2025-07-12 18:50:32	48	11	\N	0
419	132	0	2025-07-12 18:51:20	84	1	\N	0
420	133	0	2025-07-14 17:00:00	53	10	\N	78
421	133	1	2025-07-14 17:02:11	56	7	\N	155
422	133	2	2025-07-14 17:05:42	72	11	\N	108
423	133	3	2025-07-14 17:08:42	103	10	\N	0
424	134	0	2025-07-14 17:10:25	84	9	\N	152
425	134	1	2025-07-14 17:14:21	117	9	\N	136
426	134	2	2025-07-14 17:18:34	51	7	\N	0
427	135	0	2025-07-14 17:19:25	51	11	\N	146
428	135	1	2025-07-14 17:22:42	79	7	\N	116
429	135	2	2025-07-14 17:25:57	107	10	\N	0
430	136	0	2025-07-14 17:27:44	79	10	\N	87
431	136	1	2025-07-14 17:30:30	59	11	\N	104
432	136	2	2025-07-14 17:33:13	59	10	\N	0
433	137	0	2025-07-16 19:31:00	121	6	\N	67
434	137	1	2025-07-16 19:34:08	71	3	\N	98
435	137	2	2025-07-16 19:36:57	62	4	\N	0
436	138	0	2025-07-16 19:37:59	60	5	\N	60
437	138	1	2025-07-16 19:39:59	100	6	\N	82
438	138	2	2025-07-16 19:43:01	93	4	\N	0
439	139	0	2025-07-16 19:44:34	130	7	\N	163
440	139	1	2025-07-16 19:49:27	54	5	\N	110
441	139	2	2025-07-16 19:52:11	100	3	\N	62
442	139	3	2025-07-16 19:54:53	54	6	\N	0
443	140	0	2025-07-16 19:55:47	118	6	\N	111
444	140	1	2025-07-16 19:59:36	82	6	\N	74
445	140	2	2025-07-16 20:02:12	47	6	\N	101
446	140	3	2025-07-16 20:04:40	124	4	\N	0
447	141	0	2025-07-18 17:05:00	96	13	\N	127
448	141	1	2025-07-18 17:08:43	95	9	\N	171
449	141	2	2025-07-18 17:13:09	88	11	\N	0
450	142	0	2025-07-18 17:14:37	54	10	\N	125
451	142	1	2025-07-18 17:17:36	112	9	\N	125
452	142	2	2025-07-18 17:21:33	89	10	\N	0
453	143	0	2025-07-18 17:23:02	75	10	\N	73
454	143	1	2025-07-18 17:25:30	77	10	\N	85
455	143	2	2025-07-18 17:28:12	122	10	\N	79
456	143	3	2025-07-18 17:31:33	67	9	\N	0
457	144	0	2025-07-18 17:32:40	119	13	\N	117
458	144	1	2025-07-18 17:36:36	127	13	\N	141
459	144	2	2025-07-18 17:41:04	86	13	\N	0
460	145	0	2025-07-19 17:09:00	80	9	\N	135
461	145	1	2025-07-19 17:12:35	90	7	\N	124
462	145	2	2025-07-19 17:16:09	84	7	\N	0
463	146	0	2025-07-19 17:17:33	52	3	\N	107
464	146	1	2025-07-19 17:20:12	54	5	\N	142
465	146	2	2025-07-19 17:23:28	123	3	\N	0
466	147	0	2025-07-19 17:25:31	104	12	\N	134
467	147	1	2025-07-19 17:29:29	50	13	\N	117
468	147	2	2025-07-19 17:32:16	128	13	\N	84
469	147	3	2025-07-19 17:35:48	122	11	\N	0
470	148	0	2025-07-19 17:37:50	64	2	\N	0
471	149	0	2025-07-21 18:06:00	127	11	\N	82
472	149	1	2025-07-21 18:09:29	76	7	\N	150
473	149	2	2025-07-21 18:13:15	101	10	\N	0
474	150	0	2025-07-21 18:14:56	65	11	\N	106
475	150	1	2025-07-21 18:17:47	81	9	\N	109
476	150	2	2025-07-21 18:20:57	88	10	\N	146
477	150	3	2025-07-21 18:24:51	51	11	\N	0
478	151	0	2025-07-21 18:25:42	57	9	\N	131
479	151	1	2025-07-21 18:28:50	81	10	\N	92
480	151	2	2025-07-21 18:31:43	64	11	\N	0
481	152	0	2025-07-21 18:32:47	129	11	\N	78
482	152	1	2025-07-21 18:36:14	84	9	\N	143
483	152	2	2025-07-21 18:40:01	61	10	\N	0
484	153	0	2025-07-23 08:19:00	130	4	\N	149
485	153	1	2025-07-23 08:23:39	56	7	\N	142
486	153	2	2025-07-23 08:26:57	110	6	\N	0
487	154	0	2025-07-23 08:28:47	84	5	\N	83
488	154	1	2025-07-23 08:31:34	88	4	\N	158
489	154	2	2025-07-23 08:35:40	69	6	\N	0
490	155	0	2025-07-23 08:36:49	54	4	\N	97
491	155	1	2025-07-23 08:39:20	109	3	\N	158
492	155	2	2025-07-23 08:43:47	112	7	\N	0
493	156	0	2025-07-23 08:45:39	124	5	\N	76
494	156	1	2025-07-23 08:48:59	93	7	\N	79
495	156	2	2025-07-23 08:51:51	68	4	\N	166
496	156	3	2025-07-23 08:55:45	66	7	\N	0
497	157	0	2025-07-25 08:26:00	102	11	\N	89
498	157	1	2025-07-25 08:29:11	75	13	\N	99
499	157	2	2025-07-25 08:32:05	69	12	\N	107
500	157	3	2025-07-25 08:35:01	101	13	\N	0
501	158	0	2025-07-25 08:36:42	109	12	\N	127
502	158	1	2025-07-25 08:40:38	65	12	\N	164
503	158	2	2025-07-25 08:44:27	122	10	\N	0
504	159	0	2025-07-25 08:46:29	127	9	\N	121
505	159	1	2025-07-25 08:50:37	115	11	\N	179
506	159	2	2025-07-25 08:55:31	111	9	\N	0
507	160	0	2025-07-25 08:57:22	65	9	\N	94
508	160	1	2025-07-25 09:00:01	110	12	\N	78
509	160	2	2025-07-25 09:03:09	56	12	\N	0
510	161	0	2025-07-26 09:52:00	95	7	\N	124
511	161	1	2025-07-26 09:55:39	75	9	\N	109
512	161	2	2025-07-26 09:58:43	92	7	\N	0
513	162	0	2025-07-26 10:00:15	57	5	\N	167
514	162	1	2025-07-26 10:03:59	63	5	\N	77
515	162	2	2025-07-26 10:06:19	81	3	\N	0
516	163	0	2025-07-26 10:07:40	105	10	\N	117
517	163	1	2025-07-26 10:11:22	45	13	\N	175
518	163	2	2025-07-26 10:15:02	47	9	\N	92
519	163	3	2025-07-26 10:17:21	64	10	\N	0
520	164	0	2025-07-26 10:18:25	81	1	\N	0
521	165	0	2025-07-28 08:03:00	53	10	\N	74
522	165	1	2025-07-28 08:05:07	121	10	\N	128
523	165	2	2025-07-28 08:09:16	125	7	\N	125
524	165	3	2025-07-28 08:13:26	75	11	\N	0
525	166	0	2025-07-28 08:14:41	45	10	\N	138
526	166	1	2025-07-28 08:17:44	75	9	\N	133
527	166	2	2025-07-28 08:21:12	68	10	\N	0
528	167	0	2025-07-28 08:22:20	53	9	\N	127
529	167	1	2025-07-28 08:25:20	109	11	\N	160
530	167	2	2025-07-28 08:29:49	115	11	\N	62
531	167	3	2025-07-28 08:32:46	105	10	\N	0
532	168	0	2025-07-28 08:34:31	92	10	\N	92
533	168	1	2025-07-28 08:37:35	90	7	\N	160
534	168	2	2025-07-28 08:41:45	89	7	\N	90
535	168	3	2025-07-28 08:44:44	119	7	\N	0
536	169	0	2025-07-30 17:08:00	104	4	\N	149
537	169	1	2025-07-30 17:12:13	125	6	\N	83
538	169	2	2025-07-30 17:15:41	53	4	\N	0
539	170	0	2025-07-30 17:16:34	70	5	\N	65
540	170	1	2025-07-30 17:18:49	50	4	\N	100
541	170	2	2025-07-30 17:21:19	110	5	\N	0
542	171	0	2025-07-30 17:23:09	77	6	\N	64
543	171	1	2025-07-30 17:25:30	81	4	\N	105
544	171	2	2025-07-30 17:28:36	128	3	\N	102
545	171	3	2025-07-30 17:32:26	60	5	\N	0
546	172	0	2025-07-30 17:33:26	101	6	\N	174
547	172	1	2025-07-30 17:38:01	88	6	\N	83
548	172	2	2025-07-30 17:40:52	108	6	\N	0
549	173	0	2025-08-01 19:17:00	122	12	\N	165
550	173	1	2025-08-01 19:21:47	114	10	\N	97
551	173	2	2025-08-01 19:25:18	58	11	\N	0
552	174	0	2025-08-01 19:26:16	84	11	\N	117
553	174	1	2025-08-01 19:29:37	99	13	\N	81
554	174	2	2025-08-01 19:32:37	89	12	\N	0
555	175	0	2025-08-01 19:34:06	123	11	\N	115
556	175	1	2025-08-01 19:38:04	126	11	\N	161
557	175	2	2025-08-01 19:42:51	54	9	\N	0
558	176	0	2025-08-01 19:43:45	65	13	\N	63
559	176	1	2025-08-01 19:45:53	122	10	\N	146
560	176	2	2025-08-01 19:50:21	49	12	\N	0
561	177	0	2025-08-04 17:23:00	102	8	\N	107
562	177	1	2025-08-04 17:26:29	101	9	\N	157
563	177	2	2025-08-04 17:30:47	118	7	\N	77
564	177	3	2025-08-04 17:34:02	91	11	\N	0
565	178	0	2025-08-04 17:35:33	76	9	\N	74
566	178	1	2025-08-04 17:38:03	68	7	\N	123
567	178	2	2025-08-04 17:41:14	94	11	\N	0
568	179	0	2025-08-04 17:42:48	102	9	\N	87
569	179	1	2025-08-04 17:45:57	81	11	\N	148
570	179	2	2025-08-04 17:49:46	70	10	\N	0
571	180	0	2025-08-04 17:50:56	102	7	\N	82
572	180	1	2025-08-04 17:54:00	56	10	\N	163
573	180	2	2025-08-04 17:57:39	130	9	\N	0
574	181	0	2025-08-06 08:35:00	91	4	\N	125
575	181	1	2025-08-06 08:38:36	60	4	\N	85
576	181	2	2025-08-06 08:41:01	75	4	\N	0
577	182	0	2025-08-06 08:42:16	115	5	\N	133
578	182	1	2025-08-06 08:46:24	104	5	\N	162
579	182	2	2025-08-06 08:50:50	61	7	\N	0
580	183	0	2025-08-06 08:51:51	95	5	\N	151
581	183	1	2025-08-06 08:55:57	112	6	\N	112
582	183	2	2025-08-06 08:59:41	118	6	\N	0
583	184	0	2025-08-06 09:01:39	127	5	\N	69
584	184	1	2025-08-06 09:04:55	104	6	\N	147
585	184	2	2025-08-06 09:09:06	89	7	\N	0
586	185	0	2025-08-09 19:40:00	52	11	\N	166
587	185	1	2025-08-09 19:43:38	111	7	\N	79
588	185	2	2025-08-09 19:46:48	66	9	\N	0
589	186	0	2025-08-09 19:47:54	89	4	\N	180
590	186	1	2025-08-09 19:52:23	81	7	\N	168
591	186	2	2025-08-09 19:56:32	77	3	\N	0
592	187	0	2025-08-09 19:57:49	80	13	\N	76
593	187	1	2025-08-09 20:00:25	123	11	\N	128
594	187	2	2025-08-09 20:04:36	109	9	\N	142
595	187	3	2025-08-09 20:08:47	120	10	\N	0
596	188	0	2025-08-09 20:10:47	129	1	\N	0
597	189	0	2025-08-11 19:21:00	50	7	\N	142
598	189	1	2025-08-11 19:24:12	78	11	\N	143
599	189	2	2025-08-11 19:27:53	118	8	\N	0
600	190	0	2025-08-11 19:29:51	108	7	\N	173
601	190	1	2025-08-11 19:34:32	82	11	\N	142
602	190	2	2025-08-11 19:38:16	106	9	\N	91
603	190	3	2025-08-11 19:41:33	83	10	\N	0
604	191	0	2025-08-11 19:42:56	65	7	\N	116
605	191	1	2025-08-11 19:45:57	106	10	\N	119
606	191	2	2025-08-11 19:49:42	88	8	\N	0
607	192	0	2025-08-11 19:51:10	85	9	\N	153
608	192	1	2025-08-11 19:55:08	96	9	\N	76
609	192	2	2025-08-11 19:58:00	110	9	\N	0
610	193	0	2025-08-13 17:15:00	63	4	\N	72
611	193	1	2025-08-13 17:17:15	82	3	\N	109
612	193	2	2025-08-13 17:20:26	98	7	\N	0
613	194	0	2025-08-13 17:22:04	118	5	\N	152
614	194	1	2025-08-13 17:26:34	69	5	\N	157
615	194	2	2025-08-13 17:30:20	108	4	\N	0
616	195	0	2025-08-13 17:32:08	108	5	\N	62
617	195	1	2025-08-13 17:34:58	95	3	\N	124
618	195	2	2025-08-13 17:38:37	75	6	\N	0
619	196	0	2025-08-13 17:39:52	51	5	\N	66
620	196	1	2025-08-13 17:41:49	108	5	\N	136
621	196	2	2025-08-13 17:45:53	81	6	\N	128
622	196	3	2025-08-13 17:49:22	58	3	\N	0
623	197	0	2025-08-15 17:46:00	51	12	\N	132
624	197	1	2025-08-15 17:49:03	69	13	\N	106
625	197	2	2025-08-15 17:51:58	81	13	\N	0
626	198	0	2025-08-15 17:53:19	102	13	\N	157
627	198	1	2025-08-15 17:57:38	80	13	\N	165
628	198	2	2025-08-15 18:01:43	123	13	\N	0
629	199	0	2025-08-15 18:03:46	95	9	\N	107
630	199	1	2025-08-15 18:07:08	116	11	\N	180
631	199	2	2025-08-15 18:12:04	63	11	\N	0
632	200	0	2025-08-15 18:13:07	96	13	\N	124
633	200	1	2025-08-15 18:16:47	50	9	\N	64
634	200	2	2025-08-15 18:18:41	87	10	\N	162
635	200	3	2025-08-15 18:22:50	111	12	\N	0
636	201	0	2025-08-16 19:57:00	65	9	\N	110
637	201	1	2025-08-16 19:59:55	83	11	\N	135
638	201	2	2025-08-16 20:03:33	109	9	\N	166
639	201	3	2025-08-16 20:08:08	113	11	\N	0
640	202	0	2025-08-16 20:10:01	83	7	\N	120
641	202	1	2025-08-16 20:13:24	92	3	\N	102
642	202	2	2025-08-16 20:16:38	98	3	\N	134
643	202	3	2025-08-16 20:20:30	125	5	\N	0
644	203	0	2025-08-16 20:22:35	78	12	\N	143
645	203	1	2025-08-16 20:26:16	118	13	\N	89
646	203	2	2025-08-16 20:29:43	119	9	\N	121
647	203	3	2025-08-16 20:33:43	112	10	\N	0
648	204	0	2025-08-16 20:35:35	76	1	\N	0
649	205	0	2025-08-20 08:12:00	97	4	\N	148
650	205	1	2025-08-20 08:16:05	97	4	\N	124
651	205	2	2025-08-20 08:19:46	105	7	\N	0
652	206	0	2025-08-20 08:21:31	111	4	\N	86
653	206	1	2025-08-20 08:24:48	86	7	\N	144
654	206	2	2025-08-20 08:28:38	112	6	\N	108
655	206	3	2025-08-20 08:32:18	67	5	\N	0
656	207	0	2025-08-20 08:33:25	114	5	\N	105
657	207	1	2025-08-20 08:37:04	123	5	\N	121
658	207	2	2025-08-20 08:41:08	76	4	\N	95
659	207	3	2025-08-20 08:43:59	83	7	\N	0
660	208	0	2025-08-20 08:45:22	71	5	\N	148
661	208	1	2025-08-20 08:49:01	85	6	\N	121
662	208	2	2025-08-20 08:52:27	116	5	\N	0
663	209	0	2025-08-22 17:18:00	89	12	\N	158
664	209	1	2025-08-22 17:22:07	82	10	\N	65
665	209	2	2025-08-22 17:24:34	55	11	\N	0
666	210	0	2025-08-22 17:25:29	106	11	\N	87
667	210	1	2025-08-22 17:28:42	113	10	\N	94
668	210	2	2025-08-22 17:32:09	79	13	\N	0
669	211	0	2025-08-22 17:33:28	120	13	\N	90
670	211	1	2025-08-22 17:36:58	51	10	\N	145
671	211	2	2025-08-22 17:40:14	73	13	\N	0
672	212	0	2025-08-22 17:41:27	97	9	\N	102
673	212	1	2025-08-22 17:44:46	57	12	\N	147
674	212	2	2025-08-22 17:48:10	45	10	\N	0
675	213	0	2025-08-23 09:26:00	81	8	\N	101
676	213	1	2025-08-23 09:29:02	127	9	\N	67
677	213	2	2025-08-23 09:32:16	128	7	\N	133
678	213	3	2025-08-23 09:36:37	113	8	\N	0
679	214	0	2025-08-23 09:38:30	67	3	\N	113
680	214	1	2025-08-23 09:41:30	49	4	\N	167
681	214	2	2025-08-23 09:45:06	108	6	\N	83
682	214	3	2025-08-23 09:48:17	49	5	\N	0
683	215	0	2025-08-23 09:49:06	122	13	\N	73
684	215	1	2025-08-23 09:52:21	81	11	\N	118
685	215	2	2025-08-23 09:55:40	112	13	\N	0
686	216	0	2025-08-23 09:57:32	109	1	\N	0
687	217	0	2025-08-25 09:51:00	127	11	\N	92
688	217	1	2025-08-25 09:54:39	46	9	\N	154
689	217	2	2025-08-25 09:57:59	82	10	\N	132
690	217	3	2025-08-25 10:01:33	67	9	\N	0
691	218	0	2025-08-25 10:02:40	99	11	\N	125
692	218	1	2025-08-25 10:06:24	56	10	\N	111
693	218	2	2025-08-25 10:09:11	68	8	\N	77
694	218	3	2025-08-25 10:11:36	86	11	\N	0
695	219	0	2025-08-25 10:13:02	94	10	\N	90
696	219	1	2025-08-25 10:16:06	79	11	\N	102
697	219	2	2025-08-25 10:19:07	119	10	\N	0
698	220	0	2025-08-25 10:21:06	78	8	\N	143
699	220	1	2025-08-25 10:24:47	75	10	\N	67
700	220	2	2025-08-25 10:27:09	104	8	\N	99
701	220	3	2025-08-25 10:30:32	96	9	\N	0
702	221	0	2025-08-27 17:44:00	73	5	\N	77
703	221	1	2025-08-27 17:46:30	64	7	\N	118
704	221	2	2025-08-27 17:49:32	92	8	\N	113
705	221	3	2025-08-27 17:52:57	105	8	\N	0
706	222	0	2025-08-27 17:54:42	76	5	\N	147
707	222	1	2025-08-27 17:58:25	55	8	\N	127
708	222	2	2025-08-27 18:01:27	112	7	\N	150
709	222	3	2025-08-27 18:05:49	54	6	\N	0
710	223	0	2025-08-27 18:06:43	109	8	\N	85
711	223	1	2025-08-27 18:09:57	113	8	\N	79
712	223	2	2025-08-27 18:13:09	86	5	\N	0
713	224	0	2025-08-27 18:14:35	71	4	\N	151
714	224	1	2025-08-27 18:18:17	107	8	\N	71
715	224	2	2025-08-27 18:21:15	102	8	\N	0
716	225	0	2025-08-29 18:08:00	116	10	\N	119
717	225	1	2025-08-29 18:11:55	47	12	\N	110
718	225	2	2025-08-29 18:14:32	45	12	\N	155
719	225	3	2025-08-29 18:17:52	119	11	\N	0
720	226	0	2025-08-29 18:19:51	89	13	\N	149
721	226	1	2025-08-29 18:23:49	114	10	\N	67
722	226	2	2025-08-29 18:26:50	105	10	\N	0
723	227	0	2025-08-29 18:28:35	68	13	\N	158
724	227	1	2025-08-29 18:32:21	127	11	\N	153
725	227	2	2025-08-29 18:37:01	92	13	\N	0
726	228	0	2025-08-29 18:38:33	93	13	\N	70
727	228	1	2025-08-29 18:41:16	62	14	\N	143
728	228	2	2025-08-29 18:44:41	60	12	\N	0
729	229	0	2025-09-01 19:08:00	104	10	\N	146
730	229	1	2025-09-01 19:12:10	99	12	\N	128
731	229	2	2025-09-01 19:15:57	74	11	\N	0
732	230	0	2025-09-01 19:17:11	64	10	\N	95
733	230	1	2025-09-01 19:19:50	59	9	\N	64
734	230	2	2025-09-01 19:21:53	123	11	\N	0
735	231	0	2025-09-01 19:23:56	53	9	\N	72
736	231	1	2025-09-01 19:26:01	49	12	\N	117
737	231	2	2025-09-01 19:28:47	51	12	\N	0
738	232	0	2025-09-01 19:29:38	96	8	\N	116
739	232	1	2025-09-01 19:33:10	114	9	\N	87
740	232	2	2025-09-01 19:36:31	62	8	\N	124
741	232	3	2025-09-01 19:39:37	74	10	\N	0
742	233	0	2025-09-03 19:20:00	83	5	\N	172
743	233	1	2025-09-03 19:24:15	129	5	\N	126
744	233	2	2025-09-03 19:28:30	97	5	\N	0
745	234	0	2025-09-03 19:30:07	116	4	\N	135
746	234	1	2025-09-03 19:34:18	125	5	\N	146
747	234	2	2025-09-03 19:38:49	116	7	\N	0
748	235	0	2025-09-03 19:40:45	127	6	\N	145
749	235	1	2025-09-03 19:45:17	112	7	\N	100
750	235	2	2025-09-03 19:48:49	97	7	\N	0
751	236	0	2025-09-03 19:50:26	68	7	\N	156
752	236	1	2025-09-03 19:54:10	105	8	\N	90
753	236	2	2025-09-03 19:57:25	83	5	\N	0
754	237	0	2025-09-05 09:51:00	116	13	\N	127
755	237	1	2025-09-05 09:55:03	94	11	\N	91
756	237	2	2025-09-05 09:58:08	71	12	\N	0
757	238	0	2025-09-05 09:59:19	102	10	\N	168
758	238	1	2025-09-05 10:03:49	56	12	\N	128
759	238	2	2025-09-05 10:06:53	51	11	\N	94
760	238	3	2025-09-05 10:09:18	122	13	\N	0
761	239	0	2025-09-05 10:11:20	69	10	\N	162
762	239	1	2025-09-05 10:15:11	130	14	\N	131
763	239	2	2025-09-05 10:19:32	106	11	\N	0
764	240	0	2025-09-05 10:21:18	46	12	\N	87
765	240	1	2025-09-05 10:23:31	60	11	\N	155
766	240	2	2025-09-05 10:27:06	76	13	\N	0
767	241	0	2025-09-06 09:25:00	104	11	\N	128
768	241	1	2025-09-06 09:28:52	84	10	\N	93
769	241	2	2025-09-06 09:31:49	110	10	\N	0
770	242	0	2025-09-06 09:33:39	105	4	\N	157
771	242	1	2025-09-06 09:38:01	71	6	\N	107
772	242	2	2025-09-06 09:40:59	97	6	\N	0
773	243	0	2025-09-06 09:42:36	63	11	\N	62
774	243	1	2025-09-06 09:44:41	115	12	\N	179
775	243	2	2025-09-06 09:49:35	119	14	\N	152
776	243	3	2025-09-06 09:54:06	82	13	\N	0
777	244	0	2025-09-06 09:55:28	87	1	\N	0
778	245	0	2025-09-08 19:53:00	77	10	\N	157
779	245	1	2025-09-08 19:56:54	127	11	\N	154
780	245	2	2025-09-08 20:01:35	103	11	\N	81
781	245	3	2025-09-08 20:04:39	66	10	\N	0
782	246	0	2025-09-08 20:05:45	107	12	\N	83
783	246	1	2025-09-08 20:08:55	127	12	\N	67
784	246	2	2025-09-08 20:12:09	49	12	\N	167
785	246	3	2025-09-08 20:15:45	130	8	\N	0
786	247	0	2025-09-08 20:17:55	62	11	\N	167
787	247	1	2025-09-08 20:21:44	53	9	\N	150
788	247	2	2025-09-08 20:25:07	46	9	\N	0
789	248	0	2025-09-08 20:25:53	92	11	\N	67
790	248	1	2025-09-08 20:28:32	126	12	\N	145
791	248	2	2025-09-08 20:33:03	106	12	\N	144
792	248	3	2025-09-08 20:37:13	47	11	\N	0
793	249	0	2025-09-12 08:01:00	109	10	\N	164
794	249	1	2025-09-12 08:05:33	67	13	\N	73
795	249	2	2025-09-12 08:07:53	112	10	\N	0
796	250	0	2025-09-12 08:09:45	124	11	\N	127
797	250	1	2025-09-12 08:13:56	90	12	\N	94
798	250	2	2025-09-12 08:17:00	55	13	\N	0
799	251	0	2025-09-12 08:17:55	117	13	\N	91
800	251	1	2025-09-12 08:21:23	83	11	\N	147
801	251	2	2025-09-12 08:25:13	128	10	\N	0
802	252	0	2025-09-12 08:27:21	93	13	\N	108
803	252	1	2025-09-12 08:30:42	105	14	\N	67
804	252	2	2025-09-12 08:33:34	66	10	\N	0
805	253	0	2025-09-15 17:36:00	72	9	\N	175
806	253	1	2025-09-15 17:40:07	105	12	\N	94
807	253	2	2025-09-15 17:43:26	54	8	\N	0
808	254	0	2025-09-15 17:44:20	129	12	\N	64
809	254	1	2025-09-15 17:47:33	85	9	\N	62
810	254	2	2025-09-15 17:50:00	120	9	\N	78
811	254	3	2025-09-15 17:53:18	54	11	\N	0
812	255	0	2025-09-15 17:54:12	75	12	\N	132
813	255	1	2025-09-15 17:57:39	114	11	\N	102
814	255	2	2025-09-15 18:01:15	62	11	\N	0
815	256	0	2025-09-15 18:02:17	109	8	\N	155
816	256	1	2025-09-15 18:06:41	51	10	\N	72
817	256	2	2025-09-15 18:08:44	74	11	\N	167
818	256	3	2025-09-15 18:12:45	88	8	\N	0
819	257	0	2025-09-17 19:38:00	102	6	\N	122
820	257	1	2025-09-17 19:41:44	90	5	\N	130
821	257	2	2025-09-17 19:45:24	100	7	\N	83
822	257	3	2025-09-17 19:48:27	129	8	\N	0
823	258	0	2025-09-17 19:50:36	82	8	\N	162
824	258	1	2025-09-17 19:54:40	54	5	\N	70
825	258	2	2025-09-17 19:56:44	64	6	\N	0
826	259	0	2025-09-17 19:57:48	94	5	\N	100
827	259	1	2025-09-17 20:01:02	58	6	\N	71
828	259	2	2025-09-17 20:03:11	84	4	\N	116
829	259	3	2025-09-17 20:06:31	79	6	\N	0
830	260	0	2025-09-17 20:07:50	68	4	\N	115
831	260	1	2025-09-17 20:10:53	116	7	\N	131
832	260	2	2025-09-17 20:15:00	97	8	\N	0
833	261	0	2025-09-22 19:38:00	97	10	\N	109
834	261	1	2025-09-22 19:41:26	116	8	\N	175
835	261	2	2025-09-22 19:46:17	118	9	\N	0
836	262	0	2025-09-22 19:48:15	66	11	\N	77
837	262	1	2025-09-22 19:50:38	83	10	\N	94
838	262	2	2025-09-22 19:53:35	63	11	\N	0
839	263	0	2025-09-22 19:54:38	80	11	\N	113
840	263	1	2025-09-22 19:57:51	106	10	\N	160
841	263	2	2025-09-22 20:02:17	91	8	\N	0
842	264	0	2025-09-22 20:03:48	121	11	\N	138
843	264	1	2025-09-22 20:08:07	103	9	\N	73
844	264	2	2025-09-22 20:11:03	83	9	\N	0
845	265	0	2025-09-26 19:24:00	128	13	\N	136
846	265	1	2025-09-26 19:28:24	83	11	\N	101
847	265	2	2025-09-26 19:31:28	70	14	\N	0
848	266	0	2025-09-26 19:32:38	95	11	\N	100
849	266	1	2025-09-26 19:35:53	126	12	\N	122
850	266	2	2025-09-26 19:40:01	76	14	\N	0
851	267	0	2025-09-26 19:41:17	95	12	\N	106
852	267	1	2025-09-26 19:44:38	117	10	\N	85
853	267	2	2025-09-26 19:48:00	114	14	\N	0
854	268	0	2025-09-26 19:49:54	48	14	\N	153
855	268	1	2025-09-26 19:53:15	71	13	\N	116
856	268	2	2025-09-26 19:56:22	53	12	\N	164
857	268	3	2025-09-26 19:59:59	108	13	\N	0
858	269	0	2025-09-29 17:42:00	121	11	\N	121
859	269	1	2025-09-29 17:46:02	96	12	\N	128
860	269	2	2025-09-29 17:49:46	98	12	\N	0
861	270	0	2025-09-29 17:51:24	113	10	\N	136
862	270	1	2025-09-29 17:55:33	58	8	\N	158
863	270	2	2025-09-29 17:59:09	129	9	\N	0
864	271	0	2025-09-29 18:01:18	50	12	\N	132
865	271	1	2025-09-29 18:04:20	87	11	\N	161
866	271	2	2025-09-29 18:08:28	58	11	\N	0
867	272	0	2025-09-29 18:09:26	73	10	\N	125
868	272	1	2025-09-29 18:12:44	116	12	\N	134
869	272	2	2025-09-29 18:16:54	73	12	\N	0
870	273	0	2025-10-01 18:29:00	89	5	\N	63
871	273	1	2025-10-01 18:31:32	58	7	\N	97
872	273	2	2025-10-01 18:34:07	55	7	\N	74
873	273	3	2025-10-01 18:36:16	89	5	\N	0
874	274	0	2025-10-01 18:37:45	71	7	\N	126
875	274	1	2025-10-01 18:41:02	89	7	\N	120
876	274	2	2025-10-01 18:44:31	101	4	\N	0
877	275	0	2025-10-01 18:46:12	83	4	\N	65
878	275	1	2025-10-01 18:48:40	47	4	\N	168
879	275	2	2025-10-01 18:52:15	127	6	\N	0
880	276	0	2025-10-01 18:54:22	76	5	\N	126
881	276	1	2025-10-01 18:57:44	115	5	\N	80
882	276	2	2025-10-01 19:00:59	116	6	\N	114
883	276	3	2025-10-01 19:04:49	74	7	\N	0
884	277	0	2025-10-03 09:11:00	70	14	\N	117
885	277	1	2025-10-03 09:14:07	99	14	\N	109
886	277	2	2025-10-03 09:17:35	72	10	\N	0
887	278	0	2025-10-03 09:18:47	118	10	\N	73
888	278	1	2025-10-03 09:21:58	68	14	\N	106
889	278	2	2025-10-03 09:24:52	70	12	\N	0
890	279	0	2025-10-03 09:26:02	130	12	\N	170
891	279	1	2025-10-03 09:31:02	112	13	\N	141
892	279	2	2025-10-03 09:35:15	121	12	\N	0
893	280	0	2025-10-03 09:37:16	120	13	\N	74
894	280	1	2025-10-03 09:40:30	90	12	\N	168
895	280	2	2025-10-03 09:44:48	124	13	\N	82
896	280	3	2025-10-03 09:48:14	123	12	\N	0
897	281	0	2025-10-04 09:20:00	92	9	\N	148
898	281	1	2025-10-04 09:24:00	110	9	\N	109
899	281	2	2025-10-04 09:27:39	121	11	\N	0
900	282	0	2025-10-04 09:29:40	99	7	\N	83
901	282	1	2025-10-04 09:32:42	126	7	\N	128
902	282	2	2025-10-04 09:36:56	116	5	\N	81
903	282	3	2025-10-04 09:40:13	81	7	\N	0
904	283	0	2025-10-04 09:41:34	102	12	\N	139
905	283	1	2025-10-04 09:45:35	90	10	\N	61
906	283	2	2025-10-04 09:48:06	62	13	\N	0
907	284	0	2025-10-04 09:49:08	116	2	\N	0
908	285	0	2025-10-06 18:26:00	107	11	\N	81
909	285	1	2025-10-06 18:29:08	117	8	\N	63
910	285	2	2025-10-06 18:32:08	82	9	\N	64
911	285	3	2025-10-06 18:34:34	73	10	\N	0
912	286	0	2025-10-06 18:35:47	103	9	\N	132
913	286	1	2025-10-06 18:39:42	115	11	\N	125
914	286	2	2025-10-06 18:43:42	118	8	\N	0
915	287	0	2025-10-06 18:45:40	91	12	\N	129
916	287	1	2025-10-06 18:49:20	101	8	\N	129
917	287	2	2025-10-06 18:53:10	99	9	\N	0
918	288	0	2025-10-06 18:54:49	83	9	\N	171
919	288	1	2025-10-06 18:59:03	102	8	\N	93
920	288	2	2025-10-06 19:02:18	56	10	\N	116
921	288	3	2025-10-06 19:05:10	75	8	\N	0
922	289	0	2025-10-08 19:44:00	123	5	\N	77
923	289	1	2025-10-08 19:47:20	71	5	\N	163
924	289	2	2025-10-08 19:51:14	117	4	\N	0
925	290	0	2025-10-08 19:53:11	121	6	\N	128
926	290	1	2025-10-08 19:57:20	86	5	\N	150
927	290	2	2025-10-08 20:01:16	82	6	\N	133
928	290	3	2025-10-08 20:04:51	110	6	\N	0
929	291	0	2025-10-08 20:06:41	52	7	\N	95
930	291	1	2025-10-08 20:09:08	61	5	\N	91
931	291	2	2025-10-08 20:11:40	86	5	\N	0
932	292	0	2025-10-08 20:13:06	107	7	\N	78
933	292	1	2025-10-08 20:16:11	125	8	\N	94
934	292	2	2025-10-08 20:19:50	93	7	\N	117
935	292	3	2025-10-08 20:23:20	126	4	\N	0
936	293	0	2025-10-10 08:25:00	86	13	\N	134
937	293	1	2025-10-10 08:28:40	56	10	\N	153
938	293	2	2025-10-10 08:32:09	126	13	\N	0
939	294	0	2025-10-10 08:34:15	95	14	\N	87
940	294	1	2025-10-10 08:37:17	72	13	\N	123
941	294	2	2025-10-10 08:40:32	86	12	\N	0
942	295	0	2025-10-10 08:41:58	118	14	\N	76
943	295	1	2025-10-10 08:45:12	107	14	\N	160
944	295	2	2025-10-10 08:49:39	51	12	\N	0
945	296	0	2025-10-10 08:50:30	47	13	\N	75
946	296	1	2025-10-10 08:52:32	101	11	\N	118
947	296	2	2025-10-10 08:56:11	99	10	\N	0
948	297	0	2025-10-11 09:56:00	128	8	\N	106
949	297	1	2025-10-11 09:59:54	55	10	\N	107
950	297	2	2025-10-11 10:02:36	51	9	\N	0
951	298	0	2025-10-11 10:03:27	74	6	\N	114
952	298	1	2025-10-11 10:06:35	57	4	\N	60
953	298	2	2025-10-11 10:08:32	106	5	\N	69
954	298	3	2025-10-11 10:11:27	120	5	\N	0
955	299	0	2025-10-11 10:13:27	46	13	\N	61
956	299	1	2025-10-11 10:15:14	60	12	\N	170
957	299	2	2025-10-11 10:19:04	61	13	\N	121
958	299	3	2025-10-11 10:22:06	74	10	\N	0
959	300	0	2025-10-11 10:23:20	58	1	\N	0
960	301	0	2025-10-15 17:08:00	53	5	\N	127
961	301	1	2025-10-15 17:11:00	46	8	\N	138
962	301	2	2025-10-15 17:14:04	101	5	\N	104
963	301	3	2025-10-15 17:17:29	125	5	\N	0
964	302	0	2025-10-15 17:19:34	101	8	\N	170
965	302	1	2025-10-15 17:24:05	56	5	\N	174
966	302	2	2025-10-15 17:27:55	62	4	\N	0
967	303	0	2025-10-15 17:28:57	89	7	\N	114
968	303	1	2025-10-15 17:32:20	62	6	\N	91
969	303	2	2025-10-15 17:34:53	127	6	\N	70
970	303	3	2025-10-15 17:38:10	115	5	\N	0
971	304	0	2025-10-15 17:40:05	81	8	\N	159
972	304	1	2025-10-15 17:44:05	129	4	\N	172
973	304	2	2025-10-15 17:49:06	71	6	\N	126
974	304	3	2025-10-15 17:52:23	110	8	\N	0
975	305	0	2025-10-18 08:50:00	75	8	\N	123
976	305	1	2025-10-18 08:53:18	54	12	\N	127
977	305	2	2025-10-18 08:56:19	91	8	\N	0
978	306	0	2025-10-18 08:57:50	117	7	\N	113
979	306	1	2025-10-18 09:01:40	114	6	\N	147
980	306	2	2025-10-18 09:06:01	105	5	\N	0
981	307	0	2025-10-18 09:07:46	53	14	\N	61
982	307	1	2025-10-18 09:09:40	72	12	\N	65
983	307	2	2025-10-18 09:11:57	95	10	\N	0
984	308	0	2025-10-18 09:13:32	98	3	\N	0
985	309	0	2025-10-20 18:05:00	80	9	\N	70
986	309	1	2025-10-20 18:07:30	55	10	\N	125
987	309	2	2025-10-20 18:10:30	64	9	\N	128
988	309	3	2025-10-20 18:13:42	95	10	\N	0
989	310	0	2025-10-20 18:15:17	84	8	\N	149
990	310	1	2025-10-20 18:19:10	75	11	\N	67
991	310	2	2025-10-20 18:21:32	56	9	\N	178
992	310	3	2025-10-20 18:25:26	59	11	\N	0
993	311	0	2025-10-20 18:26:25	52	12	\N	99
994	311	1	2025-10-20 18:28:56	60	9	\N	61
995	311	2	2025-10-20 18:30:57	46	9	\N	80
996	311	3	2025-10-20 18:33:03	89	11	\N	0
997	312	0	2025-10-20 18:34:32	66	10	\N	107
998	312	1	2025-10-20 18:37:25	79	9	\N	153
999	312	2	2025-10-20 18:41:17	48	8	\N	102
1000	312	3	2025-10-20 18:43:47	79	11	\N	0
1001	313	0	2025-10-22 17:45:00	91	8	\N	67
1002	313	1	2025-10-22 17:47:38	117	7	\N	81
1003	313	2	2025-10-22 17:50:56	65	6	\N	0
1004	314	0	2025-10-22 17:52:01	59	8	\N	89
1005	314	1	2025-10-22 17:54:29	45	8	\N	65
1006	314	2	2025-10-22 17:56:19	76	4	\N	0
1007	315	0	2025-10-22 17:57:35	94	6	\N	177
1008	315	1	2025-10-22 18:02:06	67	5	\N	179
1009	315	2	2025-10-22 18:06:12	115	4	\N	0
1010	316	0	2025-10-22 18:08:07	73	7	\N	101
1011	316	1	2025-10-22 18:11:01	98	5	\N	177
1012	316	2	2025-10-22 18:15:36	79	6	\N	165
1013	316	3	2025-10-22 18:19:40	118	4	\N	0
1014	317	0	2025-10-24 19:43:00	96	10	\N	68
1015	317	1	2025-10-24 19:45:44	81	13	\N	159
1016	317	2	2025-10-24 19:49:44	86	12	\N	71
1017	317	3	2025-10-24 19:52:21	103	14	\N	0
1018	318	0	2025-10-24 19:54:04	82	11	\N	132
1019	318	1	2025-10-24 19:57:38	124	12	\N	91
1020	318	2	2025-10-24 20:01:13	92	13	\N	0
1021	319	0	2025-10-24 20:02:45	114	11	\N	157
1022	319	1	2025-10-24 20:07:16	64	11	\N	60
1023	319	2	2025-10-24 20:09:20	48	13	\N	0
1024	320	0	2025-10-24 20:10:08	126	12	\N	167
1025	320	1	2025-10-24 20:15:01	87	10	\N	60
1026	320	2	2025-10-24 20:17:28	84	13	\N	73
1027	320	3	2025-10-24 20:20:05	112	11	\N	0
1028	321	0	2025-10-25 18:31:00	50	8	\N	177
1029	321	1	2025-10-25 18:34:47	111	9	\N	112
1030	321	2	2025-10-25 18:38:30	103	10	\N	0
1031	322	0	2025-10-25 18:40:13	57	8	\N	124
1032	322	1	2025-10-25 18:43:14	126	5	\N	164
1033	322	2	2025-10-25 18:48:04	54	7	\N	0
1034	323	0	2025-10-25 18:48:58	100	10	\N	144
1035	323	1	2025-10-25 18:53:02	75	11	\N	97
1036	323	2	2025-10-25 18:55:54	85	12	\N	178
1037	323	3	2025-10-25 19:00:17	86	13	\N	0
1038	324	0	2025-10-25 19:01:43	79	2	\N	0
1039	325	0	2025-10-27 09:08:00	66	8	\N	117
1040	325	1	2025-10-27 09:11:03	85	11	\N	112
1041	325	2	2025-10-27 09:14:20	113	8	\N	0
1042	326	0	2025-10-27 09:16:13	84	11	\N	119
1043	326	1	2025-10-27 09:19:36	60	10	\N	71
1044	326	2	2025-10-27 09:21:47	83	9	\N	0
1045	327	0	2025-10-27 09:23:10	63	10	\N	71
1046	327	1	2025-10-27 09:25:24	90	9	\N	110
1047	327	2	2025-10-27 09:28:44	51	12	\N	0
1048	328	0	2025-10-27 09:29:35	67	10	\N	63
1049	328	1	2025-10-27 09:31:45	102	11	\N	131
1050	328	2	2025-10-27 09:35:38	76	12	\N	0
1051	329	0	2025-11-01 08:00:00	92	11	\N	147
1052	329	1	2025-11-01 08:03:59	119	8	\N	135
1053	329	2	2025-11-01 08:08:13	54	10	\N	0
1054	330	0	2025-11-01 08:09:07	127	5	\N	116
1055	330	1	2025-11-01 08:13:10	56	5	\N	175
1056	330	2	2025-11-01 08:17:01	60	6	\N	0
1057	331	0	2025-11-01 08:18:01	66	11	\N	178
1058	331	1	2025-11-01 08:22:05	100	15	\N	165
1059	331	2	2025-11-01 08:26:30	108	14	\N	0
1060	332	0	2025-11-01 08:28:18	99	2	\N	0
1061	333	0	2025-11-05 09:17:00	124	8	\N	138
1062	333	1	2025-11-05 09:21:22	127	5	\N	97
1063	333	2	2025-11-05 09:25:06	97	7	\N	0
1064	334	0	2025-11-05 09:26:43	56	4	\N	95
1065	334	1	2025-11-05 09:29:14	62	7	\N	113
1066	334	2	2025-11-05 09:32:09	127	5	\N	0
1067	335	0	2025-11-05 09:34:16	47	8	\N	108
1068	335	1	2025-11-05 09:36:51	106	6	\N	129
1069	335	2	2025-11-05 09:40:46	89	7	\N	176
1070	335	3	2025-11-05 09:45:11	109	8	\N	0
1071	336	0	2025-11-05 09:47:00	68	6	\N	63
1072	336	1	2025-11-05 09:49:11	121	6	\N	88
1073	336	2	2025-11-05 09:52:40	80	4	\N	0
1074	337	0	2025-11-08 19:22:00	76	9	\N	144
1075	337	1	2025-11-08 19:25:40	79	10	\N	128
1076	337	2	2025-11-08 19:29:07	73	9	\N	0
1077	338	0	2025-11-08 19:30:20	67	6	\N	82
1078	338	1	2025-11-08 19:32:49	120	5	\N	100
1079	338	2	2025-11-08 19:36:29	120	6	\N	0
1080	339	0	2025-11-08 19:38:29	117	13	\N	132
1081	339	1	2025-11-08 19:42:38	117	12	\N	84
1082	339	2	2025-11-08 19:45:59	114	14	\N	99
1083	339	3	2025-11-08 19:49:32	107	12	\N	0
1084	340	0	2025-11-08 19:51:19	52	1	\N	0
1085	341	0	2025-11-10 09:01:00	70	13	\N	163
1086	341	1	2025-11-10 09:04:53	88	10	\N	151
1087	341	2	2025-11-10 09:08:52	86	10	\N	0
1088	342	0	2025-11-10 09:10:18	120	10	\N	150
1089	342	1	2025-11-10 09:14:48	59	10	\N	168
1090	342	2	2025-11-10 09:18:35	91	13	\N	0
1091	343	0	2025-11-10 09:20:06	120	12	\N	72
1092	343	1	2025-11-10 09:23:18	83	11	\N	101
1093	343	2	2025-11-10 09:26:22	65	10	\N	0
1094	344	0	2025-11-10 09:27:27	128	12	\N	100
1095	344	1	2025-11-10 09:31:15	116	10	\N	148
1096	344	2	2025-11-10 09:35:39	90	13	\N	0
1097	345	0	2025-11-12 19:52:00	61	6	\N	82
1098	345	1	2025-11-12 19:54:23	118	4	\N	110
1099	345	2	2025-11-12 19:58:11	49	8	\N	83
1100	345	3	2025-11-12 20:00:23	85	8	\N	0
1101	346	0	2025-11-12 20:01:48	58	8	\N	179
1102	346	1	2025-11-12 20:05:45	63	7	\N	102
1103	346	2	2025-11-12 20:08:30	75	4	\N	0
1104	347	0	2025-11-12 20:09:45	126	5	\N	173
1105	347	1	2025-11-12 20:14:44	130	4	\N	141
1106	347	2	2025-11-12 20:19:15	102	6	\N	0
1107	348	0	2025-11-12 20:20:57	76	5	\N	148
1108	348	1	2025-11-12 20:24:41	89	4	\N	92
1109	348	2	2025-11-12 20:27:42	45	4	\N	0
1110	349	0	2025-11-15 18:10:00	93	13	\N	72
1111	349	1	2025-11-15 18:12:45	118	12	\N	143
1112	349	2	2025-11-15 18:17:06	65	10	\N	0
1113	350	0	2025-11-15 18:18:11	82	4	\N	62
1114	350	1	2025-11-15 18:20:35	78	6	\N	73
1115	350	2	2025-11-15 18:23:06	88	4	\N	0
1116	351	0	2025-11-15 18:24:34	54	12	\N	130
1117	351	1	2025-11-15 18:27:38	88	11	\N	136
1118	351	2	2025-11-15 18:31:22	106	15	\N	0
1119	352	0	2025-11-15 18:33:08	128	2	\N	0
1120	353	0	2025-11-19 09:03:00	115	7	\N	152
1121	353	1	2025-11-19 09:07:27	78	8	\N	144
1122	353	2	2025-11-19 09:11:09	83	6	\N	0
1123	354	0	2025-11-19 09:12:32	95	4	\N	133
1124	354	1	2025-11-19 09:16:20	107	8	\N	79
1125	354	2	2025-11-19 09:19:26	91	4	\N	0
1126	355	0	2025-11-19 09:20:57	82	4	\N	165
1127	355	1	2025-11-19 09:25:04	106	8	\N	85
1128	355	2	2025-11-19 09:28:15	48	4	\N	0
1129	356	0	2025-11-19 09:29:03	55	6	\N	120
1130	356	1	2025-11-19 09:31:58	84	4	\N	160
1131	356	2	2025-11-19 09:36:02	105	7	\N	0
1132	357	0	2025-11-21 17:05:00	93	13	\N	107
1133	357	1	2025-11-21 17:08:20	102	12	\N	65
1134	357	2	2025-11-21 17:11:07	101	13	\N	0
1135	358	0	2025-11-21 17:12:48	79	12	\N	132
1136	358	1	2025-11-21 17:16:19	64	11	\N	156
1137	358	2	2025-11-21 17:19:59	55	11	\N	0
1138	359	0	2025-11-21 17:20:54	97	15	\N	156
1139	359	1	2025-11-21 17:25:07	74	15	\N	130
1140	359	2	2025-11-21 17:28:31	94	11	\N	0
1141	360	0	2025-11-21 17:30:05	118	14	\N	172
1142	360	1	2025-11-21 17:34:55	105	12	\N	98
1143	360	2	2025-11-21 17:38:18	95	11	\N	175
1144	360	3	2025-11-21 17:42:48	109	11	\N	0
1145	361	0	2025-11-22 19:51:00	67	12	\N	81
1146	361	1	2025-11-22 19:53:28	69	10	\N	76
1147	361	2	2025-11-22 19:55:53	99	9	\N	0
1148	362	0	2025-11-22 19:57:32	70	7	\N	165
1149	362	1	2025-11-22 20:01:27	121	5	\N	93
1150	362	2	2025-11-22 20:05:01	53	6	\N	71
1151	362	3	2025-11-22 20:07:05	116	7	\N	0
1152	363	0	2025-11-22 20:09:01	80	13	\N	126
1153	363	1	2025-11-22 20:12:27	46	14	\N	160
1154	363	2	2025-11-22 20:15:53	120	15	\N	126
1155	363	3	2025-11-22 20:19:59	59	14	\N	0
1156	364	0	2025-11-22 20:20:58	63	1	\N	0
1157	365	0	2025-11-24 19:48:00	113	11	\N	172
1158	365	1	2025-11-24 19:52:45	97	11	\N	93
1159	365	2	2025-11-24 19:55:55	128	12	\N	0
1160	366	0	2025-11-24 19:58:03	105	13	\N	64
1161	366	1	2025-11-24 20:00:52	80	10	\N	111
1162	366	2	2025-11-24 20:04:03	124	10	\N	137
1163	366	3	2025-11-24 20:08:24	49	12	\N	0
1164	367	0	2025-11-24 20:09:13	51	10	\N	155
1165	367	1	2025-11-24 20:12:39	79	12	\N	174
1166	367	2	2025-11-24 20:16:52	47	11	\N	0
1167	368	0	2025-11-24 20:17:39	80	11	\N	167
1168	368	1	2025-11-24 20:21:46	57	12	\N	171
1169	368	2	2025-11-24 20:25:34	62	10	\N	0
1170	369	0	2025-11-26 18:49:00	122	7	\N	142
1171	369	1	2025-11-26 18:53:24	69	4	\N	116
1172	369	2	2025-11-26 18:56:29	97	5	\N	154
1173	369	3	2025-11-26 19:00:40	111	7	\N	0
1174	370	0	2025-11-26 19:02:31	65	8	\N	68
1175	370	1	2025-11-26 19:04:44	109	6	\N	111
1176	370	2	2025-11-26 19:08:24	112	5	\N	0
1177	371	0	2025-11-26 19:10:16	70	5	\N	167
1178	371	1	2025-11-26 19:14:13	76	4	\N	64
1179	371	2	2025-11-26 19:16:33	51	7	\N	0
1180	372	0	2025-11-26 19:17:24	80	5	\N	107
1181	372	1	2025-11-26 19:20:31	109	7	\N	110
1182	372	2	2025-11-26 19:24:10	48	4	\N	90
1183	372	3	2025-11-26 19:26:28	107	6	\N	0
1184	373	0	2025-11-28 09:55:00	65	13	\N	167
1185	373	1	2025-11-28 09:58:52	56	13	\N	96
1186	373	2	2025-11-28 10:01:24	94	11	\N	0
1187	374	0	2025-11-28 10:02:58	72	15	\N	169
1188	374	1	2025-11-28 10:06:59	127	12	\N	88
1189	374	2	2025-11-28 10:10:34	79	12	\N	0
1190	375	0	2025-11-28 10:11:53	47	15	\N	170
1191	375	1	2025-11-28 10:15:30	105	11	\N	176
1192	375	2	2025-11-28 10:20:11	127	12	\N	0
1193	376	0	2025-11-28 10:22:18	73	11	\N	92
1194	376	1	2025-11-28 10:25:03	84	15	\N	151
1195	376	2	2025-11-28 10:28:58	99	13	\N	174
1196	376	3	2025-11-28 10:33:31	89	14	\N	0
1197	377	0	2025-11-29 09:29:00	58	13	\N	60
1198	377	1	2025-11-29 09:30:58	129	13	\N	167
1199	377	2	2025-11-29 09:35:54	116	11	\N	0
1200	378	0	2025-11-29 09:37:50	81	8	\N	98
1201	378	1	2025-11-29 09:40:49	106	4	\N	68
1202	378	2	2025-11-29 09:43:43	80	6	\N	141
1203	378	3	2025-11-29 09:47:24	80	6	\N	0
1204	379	0	2025-11-29 09:48:44	69	13	\N	79
1205	379	1	2025-11-29 09:51:12	75	15	\N	175
1206	379	2	2025-11-29 09:55:22	121	11	\N	111
1207	379	3	2025-11-29 09:59:14	62	13	\N	0
1208	380	0	2025-11-29 10:00:16	82	2	\N	0
1209	381	0	2025-12-01 18:25:00	69	13	\N	103
1210	381	1	2025-12-01 18:27:52	113	10	\N	141
1211	381	2	2025-12-01 18:32:06	130	12	\N	105
1212	381	3	2025-12-01 18:36:01	83	13	\N	0
1213	382	0	2025-12-01 18:37:24	68	13	\N	97
1214	382	1	2025-12-01 18:40:09	105	9	\N	76
1215	382	2	2025-12-01 18:43:10	116	11	\N	157
1216	382	3	2025-12-01 18:47:43	87	10	\N	0
1217	383	0	2025-12-01 18:49:10	73	11	\N	155
1218	383	1	2025-12-01 18:52:58	98	11	\N	160
1219	383	2	2025-12-01 18:57:16	92	11	\N	0
1220	384	0	2025-12-01 18:58:48	104	11	\N	168
1221	384	1	2025-12-01 19:03:20	105	9	\N	66
1222	384	2	2025-12-01 19:06:11	119	13	\N	180
1223	384	3	2025-12-01 19:11:10	54	13	\N	0
1224	385	0	2025-12-03 09:32:00	51	7	\N	171
1225	385	1	2025-12-03 09:35:42	62	5	\N	85
1226	385	2	2025-12-03 09:38:09	97	6	\N	0
1227	386	0	2025-12-03 09:39:46	85	5	\N	170
1228	386	1	2025-12-03 09:44:01	55	5	\N	122
1229	386	2	2025-12-03 09:46:58	125	6	\N	0
1230	387	0	2025-12-03 09:49:03	45	4	\N	117
1231	387	1	2025-12-03 09:51:45	71	6	\N	157
1232	387	2	2025-12-03 09:55:33	118	5	\N	0
1233	388	0	2025-12-03 09:57:31	61	4	\N	138
1234	388	1	2025-12-03 10:00:50	126	7	\N	114
1235	388	2	2025-12-03 10:04:50	99	7	\N	0
1236	389	0	2025-12-05 18:00:00	46	13	\N	174
1237	389	1	2025-12-05 18:03:40	112	13	\N	84
1238	389	2	2025-12-05 18:06:56	45	11	\N	140
1239	389	3	2025-12-05 18:10:01	73	12	\N	0
1240	390	0	2025-12-05 18:11:14	58	12	\N	109
1241	390	1	2025-12-05 18:14:01	120	15	\N	99
1242	390	2	2025-12-05 18:17:40	53	12	\N	0
1243	391	0	2025-12-05 18:18:33	103	13	\N	153
1244	391	1	2025-12-05 18:22:49	121	15	\N	127
1245	391	2	2025-12-05 18:26:57	100	13	\N	0
1246	392	0	2025-12-05 18:28:37	90	14	\N	156
1247	392	1	2025-12-05 18:32:43	66	12	\N	176
1248	392	2	2025-12-05 18:36:45	47	14	\N	0
1249	393	0	2025-12-06 09:13:00	60	10	\N	106
1250	393	1	2025-12-06 09:15:46	93	9	\N	172
1251	393	2	2025-12-06 09:20:11	113	11	\N	139
1252	393	3	2025-12-06 09:24:23	121	9	\N	0
1253	394	0	2025-12-06 09:26:24	128	4	\N	167
1254	394	1	2025-12-06 09:31:19	51	4	\N	148
1255	394	2	2025-12-06 09:34:38	98	4	\N	116
1256	394	3	2025-12-06 09:38:12	60	7	\N	0
1257	395	0	2025-12-06 09:39:12	64	14	\N	86
1258	395	1	2025-12-06 09:41:42	83	11	\N	113
1259	395	2	2025-12-06 09:44:58	129	11	\N	0
1260	396	0	2025-12-06 09:47:07	122	3	\N	0
1261	397	0	2025-12-08 18:53:00	81	9	\N	74
1262	397	1	2025-12-08 18:55:35	108	9	\N	85
1263	397	2	2025-12-08 18:58:48	70	13	\N	159
1264	397	3	2025-12-08 19:02:37	111	11	\N	0
1265	398	0	2025-12-08 19:04:28	82	12	\N	80
1266	398	1	2025-12-08 19:07:10	115	9	\N	123
1267	398	2	2025-12-08 19:11:08	106	10	\N	0
1268	399	0	2025-12-08 19:12:54	46	9	\N	145
1269	399	1	2025-12-08 19:16:05	59	9	\N	166
1270	399	2	2025-12-08 19:19:50	130	13	\N	0
1271	400	0	2025-12-08 19:22:00	110	9	\N	69
1272	400	1	2025-12-08 19:24:59	77	9	\N	142
1273	400	2	2025-12-08 19:28:38	103	10	\N	0
1274	401	0	2025-12-10 17:16:00	82	4	\N	106
1275	401	1	2025-12-10 17:19:08	99	6	\N	154
1276	401	2	2025-12-10 17:23:21	57	4	\N	0
1277	402	0	2025-12-10 17:24:18	129	5	\N	142
1278	402	1	2025-12-10 17:28:49	87	5	\N	105
1279	402	2	2025-12-10 17:32:01	124	7	\N	0
1280	403	0	2025-12-10 17:34:05	92	4	\N	164
1281	403	1	2025-12-10 17:38:21	68	6	\N	74
1282	403	2	2025-12-10 17:40:43	96	7	\N	118
1283	403	3	2025-12-10 17:44:17	94	6	\N	0
1284	404	0	2025-12-10 17:45:51	128	7	\N	173
1285	404	1	2025-12-10 17:50:52	59	5	\N	76
1286	404	2	2025-12-10 17:53:07	65	4	\N	0
1287	405	0	2025-12-13 18:51:00	90	12	\N	138
1288	405	1	2025-12-13 18:54:48	61	9	\N	121
1289	405	2	2025-12-13 18:57:50	59	12	\N	173
1290	405	3	2025-12-13 19:01:42	101	12	\N	0
1291	406	0	2025-12-13 19:03:23	128	6	\N	100
1292	406	1	2025-12-13 19:07:11	112	4	\N	158
1293	406	2	2025-12-13 19:11:41	117	8	\N	0
1294	407	0	2025-12-13 19:13:38	111	13	\N	126
1295	407	1	2025-12-13 19:17:35	57	15	\N	115
1296	407	2	2025-12-13 19:20:27	106	12	\N	104
1297	407	3	2025-12-13 19:23:57	64	14	\N	0
1298	408	0	2025-12-13 19:25:01	127	1	\N	0
1299	409	0	2025-12-15 19:54:00	86	12	\N	90
1300	409	1	2025-12-15 19:56:56	80	11	\N	66
1301	409	2	2025-12-15 19:59:22	73	13	\N	0
1302	410	0	2025-12-15 20:00:35	96	12	\N	164
1303	410	1	2025-12-15 20:04:55	55	10	\N	118
1304	410	2	2025-12-15 20:07:48	118	12	\N	117
1305	410	3	2025-12-15 20:11:43	108	9	\N	0
1306	411	0	2025-12-15 20:13:31	108	9	\N	155
1307	411	1	2025-12-15 20:17:54	58	9	\N	111
1308	411	2	2025-12-15 20:20:43	49	12	\N	0
1309	412	0	2025-12-15 20:21:32	56	9	\N	161
1310	412	1	2025-12-15 20:25:09	124	13	\N	141
1311	412	2	2025-12-15 20:29:34	110	11	\N	131
1312	412	3	2025-12-15 20:33:35	128	10	\N	0
1313	413	0	2025-12-17 17:23:00	116	6	\N	158
1314	413	1	2025-12-17 17:27:34	121	8	\N	120
1315	413	2	2025-12-17 17:31:35	102	6	\N	0
1316	414	0	2025-12-17 17:33:17	45	5	\N	103
1317	414	1	2025-12-17 17:35:45	126	6	\N	162
1318	414	2	2025-12-17 17:40:33	115	6	\N	0
1319	415	0	2025-12-17 17:42:28	50	4	\N	174
1320	415	1	2025-12-17 17:46:12	108	5	\N	77
1321	415	2	2025-12-17 17:49:17	58	7	\N	92
1322	415	3	2025-12-17 17:51:47	70	8	\N	0
1323	416	0	2025-12-17 17:52:57	72	7	\N	118
1324	416	1	2025-12-17 17:56:07	88	5	\N	73
1325	416	2	2025-12-17 17:58:48	50	7	\N	0
1326	417	0	2025-12-19 19:07:00	109	15	\N	77
1327	417	1	2025-12-19 19:10:06	45	14	\N	127
1328	417	2	2025-12-19 19:12:58	115	11	\N	179
1329	417	3	2025-12-19 19:17:52	119	14	\N	0
1330	418	0	2025-12-19 19:19:51	119	12	\N	82
1331	418	1	2025-12-19 19:23:12	58	12	\N	109
1332	418	2	2025-12-19 19:25:59	122	15	\N	172
1333	418	3	2025-12-19 19:30:53	109	13	\N	0
1334	419	0	2025-12-19 19:32:42	76	15	\N	95
1335	419	1	2025-12-19 19:35:33	88	14	\N	97
1336	419	2	2025-12-19 19:38:38	62	14	\N	0
1337	420	0	2025-12-19 19:39:40	110	15	\N	98
1338	420	1	2025-12-19 19:43:08	85	15	\N	151
1339	420	2	2025-12-19 19:47:04	125	15	\N	0
1340	421	0	2025-12-20 09:39:00	128	10	\N	82
1341	421	1	2025-12-20 09:42:30	114	13	\N	148
1342	421	2	2025-12-20 09:46:52	59	11	\N	0
1343	422	0	2025-12-20 09:47:51	119	7	\N	133
1344	422	1	2025-12-20 09:52:03	113	7	\N	96
1345	422	2	2025-12-20 09:55:32	46	7	\N	126
1346	422	3	2025-12-20 09:58:24	48	4	\N	0
1347	423	0	2025-12-20 09:59:12	130	11	\N	67
1348	423	1	2025-12-20 10:02:29	79	12	\N	156
1349	423	2	2025-12-20 10:06:24	81	12	\N	0
1350	424	0	2025-12-20 10:07:45	52	1	\N	0
1351	425	0	2025-12-22 17:13:00	58	12	\N	138
1352	425	1	2025-12-22 17:16:16	73	13	\N	155
1353	425	2	2025-12-22 17:20:04	94	13	\N	0
1354	426	0	2025-12-22 17:21:38	130	11	\N	66
1355	426	1	2025-12-22 17:24:54	94	12	\N	113
1356	426	2	2025-12-22 17:28:21	115	11	\N	66
1357	426	3	2025-12-22 17:31:22	77	9	\N	0
1358	427	0	2025-12-22 17:32:39	73	12	\N	176
1359	427	1	2025-12-22 17:36:48	120	11	\N	129
1360	427	2	2025-12-22 17:40:57	70	13	\N	159
1361	427	3	2025-12-22 17:44:46	82	10	\N	0
1362	428	0	2025-12-22 17:46:08	68	9	\N	82
1363	428	1	2025-12-22 17:48:38	60	13	\N	108
1364	428	2	2025-12-22 17:51:26	99	9	\N	0
1365	429	0	2025-12-24 17:08:00	104	7	\N	150
1366	429	1	2025-12-24 17:12:14	50	6	\N	79
1367	429	2	2025-12-24 17:14:23	121	7	\N	0
1368	430	0	2025-12-24 17:16:24	129	9	\N	98
1369	430	1	2025-12-24 17:20:11	118	8	\N	130
1370	430	2	2025-12-24 17:24:19	54	7	\N	160
1371	430	3	2025-12-24 17:27:53	112	7	\N	0
1372	431	0	2025-12-24 17:29:45	53	9	\N	160
1373	431	1	2025-12-24 17:33:18	65	9	\N	113
1374	431	2	2025-12-24 17:36:16	113	9	\N	0
1375	432	0	2025-12-24 17:38:09	73	7	\N	173
1376	432	1	2025-12-24 17:42:15	129	6	\N	102
1377	432	2	2025-12-24 17:46:06	91	7	\N	0
1378	433	0	2025-12-26 19:33:00	102	14	\N	90
1379	433	1	2025-12-26 19:36:12	124	16	\N	91
1380	433	2	2025-12-26 19:39:47	86	12	\N	0
1381	434	0	2025-12-26 19:41:13	77	15	\N	129
1382	434	1	2025-12-26 19:44:39	48	14	\N	176
1383	434	2	2025-12-26 19:48:23	92	16	\N	0
1384	435	0	2025-12-26 19:49:55	107	15	\N	65
1385	435	1	2025-12-26 19:52:47	128	14	\N	84
1386	435	2	2025-12-26 19:56:19	110	14	\N	70
1387	435	3	2025-12-26 19:59:19	66	12	\N	0
1388	436	0	2025-12-26 20:00:25	71	12	\N	145
1389	436	1	2025-12-26 20:04:01	99	13	\N	166
1390	436	2	2025-12-26 20:08:26	71	12	\N	128
1391	436	3	2025-12-26 20:11:45	127	15	\N	0
1392	437	0	2025-12-27 08:47:00	49	11	\N	71
1393	437	1	2025-12-27 08:49:00	51	9	\N	82
1394	437	2	2025-12-27 08:51:13	116	11	\N	0
1395	438	0	2025-12-27 08:53:09	78	6	\N	112
1396	438	1	2025-12-27 08:56:19	102	8	\N	140
1397	438	2	2025-12-27 09:00:21	100	8	\N	100
1398	438	3	2025-12-27 09:03:41	94	5	\N	0
1399	439	0	2025-12-27 09:05:15	127	12	\N	152
1400	439	1	2025-12-27 09:09:54	53	16	\N	156
1401	439	2	2025-12-27 09:13:23	50	16	\N	149
1402	439	3	2025-12-27 09:16:42	90	12	\N	0
1403	440	0	2025-12-27 09:18:12	83	1	\N	0
1404	441	0	2025-12-29 17:48:00	105	9	\N	80
1405	441	1	2025-12-29 17:51:05	73	13	\N	77
1406	441	2	2025-12-29 17:53:35	114	12	\N	97
1407	441	3	2025-12-29 17:57:06	83	10	\N	0
1408	442	0	2025-12-29 17:58:29	116	13	\N	78
1409	442	1	2025-12-29 18:01:43	50	9	\N	60
1410	442	2	2025-12-29 18:03:33	121	13	\N	0
1411	443	0	2025-12-29 18:05:34	55	13	\N	99
1412	443	1	2025-12-29 18:08:08	89	10	\N	87
1413	443	2	2025-12-29 18:11:04	127	12	\N	168
1414	443	3	2025-12-29 18:15:59	63	13	\N	0
1415	444	0	2025-12-29 18:17:02	123	10	\N	166
1416	444	1	2025-12-29 18:21:51	69	11	\N	74
1417	444	2	2025-12-29 18:24:14	130	10	\N	0
1418	445	0	2025-12-31 08:54:00	54	9	\N	97
1419	445	1	2025-12-31 08:56:31	77	5	\N	72
1420	445	2	2025-12-31 08:59:00	119	6	\N	122
1421	445	3	2025-12-31 09:03:01	90	7	\N	0
1422	446	0	2025-12-31 09:04:31	57	6	\N	96
1423	446	1	2025-12-31 09:07:04	53	9	\N	175
1424	446	2	2025-12-31 09:10:52	85	6	\N	122
1425	446	3	2025-12-31 09:14:19	87	8	\N	0
1426	447	0	2025-12-31 09:15:46	64	9	\N	132
1427	447	1	2025-12-31 09:19:02	91	9	\N	163
1428	447	2	2025-12-31 09:23:16	99	7	\N	81
1429	447	3	2025-12-31 09:26:16	85	5	\N	0
1430	448	0	2025-12-31 09:27:41	80	8	\N	167
1431	448	1	2025-12-31 09:31:48	62	7	\N	146
1432	448	2	2025-12-31 09:35:16	106	7	\N	0
1433	449	0	2026-01-02 17:49:00	127	13	\N	137
1434	449	1	2026-01-02 17:53:24	80	12	\N	169
1435	449	2	2026-01-02 17:57:33	113	13	\N	0
1436	450	0	2026-01-02 17:59:26	54	12	\N	174
1437	450	1	2026-01-02 18:03:14	109	12	\N	140
1438	450	2	2026-01-02 18:07:23	119	12	\N	0
1439	451	0	2026-01-02 18:09:22	72	16	\N	176
1440	451	1	2026-01-02 18:13:30	115	12	\N	93
1441	451	2	2026-01-02 18:16:58	114	16	\N	0
1442	452	0	2026-01-02 18:18:52	91	13	\N	110
1443	452	1	2026-01-02 18:22:13	120	13	\N	153
1444	452	2	2026-01-02 18:26:46	62	14	\N	119
1445	452	3	2026-01-02 18:29:47	110	16	\N	0
1446	453	0	2026-01-05 08:42:00	62	13	\N	117
1447	453	1	2026-01-05 08:44:59	67	10	\N	132
1448	453	2	2026-01-05 08:48:18	129	13	\N	0
1449	454	0	2026-01-05 08:50:27	90	12	\N	65
1450	454	1	2026-01-05 08:53:02	107	10	\N	89
1451	454	2	2026-01-05 08:56:18	78	9	\N	107
1452	454	3	2026-01-05 08:59:23	50	10	\N	0
1453	455	0	2026-01-05 09:00:13	94	11	\N	120
1454	455	1	2026-01-05 09:03:47	50	12	\N	65
1455	455	2	2026-01-05 09:05:42	58	11	\N	150
1456	455	3	2026-01-05 09:09:10	126	13	\N	0
1457	456	0	2026-01-05 09:11:16	119	11	\N	129
1458	456	1	2026-01-05 09:15:24	67	13	\N	108
1459	456	2	2026-01-05 09:18:19	91	12	\N	135
1460	456	3	2026-01-05 09:22:05	111	9	\N	0
1461	457	0	2026-01-07 09:33:00	122	8	\N	60
1462	457	1	2026-01-07 09:36:02	62	9	\N	116
1463	457	2	2026-01-07 09:39:00	74	6	\N	0
1464	458	0	2026-01-07 09:40:14	72	7	\N	79
1465	458	1	2026-01-07 09:42:45	65	6	\N	106
1466	458	2	2026-01-07 09:45:36	60	9	\N	144
1467	458	3	2026-01-07 09:49:00	98	6	\N	0
1468	459	0	2026-01-07 09:50:38	106	5	\N	146
1469	459	1	2026-01-07 09:54:50	106	8	\N	86
1470	459	2	2026-01-07 09:58:02	65	9	\N	142
1471	459	3	2026-01-07 10:01:29	47	8	\N	0
1472	460	0	2026-01-07 10:02:16	118	6	\N	135
1473	460	1	2026-01-07 10:06:29	62	6	\N	140
1474	460	2	2026-01-07 10:09:51	50	9	\N	0
1475	461	0	2026-01-09 09:03:00	121	15	\N	132
1476	461	1	2026-01-09 09:07:13	129	12	\N	165
1477	461	2	2026-01-09 09:12:07	55	14	\N	87
1478	461	3	2026-01-09 09:14:29	122	15	\N	0
1479	462	0	2026-01-09 09:16:31	73	13	\N	166
1480	462	1	2026-01-09 09:20:30	121	15	\N	78
1481	462	2	2026-01-09 09:23:49	68	16	\N	0
1482	463	0	2026-01-09 09:24:57	78	16	\N	81
1483	463	1	2026-01-09 09:27:36	103	14	\N	136
1484	463	2	2026-01-09 09:31:35	53	16	\N	89
1485	463	3	2026-01-09 09:33:57	94	15	\N	0
1486	464	0	2026-01-09 09:35:31	70	12	\N	126
1487	464	1	2026-01-09 09:38:47	98	16	\N	165
1488	464	2	2026-01-09 09:43:10	122	13	\N	0
1489	465	0	2026-01-12 19:38:00	106	9	\N	144
1490	465	1	2026-01-12 19:42:10	122	10	\N	129
1491	465	2	2026-01-12 19:46:21	128	9	\N	0
1492	466	0	2026-01-12 19:48:29	92	12	\N	171
1493	466	1	2026-01-12 19:52:52	112	9	\N	114
1494	466	2	2026-01-12 19:56:38	106	10	\N	161
1495	466	3	2026-01-12 20:01:05	89	12	\N	0
1496	467	0	2026-01-12 20:02:34	77	10	\N	121
1497	467	1	2026-01-12 20:05:52	55	10	\N	96
1498	467	2	2026-01-12 20:08:23	114	13	\N	0
1499	468	0	2026-01-12 20:10:17	45	10	\N	150
1500	468	1	2026-01-12 20:13:32	118	9	\N	126
1501	468	2	2026-01-12 20:17:36	111	9	\N	0
1502	469	0	2026-01-16 17:26:00	77	16	\N	93
1503	469	1	2026-01-16 17:28:50	99	16	\N	132
1504	469	2	2026-01-16 17:32:41	123	14	\N	0
1505	470	0	2026-01-16 17:34:44	71	15	\N	112
1506	470	1	2026-01-16 17:37:47	116	16	\N	121
1507	470	2	2026-01-16 17:41:44	92	13	\N	131
1508	470	3	2026-01-16 17:45:27	106	16	\N	0
1509	471	0	2026-01-16 17:47:13	89	16	\N	159
1510	471	1	2026-01-16 17:51:21	62	15	\N	169
1511	471	2	2026-01-16 17:55:12	74	12	\N	0
1512	472	0	2026-01-16 17:56:26	57	13	\N	87
1513	472	1	2026-01-16 17:58:50	96	16	\N	160
1514	472	2	2026-01-16 18:03:06	115	14	\N	138
1515	472	3	2026-01-16 18:07:19	65	12	\N	0
1516	473	0	2026-01-17 08:51:00	56	12	\N	68
1517	473	1	2026-01-17 08:53:04	73	11	\N	107
1518	473	2	2026-01-17 08:56:04	122	9	\N	64
1519	473	3	2026-01-17 08:59:10	96	12	\N	0
1520	474	0	2026-01-17 09:00:46	81	9	\N	151
1521	474	1	2026-01-17 09:04:38	52	9	\N	159
1522	474	2	2026-01-17 09:08:09	126	6	\N	123
1523	474	3	2026-01-17 09:12:18	46	8	\N	0
1524	475	0	2026-01-17 09:13:04	81	16	\N	84
1525	475	1	2026-01-17 09:15:49	121	12	\N	125
1526	475	2	2026-01-17 09:19:55	74	16	\N	138
1527	475	3	2026-01-17 09:23:27	49	13	\N	0
1528	476	0	2026-01-17 09:24:16	128	1	\N	0
1529	477	0	2026-01-23 18:22:00	111	13	\N	61
1530	477	1	2026-01-23 18:24:52	56	12	\N	130
1531	477	2	2026-01-23 18:27:58	116	14	\N	177
1532	477	3	2026-01-23 18:32:51	89	16	\N	0
1533	478	0	2026-01-23 18:34:20	122	13	\N	84
1534	478	1	2026-01-23 18:37:46	96	15	\N	133
1535	478	2	2026-01-23 18:41:35	78	12	\N	0
1536	479	0	2026-01-23 18:42:53	58	16	\N	131
1537	479	1	2026-01-23 18:46:02	109	12	\N	97
1538	479	2	2026-01-23 18:49:28	59	14	\N	0
1539	480	0	2026-01-23 18:50:27	77	16	\N	148
1540	480	1	2026-01-23 18:54:12	93	15	\N	132
1541	480	2	2026-01-23 18:57:57	76	15	\N	156
1542	480	3	2026-01-23 19:01:49	103	14	\N	0
1543	481	0	2026-01-24 19:55:00	93	10	\N	141
1544	481	1	2026-01-24 19:58:54	74	11	\N	162
1545	481	2	2026-01-24 20:02:50	97	12	\N	0
1546	482	0	2026-01-24 20:04:27	46	9	\N	149
1547	482	1	2026-01-24 20:07:42	76	7	\N	96
1548	482	2	2026-01-24 20:10:34	96	5	\N	146
1549	482	3	2026-01-24 20:14:36	54	7	\N	0
1550	483	0	2026-01-24 20:15:30	85	15	\N	105
1551	483	1	2026-01-24 20:18:40	118	13	\N	94
1552	483	2	2026-01-24 20:22:12	69	13	\N	0
1553	484	0	2026-01-24 20:23:21	75	1	\N	0
1554	485	0	2026-01-26 17:13:00	64	12	\N	159
1555	485	1	2026-01-26 17:16:43	60	10	\N	177
1556	485	2	2026-01-26 17:20:40	129	10	\N	123
1557	485	3	2026-01-26 17:24:52	45	14	\N	0
1558	486	0	2026-01-26 17:25:37	92	13	\N	139
1559	486	1	2026-01-26 17:29:28	108	12	\N	174
1560	486	2	2026-01-26 17:34:10	80	14	\N	0
1561	487	0	2026-01-26 17:35:30	80	14	\N	110
1562	487	1	2026-01-26 17:38:40	118	11	\N	76
1563	487	2	2026-01-26 17:41:54	112	10	\N	0
1564	488	0	2026-01-26 17:43:46	49	14	\N	124
1565	488	1	2026-01-26 17:46:39	95	12	\N	170
1566	488	2	2026-01-26 17:51:04	103	11	\N	0
1567	489	0	2026-01-28 19:29:00	93	6	\N	134
1568	489	1	2026-01-28 19:32:47	86	5	\N	106
1569	489	2	2026-01-28 19:35:59	78	9	\N	83
1570	489	3	2026-01-28 19:38:40	78	9	\N	0
1571	490	0	2026-01-28 19:39:58	123	8	\N	103
1572	490	1	2026-01-28 19:43:44	68	7	\N	123
1573	490	2	2026-01-28 19:46:55	71	8	\N	0
1574	491	0	2026-01-28 19:48:06	91	7	\N	169
1575	491	1	2026-01-28 19:52:26	80	8	\N	117
1576	491	2	2026-01-28 19:55:43	118	6	\N	76
1577	491	3	2026-01-28 19:58:57	74	9	\N	0
1578	492	0	2026-01-28 20:00:11	75	7	\N	131
1579	492	1	2026-01-28 20:03:37	93	8	\N	85
1580	492	2	2026-01-28 20:06:35	64	6	\N	120
1581	492	3	2026-01-28 20:09:39	67	5	\N	0
1582	493	0	2026-01-30 09:57:00	107	14	\N	98
1583	493	1	2026-01-30 10:00:25	116	14	\N	169
1584	493	2	2026-01-30 10:05:10	51	16	\N	110
1585	493	3	2026-01-30 10:07:51	65	12	\N	0
1586	494	0	2026-01-30 10:08:56	105	14	\N	167
1587	494	1	2026-01-30 10:13:28	102	12	\N	155
1588	494	2	2026-01-30 10:17:45	78	14	\N	0
1589	495	0	2026-01-30 10:19:03	116	16	\N	179
1590	495	1	2026-01-30 10:23:58	89	14	\N	62
1591	495	2	2026-01-30 10:26:29	60	15	\N	0
1592	496	0	2026-01-30 10:27:29	70	16	\N	133
1593	496	1	2026-01-30 10:30:52	128	16	\N	143
1594	496	2	2026-01-30 10:35:23	67	16	\N	159
1595	496	3	2026-01-30 10:39:09	90	14	\N	0
1596	497	0	2026-01-31 19:31:00	81	14	\N	119
1597	497	1	2026-01-31 19:34:20	66	11	\N	141
1598	497	2	2026-01-31 19:37:47	98	12	\N	0
1599	498	0	2026-01-31 19:39:25	96	9	\N	168
1600	498	1	2026-01-31 19:43:49	55	5	\N	80
1601	498	2	2026-01-31 19:46:04	74	7	\N	100
1602	498	3	2026-01-31 19:48:58	128	7	\N	0
1603	499	0	2026-01-31 19:51:06	122	14	\N	142
1604	499	1	2026-01-31 19:55:30	79	15	\N	173
1605	499	2	2026-01-31 19:59:42	91	15	\N	155
1606	499	3	2026-01-31 20:03:48	111	16	\N	0
1607	500	0	2026-01-31 20:05:39	66	2	\N	0
1608	501	0	2026-02-06 17:47:00	58	15	\N	72
1609	501	1	2026-02-06 17:49:10	105	12	\N	130
1610	501	2	2026-02-06 17:53:05	48	12	\N	0
1611	502	0	2026-02-06 17:53:53	58	12	\N	93
1612	502	1	2026-02-06 17:56:24	64	16	\N	70
1613	502	2	2026-02-06 17:58:38	84	15	\N	89
1614	502	3	2026-02-06 18:01:31	81	13	\N	0
1615	503	0	2026-02-06 18:02:52	61	13	\N	127
1616	503	1	2026-02-06 18:06:00	48	13	\N	64
1617	503	2	2026-02-06 18:07:52	86	14	\N	170
1618	503	3	2026-02-06 18:12:08	104	15	\N	0
1619	504	0	2026-02-06 18:13:52	62	15	\N	149
1620	504	1	2026-02-06 18:17:23	67	16	\N	135
1621	504	2	2026-02-06 18:20:45	103	16	\N	140
1622	504	3	2026-02-06 18:24:48	100	16	\N	0
1623	505	0	2026-02-07 19:19:00	101	10	\N	99
1624	505	1	2026-02-07 19:22:20	97	12	\N	93
1625	505	2	2026-02-07 19:25:30	83	11	\N	0
1626	506	0	2026-02-07 19:26:53	62	9	\N	104
1627	506	1	2026-02-07 19:29:39	105	7	\N	128
1628	506	2	2026-02-07 19:33:32	107	5	\N	0
1629	507	0	2026-02-07 19:35:19	100	12	\N	162
1630	507	1	2026-02-07 19:39:41	121	14	\N	89
1631	507	2	2026-02-07 19:43:11	115	12	\N	0
1632	508	0	2026-02-07 19:45:06	97	1	\N	0
1633	509	0	2026-02-09 18:25:00	93	13	\N	88
1634	509	1	2026-02-09 18:28:01	55	12	\N	114
1635	509	2	2026-02-09 18:30:50	111	11	\N	157
1636	509	3	2026-02-09 18:35:18	79	14	\N	0
1637	510	0	2026-02-09 18:36:37	79	14	\N	112
1638	510	1	2026-02-09 18:39:48	53	11	\N	83
1639	510	2	2026-02-09 18:42:04	82	11	\N	74
1640	510	3	2026-02-09 18:44:40	124	13	\N	0
1641	511	0	2026-02-09 18:46:44	107	14	\N	84
1642	511	1	2026-02-09 18:49:55	47	12	\N	79
1643	511	2	2026-02-09 18:52:01	113	10	\N	0
1644	512	0	2026-02-09 18:53:54	81	10	\N	94
1645	512	1	2026-02-09 18:56:49	101	11	\N	153
1646	512	2	2026-02-09 19:01:03	74	10	\N	0
1647	513	0	2026-02-14 18:19:00	87	10	\N	70
1648	513	1	2026-02-14 18:21:37	52	11	\N	94
1649	513	2	2026-02-14 18:24:03	54	13	\N	0
1650	514	0	2026-02-14 18:24:57	69	6	\N	174
1651	514	1	2026-02-14 18:29:00	93	7	\N	166
1652	514	2	2026-02-14 18:33:19	60	5	\N	0
1653	515	0	2026-02-14 18:34:19	76	15	\N	154
1654	515	1	2026-02-14 18:38:09	70	12	\N	118
1655	515	2	2026-02-14 18:41:17	111	12	\N	0
1656	516	0	2026-02-14 18:43:08	94	2	\N	0
1657	517	0	2026-02-16 17:59:00	115	10	\N	126
1658	517	1	2026-02-16 18:03:01	77	10	\N	121
1659	517	2	2026-02-16 18:06:19	70	12	\N	106
1660	517	3	2026-02-16 18:09:15	130	10	\N	0
1661	518	0	2026-02-16 18:11:25	126	11	\N	115
1662	518	1	2026-02-16 18:15:26	46	12	\N	81
1663	518	2	2026-02-16 18:17:33	119	12	\N	0
1664	519	0	2026-02-16 18:19:32	46	11	\N	65
1665	519	1	2026-02-16 18:21:23	105	14	\N	148
1666	519	2	2026-02-16 18:25:36	64	14	\N	0
1667	520	0	2026-02-16 18:26:40	65	11	\N	123
1668	520	1	2026-02-16 18:29:48	124	10	\N	103
1669	520	2	2026-02-16 18:33:35	52	10	\N	0
1670	521	0	2026-02-18 09:44:00	85	6	\N	131
1671	521	1	2026-02-18 09:47:36	101	7	\N	153
1672	521	2	2026-02-18 09:51:50	47	6	\N	0
1673	522	0	2026-02-18 09:52:37	77	6	\N	175
1674	522	1	2026-02-18 09:56:49	107	5	\N	150
1675	522	2	2026-02-18 10:01:06	116	8	\N	0
1676	523	0	2026-02-18 10:03:02	69	8	\N	132
1677	523	1	2026-02-18 10:06:23	114	6	\N	104
1678	523	2	2026-02-18 10:10:01	104	7	\N	95
1679	523	3	2026-02-18 10:13:20	115	9	\N	0
1680	524	0	2026-02-18 10:15:15	64	9	\N	117
1681	524	1	2026-02-18 10:18:16	78	7	\N	129
1682	524	2	2026-02-18 10:21:43	103	7	\N	0
1683	525	0	2026-02-21 18:46:00	75	14	\N	101
1684	525	1	2026-02-21 18:48:56	129	10	\N	128
1685	525	2	2026-02-21 18:53:13	69	13	\N	0
1686	526	0	2026-02-21 18:54:22	115	8	\N	79
1687	526	1	2026-02-21 18:57:36	81	9	\N	101
1688	526	2	2026-02-21 19:00:38	127	8	\N	101
1689	526	3	2026-02-21 19:04:26	57	5	\N	0
1690	527	0	2026-02-21 19:05:23	50	12	\N	166
1691	527	1	2026-02-21 19:08:59	67	13	\N	171
1692	527	2	2026-02-21 19:12:57	70	12	\N	73
1693	527	3	2026-02-21 19:15:20	69	15	\N	0
1694	528	0	2026-02-21 19:16:29	118	1	\N	0
1695	529	0	2026-02-23 18:42:00	77	14	\N	66
1696	529	1	2026-02-23 18:44:23	73	12	\N	137
1697	529	2	2026-02-23 18:47:53	46	10	\N	179
1698	529	3	2026-02-23 18:51:38	128	11	\N	0
1699	530	0	2026-02-23 18:53:46	126	13	\N	67
1700	530	1	2026-02-23 18:56:59	116	12	\N	155
1701	530	2	2026-02-23 19:01:30	92	13	\N	0
1702	531	0	2026-02-23 19:03:02	112	12	\N	65
1703	531	1	2026-02-23 19:05:59	83	10	\N	69
1704	531	2	2026-02-23 19:08:31	111	11	\N	72
1705	531	3	2026-02-23 19:11:34	74	10	\N	0
1706	532	0	2026-02-23 19:12:48	69	11	\N	127
1707	532	1	2026-02-23 19:16:04	117	11	\N	140
1708	532	2	2026-02-23 19:20:21	116	11	\N	0
1709	533	0	2026-02-25 18:47:00	130	8	\N	114
1710	533	1	2026-02-25 18:51:04	66	5	\N	161
1711	533	2	2026-02-25 18:54:51	115	6	\N	111
1712	533	3	2026-02-25 18:58:37	88	9	\N	0
1713	534	0	2026-02-25 19:00:05	101	9	\N	179
1714	534	1	2026-02-25 19:04:45	85	7	\N	130
1715	534	2	2026-02-25 19:08:20	92	7	\N	112
1716	534	3	2026-02-25 19:11:44	86	8	\N	0
1717	535	0	2026-02-25 19:13:10	72	9	\N	108
1718	535	1	2026-02-25 19:16:10	77	9	\N	106
1719	535	2	2026-02-25 19:19:13	102	8	\N	110
1720	535	3	2026-02-25 19:22:45	49	5	\N	0
1721	536	0	2026-02-25 19:23:34	111	5	\N	77
1722	536	1	2026-02-25 19:26:42	45	7	\N	98
1723	536	2	2026-02-25 19:29:05	72	6	\N	169
1724	536	3	2026-02-25 19:33:06	47	7	\N	0
1725	537	0	2026-02-27 17:58:00	64	17	\N	72
1726	537	1	2026-02-27 18:00:16	103	13	\N	105
1727	537	2	2026-02-27 18:03:44	62	14	\N	93
1728	537	3	2026-02-27 18:06:19	119	15	\N	0
1729	538	0	2026-02-27 18:08:18	83	15	\N	71
1730	538	1	2026-02-27 18:10:52	96	17	\N	132
1731	538	2	2026-02-27 18:14:40	54	14	\N	0
1732	539	0	2026-02-27 18:15:34	67	16	\N	122
1733	539	1	2026-02-27 18:18:43	57	17	\N	136
1734	539	2	2026-02-27 18:21:56	49	15	\N	0
1735	540	0	2026-02-27 18:22:45	87	13	\N	104
1736	540	1	2026-02-27 18:25:56	98	16	\N	179
1737	540	2	2026-02-27 18:30:33	74	13	\N	0
1738	541	0	2026-02-28 19:59:00	50	14	\N	100
1739	541	1	2026-02-28 20:01:30	117	14	\N	79
1740	541	2	2026-02-28 20:04:46	109	12	\N	0
1741	542	0	2026-02-28 20:06:35	51	6	\N	146
1742	542	1	2026-02-28 20:09:52	102	8	\N	156
1743	542	2	2026-02-28 20:14:10	118	9	\N	0
1744	543	0	2026-02-28 20:16:08	100	14	\N	97
1745	543	1	2026-02-28 20:19:25	63	16	\N	76
1746	543	2	2026-02-28 20:21:44	55	15	\N	0
1747	544	0	2026-02-28 20:22:39	51	3	\N	0
1748	545	0	2026-03-02 17:05:00	62	11	\N	121
1749	545	1	2026-03-02 17:08:03	70	14	\N	122
1750	545	2	2026-03-02 17:11:15	128	13	\N	133
1751	545	3	2026-03-02 17:15:36	116	11	\N	0
1752	546	0	2026-03-02 17:17:32	76	14	\N	91
1753	546	1	2026-03-02 17:20:19	79	10	\N	159
1754	546	2	2026-03-02 17:24:17	86	13	\N	147
1755	546	3	2026-03-02 17:28:10	56	14	\N	0
1756	547	0	2026-03-02 17:29:06	99	13	\N	106
1757	547	1	2026-03-02 17:32:31	69	12	\N	101
1758	547	2	2026-03-02 17:35:21	121	12	\N	143
1759	547	3	2026-03-02 17:39:45	84	10	\N	0
1760	548	0	2026-03-02 17:41:09	101	14	\N	139
1761	548	1	2026-03-02 17:45:09	101	11	\N	65
1762	548	2	2026-03-02 17:47:55	70	11	\N	0
1763	549	0	2026-03-04 09:48:00	76	5	\N	139
1764	549	1	2026-03-04 09:51:35	81	6	\N	61
1765	549	2	2026-03-04 09:53:57	59	7	\N	99
1766	549	3	2026-03-04 09:56:35	105	8	\N	0
1767	550	0	2026-03-04 09:58:20	113	6	\N	87
1768	550	1	2026-03-04 10:01:40	114	6	\N	126
1769	550	2	2026-03-04 10:05:40	115	7	\N	0
1770	551	0	2026-03-04 10:07:35	130	6	\N	62
1771	551	1	2026-03-04 10:10:47	119	8	\N	175
1772	551	2	2026-03-04 10:15:41	50	9	\N	92
1773	551	3	2026-03-04 10:18:03	52	6	\N	0
1774	552	0	2026-03-04 10:18:55	79	9	\N	66
1775	552	1	2026-03-04 10:21:20	128	8	\N	180
1776	552	2	2026-03-04 10:26:28	53	5	\N	0
1777	553	0	2026-03-06 17:42:00	128	15	\N	109
1778	553	1	2026-03-06 17:45:57	93	14	\N	125
1779	553	2	2026-03-06 17:49:35	85	13	\N	0
1780	554	0	2026-03-06 17:51:00	56	17	\N	83
1781	554	1	2026-03-06 17:53:19	109	14	\N	118
1782	554	2	2026-03-06 17:57:06	47	17	\N	65
1783	554	3	2026-03-06 17:58:58	112	14	\N	0
1784	555	0	2026-03-06 18:00:50	95	16	\N	155
1785	555	1	2026-03-06 18:05:00	47	14	\N	104
1786	555	2	2026-03-06 18:07:31	90	15	\N	0
1787	556	0	2026-03-06 18:09:01	80	17	\N	163
1788	556	1	2026-03-06 18:13:04	125	13	\N	92
1789	556	2	2026-03-06 18:16:41	48	16	\N	0
1790	557	0	2026-03-07 17:14:00	56	11	\N	153
1791	557	1	2026-03-07 17:17:29	111	13	\N	146
1792	557	2	2026-03-07 17:21:46	125	14	\N	147
1793	557	3	2026-03-07 17:26:18	98	11	\N	0
1794	558	0	2026-03-07 17:27:56	99	6	\N	99
1795	558	1	2026-03-07 17:31:14	87	9	\N	117
1796	558	2	2026-03-07 17:34:38	61	9	\N	86
1797	558	3	2026-03-07 17:37:05	119	6	\N	0
1798	559	0	2026-03-07 17:39:04	62	14	\N	99
1799	559	1	2026-03-07 17:41:45	62	17	\N	115
1800	559	2	2026-03-07 17:44:42	128	14	\N	179
1801	559	3	2026-03-07 17:49:49	65	17	\N	0
1802	560	0	2026-03-07 17:50:54	116	1	\N	0
1803	561	0	2026-03-09 08:11:00	97	12	\N	112
1804	561	1	2026-03-09 08:14:29	101	12	\N	155
1805	561	2	2026-03-09 08:18:45	64	12	\N	0
1806	562	0	2026-03-09 08:19:49	68	11	\N	63
1807	562	1	2026-03-09 08:22:00	123	14	\N	94
1808	562	2	2026-03-09 08:25:37	117	14	\N	0
1809	563	0	2026-03-09 08:27:34	74	11	\N	147
1810	563	1	2026-03-09 08:31:15	90	10	\N	70
1811	563	2	2026-03-09 08:33:55	62	13	\N	124
1812	563	3	2026-03-09 08:37:01	105	14	\N	0
1813	564	0	2026-03-09 08:38:46	68	12	\N	169
1814	564	1	2026-03-09 08:42:43	107	13	\N	120
1815	564	2	2026-03-09 08:46:30	65	11	\N	84
1816	564	3	2026-03-09 08:48:59	49	11	\N	0
1817	565	0	2026-03-11 08:59:00	71	6	\N	68
1818	565	1	2026-03-11 09:01:19	101	6	\N	170
1819	565	2	2026-03-11 09:05:50	107	9	\N	148
1820	565	3	2026-03-11 09:10:05	103	7	\N	0
1821	566	0	2026-03-11 09:11:48	50	8	\N	137
1822	566	1	2026-03-11 09:14:55	85	8	\N	110
1823	566	2	2026-03-11 09:18:10	118	9	\N	0
1824	567	0	2026-03-11 09:20:08	102	5	\N	118
1825	567	1	2026-03-11 09:23:48	76	5	\N	126
1826	567	2	2026-03-11 09:27:10	95	9	\N	154
1827	567	3	2026-03-11 09:31:19	116	5	\N	0
1828	568	0	2026-03-11 09:33:15	69	5	\N	97
1829	568	1	2026-03-11 09:36:01	95	8	\N	173
1830	568	2	2026-03-11 09:40:29	81	7	\N	119
1831	568	3	2026-03-11 09:43:49	99	6	\N	0
1832	569	0	2026-03-13 08:44:00	56	16	\N	152
1833	569	1	2026-03-13 08:47:28	59	17	\N	83
1834	569	2	2026-03-13 08:49:50	114	17	\N	77
1835	569	3	2026-03-13 08:53:01	97	16	\N	0
1836	570	0	2026-03-13 08:54:38	67	13	\N	118
1837	570	1	2026-03-13 08:57:43	70	17	\N	172
1838	570	2	2026-03-13 09:01:45	56	16	\N	0
1839	571	0	2026-03-13 09:02:41	60	14	\N	71
1840	571	1	2026-03-13 09:04:52	102	13	\N	141
1841	571	2	2026-03-13 09:08:55	55	15	\N	0
1842	572	0	2026-03-13 09:09:50	123	17	\N	80
1843	572	1	2026-03-13 09:13:13	115	16	\N	108
1844	572	2	2026-03-13 09:16:56	66	13	\N	176
1845	572	3	2026-03-13 09:20:58	117	15	\N	0
1846	573	0	2026-03-14 09:10:00	98	10	\N	99
1847	573	1	2026-03-14 09:13:17	102	12	\N	96
1848	573	2	2026-03-14 09:16:35	60	11	\N	175
1849	573	3	2026-03-14 09:20:30	70	11	\N	0
1850	574	0	2026-03-14 09:21:40	46	7	\N	118
1851	574	1	2026-03-14 09:24:24	108	8	\N	129
1852	574	2	2026-03-14 09:28:21	122	5	\N	172
1853	574	3	2026-03-14 09:33:15	75	8	\N	0
1854	575	0	2026-03-14 09:34:30	103	16	\N	112
1855	575	1	2026-03-14 09:38:05	55	16	\N	136
1856	575	2	2026-03-14 09:41:16	45	17	\N	91
1857	575	3	2026-03-14 09:43:32	80	17	\N	0
1858	576	0	2026-03-14 09:44:52	68	1	\N	0
1859	577	0	2026-03-18 08:09:00	83	9	\N	102
1860	577	1	2026-03-18 08:12:05	51	5	\N	73
1861	577	2	2026-03-18 08:14:09	67	8	\N	80
1862	577	3	2026-03-18 08:16:36	123	7	\N	0
1863	578	0	2026-03-18 08:18:39	67	9	\N	118
1864	578	1	2026-03-18 08:21:44	91	9	\N	179
1865	578	2	2026-03-18 08:26:14	56	5	\N	158
1866	578	3	2026-03-18 08:29:48	86	7	\N	0
1867	579	0	2026-03-18 08:31:14	99	5	\N	167
1868	579	1	2026-03-18 08:35:40	53	9	\N	97
1869	579	2	2026-03-18 08:38:10	62	8	\N	0
1870	580	0	2026-03-18 08:39:12	87	7	\N	127
1871	580	1	2026-03-18 08:42:46	112	8	\N	86
1872	580	2	2026-03-18 08:46:04	123	6	\N	67
1873	580	3	2026-03-18 08:49:14	118	5	\N	0
1874	581	0	2026-03-20 19:05:00	85	17	\N	93
1875	581	1	2026-03-20 19:07:58	118	17	\N	139
1876	581	2	2026-03-20 19:12:15	61	15	\N	0
1877	582	0	2026-03-20 19:13:16	108	16	\N	163
1878	582	1	2026-03-20 19:17:47	123	14	\N	89
1879	582	2	2026-03-20 19:21:19	69	15	\N	60
1880	582	3	2026-03-20 19:23:28	48	13	\N	0
1881	583	0	2026-03-20 19:24:16	71	13	\N	162
1882	583	1	2026-03-20 19:28:09	98	17	\N	112
1883	583	2	2026-03-20 19:31:39	87	13	\N	104
1884	583	3	2026-03-20 19:34:50	126	17	\N	0
1885	584	0	2026-03-20 19:36:56	81	14	\N	92
1886	584	1	2026-03-20 19:39:49	84	13	\N	98
1887	584	2	2026-03-20 19:42:51	115	17	\N	0
1888	585	0	2026-03-21 08:07:00	123	14	\N	63
1889	585	1	2026-03-21 08:10:06	69	11	\N	102
1890	585	2	2026-03-21 08:12:57	106	12	\N	0
1891	586	0	2026-03-21 08:14:43	106	6	\N	79
1892	586	1	2026-03-21 08:17:48	113	8	\N	174
1893	586	2	2026-03-21 08:22:35	104	7	\N	0
1894	587	0	2026-03-21 08:24:19	111	13	\N	98
1895	587	1	2026-03-21 08:27:48	85	17	\N	131
1896	587	2	2026-03-21 08:31:24	47	17	\N	86
1897	587	3	2026-03-21 08:33:37	87	17	\N	0
1898	588	0	2026-03-21 08:35:04	64	1	\N	0
1899	589	0	2026-03-23 08:21:00	94	14	\N	83
1900	589	1	2026-03-23 08:23:57	59	14	\N	170
1901	589	2	2026-03-23 08:27:46	85	12	\N	150
1902	589	3	2026-03-23 08:31:41	79	10	\N	0
1903	590	0	2026-03-23 08:33:00	75	13	\N	107
1904	590	1	2026-03-23 08:36:02	83	13	\N	87
1905	590	2	2026-03-23 08:38:52	83	14	\N	0
1906	591	0	2026-03-23 08:40:15	49	12	\N	159
1907	591	1	2026-03-23 08:43:43	56	11	\N	116
1908	591	2	2026-03-23 08:46:35	48	14	\N	0
1909	592	0	2026-03-23 08:47:23	69	11	\N	103
1910	592	1	2026-03-23 08:50:15	112	13	\N	99
1911	592	2	2026-03-23 08:53:46	63	12	\N	158
1912	592	3	2026-03-23 08:57:27	111	10	\N	0
1913	593	0	2026-03-25 09:13:00	59	9	\N	60
1914	593	1	2026-03-25 09:14:59	50	7	\N	147
1915	593	2	2026-03-25 09:18:16	56	9	\N	0
1916	594	0	2026-03-25 09:19:12	58	5	\N	126
1917	594	1	2026-03-25 09:22:16	47	7	\N	133
1918	594	2	2026-03-25 09:25:16	126	7	\N	0
1919	595	0	2026-03-25 09:27:22	69	6	\N	96
1920	595	1	2026-03-25 09:30:07	113	7	\N	100
1921	595	2	2026-03-25 09:33:40	130	8	\N	0
1922	596	0	2026-03-25 09:35:50	65	6	\N	95
1923	596	1	2026-03-25 09:38:30	46	5	\N	139
1924	596	2	2026-03-25 09:41:35	110	9	\N	0
1925	597	0	2026-03-28 19:20:00	76	14	\N	81
1926	597	1	2026-03-28 19:22:37	84	10	\N	138
1927	597	2	2026-03-28 19:26:19	114	12	\N	0
1928	598	0	2026-03-28 19:28:13	48	6	\N	120
1929	598	1	2026-03-28 19:31:01	58	5	\N	109
1930	598	2	2026-03-28 19:33:48	56	5	\N	0
1931	599	0	2026-03-28 19:34:44	121	14	\N	174
1932	599	1	2026-03-28 19:39:39	125	17	\N	167
1933	599	2	2026-03-28 19:44:31	123	16	\N	0
1934	600	0	2026-03-28 19:46:34	87	1	\N	0
1935	601	0	2026-03-30 19:05:00	104	11	\N	72
1936	601	1	2026-03-30 19:07:56	84	14	\N	147
1937	601	2	2026-03-30 19:11:47	105	14	\N	0
1938	602	0	2026-03-30 19:13:32	123	12	\N	93
1939	602	1	2026-03-30 19:17:08	95	13	\N	83
1940	602	2	2026-03-30 19:20:06	86	13	\N	0
1941	603	0	2026-03-30 19:21:32	53	11	\N	120
1942	603	1	2026-03-30 19:24:25	89	11	\N	121
1943	603	2	2026-03-30 19:27:55	66	14	\N	0
1944	604	0	2026-03-30 19:29:01	118	15	\N	76
1945	604	1	2026-03-30 19:32:15	58	15	\N	111
1946	604	2	2026-03-30 19:35:04	86	11	\N	0
1947	605	0	2026-04-01 08:50:00	97	9	\N	90
1948	605	1	2026-04-01 08:53:07	76	9	\N	130
1949	605	2	2026-04-01 08:56:33	106	6	\N	0
1950	606	0	2026-04-01 08:58:19	71	7	\N	164
1951	606	1	2026-04-01 09:02:14	100	9	\N	160
1952	606	2	2026-04-01 09:06:34	117	8	\N	0
1953	607	0	2026-04-01 09:08:31	67	6	\N	144
1954	607	1	2026-04-01 09:12:02	118	5	\N	167
1955	607	2	2026-04-01 09:16:47	59	8	\N	135
1956	607	3	2026-04-01 09:20:01	104	9	\N	0
1957	608	0	2026-04-01 09:21:45	101	5	\N	82
1958	608	1	2026-04-01 09:24:48	96	7	\N	68
1959	608	2	2026-04-01 09:27:32	58	9	\N	147
1960	608	3	2026-04-01 09:30:57	93	9	\N	0
1961	609	0	2026-04-03 08:05:00	63	13	\N	144
1962	609	1	2026-04-03 08:08:27	102	14	\N	128
1963	609	2	2026-04-03 08:12:17	94	15	\N	138
1964	609	3	2026-04-03 08:16:09	102	17	\N	0
1965	610	0	2026-04-03 08:17:51	83	15	\N	132
1966	610	1	2026-04-03 08:21:26	100	15	\N	151
1967	610	2	2026-04-03 08:25:37	56	15	\N	0
1968	611	0	2026-04-03 08:26:33	110	17	\N	111
1969	611	1	2026-04-03 08:30:14	82	14	\N	67
1970	611	2	2026-04-03 08:32:43	115	15	\N	0
1971	612	0	2026-04-03 08:34:38	90	17	\N	74
1972	612	1	2026-04-03 08:37:22	48	15	\N	90
1973	612	2	2026-04-03 08:39:40	120	16	\N	0
1974	613	0	2026-04-04 17:45:00	72	15	\N	144
1975	613	1	2026-04-04 17:48:36	105	12	\N	77
1976	613	2	2026-04-04 17:51:38	116	12	\N	0
1977	614	0	2026-04-04 17:53:34	64	8	\N	96
1978	614	1	2026-04-04 17:56:14	62	6	\N	61
1979	614	2	2026-04-04 17:58:17	127	5	\N	0
1980	615	0	2026-04-04 18:00:24	129	16	\N	115
1981	615	1	2026-04-04 18:04:28	55	14	\N	77
1982	615	2	2026-04-04 18:06:40	103	16	\N	0
1983	616	0	2026-04-04 18:08:23	68	3	\N	0
1984	617	0	2026-04-06 18:35:00	68	12	\N	114
1985	617	1	2026-04-06 18:38:02	45	15	\N	133
1986	617	2	2026-04-06 18:41:00	75	14	\N	0
1987	618	0	2026-04-06 18:42:15	114	14	\N	133
1988	618	1	2026-04-06 18:46:22	49	13	\N	64
1989	618	2	2026-04-06 18:48:15	106	15	\N	0
1990	619	0	2026-04-06 18:50:01	106	15	\N	148
1991	619	1	2026-04-06 18:54:15	63	11	\N	153
1992	619	2	2026-04-06 18:57:51	80	15	\N	0
1993	620	0	2026-04-06 18:59:11	111	11	\N	173
1994	620	1	2026-04-06 19:03:55	56	15	\N	91
1995	620	2	2026-04-06 19:06:22	125	14	\N	154
1996	620	3	2026-04-06 19:11:01	126	11	\N	0
1997	621	0	2026-04-08 19:19:00	105	5	\N	118
1998	621	1	2026-04-08 19:22:43	105	9	\N	133
1999	621	2	2026-04-08 19:26:41	98	7	\N	105
2000	621	3	2026-04-08 19:30:04	82	7	\N	0
2001	622	0	2026-04-08 19:31:26	83	9	\N	153
2002	622	1	2026-04-08 19:35:22	78	9	\N	67
2003	622	2	2026-04-08 19:37:47	119	8	\N	0
2004	623	0	2026-04-08 19:39:46	129	5	\N	97
2005	623	1	2026-04-08 19:43:32	48	9	\N	96
2006	623	2	2026-04-08 19:45:56	55	8	\N	76
2007	623	3	2026-04-08 19:48:07	54	9	\N	0
2008	624	0	2026-04-08 19:49:01	123	6	\N	95
2009	624	1	2026-04-08 19:52:39	77	7	\N	61
2010	624	2	2026-04-08 19:54:57	122	5	\N	0
2011	625	0	2026-04-11 09:42:00	107	12	\N	83
2012	625	1	2026-04-11 09:45:10	49	15	\N	103
2013	625	2	2026-04-11 09:47:42	63	11	\N	0
2014	626	0	2026-04-11 09:48:45	97	8	\N	158
2015	626	1	2026-04-11 09:53:00	75	8	\N	144
2016	626	2	2026-04-11 09:56:39	126	8	\N	0
2017	627	0	2026-04-11 09:58:45	89	17	\N	66
2018	627	1	2026-04-11 10:01:20	59	15	\N	66
2019	627	2	2026-04-11 10:03:25	104	14	\N	0
2020	628	0	2026-04-11 10:05:09	83	2	\N	0
2021	629	0	2026-04-13 19:14:00	112	12	\N	171
2022	629	1	2026-04-13 19:18:43	46	14	\N	96
2023	629	2	2026-04-13 19:21:05	93	14	\N	0
2024	630	0	2026-04-13 19:22:38	57	11	\N	177
2025	630	1	2026-04-13 19:26:32	126	15	\N	105
2026	630	2	2026-04-13 19:30:23	123	14	\N	177
2027	630	3	2026-04-13 19:35:23	87	13	\N	0
2028	631	0	2026-04-13 19:36:50	77	11	\N	143
2029	631	1	2026-04-13 19:40:30	95	15	\N	119
2030	631	2	2026-04-13 19:44:04	120	12	\N	0
2031	632	0	2026-04-13 19:46:04	68	13	\N	100
2032	632	1	2026-04-13 19:48:52	46	15	\N	146
2033	632	2	2026-04-13 19:52:04	53	11	\N	61
2034	632	3	2026-04-13 19:53:58	57	14	\N	0
2035	633	0	2026-04-15 18:22:00	48	5	\N	139
2036	633	1	2026-04-15 18:25:07	52	5	\N	180
2037	633	2	2026-04-15 18:28:59	129	9	\N	0
2038	634	0	2026-04-15 18:31:08	60	5	\N	71
2039	634	1	2026-04-15 18:33:19	61	9	\N	108
2040	634	2	2026-04-15 18:36:08	68	9	\N	174
2041	634	3	2026-04-15 18:40:10	68	5	\N	0
2042	635	0	2026-04-15 18:41:18	129	8	\N	179
2043	635	1	2026-04-15 18:46:26	126	5	\N	118
2044	635	2	2026-04-15 18:50:30	99	7	\N	0
2045	636	0	2026-04-15 18:52:09	77	7	\N	80
2046	636	1	2026-04-15 18:54:46	80	5	\N	159
2047	636	2	2026-04-15 18:58:45	93	5	\N	109
2048	636	3	2026-04-15 19:02:07	52	7	\N	0
2049	637	0	2026-04-17 17:11:00	95	17	\N	82
2050	637	1	2026-04-17 17:13:57	58	16	\N	78
2051	637	2	2026-04-17 17:16:13	100	17	\N	0
2052	638	0	2026-04-17 17:17:53	101	13	\N	151
2053	638	1	2026-04-17 17:22:05	58	15	\N	64
2054	638	2	2026-04-17 17:24:07	54	13	\N	133
2055	638	3	2026-04-17 17:27:14	102	15	\N	0
2056	639	0	2026-04-17 17:28:56	128	14	\N	141
2057	639	1	2026-04-17 17:33:25	49	13	\N	145
2058	639	2	2026-04-17 17:36:39	79	16	\N	0
2059	640	0	2026-04-17 17:37:58	95	15	\N	133
2060	640	1	2026-04-17 17:41:46	110	13	\N	150
2061	640	2	2026-04-17 17:46:06	106	16	\N	115
2062	640	3	2026-04-17 17:49:47	53	16	\N	0
2063	641	0	2026-04-18 08:24:00	90	15	\N	102
2064	641	1	2026-04-18 08:27:12	96	13	\N	67
2065	641	2	2026-04-18 08:29:55	91	11	\N	128
2066	641	3	2026-04-18 08:33:34	55	13	\N	0
2067	642	0	2026-04-18 08:34:29	67	6	\N	130
2068	642	1	2026-04-18 08:37:46	94	5	\N	144
2069	642	2	2026-04-18 08:41:44	83	6	\N	0
2070	643	0	2026-04-18 08:43:07	107	15	\N	70
2071	643	1	2026-04-18 08:46:04	69	16	\N	77
2072	643	2	2026-04-18 08:48:30	69	13	\N	0
2073	644	0	2026-04-18 08:49:39	75	3	\N	0
2074	645	0	2026-04-20 08:50:00	47	14	\N	64
2075	645	1	2026-04-20 08:51:51	52	13	\N	103
2076	645	2	2026-04-20 08:54:26	96	11	\N	75
2077	645	3	2026-04-20 08:57:17	128	12	\N	0
2078	646	0	2026-04-20 08:59:25	64	15	\N	154
2079	646	1	2026-04-20 09:03:03	74	15	\N	178
2080	646	2	2026-04-20 09:07:15	49	11	\N	0
2081	647	0	2026-04-20 09:08:04	105	11	\N	176
2082	647	1	2026-04-20 09:12:45	50	15	\N	91
2083	647	2	2026-04-20 09:15:06	46	12	\N	0
2084	648	0	2026-04-20 09:15:52	84	11	\N	165
2085	648	1	2026-04-20 09:20:01	103	11	\N	138
2086	648	2	2026-04-20 09:24:02	120	12	\N	68
2087	648	3	2026-04-20 09:27:10	59	11	\N	0
2088	649	0	2026-04-22 19:14:00	86	8	\N	75
2089	649	1	2026-04-22 19:16:41	114	9	\N	77
2090	649	2	2026-04-22 19:19:52	72	7	\N	0
2091	650	0	2026-04-22 19:21:04	87	6	\N	68
2092	650	1	2026-04-22 19:23:39	80	5	\N	78
2093	650	2	2026-04-22 19:26:17	66	8	\N	149
2094	650	3	2026-04-22 19:29:52	115	7	\N	0
2095	651	0	2026-04-22 19:31:47	119	6	\N	65
2096	651	1	2026-04-22 19:34:51	57	6	\N	161
2097	651	2	2026-04-22 19:38:29	93	9	\N	0
2098	652	0	2026-04-22 19:40:02	55	8	\N	60
2099	652	1	2026-04-22 19:41:57	67	5	\N	178
2100	652	2	2026-04-22 19:46:02	128	5	\N	0
2101	653	0	2026-04-24 17:26:00	126	14	\N	94
2102	653	1	2026-04-24 17:29:40	102	17	\N	112
2103	653	2	2026-04-24 17:33:14	67	14	\N	0
2104	654	0	2026-04-24 17:34:21	108	14	\N	138
2105	654	1	2026-04-24 17:38:27	125	13	\N	165
2106	654	2	2026-04-24 17:43:17	89	15	\N	113
2107	654	3	2026-04-24 17:46:39	116	13	\N	0
2108	655	0	2026-04-24 17:48:35	112	13	\N	72
2109	655	1	2026-04-24 17:51:39	91	17	\N	170
2110	655	2	2026-04-24 17:56:00	109	17	\N	0
2111	656	0	2026-04-24 17:57:49	80	14	\N	66
2112	656	1	2026-04-24 18:00:15	59	14	\N	161
2113	656	2	2026-04-24 18:03:55	105	14	\N	0
2114	657	0	2026-04-25 09:42:00	71	13	\N	115
2115	657	1	2026-04-25 09:45:06	87	13	\N	138
2116	657	2	2026-04-25 09:48:51	50	14	\N	0
2117	658	0	2026-04-25 09:49:41	113	5	\N	82
2118	658	1	2026-04-25 09:52:56	48	6	\N	122
2119	658	2	2026-04-25 09:55:46	59	9	\N	69
2120	658	3	2026-04-25 09:57:54	101	6	\N	0
2121	659	0	2026-04-25 09:59:35	98	15	\N	85
2122	659	1	2026-04-25 10:02:38	74	15	\N	159
2123	659	2	2026-04-25 10:06:31	86	13	\N	89
2124	659	3	2026-04-25 10:09:26	75	13	\N	0
2125	660	0	2026-04-25 10:10:41	93	1	\N	0
2126	661	0	2026-04-27 08:30:00	72	12	\N	178
2127	661	1	2026-04-27 08:34:10	103	15	\N	82
2128	661	2	2026-04-27 08:37:15	92	14	\N	0
2129	662	0	2026-04-27 08:38:47	125	12	\N	105
2130	662	1	2026-04-27 08:42:37	70	13	\N	102
2131	662	2	2026-04-27 08:45:29	49	12	\N	0
2132	663	0	2026-04-27 08:46:18	59	12	\N	169
2133	663	1	2026-04-27 08:50:06	103	14	\N	113
2134	663	2	2026-04-27 08:53:42	88	12	\N	0
2135	664	0	2026-04-27 08:55:10	65	15	\N	161
2136	664	1	2026-04-27 08:58:56	66	15	\N	133
2137	664	2	2026-04-27 09:02:15	74	15	\N	0
2138	665	0	2026-05-01 18:55:00	46	16	\N	153
2139	665	1	2026-05-01 18:58:19	76	17	\N	91
2140	665	2	2026-05-01 19:01:06	100	16	\N	0
2141	666	0	2026-05-01 19:02:46	118	15	\N	174
2142	666	1	2026-05-01 19:07:38	98	14	\N	65
2143	666	2	2026-05-01 19:10:21	105	14	\N	153
2144	666	3	2026-05-01 19:14:39	49	18	\N	0
2145	667	0	2026-05-01 19:15:28	106	17	\N	163
2146	667	1	2026-05-01 19:19:57	102	14	\N	123
2147	667	2	2026-05-01 19:23:42	55	15	\N	131
2148	667	3	2026-05-01 19:26:48	97	14	\N	0
2149	668	0	2026-05-01 19:28:25	82	16	\N	90
2150	668	1	2026-05-01 19:31:17	47	14	\N	121
2151	668	2	2026-05-01 19:34:05	65	16	\N	0
2152	669	0	2026-05-02 19:47:00	96	12	\N	83
2153	669	1	2026-05-02 19:49:59	125	13	\N	119
2154	669	2	2026-05-02 19:54:03	125	11	\N	0
2155	670	0	2026-05-02 19:56:08	112	8	\N	64
2156	670	1	2026-05-02 19:59:04	99	8	\N	156
2157	670	2	2026-05-02 20:03:19	123	8	\N	0
2158	671	0	2026-05-02 20:05:22	55	15	\N	139
2159	671	1	2026-05-02 20:08:36	52	16	\N	125
2160	671	2	2026-05-02 20:11:33	51	16	\N	74
2161	671	3	2026-05-02 20:13:38	91	17	\N	0
2162	672	0	2026-05-02 20:15:09	50	3	\N	0
2163	673	0	2026-05-04 09:41:00	62	12	\N	102
2164	673	1	2026-05-04 09:43:44	114	12	\N	74
2165	673	2	2026-05-04 09:46:52	119	14	\N	171
2166	673	3	2026-05-04 09:51:42	73	12	\N	0
2167	674	0	2026-05-04 09:52:55	109	13	\N	147
2168	674	1	2026-05-04 09:57:11	80	14	\N	66
2169	674	2	2026-05-04 09:59:37	92	11	\N	0
2170	675	0	2026-05-04 10:01:09	109	14	\N	127
2171	675	1	2026-05-04 10:05:05	105	11	\N	150
2172	675	2	2026-05-04 10:09:20	113	15	\N	0
2173	676	0	2026-05-04 10:11:13	92	15	\N	162
2174	676	1	2026-05-04 10:15:27	69	11	\N	174
2175	676	2	2026-05-04 10:19:30	56	14	\N	0
13026	4253	1	2026-06-08 18:30:02.874	39	8	\N	152
13027	4253	2	2026-06-08 18:33:15.068	48	8	\N	49
13028	4254	0	2026-06-08 18:26:26.276	0	6	\N	158
13029	4254	1	2026-06-08 18:29:05.164	54	6	\N	245
13030	4254	2	2026-06-08 18:34:05.466	41	6	\N	214
13031	4255	0	2026-06-08 18:38:23.708	45	6	\N	262
13032	4255	1	2026-06-08 18:43:32.351	44	6	\N	139
13033	4255	2	2026-06-08 18:46:37.02	50	6	\N	\N
13034	4256	0	2026-06-08 18:49:24.041	40	3	\N	75
13035	4257	0	2026-06-08 18:08:41.505	311	1	\N	871
13036	4258	0	2026-06-09 16:27:27.759	46	10	45	221
13037	4258	1	2026-06-09 16:31:55.77	49	8	45	\N
13038	4259	0	2026-06-09 16:28:23.16	67	1	\N	225
13039	4259	1	2026-06-09 16:33:15.64	34	1	\N	\N
13040	4260	0	2026-06-09 16:19:12.118	302	1	\N	\N
13041	4261	0	2026-06-16 17:29:19.973	44	15	40	199
13042	4261	1	2026-06-16 17:33:23.502	53	15	40	214
13043	4261	2	2026-06-16 17:37:51.278	87	15	40	239
13044	4262	0	2026-06-16 17:30:11.456	55	1	\N	192
13045	4262	1	2026-06-16 17:34:19.829	57	1	\N	248
13046	4262	2	2026-06-16 17:39:26.106	61	1	\N	171
13047	4263	0	2026-06-16 17:19:30.878	313	1	\N	85
13048	4263	1	2026-06-16 17:45:30.89	182	1	\N	\N
13049	4264	0	2026-06-18 18:19:10.34	31	10	\N	126
13050	4264	1	2026-06-18 18:21:48.038	50	15	\N	118
13051	4264	2	2026-06-18 18:24:36.754	48	15	\N	184
13052	4265	0	2026-06-18 18:28:30.636	59	8	\N	182
13053	4265	1	2026-06-18 18:32:33.425	50	5	\N	243
13054	4265	2	2026-06-18 18:37:27.698	44	8	\N	54
13055	4266	0	2026-06-18 18:29:31.945	80	3	\N	157
13056	4266	1	2026-06-18 18:33:30.061	49	4	\N	280
13057	4266	2	2026-06-18 18:39:01.036	0	5	\N	6
13058	4267	0	2026-06-18 18:40:39.378	38	6	\N	127
13059	4267	1	2026-06-18 18:43:25.077	27	6	\N	116
13060	4267	2	2026-06-18 18:45:49.238	40	6	\N	124
13061	4268	0	2026-06-18 18:48:37.097	35	4	\N	52
13062	4268	1	2026-06-18 18:50:04.93	30	4	\N	64
13063	4268	2	2026-06-18 18:51:40.363	24	4	\N	\N
13064	4269	0	2026-06-18 18:13:30.218	298	1	\N	33
13065	4270	0	2026-06-19 16:26:08.007	62	8	8	197
13066	4270	1	2026-06-19 16:30:27.753	1	8	8	133
13067	4270	2	2026-06-19 16:32:42.845	48	7	8	186
13068	4271	0	2026-06-19 16:37:02.057	134	8	8	107
13069	4271	1	2026-06-19 16:41:04.176	108	8	8	111
13070	4271	2	2026-06-19 16:44:44.67	95	8	8	3
13071	4272	0	2026-06-19 16:49:09.788	42	8	8	279
13072	4272	1	2026-06-19 16:54:32.163	0	8	8	85
13073	4272	2	2026-06-19 16:55:58.839	38	8	8	41
13074	4273	0	2026-06-19 16:49:54.031	29	8	8	153
13075	4273	1	2026-06-19 16:52:57.267	44	8	8	177
13076	4273	2	2026-06-19 16:56:39.075	31	8	8	13
13077	4274	0	2026-06-19 16:21:27.985	202	1	\N	140
13078	4275	0	2026-06-30 16:23:03.148	36	8	8	95
13079	4275	1	2026-06-30 16:25:14.927	38	6	8	80
13080	4275	2	2026-06-30 16:27:14.134	50	8	8	77
13081	4276	0	2026-06-30 16:30:14.602	100	8	8	85
13082	4276	1	2026-06-30 16:33:21.128	84	8	8	164
13083	4276	2	2026-06-30 16:37:30.85	132	8	8	73
13084	4277	0	2026-06-30 16:41:12.356	30	8	8	\N
13085	4277	1	2026-06-30 16:44:55.981	28	8	8	145
13086	4277	2	2026-06-30 16:47:50.573	34	8	8	48
13087	4278	0	2026-06-30 16:41:44.648	31	8	8	189
13088	4278	1	2026-06-30 16:45:26.253	32	8	8	147
13089	4278	2	2026-06-30 16:48:25.952	32	8	8	12
13090	4279	0	2026-06-30 16:14:13.262	305	1	\N	114
13091	4279	1	2026-06-30 16:51:31.876	276	1	\N	\N
13092	4280	0	2026-07-11 15:09:06.547	1	12	\N	51
13093	4280	1	2026-07-11 15:09:59.897	42	12	\N	42
13094	4280	2	2026-07-11 15:11:24.956	47	12	\N	41
13095	4280	3	2026-07-11 15:12:53.732	41	9	\N	\N
13096	4281	0	2026-07-11 15:16:39.085	1	12	\N	47
13097	4281	1	2026-07-11 15:17:28.047	40	12	\N	79
13098	4281	2	2026-07-11 15:19:27.839	33	12	\N	215
13099	4281	3	2026-07-11 15:23:36.511	0	12	\N	265
13100	4282	0	2026-07-11 15:25:25.996	0	2	\N	1
13101	4283	0	2026-07-11 15:28:04.702	39	1	\N	165
13102	4283	1	2026-07-11 15:31:34.972	37	1	\N	94
13103	4283	2	2026-07-11 15:33:46.544	31	1	\N	156
13104	4283	3	2026-07-11 15:36:55.104	34	1	\N	30
13105	4284	0	2026-07-11 15:38:01.416	326	1	\N	1
13106	4285	0	2026-07-14 01:10:23.293	40	8	8	68
13107	4285	1	2026-07-14 01:12:12.1	45	8	8	56
13108	4285	2	2026-07-14 01:13:53.646	39	8	8	95
13109	4286	0	2026-07-14 01:16:09.59	119	8	8	84
13110	4286	1	2026-07-14 01:19:33.762	137	8	8	78
13111	4286	2	2026-07-14 01:23:09.559	104	8	8	558
13112	4287	0	2026-07-14 01:26:22.76	33	8	8	133
12712	4150	0	2026-05-06 16:29:09.659	97	12	\N	82
12713	4150	1	2026-05-06 16:32:09.577	92	12	\N	103
12714	4150	2	2026-05-06 16:35:25.159	93	12	\N	123
12715	4151	0	2026-05-06 16:21:52.098	77	12	\N	80
12716	4151	1	2026-05-06 16:24:30.424	57	12	\N	80
12717	4151	2	2026-05-06 16:26:48.501	48	12	\N	93
12718	4152	0	2026-05-06 16:39:04.479	122	12	\N	83
12719	4152	1	2026-05-06 16:42:30.963	96	12	\N	107
12720	4152	2	2026-05-06 16:45:55.824	89	12	\N	2
12721	4153	0	2026-05-06 16:48:45.377	252	1	\N	\N
12722	4154	0	2026-05-07 16:13:49.528	70	8	\N	83
12723	4154	1	2026-05-07 16:16:23.639	68	8	\N	93
12724	4154	2	2026-05-07 16:19:05.128	78	8	\N	312
12725	4155	0	2026-05-07 16:25:38.115	65	8	\N	84
12726	4155	1	2026-05-07 16:28:10.805	38	8	\N	112
12727	4155	2	2026-05-07 16:30:40.966	51	10	\N	306
12728	4155	3	2026-05-07 16:36:40.278	1	10	\N	147
12729	4156	0	2026-05-07 16:39:10.809	64	1	\N	150
12730	4156	1	2026-05-07 16:42:47.967	65	1	\N	121
12731	4156	2	2026-05-07 16:45:54.659	62	1	9	57
12732	4157	0	2026-05-07 16:47:55.734	304	1	9	1
12733	4158	0	2026-05-08 16:30:14.845	1	11	\N	134
12734	4158	1	2026-05-08 16:33:01.654	40	15	\N	135
12735	4158	2	2026-05-08 16:35:56.968	88	15	\N	99
12736	4158	3	2026-05-08 16:39:04.857	53	15	\N	63
12737	4159	0	2026-05-08 16:30:54.076	10	1	\N	115
12738	4159	1	2026-05-08 16:33:45.046	25	1	\N	187
12739	4159	2	2026-05-08 16:37:18.694	4	1	\N	158
12740	4159	3	2026-05-08 16:40:01.106	39	1	\N	19
12741	4160	0	2026-05-08 16:51:17.805	372	1	\N	\N
12742	4161	0	2026-05-09 16:16:52.259	1	10	\N	2
12743	4161	1	2026-05-09 16:16:56.684	0	15	\N	2
12744	4161	2	2026-05-09 16:17:01.222	0	15	\N	\N
12745	4162	0	2026-05-09 16:17:06.127	1	12	\N	2
12746	4162	1	2026-05-09 16:17:10.622	1	12	\N	4
12747	4162	2	2026-05-09 16:17:16.512	0	12	\N	\N
12748	4163	0	2026-05-09 16:17:20.407	0	15	4	2
12749	4163	1	2026-05-09 16:17:24.669	0	15	4	2
12750	4163	2	2026-05-09 16:17:28.883	0	15	4	5
12751	4164	0	2026-05-11 16:30:38.806	73	8	\N	99
12752	4164	1	2026-05-11 16:33:31.373	70	12	\N	126
12753	4164	2	2026-05-11 16:36:49.19	119	8	\N	123
12754	4165	0	2026-05-11 16:40:53.302	42	16	\N	90
12755	4165	1	2026-05-11 16:43:05.975	61	22	\N	162
12756	4165	2	2026-05-11 16:46:50.735	47	20	\N	175
12757	4165	3	2026-05-11 16:50:32.839	31	15	\N	47
12758	4166	0	2026-05-11 16:52:23.458	65	1	\N	115
12759	4166	1	2026-05-11 16:55:44.702	62	1	\N	5
12760	4166	2	2026-05-11 16:58:15.167	54	1	\N	91
12761	4166	3	2026-05-11 17:01:12.057	43	1	\N	2
12762	4167	0	2026-05-11 17:03:17.378	337	1	\N	\N
12763	4168	0	2026-05-12 15:20:31.318	42	15	10	2
12764	4168	1	2026-05-12 15:25:37.199	46	15	15	396
12765	4168	2	2026-05-12 15:33:01.1	1	15	15	10
12766	4168	3	2026-05-12 15:38:07.663	60	15	15	\N
12767	4169	0	2026-05-12 15:21:34.146	26	1	\N	273
12768	4169	1	2026-05-12 15:26:34.298	42	1	\N	350
12769	4169	2	2026-05-12 15:33:07.547	44	1	\N	318
12770	4169	3	2026-05-12 15:39:10.889	31	1	\N	61
12771	4170	0	2026-05-12 15:42:16.009	385	1	\N	\N
12772	4171	0	2026-05-13 16:41:16.065	126	6	\N	107
12773	4171	1	2026-05-13 16:45:10.574	86	6	\N	110
12774	4171	2	2026-05-13 16:48:28.249	89	6	\N	132
12775	4171	3	2026-05-13 16:52:10.947	65	6	\N	149
12776	4172	0	2026-05-13 16:55:46.581	63	10	\N	146
12777	4172	1	2026-05-13 16:59:16.108	55	15	\N	219
12778	4172	2	2026-05-13 17:03:51.236	52	15	\N	293
12779	4172	3	2026-05-13 17:09:37.357	52	15	\N	120
12780	4173	0	2026-05-13 16:56:56.895	1	10	\N	194
12781	4173	1	2026-05-13 17:00:13.362	48	15	\N	222
12782	4173	2	2026-05-13 17:04:44.689	52	15	\N	294
12783	4173	3	2026-05-13 17:10:31.377	45	15	\N	76
12784	4174	0	2026-05-13 17:13:37.122	146	1	\N	\N
12785	4175	0	2026-05-14 16:22:21.964	53	10	\N	114
12786	4175	1	2026-05-14 16:25:09.747	48	12	\N	104
12787	4175	2	2026-05-14 16:27:42.632	57	9	\N	189
12788	4176	0	2026-05-14 16:31:49.951	47	7	\N	120
12789	4176	1	2026-05-14 16:34:37.895	46	5	\N	151
12790	4176	2	2026-05-14 16:37:55.875	40	4	\N	9
12791	4177	0	2026-05-14 16:42:22.643	24	9	\N	188
12792	4177	1	2026-05-14 16:45:55.468	35	10	\N	181
12793	4177	2	2026-05-14 16:49:32.519	90	10	\N	217
12794	4177	3	2026-05-14 16:54:41.366	30	1	\N	69
12795	4178	0	2026-05-14 16:42:49.013	62	1	\N	161
12796	4178	1	2026-05-14 16:46:33.147	30	1	\N	170
12797	4178	2	2026-05-14 16:49:53.987	61	1	\N	257
12798	4178	3	2026-05-14 16:55:13.038	57	1	\N	6
12799	4179	0	2026-05-18 16:40:58.316	1	15	\N	164
12800	4179	1	2026-05-18 16:43:43.932	51	15	\N	69
12801	4179	2	2026-05-18 16:45:45.207	54	8	\N	70
12802	4180	0	2026-05-18 16:49:05.993	36	4	\N	217
12803	4180	1	2026-05-18 16:53:20.09	2	3	\N	95
12804	4180	2	2026-05-18 16:54:58.118	43	2	\N	32
12805	4181	0	2026-05-18 16:58:29.03	41	12	\N	155
12806	4181	1	2026-05-18 17:01:46.5	99	12	\N	150
12807	4181	2	2026-05-18 17:05:56.545	30	12	\N	170
12808	4181	3	2026-05-18 17:09:17.535	31	15	\N	103
12809	4182	0	2026-05-18 16:59:11.886	46	1	\N	136
12810	4182	1	2026-05-18 17:02:15.29	62	1	\N	190
12811	4182	2	2026-05-18 17:06:28.878	48	1	\N	154
12812	4182	3	2026-05-18 17:09:51.414	65	1	\N	38
12813	4183	0	2026-05-18 16:33:57.97	248	1	\N	2
12814	4183	1	2026-05-18 17:14:35.246	132	1	\N	\N
12815	4184	0	2026-05-19 16:32:00.957	48	12	\N	139
12816	4184	1	2026-05-19 16:35:24.699	41	12	\N	230
12817	4184	2	2026-05-19 16:39:57.132	45	15	\N	225
12818	4184	3	2026-05-19 16:44:28.168	49	10	\N	89
12819	4185	0	2026-05-19 16:32:51.438	46	1	\N	151
12820	4185	1	2026-05-19 16:36:09.439	44	1	\N	236
12821	4185	2	2026-05-19 16:40:50.924	39	1	\N	242
12822	4185	3	2026-05-19 16:45:32.956	43	1	\N	32
12823	4186	0	2026-05-19 16:19:31.394	314	1	\N	75
12824	4186	1	2026-05-19 16:46:51.882	317	1	\N	\N
12825	4187	0	2026-05-20 16:34:50.234	88	6	\N	109
12826	4187	1	2026-05-20 16:38:08.092	76	6	\N	117
12827	4187	2	2026-05-20 16:41:22.756	64	6	\N	184
12828	4187	3	2026-05-20 16:45:31.7	144	20	\N	4
12829	4188	0	2026-05-20 16:50:37.744	40	12	\N	265
12830	4188	1	2026-05-20 16:55:43.85	87	15	\N	155
12831	4188	2	2026-05-20 16:59:47.232	47	15	\N	198
12832	4188	3	2026-05-20 17:03:53.033	53	20	\N	250
12833	4189	0	2026-05-20 16:51:19.755	32	12	\N	321
12834	4189	1	2026-05-20 16:57:12.996	0	15	\N	203
12835	4189	2	2026-05-20 17:00:36.882	41	15	\N	209
12836	4189	3	2026-05-20 17:04:48.181	88	20	\N	159
12837	4190	0	2026-05-20 16:23:37.576	668	1	\N	2
12838	4190	1	2026-05-20 17:08:54.407	367	1	\N	3
12839	4191	0	2026-05-21 16:22:50.113	39	12	\N	98
12840	4191	1	2026-05-21 16:25:08.623	47	12	\N	108
12841	4191	2	2026-05-21 16:27:44.911	57	8	\N	110
12842	4192	0	2026-05-21 16:30:34.38	57	7	\N	100
12843	4192	1	2026-05-21 16:33:12.337	73	3	\N	128
12844	4192	2	2026-05-21 16:36:33.726	76	4	\N	122
12845	4193	0	2026-05-21 16:39:53.143	28	8	\N	1
12846	4193	1	2026-05-21 16:43:38.236	20	10	\N	76
12847	4193	2	2026-05-21 16:46:55.784	19	10	\N	186
12848	4193	3	2026-05-21 16:50:21.792	22	10	\N	\N
12849	4194	0	2026-05-21 16:40:32.934	64	1	\N	143
12850	4194	1	2026-05-21 16:44:00.08	64	1	\N	109
12851	4194	2	2026-05-21 16:47:16.714	65	1	\N	143
12852	4194	3	2026-05-21 16:50:46.468	65	1	\N	\N
12853	4195	0	2026-05-21 16:14:13.766	355	1	\N	1
12854	4196	0	2026-05-22 18:26:54.107	33	12	\N	180
12855	4196	1	2026-05-22 18:30:27.785	36	15	\N	193
12856	4196	2	2026-05-22 18:34:18.197	36	11	\N	185
12857	4196	3	2026-05-22 18:38:00.673	37	9	\N	207
12858	4196	4	2026-05-22 18:42:06.187	36	8	\N	117
12859	4197	0	2026-05-22 18:27:33.279	31	1	\N	141
12860	4197	1	2026-05-22 18:31:59.421	40	1	\N	176
12861	4197	2	2026-05-22 18:35:28.143	40	1	\N	109
12862	4197	3	2026-05-22 18:38:47.922	38	1	\N	157
12863	4197	4	2026-05-22 18:42:51.843	44	1	\N	65
12864	4198	0	2026-05-22 18:18:25.45	304	1	\N	186
12865	4198	1	2026-05-22 18:44:34.073	303	1	\N	\N
12866	4199	0	2026-05-25 16:32:45.155	27	12	\N	125
12867	4199	1	2026-05-25 16:35:18.931	40	12	\N	104
12868	4199	2	2026-05-25 16:37:44.881	21	12	\N	5
12869	4200	0	2026-05-25 16:40:00.589	67	8	\N	98
12870	4200	1	2026-05-25 16:42:45.866	54	8	\N	148
12871	4200	2	2026-05-25 16:46:08.493	49	8	\N	3
12872	4201	0	2026-05-25 16:49:33.31	21	10	\N	1
12873	4201	1	2026-05-25 16:52:30.166	21	10	\N	173
12874	4201	2	2026-05-25 16:55:45.131	21	10	\N	190
12875	4201	3	2026-05-25 16:59:16.542	22	10	\N	108
12876	4202	0	2026-05-25 16:50:00.539	63	1	\N	109
12877	4202	1	2026-05-25 16:52:53.565	64	1	\N	131
12878	4202	2	2026-05-25 16:56:10.073	63	1	\N	147
12879	4202	3	2026-05-25 16:59:41.088	63	1	\N	46
12880	4203	0	2026-05-25 16:25:24.999	349	1	\N	1
12881	4204	0	2026-05-26 16:25:42.542	34	12	40	137
12882	4204	1	2026-05-26 16:28:33.956	40	12	40	195
12883	4204	2	2026-05-26 16:32:29.51	34	10	40	164
12884	4204	3	2026-05-26 16:35:49.192	39	9	40	297
12885	4204	4	2026-05-26 16:41:26.775	0	8	40	\N
12886	4205	0	2026-05-26 16:26:27.092	20	1	\N	152
12887	4205	1	2026-05-26 16:29:19.759	36	1	\N	194
12888	4205	2	2026-05-26 16:33:10.477	38	1	\N	174
12889	4205	3	2026-05-26 16:36:43.241	21	1	\N	179
12890	4205	4	2026-05-26 16:40:04.239	37	1	\N	2
12891	4205	5	2026-05-26 16:42:17.576	32	1	\N	119
12892	4205	6	2026-05-26 16:44:50.066	26	1	\N	\N
12893	4206	0	2026-05-26 16:12:13.012	82	1	\N	86
12894	4206	1	2026-05-26 16:46:59.68	301	1	\N	\N
12895	4207	0	2026-05-28 01:20:34.342	34	3	\N	244
12896	4207	1	2026-05-28 01:25:13.982	0	5	\N	106
12897	4207	2	2026-05-28 01:27:01.248	37	3	\N	106
12898	4208	0	2026-05-28 01:29:26.01	74	4	\N	159
12899	4208	1	2026-05-28 01:33:19.455	136	8	\N	112
12900	4208	2	2026-05-28 01:37:28.647	154	8	\N	113
12901	4209	0	2026-05-28 01:42:06.299	49	8	\N	109
12902	4209	1	2026-05-28 01:44:45.775	29	16	\N	204
12903	4209	2	2026-05-28 01:48:39.149	48	16	\N	55
12904	4210	0	2026-05-28 01:42:34.101	22	8	\N	139
12905	4210	1	2026-05-28 01:45:16.678	59	16	\N	193
12906	4210	2	2026-05-28 01:49:29.612	42	16	\N	12
12907	4211	0	2026-05-28 01:07:33.44	294	1	\N	1
12908	4211	1	2026-05-28 01:51:29.102	302	1	\N	\N
12909	4212	0	2026-05-28 16:23:57.959	88	15	\N	108
12910	4212	1	2026-05-28 16:27:15.096	57	8	\N	156
12911	4212	2	2026-05-28 16:30:49.087	69	10	\N	513
12912	4213	0	2026-05-28 16:37:42.726	23	8	\N	152
12913	4213	1	2026-05-28 16:40:38.699	28	8	\N	126
12914	4213	2	2026-05-28 16:44:04.959	32	8	\N	267
12915	4214	0	2026-05-28 16:38:09.339	36	5	\N	185
12916	4214	1	2026-05-28 16:41:50.983	9	7	\N	158
12917	4214	2	2026-05-28 16:44:39.454	31	5	\N	234
12918	4215	0	2026-05-28 16:49:06.913	83	6	\N	146
12919	4215	1	2026-05-28 16:52:56.487	44	6	\N	220
12920	4215	2	2026-05-28 16:57:20.752	45	6	\N	109
12921	4216	0	2026-05-28 17:00:13.267	44	4	\N	201
12922	4216	1	2026-05-28 17:04:19.617	37	4	\N	104
12923	4216	2	2026-05-28 17:06:42.207	45	4	\N	221
12924	4217	0	2026-05-29 16:30:32.277	37	12	50	200
12925	4217	1	2026-05-29 16:34:30.722	45	12	50	183
12926	4217	2	2026-05-29 16:38:19.904	42	9	50	192
12927	4217	3	2026-05-29 16:42:15.181	55	10	50	191
12928	4218	0	2026-05-29 16:31:19.434	48	1	\N	190
12929	4218	1	2026-05-29 16:35:18.545	45	1	\N	186
12930	4218	2	2026-05-29 16:39:10.408	37	1	\N	9
12931	4218	3	2026-05-29 16:43:30.38	54	1	\N	439
12932	4219	0	2026-05-29 16:21:09.141	303	1	\N	1218
12933	4219	1	2026-05-29 16:46:33.878	302	1	\N	5
12934	4220	0	2026-05-30 15:30:01.304	39	6	\N	94
12935	4220	1	2026-05-30 15:32:15.645	36	6	\N	116
12936	4220	2	2026-05-30 15:34:48.811	50	6	\N	\N
12937	4221	0	2026-05-30 15:40:03.157	72	6	\N	95
12938	4221	1	2026-05-30 15:42:50.938	84	6	\N	240
12939	4221	2	2026-05-30 15:48:15.261	61	6	\N	5
12940	4221	3	2026-05-30 15:51:07.724	83	10	\N	86
12941	4222	0	2026-05-30 15:54:42.645	56	10	\N	122
12942	4222	1	2026-05-30 15:57:41.168	37	10	\N	122
12943	4222	2	2026-05-30 16:00:20.467	27	1	\N	\N
12944	4223	0	2026-05-30 15:55:40.188	157	10	\N	9
12945	4223	1	2026-05-30 15:58:27.204	26	10	\N	115
12946	4223	2	2026-05-30 16:00:49.966	22	10	\N	190
12947	4224	0	2026-05-30 15:17:11.611	318	1	\N	\N
12948	4224	1	2026-05-30 16:01:36.598	320	1	\N	\N
12949	4225	0	2026-06-01 16:29:38.185	47	15	\N	127
12950	4225	1	2026-06-01 16:32:32.671	54	15	\N	190
12951	4225	2	2026-06-01 16:36:37.371	53	15	\N	80
12952	4226	0	2026-06-01 16:39:32.709	61	8	\N	\N
12953	4226	1	2026-06-01 16:44:21.613	44	8	\N	220
12954	4226	2	2026-06-01 16:48:47.04	55	8	\N	3
12955	4227	0	2026-06-01 16:52:17.299	20	8	\N	276
12956	4227	1	2026-06-01 16:57:14.341	31	8	\N	268
12957	4227	2	2026-06-01 17:02:13.558	90	10	\N	\N
12958	4228	0	2026-06-01 16:52:39.934	63	1	\N	243
12959	4228	1	2026-06-01 16:57:47.018	62	1	\N	229
12960	4228	2	2026-06-01 17:02:38.949	64	1	\N	\N
12961	4229	0	2026-06-01 16:23:37.522	297	1	\N	608
12962	4230	0	2026-06-02 16:37:38.256	44	12	45	205
12963	4230	1	2026-06-02 16:41:47.847	45	12	45	245
12964	4230	2	2026-06-02 16:46:38.88	31	12	45	254
12965	4230	3	2026-06-02 16:51:25.515	39	12	45	260
12966	4231	0	2026-06-02 16:39:04.251	37	1	\N	131
12967	4231	1	2026-06-02 16:42:38.024	42	1	\N	232
12968	4231	2	2026-06-02 16:47:46.014	51	1	\N	2
12969	4231	3	2026-06-02 16:52:45.812	50	1	\N	168
12970	4232	0	2026-06-02 16:27:52.806	302	1	\N	280
12971	4232	1	2026-06-02 16:57:17.753	279	1	\N	12
12972	4233	0	2026-06-03 16:23:56.623	43	7	\N	116
12973	4233	1	2026-06-03 16:26:36.134	38	8	\N	120
12974	4233	2	2026-06-03 16:29:14.725	36	8	\N	131
12975	4234	0	2026-06-03 16:32:05.011	75	8	\N	175
12976	4234	1	2026-06-03 16:36:16.28	78	8	\N	150
12977	4234	2	2026-06-03 16:40:05.894	171	15	\N	2
12978	4235	0	2026-06-03 16:47:12.725	49	15	\N	226
12979	4235	1	2026-06-03 16:51:49.349	50	15	\N	220
12980	4235	2	2026-06-03 16:56:20.977	60	15	\N	90
12981	4236	0	2026-06-03 16:48:04.104	35	15	\N	241
12982	4236	1	2026-06-03 16:52:41.394	41	15	\N	239
12983	4236	2	2026-06-03 16:57:22.487	41	15	\N	49
12984	4237	0	2026-06-03 16:14:29.658	303	1	\N	1
12985	4237	1	2026-06-03 16:58:54.655	318	1	\N	\N
12986	4238	0	2026-06-04 16:37:02.768	48	15	\N	131
12987	4238	1	2026-06-04 16:40:03.226	57	15	\N	118
12988	4238	2	2026-06-04 16:42:59.089	57	15	\N	148
12989	4239	0	2026-06-04 16:46:26.539	47	8	\N	175
12990	4239	1	2026-06-04 16:50:08.686	47	8	\N	188
12991	4239	2	2026-06-04 16:54:04.701	58	8	\N	56
12992	4240	0	2026-06-04 16:47:15.63	41	6	\N	183
12993	4240	1	2026-06-04 16:51:01.388	49	6	\N	195
12994	4240	2	2026-06-04 16:55:06.718	49	6	\N	4
12995	4241	0	2026-06-04 16:59:07.499	43	6	\N	123
12996	4241	1	2026-06-04 17:01:54.459	40	6	\N	132
12997	4241	2	2026-06-04 17:04:46.955	39	6	\N	519
12998	4242	0	2026-06-04 17:07:28.761	43	4	\N	245
12999	4242	1	2026-06-04 17:12:17.383	43	4	\N	182
13000	4242	2	2026-06-04 17:16:04.816	0	4	\N	4
13001	4243	0	2026-06-04 16:31:10.976	318	1	\N	1438
13002	4244	0	2026-06-05 16:27:46.931	36	12	45	212
13003	4244	1	2026-06-05 16:31:56.688	43	11	45	2
13004	4244	2	2026-06-05 16:38:49.563	59	8	45	5
13005	4244	3	2026-06-05 16:46:06.762	38	12	45	\N
13006	4245	0	2026-06-05 16:28:40.885	45	1	\N	208
13007	4245	1	2026-06-05 16:32:55.776	62	1	\N	395
13008	4245	2	2026-06-05 16:40:33.306	58	1	\N	322
13009	4245	3	2026-06-05 16:47:17.401	51	1	\N	331
13010	4246	0	2026-06-05 16:19:18.269	303	1	\N	2
13011	4246	1	2026-06-05 16:52:03.236	301	1	\N	212
13012	4247	0	2026-06-06 16:35:22.445	34	10	\N	116
13013	4247	1	2026-06-06 16:37:53.876	43	9	\N	220
13014	4247	2	2026-06-06 16:42:18.406	63	7	\N	159
13015	4248	0	2026-06-06 16:46:04.952	91	10	\N	138
13016	4248	1	2026-06-06 16:49:55.757	86	10	\N	205
13017	4248	2	2026-06-06 16:54:47.994	17	10	\N	1
13018	4249	0	2026-06-06 17:08:59.607	24	10	\N	180
13019	4249	1	2026-06-06 17:12:24.734	43	1	\N	\N
13020	4250	0	2026-06-06 17:09:25.556	26	1	\N	\N
13021	4251	0	2026-06-06 16:27:34.266	309	1	\N	75
13022	4252	0	2026-06-08 18:14:21.676	60	15	\N	122
13023	4252	1	2026-06-08 18:17:24.308	76	15	\N	127
13024	4252	2	2026-06-08 18:20:48.199	73	9	\N	172
13025	4253	0	2026-06-08 18:24:55.304	87	8	\N	219
13113	4287	1	2026-07-14 01:29:09.703	37	8	8	141
13114	4287	2	2026-07-14 01:32:07.999	34	8	8	82
13115	4288	0	2026-07-14 01:26:58.636	30	8	8	138
13116	4288	1	2026-07-14 01:29:48.376	36	8	8	138
13117	4288	2	2026-07-14 01:32:43.686	76	8	8	5
13118	4289	0	2026-07-14 01:35:36.234	45	6	\N	61
13119	4289	1	2026-07-14 01:37:23.405	57	8	\N	62
13120	4289	2	2026-07-14 01:39:22.975	51	7	\N	12
13121	4290	0	2026-07-14 01:41:46.642	41	8	\N	87
13122	4290	1	2026-07-14 01:43:55.011	59	12	\N	76
13123	4290	2	2026-07-14 01:46:11.384	64	6	\N	137
13124	4291	0	2026-07-14 01:49:39.247	63	8	\N	142
13125	4291	1	2026-07-14 01:53:05.173	43	6	\N	\N
13126	4291	2	2026-07-14 01:55:37.119	42	4	\N	95
13127	4292	0	2026-07-14 01:58:40.231	48	6	\N	174
13128	4292	1	2026-07-14 02:02:23.867	56	5	\N	126
13129	4292	2	2026-07-14 02:05:27.004	45	2	\N	\N
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: calistia
--

COPY public.sessions (id, user_id, date, start_time, end_time, duration_seconds, notes, location_id, routine_id, title) FROM stdin;
2025-05-07T08:47:00Z	2	2025-05-07	2025-05-07 08:47:00	2025-05-07 09:18:08	1868	Quick session before work.	loc_demo_park	rt_demo_pull_day	Pull day
2025-05-09T08:46:00Z	2	2025-05-09	2025-05-09 08:46:00	2025-05-09 09:22:14	2174	Sleep was great, set a small PR.	\N	rt_demo_leg_day	Leg day
2025-05-10T08:51:00Z	2	2025-05-10	2025-05-10 08:51:00	2025-05-10 09:23:15	1935	Quick session before work.	\N	rt_demo_full_body	Full body
2025-05-14T18:33:00Z	2	2025-05-14	2025-05-14 18:33:00	2025-05-14 19:17:13	2653	Quick session before work.	\N	rt_demo_pull_day	Pull day
2025-05-17T08:48:00Z	2	2025-05-17	2025-05-17 08:48:00	2025-05-17 09:20:46	1966		loc_demo_park	rt_demo_full_body	Full body
2025-05-19T08:14:00Z	2	2025-05-19	2025-05-19 08:14:00	2025-05-19 08:50:07	2167	Felt strong today.	loc_demo_home	rt_demo_push_day	Push day
2025-05-21T08:28:00Z	2	2025-05-21	2025-05-21 08:28:00	2025-05-21 09:02:19	2059		\N	rt_demo_pull_day	Pull day
2025-05-23T08:38:00Z	2	2025-05-23	2025-05-23 08:38:00	2025-05-23 09:18:30	2430	Felt strong today.	loc_demo_park	rt_demo_leg_day	Leg day
2025-05-24T17:39:00Z	2	2025-05-24	2025-05-24 17:39:00	2025-05-24 18:07:57	1737		\N	rt_demo_full_body	Full body
2025-05-26T19:45:00Z	2	2025-05-26	2025-05-26 19:45:00	2025-05-26 20:20:52	2152	Sleep was great, set a small PR.	\N	rt_demo_push_day	Push day
2025-05-30T18:55:00Z	2	2025-05-30	2025-05-30 18:55:00	2025-05-30 19:28:42	2022	Felt strong today.	\N	rt_demo_leg_day	Leg day
2025-06-02T19:43:00Z	2	2025-06-02	2025-06-02 19:43:00	2025-06-02 20:25:48	2568		loc_demo_park	rt_demo_push_day	Push day
2025-06-04T19:21:00Z	2	2025-06-04	2025-06-04 19:21:00	2025-06-04 19:57:23	2183	Felt strong today.	loc_demo_park	rt_demo_pull_day	Pull day
2025-06-06T19:27:00Z	2	2025-06-06	2025-06-06 19:27:00	2025-06-06 19:58:07	1867		\N	rt_demo_leg_day	Leg day
2025-06-07T19:44:00Z	2	2025-06-07	2025-06-07 19:44:00	2025-06-07 20:17:56	2036	Felt strong today.	\N	rt_demo_full_body	Full body
2025-06-09T18:11:00Z	2	2025-06-09	2025-06-09 18:11:00	2025-06-09 18:47:35	2195	Felt strong today.	loc_demo_box	rt_demo_push_day	Push day
2025-06-11T09:19:00Z	2	2025-06-11	2025-06-11 09:19:00	2025-06-11 09:55:35	2195	Felt strong today.	\N	rt_demo_pull_day	Pull day
2025-06-13T19:17:00Z	2	2025-06-13	2025-06-13 19:17:00	2025-06-13 19:57:59	2459	Quick session before work.	loc_demo_park	rt_demo_leg_day	Leg day
2025-06-14T17:30:00Z	2	2025-06-14	2025-06-14 17:30:00	2025-06-14 17:55:04	1504		\N	rt_demo_full_body	Full body
2025-06-16T19:18:00Z	2	2025-06-16	2025-06-16 19:18:00	2025-06-16 19:55:47	2267		loc_demo_park	rt_demo_push_day	Push day
2025-06-18T19:03:00Z	2	2025-06-18	2025-06-18 19:03:00	2025-06-18 19:41:56	2336		loc_demo_home	rt_demo_pull_day	Pull day
2025-06-20T19:58:00Z	2	2025-06-20	2025-06-20 19:58:00	2025-06-20 20:40:02	2522	Quick session before work.	\N	rt_demo_leg_day	Leg day
2025-06-21T18:18:00Z	2	2025-06-21	2025-06-21 18:18:00	2025-06-21 18:47:43	1783		\N	rt_demo_full_body	Full body
2025-06-23T17:35:00Z	2	2025-06-23	2025-06-23 17:35:00	2025-06-23 18:14:37	2377	Felt strong today.	\N	rt_demo_push_day	Push day
2025-06-25T19:48:00Z	2	2025-06-25	2025-06-25 19:48:00	2025-06-25 20:25:25	2245		\N	rt_demo_pull_day	Pull day
2025-06-27T17:40:00Z	2	2025-06-27	2025-06-27 17:40:00	2025-06-27 18:16:07	2167		\N	rt_demo_leg_day	Leg day
2025-06-28T18:57:00Z	2	2025-06-28	2025-06-28 18:57:00	2025-06-28 19:28:41	1901	Quick session before work.	\N	rt_demo_full_body	Full body
2025-06-30T09:40:00Z	2	2025-06-30	2025-06-30 09:40:00	2025-06-30 10:17:51	2271	A bit tired, kept the volume.	\N	rt_demo_push_day	Push day
2025-07-02T08:29:00Z	2	2025-07-02	2025-07-02 08:29:00	2025-07-02 09:07:23	2303	Quick session before work.	loc_demo_box	rt_demo_pull_day	Pull day
2025-07-05T18:28:00Z	2	2025-07-05	2025-07-05 18:28:00	2025-07-05 18:57:21	1761	A bit tired, kept the volume.	loc_demo_box	rt_demo_full_body	Full body
2025-07-07T08:42:00Z	2	2025-07-07	2025-07-07 08:42:00	2025-07-07 09:21:23	2363		loc_demo_home	rt_demo_push_day	Push day
2025-07-11T19:35:00Z	2	2025-07-11	2025-07-11 19:35:00	2025-07-11 20:10:12	2112		loc_demo_box	rt_demo_leg_day	Leg day
2025-07-12T18:22:00Z	2	2025-07-12	2025-07-12 18:22:00	2025-07-12 18:52:44	1844		\N	rt_demo_full_body	Full body
2025-07-14T17:00:00Z	2	2025-07-14	2025-07-14 17:00:00	2025-07-14 17:34:12	2052	A bit tired, kept the volume.	loc_demo_park	rt_demo_push_day	Push day
2025-07-16T19:31:00Z	2	2025-07-16	2025-07-16 19:31:00	2025-07-16 20:06:44	2144		loc_demo_box	rt_demo_pull_day	Pull day
2025-07-18T17:05:00Z	2	2025-07-18	2025-07-18 17:05:00	2025-07-18 17:42:30	2250	Sleep was great, set a small PR.	loc_demo_home	rt_demo_leg_day	Leg day
2025-07-19T17:09:00Z	2	2025-07-19	2025-07-19 17:09:00	2025-07-19 17:38:54	1794	Sleep was great, set a small PR.	loc_demo_home	rt_demo_full_body	Full body
2025-07-21T18:06:00Z	2	2025-07-21	2025-07-21 18:06:00	2025-07-21 18:41:02	2102		loc_demo_box	rt_demo_push_day	Push day
2025-07-23T08:19:00Z	2	2025-07-23	2025-07-23 08:19:00	2025-07-23 08:56:51	2271		\N	rt_demo_pull_day	Pull day
2025-07-25T08:26:00Z	2	2025-07-25	2025-07-25 08:26:00	2025-07-25 09:04:05	2285	Quick session before work.	loc_demo_park	rt_demo_leg_day	Leg day
2025-07-26T09:52:00Z	2	2025-07-26	2025-07-26 09:52:00	2025-07-26 10:19:46	1666	Sleep was great, set a small PR.	loc_demo_box	rt_demo_full_body	Full body
2025-07-28T08:03:00Z	2	2025-07-28	2025-07-28 08:03:00	2025-07-28 08:46:43	2623	A bit tired, kept the volume.	\N	rt_demo_push_day	Push day
2025-07-30T17:08:00Z	2	2025-07-30	2025-07-30 17:08:00	2025-07-30 17:42:40	2080	Felt strong today.	loc_demo_box	rt_demo_pull_day	Pull day
2025-08-01T19:17:00Z	2	2025-08-01	2025-08-01 19:17:00	2025-08-01 19:51:10	2050		loc_demo_home	rt_demo_leg_day	Leg day
2025-08-04T17:23:00Z	2	2025-08-04	2025-08-04 17:23:00	2025-08-04 17:59:49	2209	Sleep was great, set a small PR.	\N	rt_demo_push_day	Push day
2025-08-06T08:35:00Z	2	2025-08-06	2025-08-06 08:35:00	2025-08-06 09:10:35	2135		loc_demo_box	rt_demo_pull_day	Pull day
2025-08-09T19:40:00Z	2	2025-08-09	2025-08-09 19:40:00	2025-08-09 20:12:56	1976		loc_demo_park	rt_demo_full_body	Full body
2025-08-11T19:21:00Z	2	2025-08-11	2025-08-11 19:21:00	2025-08-11 19:59:50	2330		\N	rt_demo_push_day	Push day
2025-08-13T17:15:00Z	2	2025-08-13	2025-08-13 17:15:00	2025-08-13 17:50:20	2120	Sleep was great, set a small PR.	loc_demo_home	rt_demo_pull_day	Pull day
2025-08-15T17:46:00Z	2	2025-08-15	2025-08-15 17:46:00	2025-08-15 18:24:41	2321	Quick session before work.	\N	rt_demo_leg_day	Leg day
2025-08-16T19:57:00Z	2	2025-08-16	2025-08-16 19:57:00	2025-08-16 20:36:51	2391		loc_demo_park	rt_demo_full_body	Full body
2025-08-20T08:12:00Z	2	2025-08-20	2025-08-20 08:12:00	2025-08-20 08:54:23	2543	Felt strong today.	\N	rt_demo_pull_day	Pull day
2025-08-22T17:18:00Z	2	2025-08-22	2025-08-22 17:18:00	2025-08-22 17:48:55	1855	Felt strong today.	\N	rt_demo_leg_day	Leg day
2025-08-23T09:26:00Z	2	2025-08-23	2025-08-23 09:26:00	2025-08-23 09:59:21	2001		\N	rt_demo_full_body	Full body
2025-08-25T09:51:00Z	2	2025-08-25	2025-08-25 09:51:00	2025-08-25 10:32:08	2468	Felt strong today.	loc_demo_box	rt_demo_push_day	Push day
2025-08-27T17:44:00Z	2	2025-08-27	2025-08-27 17:44:00	2025-08-27 18:22:57	2337	Felt strong today.	loc_demo_box	rt_demo_pull_day	Pull day
2025-08-29T18:08:00Z	2	2025-08-29	2025-08-29 18:08:00	2025-08-29 18:45:41	2261		\N	rt_demo_leg_day	Leg day
2025-09-01T19:08:00Z	2	2025-09-01	2025-09-01 19:08:00	2025-09-01 19:40:51	1971		loc_demo_park	rt_demo_push_day	Push day
2025-09-03T19:20:00Z	2	2025-09-03	2025-09-03 19:20:00	2025-09-03 19:58:48	2328		\N	rt_demo_pull_day	Pull day
2025-09-05T09:51:00Z	2	2025-09-05	2025-09-05 09:51:00	2025-09-05 10:28:22	2242	Sleep was great, set a small PR.	loc_demo_home	rt_demo_leg_day	Leg day
2025-09-06T09:25:00Z	2	2025-09-06	2025-09-06 09:25:00	2025-09-06 09:56:55	1915	A bit tired, kept the volume.	\N	rt_demo_full_body	Full body
2025-09-08T19:53:00Z	2	2025-09-08	2025-09-08 19:53:00	2025-09-08 20:38:00	2700	A bit tired, kept the volume.	\N	rt_demo_push_day	Push day
2025-09-12T08:01:00Z	2	2025-09-12	2025-09-12 08:01:00	2025-09-12 08:34:40	2020		loc_demo_box	rt_demo_leg_day	Leg day
2025-09-15T17:36:00Z	2	2025-09-15	2025-09-15 17:36:00	2025-09-15 18:14:13	2293		loc_demo_home	rt_demo_push_day	Push day
2025-09-17T19:38:00Z	2	2025-09-17	2025-09-17 19:38:00	2025-09-17 20:16:37	2317	Sleep was great, set a small PR.	loc_demo_box	rt_demo_pull_day	Pull day
2025-09-22T19:38:00Z	2	2025-09-22	2025-09-22 19:38:00	2025-09-22 20:12:26	2066		loc_demo_box	rt_demo_push_day	Push day
2025-09-26T19:24:00Z	2	2025-09-26	2025-09-26 19:24:00	2025-09-26 20:01:47	2267		loc_demo_box	rt_demo_leg_day	Leg day
2025-09-29T17:42:00Z	2	2025-09-29	2025-09-29 17:42:00	2025-09-29 18:18:07	2167	A bit tired, kept the volume.	\N	rt_demo_push_day	Push day
2025-10-01T18:29:00Z	2	2025-10-01	2025-10-01 18:29:00	2025-10-01 19:06:03	2223		\N	rt_demo_pull_day	Pull day
2025-10-03T09:11:00Z	2	2025-10-03	2025-10-03 09:11:00	2025-10-03 09:50:17	2357		\N	rt_demo_leg_day	Leg day
2025-10-04T09:20:00Z	2	2025-10-04	2025-10-04 09:20:00	2025-10-04 09:51:04	1864	Felt strong today.	loc_demo_park	rt_demo_full_body	Full body
2025-10-06T18:26:00Z	2	2025-10-06	2025-10-06 18:26:00	2025-10-06 19:06:25	2425		\N	rt_demo_push_day	Push day
2025-10-08T19:44:00Z	2	2025-10-08	2025-10-08 19:44:00	2025-10-08 20:25:26	2486	Quick session before work.	\N	rt_demo_pull_day	Pull day
2025-10-10T08:25:00Z	2	2025-10-10	2025-10-10 08:25:00	2025-10-10 08:57:50	1970		loc_demo_box	rt_demo_leg_day	Leg day
2025-10-11T09:56:00Z	2	2025-10-11	2025-10-11 09:56:00	2025-10-11 10:24:18	1698		loc_demo_box	rt_demo_full_body	Full body
2025-10-15T17:08:00Z	2	2025-10-15	2025-10-15 17:08:00	2025-10-15 17:54:13	2773	Sleep was great, set a small PR.	loc_demo_park	rt_demo_pull_day	Pull day
2025-10-18T08:50:00Z	2	2025-10-18	2025-10-18 08:50:00	2025-10-18 09:15:10	1510		loc_demo_park	rt_demo_full_body	Full body
2025-10-20T18:05:00Z	2	2025-10-20	2025-10-20 18:05:00	2025-10-20 18:45:06	2406		\N	rt_demo_push_day	Push day
2025-10-22T17:45:00Z	2	2025-10-22	2025-10-22 17:45:00	2025-10-22 18:21:38	2198		loc_demo_home	rt_demo_pull_day	Pull day
2025-10-24T19:43:00Z	2	2025-10-24	2025-10-24 19:43:00	2025-10-24 20:21:57	2337	Felt strong today.	loc_demo_park	rt_demo_leg_day	Leg day
2025-10-25T18:31:00Z	2	2025-10-25	2025-10-25 18:31:00	2025-10-25 19:03:02	1922	Felt strong today.	loc_demo_park	rt_demo_full_body	Full body
2025-10-27T09:08:00Z	2	2025-10-27	2025-10-27 09:08:00	2025-10-27 09:36:54	1734		\N	rt_demo_push_day	Push day
2025-11-01T08:00:00Z	2	2025-11-01	2025-11-01 08:00:00	2025-11-01 08:29:57	1797	Felt strong today.	loc_demo_park	rt_demo_full_body	Full body
2025-11-05T09:17:00Z	2	2025-11-05	2025-11-05 09:17:00	2025-11-05 09:54:00	2220	Quick session before work.	\N	rt_demo_pull_day	Pull day
2025-11-08T19:22:00Z	2	2025-11-08	2025-11-08 19:22:00	2025-11-08 19:52:11	1811		\N	rt_demo_full_body	Full body
2025-11-10T09:01:00Z	2	2025-11-10	2025-11-10 09:01:00	2025-11-10 09:37:09	2169		\N	rt_demo_push_day	Push day
2025-11-12T19:52:00Z	2	2025-11-12	2025-11-12 19:52:00	2025-11-12 20:28:27	2187	A bit tired, kept the volume.	\N	rt_demo_pull_day	Pull day
2025-11-15T18:10:00Z	2	2025-11-15	2025-11-15 18:10:00	2025-11-15 18:35:16	1516	Sleep was great, set a small PR.	\N	rt_demo_full_body	Full body
2025-11-19T09:03:00Z	2	2025-11-19	2025-11-19 09:03:00	2025-11-19 09:37:47	2087	Felt strong today.	loc_demo_box	rt_demo_pull_day	Pull day
2025-11-21T17:05:00Z	2	2025-11-21	2025-11-21 17:05:00	2025-11-21 17:44:37	2377		\N	rt_demo_leg_day	Leg day
2025-11-22T19:51:00Z	2	2025-11-22	2025-11-22 19:51:00	2025-11-22 20:22:01	1861		\N	rt_demo_full_body	Full body
2025-11-24T19:48:00Z	2	2025-11-24	2025-11-24 19:48:00	2025-11-24 20:26:36	2316	Felt strong today.	loc_demo_home	rt_demo_push_day	Push day
2025-11-26T18:49:00Z	2	2025-11-26	2025-11-26 18:49:00	2025-11-26 19:28:15	2355		loc_demo_box	rt_demo_pull_day	Pull day
2025-11-28T09:55:00Z	2	2025-11-28	2025-11-28 09:55:00	2025-11-28 10:35:00	2400	Sleep was great, set a small PR.	\N	rt_demo_leg_day	Leg day
2025-11-29T09:29:00Z	2	2025-11-29	2025-11-29 09:29:00	2025-11-29 10:01:38	1958	Quick session before work.	\N	rt_demo_full_body	Full body
2025-12-01T18:25:00Z	2	2025-12-01	2025-12-01 18:25:00	2025-12-01 19:12:04	2824	Sleep was great, set a small PR.	loc_demo_home	rt_demo_push_day	Push day
2025-12-03T09:32:00Z	2	2025-12-03	2025-12-03 09:32:00	2025-12-03 10:06:29	2069	Felt strong today.	\N	rt_demo_pull_day	Pull day
2025-12-05T18:00:00Z	2	2025-12-05	2025-12-05 18:00:00	2025-12-05 18:37:32	2252	Felt strong today.	\N	rt_demo_leg_day	Leg day
2025-12-06T09:13:00Z	2	2025-12-06	2025-12-06 09:13:00	2025-12-06 09:49:09	2169		loc_demo_home	rt_demo_full_body	Full body
2025-12-08T18:53:00Z	2	2025-12-08	2025-12-08 18:53:00	2025-12-08 19:30:21	2241	Felt strong today.	\N	rt_demo_push_day	Push day
2025-12-10T17:16:00Z	2	2025-12-10	2025-12-10 17:16:00	2025-12-10 17:54:12	2292	Sleep was great, set a small PR.	loc_demo_home	rt_demo_pull_day	Pull day
2025-12-13T18:51:00Z	2	2025-12-13	2025-12-13 18:51:00	2025-12-13 19:27:08	2168		\N	rt_demo_full_body	Full body
2025-12-15T19:54:00Z	2	2025-12-15	2025-12-15 19:54:00	2025-12-15 20:35:43	2503	Sleep was great, set a small PR.	\N	rt_demo_push_day	Push day
2025-12-17T17:23:00Z	2	2025-12-17	2025-12-17 17:23:00	2025-12-17 17:59:38	2198		loc_demo_home	rt_demo_pull_day	Pull day
2025-12-19T19:07:00Z	2	2025-12-19	2025-12-19 19:07:00	2025-12-19 19:49:09	2529		\N	rt_demo_leg_day	Leg day
2025-12-20T09:39:00Z	2	2025-12-20	2025-12-20 09:39:00	2025-12-20 10:08:37	1777		loc_demo_box	rt_demo_full_body	Full body
2025-12-22T17:13:00Z	2	2025-12-22	2025-12-22 17:13:00	2025-12-22 17:53:05	2405		\N	rt_demo_push_day	Push day
2025-12-24T17:08:00Z	2	2025-12-24	2025-12-24 17:08:00	2025-12-24 17:47:37	2377	A bit tired, kept the volume.	\N	rt_demo_pull_day	Pull day
2026-05-06T16:21:49.842Z	1	2026-05-06	2026-05-06 16:21:49.842	2026-05-06 16:53:02.757	1872		loc_moug854i_aitp	rt_cuyi_squat_l1	Squats Level 1
2026-05-07T16:13:24.136Z	1	2026-05-07	2026-05-07 16:13:24.136	2026-05-07 16:53:20.657	2396		loc_moug854i_aitp	rt_cuyi_push_l1	Push-ups Level 1
2026-05-08T16:15:23.955Z	1	2026-05-08	2026-05-08 16:15:23.955	2026-05-08 16:57:35.372	2531		loc_moug8aqx_qb92	rt_cuyi_pull_l1	Pull-ups Level 1
2026-05-09T16:16:50.919Z	1	2026-05-09	2026-05-09 16:16:50.919	2026-05-09 16:21:30.388	279		loc_moug854i_aitp	rt_cuyi_squat_l1	Squats Level 1
2026-05-11T16:28:02.992Z	1	2026-05-11	2026-05-11 16:28:02.992	2026-05-11 17:08:58.207	2455		loc_moug854i_aitp	rt_cuyi_push_l1	Push-ups Level 1
2026-05-12T15:16:12.252Z	1	2026-05-12	2026-05-12 15:16:12.252	2026-05-12 15:48:50.073	1957		loc_moug8aqx_qb92	rt_cuyi_pull_l1	Pull-ups Level 1
2026-05-13T16:31:24.573Z	1	2026-05-13	2026-05-13 16:31:24.573	2026-05-13 17:16:06.727	2682		loc_moug854i_aitp	rt_cuyi_squat_l2	Squats Level 2
2026-05-14T16:18:21.291Z	1	2026-05-14	2026-05-14 16:18:21.291	2026-05-14 16:56:25.592	2284		\N	rt_cuyi_push_l2	Push-ups Level 2
2026-05-18T16:33:30.887Z	1	2026-05-18	2026-05-18 16:33:30.887	2026-05-18 17:16:51.027	2600		loc_moug854i_aitp	rt_cuyi_push_l2	Push-ups Level 2
2026-05-19T16:19:21.255Z	1	2026-05-19	2026-05-19 16:19:21.255	2026-05-19 16:52:27.329	1986		loc_moug8aqx_qb92	rt_cuyi_pull_l1	Pull-ups Level 1
2026-05-20T16:23:01.321Z	1	2026-05-20	2026-05-20 16:23:01.321	2026-05-20 17:15:10.174	3128		loc_moug854i_aitp	rt_cuyi_squat_l2	Squats Level 2
2026-05-21T16:14:10.883Z	1	2026-05-21	2026-05-21 16:14:10.883	2026-05-21 16:52:05.267	2274		loc_moug854i_aitp	rt_cuyi_push_l2	Push-ups Level 2
2026-05-22T18:18:14.812Z	1	2026-05-22	2026-05-22 18:18:14.812	2026-05-22 18:49:45.928	1891		loc_moug8aqx_qb92	rt_cuyi_pull_l1	Pull-ups Level 1
2026-05-25T16:25:22.317Z	1	2026-05-25	2026-05-25 16:25:22.317	2026-05-25 17:01:33.203	2170		loc_moug854i_aitp	rt_cuyi_push_l2	Push-ups Level 2
2026-05-26T16:12:03.158Z	1	2026-05-26	2026-05-26 16:12:03.158	2026-05-26 16:52:12.975	2409		loc_moug8aqx_qb92	rt_cuyi_pull_l1	Pull-ups Level 1
2026-05-28T01:07:21.153Z	1	2026-05-28	2026-05-28 01:07:21.153	2026-05-28 01:56:34.088	2952		loc_moug854i_aitp	rt_cuyi_squat_l3	Squats Level 3
2026-05-28T16:13:41.156Z	1	2026-05-28	2026-05-28 16:13:41.156	2026-05-28 17:12:49.624	3548		loc_moug854i_aitp	rt_cuyi_push_l3	Push-ups Level 3
2026-05-29T16:21:06.809Z	1	2026-05-29	2026-05-29 16:21:06.809	2026-05-29 16:51:49.93	1843		loc_moug854i_aitp	rt_cuyi_pull_l1	Pull-ups Level 1
2026-05-30T15:17:00.374Z	1	2026-05-30	2026-05-30 15:17:00.374	2026-05-30 16:07:18.392	3018		loc_moug854i_aitp	rt_cuyi_squat_l3	Squats Level 3
2026-06-01T16:22:56.752Z	1	2026-06-01	2026-06-01 16:22:56.752	2026-06-01 17:04:52.495	2515		loc_moug854i_aitp	rt_cuyi_push_l2	Push-ups Level 2
2025-12-26T19:33:00Z	2	2025-12-26	2025-12-26 19:33:00	2025-12-26 20:13:52	2452	Sleep was great, set a small PR.	\N	rt_demo_leg_day	Leg day
2025-12-27T08:47:00Z	2	2025-12-27	2025-12-27 08:47:00	2025-12-27 09:19:35	1955		loc_demo_park	rt_demo_full_body	Full body
2025-12-29T17:48:00Z	2	2025-12-29	2025-12-29 17:48:00	2025-12-29 18:26:24	2304	Sleep was great, set a small PR.	\N	rt_demo_push_day	Push day
2025-12-31T08:54:00Z	2	2025-12-31	2025-12-31 08:54:00	2025-12-31 09:37:02	2582		\N	rt_demo_pull_day	Pull day
2026-01-02T17:49:00Z	2	2026-01-02	2026-01-02 17:49:00	2026-01-02 18:31:37	2557	Quick session before work.	\N	rt_demo_leg_day	Leg day
2026-01-05T08:42:00Z	2	2026-01-05	2026-01-05 08:42:00	2026-01-05 09:23:56	2516	A bit tired, kept the volume.	\N	rt_demo_push_day	Push day
2026-01-07T09:33:00Z	2	2026-01-07	2026-01-07 09:33:00	2026-01-07 10:10:41	2261	Sleep was great, set a small PR.	loc_demo_box	rt_demo_pull_day	Pull day
2026-01-09T09:03:00Z	2	2026-01-09	2026-01-09 09:03:00	2026-01-09 09:45:12	2532	A bit tired, kept the volume.	loc_demo_box	rt_demo_leg_day	Leg day
2026-01-12T19:38:00Z	2	2026-01-12	2026-01-12 19:38:00	2026-01-12 20:19:27	2487	Felt strong today.	\N	rt_demo_push_day	Push day
2026-01-16T17:26:00Z	2	2026-01-16	2026-01-16 17:26:00	2026-01-16 18:08:24	2544	Quick session before work.	loc_demo_home	rt_demo_leg_day	Leg day
2026-01-17T08:51:00Z	2	2026-01-17	2026-01-17 08:51:00	2026-01-17 09:26:24	2124	Felt strong today.	loc_demo_park	rt_demo_full_body	Full body
2026-01-23T18:22:00Z	2	2026-01-23	2026-01-23 18:22:00	2026-01-23 19:03:32	2492		\N	rt_demo_leg_day	Leg day
2026-01-24T19:55:00Z	2	2026-01-24	2026-01-24 19:55:00	2026-01-24 20:24:36	1776	Felt strong today.	\N	rt_demo_full_body	Full body
2026-01-26T17:13:00Z	2	2026-01-26	2026-01-26 17:13:00	2026-01-26 17:52:47	2387	A bit tired, kept the volume.	loc_demo_park	rt_demo_push_day	Push day
2026-01-28T19:29:00Z	2	2026-01-28	2026-01-28 19:29:00	2026-01-28 20:10:46	2506	Quick session before work.	loc_demo_home	rt_demo_pull_day	Pull day
2026-01-30T09:57:00Z	2	2026-01-30	2026-01-30 09:57:00	2026-01-30 10:40:39	2619		\N	rt_demo_leg_day	Leg day
2026-01-31T19:31:00Z	2	2026-01-31	2026-01-31 19:31:00	2026-01-31 20:06:45	2145		\N	rt_demo_full_body	Full body
2026-02-06T17:47:00Z	2	2026-02-06	2026-02-06 17:47:00	2026-02-06 18:26:28	2368		loc_demo_home	rt_demo_leg_day	Leg day
2026-02-07T19:19:00Z	2	2026-02-07	2026-02-07 19:19:00	2026-02-07 19:46:43	1663	Quick session before work.	\N	rt_demo_full_body	Full body
2026-02-09T18:25:00Z	2	2026-02-09	2026-02-09 18:25:00	2026-02-09 19:02:17	2237	A bit tired, kept the volume.	loc_demo_park	rt_demo_push_day	Push day
2026-02-14T18:19:00Z	2	2026-02-14	2026-02-14 18:19:00	2026-02-14 18:44:42	1542		\N	rt_demo_full_body	Full body
2026-02-16T17:59:00Z	2	2026-02-16	2026-02-16 17:59:00	2026-02-16 18:34:27	2127	Quick session before work.	loc_demo_park	rt_demo_push_day	Push day
2026-02-18T09:44:00Z	2	2026-02-18	2026-02-18 09:44:00	2026-02-18 10:23:26	2366		loc_demo_home	rt_demo_pull_day	Pull day
2026-02-21T18:46:00Z	2	2026-02-21	2026-02-21 18:46:00	2026-02-21 19:18:27	1947	A bit tired, kept the volume.	loc_demo_home	rt_demo_full_body	Full body
2026-02-23T18:42:00Z	2	2026-02-23	2026-02-23 18:42:00	2026-02-23 19:22:17	2417	Sleep was great, set a small PR.	\N	rt_demo_push_day	Push day
2026-02-25T18:47:00Z	2	2026-02-25	2026-02-25 18:47:00	2026-02-25 19:33:53	2813	Felt strong today.	\N	rt_demo_pull_day	Pull day
2026-02-27T17:58:00Z	2	2026-02-27	2026-02-27 17:58:00	2026-02-27 18:31:47	2027		\N	rt_demo_leg_day	Leg day
2026-06-02T16:27:50.084Z	1	2026-06-02	2026-06-02 16:27:50.084	2026-06-02 17:02:44.105	2094		loc_moug8aqx_qb92	rt_cuyi_pull_l1	Pull-ups Level 1
2026-06-03T16:14:15.660Z	1	2026-06-03	2026-06-03 16:14:15.66	2026-06-03 17:04:25.617	3009		loc_moug854i_aitp	rt_cuyi_squat_l3	Squats Level 3
2026-06-04T16:30:37.675Z	1	2026-06-04	2026-06-04 16:30:37.675	2026-06-04 17:16:45.888	2768		loc_moug854i_aitp	rt_cuyi_push_l3	Push-ups Level 3
2026-06-05T16:19:15.145Z	1	2026-06-05	2026-06-05 16:19:15.145	2026-06-05 17:01:47.813	2552		\N	rt_cuyi_pull_l1	Pull-ups Level 1
2026-06-06T16:27:21.439Z	1	2026-06-06	2026-06-06 16:27:21.439	2026-06-06 17:13:24.379	2762	Tuve que dejar wl ejercicio por sentirme mal	loc_moug854i_aitp	rt_cuyi_squat_l3	Squats Level 3
2026-06-08T18:06:28.356Z	1	2026-06-08	2026-06-08 18:06:28.356	2026-06-08 18:51:47.471	2719		loc_moug8aqx_qb92	rt_cuyi_push_l3	Push-ups Level 3
2026-06-09T16:16:35.866Z	1	2026-06-09	2026-06-09 16:16:35.866	2026-06-09 16:34:16.062	1060	Tuve que dejar wl ejercicio por ganas de vomitar	\N	rt_cuyi_pull_l1	Pull-ups Level 1
2026-06-16T17:19:26.989Z	1	2026-06-16	2026-06-16 17:19:26.989	2026-06-16 17:48:58.113	1771		\N	rt_cuyi_pull_l1	Pull-ups Level 1
2026-06-18T18:13:15.627Z	1	2026-06-18	2026-06-18 18:13:15.627	2026-06-18 18:52:39.532	2363		\N	rt_cuyi_push_l3	Push-ups Level 3
2026-02-28T19:59:00Z	2	2026-02-28	2026-02-28 19:59:00	2026-02-28 20:23:30	1470	Felt strong today.	\N	rt_demo_full_body	Full body
2026-03-02T17:05:00Z	2	2026-03-02	2026-03-02 17:05:00	2026-03-02 17:49:05	2645	Sleep was great, set a small PR.	\N	rt_demo_push_day	Push day
2026-03-04T09:48:00Z	2	2026-03-04	2026-03-04 09:48:00	2026-03-04 10:27:21	2361		loc_demo_home	rt_demo_pull_day	Pull day
2026-03-06T17:42:00Z	2	2026-03-06	2026-03-06 17:42:00	2026-03-06 18:17:29	2129		loc_demo_box	rt_demo_leg_day	Leg day
2026-03-07T17:14:00Z	2	2026-03-07	2026-03-07 17:14:00	2026-03-07 17:52:50	2330	A bit tired, kept the volume.	loc_demo_box	rt_demo_full_body	Full body
2026-03-09T08:11:00Z	2	2026-03-09	2026-03-09 08:11:00	2026-03-09 08:49:48	2328	Quick session before work.	loc_demo_park	rt_demo_push_day	Push day
2026-03-11T08:59:00Z	2	2026-03-11	2026-03-11 08:59:00	2026-03-11 09:45:28	2788	Quick session before work.	\N	rt_demo_pull_day	Pull day
2026-03-13T08:44:00Z	2	2026-03-13	2026-03-13 08:44:00	2026-03-13 09:22:55	2335		loc_demo_park	rt_demo_leg_day	Leg day
2026-03-14T09:10:00Z	2	2026-03-14	2026-03-14 09:10:00	2026-03-14 09:46:00	2160		loc_demo_park	rt_demo_full_body	Full body
2026-03-18T08:09:00Z	2	2026-03-18	2026-03-18 08:09:00	2026-03-18 08:51:12	2532		loc_demo_home	rt_demo_pull_day	Pull day
2026-03-20T19:05:00Z	2	2026-03-20	2026-03-20 19:05:00	2026-03-20 19:44:46	2386	Sleep was great, set a small PR.	\N	rt_demo_leg_day	Leg day
2026-03-21T08:07:00Z	2	2026-03-21	2026-03-21 08:07:00	2026-03-21 08:36:08	1748		loc_demo_box	rt_demo_full_body	Full body
2026-03-23T08:21:00Z	2	2026-03-23	2026-03-23 08:21:00	2026-03-23 08:59:18	2298	Sleep was great, set a small PR.	\N	rt_demo_push_day	Push day
2026-03-25T09:13:00Z	2	2026-03-25	2026-03-25 09:13:00	2026-03-25 09:43:25	1825		loc_demo_home	rt_demo_pull_day	Pull day
2026-03-28T19:20:00Z	2	2026-03-28	2026-03-28 19:20:00	2026-03-28 19:48:01	1681	Quick session before work.	loc_demo_park	rt_demo_full_body	Full body
2026-03-30T19:05:00Z	2	2026-03-30	2026-03-30 19:05:00	2026-03-30 19:36:30	1890		\N	rt_demo_push_day	Push day
2026-04-01T08:50:00Z	2	2026-04-01	2026-04-01 08:50:00	2026-04-01 09:32:30	2550	Quick session before work.	\N	rt_demo_pull_day	Pull day
2026-04-03T08:05:00Z	2	2026-04-03	2026-04-03 08:05:00	2026-04-03 08:41:40	2200	A bit tired, kept the volume.	loc_demo_park	rt_demo_leg_day	Leg day
2026-04-04T17:45:00Z	2	2026-04-04	2026-04-04 17:45:00	2026-04-04 18:09:31	1471	Sleep was great, set a small PR.	\N	rt_demo_full_body	Full body
2026-04-06T18:35:00Z	2	2026-04-06	2026-04-06 18:35:00	2026-04-06 19:13:07	2287		\N	rt_demo_push_day	Push day
2026-04-08T19:19:00Z	2	2026-04-08	2026-04-08 19:19:00	2026-04-08 19:56:59	2279		loc_demo_home	rt_demo_pull_day	Pull day
2026-04-11T09:42:00Z	2	2026-04-11	2026-04-11 09:42:00	2026-04-11 10:06:32	1472	Sleep was great, set a small PR.	loc_demo_box	rt_demo_full_body	Full body
2026-04-13T19:14:00Z	2	2026-04-13	2026-04-13 19:14:00	2026-04-13 19:54:55	2455	Sleep was great, set a small PR.	\N	rt_demo_push_day	Push day
2026-04-15T18:22:00Z	2	2026-04-15	2026-04-15 18:22:00	2026-04-15 19:02:59	2459	A bit tired, kept the volume.	loc_demo_box	rt_demo_pull_day	Pull day
2026-04-17T17:11:00Z	2	2026-04-17	2026-04-17 17:11:00	2026-04-17 17:50:40	2380	Sleep was great, set a small PR.	loc_demo_home	rt_demo_leg_day	Leg day
2026-04-18T08:24:00Z	2	2026-04-18	2026-04-18 08:24:00	2026-04-18 08:50:54	1614		\N	rt_demo_full_body	Full body
2026-04-20T08:50:00Z	2	2026-04-20	2026-04-20 08:50:00	2026-04-20 09:28:09	2289		loc_demo_box	rt_demo_push_day	Push day
2026-04-22T19:14:00Z	2	2026-04-22	2026-04-22 19:14:00	2026-04-22 19:48:10	2050	Felt strong today.	loc_demo_park	rt_demo_pull_day	Pull day
2026-04-24T17:26:00Z	2	2026-04-24	2026-04-24 17:26:00	2026-04-24 18:05:40	2380		\N	rt_demo_leg_day	Leg day
2026-04-25T09:42:00Z	2	2026-04-25	2026-04-25 09:42:00	2026-04-25 10:12:14	1814	Felt strong today.	loc_demo_home	rt_demo_full_body	Full body
2026-04-27T08:30:00Z	2	2026-04-27	2026-04-27 08:30:00	2026-04-27 09:03:29	2009		\N	rt_demo_push_day	Push day
2026-05-01T18:55:00Z	2	2026-05-01	2026-05-01 18:55:00	2026-05-01 19:35:10	2410	A bit tired, kept the volume.	\N	rt_demo_leg_day	Leg day
2026-05-02T19:47:00Z	2	2026-05-02	2026-05-02 19:47:00	2026-05-02 20:15:59	1739		loc_demo_home	rt_demo_full_body	Full body
2026-05-04T09:41:00Z	2	2026-05-04	2026-05-04 09:41:00	2026-05-04 10:20:26	2366		loc_demo_home	rt_demo_push_day	Push day
2026-06-19T16:21:01.333Z	1	2026-06-19	2026-06-19 16:21:01.333	2026-06-19 17:00:44.638	2383		\N	rt_cuyi_squat_l3	Squats Level 3
2026-06-30T16:13:50.668Z	1	2026-06-30	2026-06-30 16:13:50.668	2026-06-30 17:04:47.073	3056		\N	rt_cuyi_squat_l3	Squats Level 3
2026-07-11T15:05:43.256Z	1	2026-07-11	2026-07-11 15:05:43.256	2026-07-11 15:43:41.649	2278		\N	rt_cuyi_pull_l2	Pull-ups Level 2
2026-07-14T01:06:43.231Z	1	2026-07-13	2026-07-14 01:06:43.231	2026-07-14 02:06:47.754	3604		\N	rt_cuyi_squat_l3	Squats Level 3
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: calistia
--

COPY public.users (id, username, password, token) FROM stdin;
1	cuyi	MiAppGymUwU	12-SF8hkrpAjCROO6L_V0y70b9831Wce
2	demo	1234	Qpbjb-gOZCMTF5VAlIqT62XYF07suv_p
\.


--
-- Name: exercises_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calistia
--

SELECT pg_catalog.setval('public.exercises_id_seq', 31, true);


--
-- Name: photos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calistia
--

SELECT pg_catalog.setval('public.photos_id_seq', 792, true);


--
-- Name: routine_exercises_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calistia
--

SELECT pg_catalog.setval('public.routine_exercises_id_seq', 5637, true);


--
-- Name: session_exercises_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calistia
--

SELECT pg_catalog.setval('public.session_exercises_id_seq', 4292, true);


--
-- Name: session_sets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calistia
--

SELECT pg_catalog.setval('public.session_sets_id_seq', 13129, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: calistia
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: exercises exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: photos photos_pkey; Type: CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_pkey PRIMARY KEY (id);


--
-- Name: routine_exercises routine_exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.routine_exercises
    ADD CONSTRAINT routine_exercises_pkey PRIMARY KEY (id);


--
-- Name: routines routines_pkey; Type: CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.routines
    ADD CONSTRAINT routines_pkey PRIMARY KEY (id);


--
-- Name: session_exercises session_exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.session_exercises
    ADD CONSTRAINT session_exercises_pkey PRIMARY KEY (id);


--
-- Name: session_sets session_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.session_sets
    ADD CONSTRAINT session_sets_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_exercises_name; Type: INDEX; Schema: public; Owner: calistia
--

CREATE UNIQUE INDEX ix_exercises_name ON public.exercises USING btree (name);


--
-- Name: ix_locations_user_id; Type: INDEX; Schema: public; Owner: calistia
--

CREATE INDEX ix_locations_user_id ON public.locations USING btree (user_id);


--
-- Name: ix_photos_session_id; Type: INDEX; Schema: public; Owner: calistia
--

CREATE INDEX ix_photos_session_id ON public.photos USING btree (session_id);


--
-- Name: ix_routine_exercises_routine_id; Type: INDEX; Schema: public; Owner: calistia
--

CREATE INDEX ix_routine_exercises_routine_id ON public.routine_exercises USING btree (routine_id);


--
-- Name: ix_routines_user_id; Type: INDEX; Schema: public; Owner: calistia
--

CREATE INDEX ix_routines_user_id ON public.routines USING btree (user_id);


--
-- Name: ix_session_exercises_session_id; Type: INDEX; Schema: public; Owner: calistia
--

CREATE INDEX ix_session_exercises_session_id ON public.session_exercises USING btree (session_id);


--
-- Name: ix_session_sets_session_exercise_id; Type: INDEX; Schema: public; Owner: calistia
--

CREATE INDEX ix_session_sets_session_exercise_id ON public.session_sets USING btree (session_exercise_id);


--
-- Name: ix_sessions_date; Type: INDEX; Schema: public; Owner: calistia
--

CREATE INDEX ix_sessions_date ON public.sessions USING btree (date);


--
-- Name: ix_sessions_user_id; Type: INDEX; Schema: public; Owner: calistia
--

CREATE INDEX ix_sessions_user_id ON public.sessions USING btree (user_id);


--
-- Name: ix_users_token; Type: INDEX; Schema: public; Owner: calistia
--

CREATE UNIQUE INDEX ix_users_token ON public.users USING btree (token);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: calistia
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: locations locations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: photos photos_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON DELETE CASCADE;


--
-- Name: routine_exercises routine_exercises_routine_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.routine_exercises
    ADD CONSTRAINT routine_exercises_routine_id_fkey FOREIGN KEY (routine_id) REFERENCES public.routines(id) ON DELETE CASCADE;


--
-- Name: routines routines_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.routines
    ADD CONSTRAINT routines_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: session_exercises session_exercises_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.session_exercises
    ADD CONSTRAINT session_exercises_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON DELETE CASCADE;


--
-- Name: session_sets session_sets_session_exercise_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.session_sets
    ADD CONSTRAINT session_sets_session_exercise_id_fkey FOREIGN KEY (session_exercise_id) REFERENCES public.session_exercises(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE SET NULL;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: calistia
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict h04CtFecfqRzZI2pwBr6vwDpW2nTCNNQfFngI02Px8VwSKpDkjOWL2JRPyz89pS

