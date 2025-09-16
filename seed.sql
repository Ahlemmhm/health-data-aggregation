-- seed.sql
WITH params AS (
  SELECT now() AS now_ts, (now() - interval '24 hours') AS start_ts,
         ARRAY['Ahlem','Maya','Lotfi','Mohamed','Chahd']::text[] AS users
),
minutes AS (
  SELECT generate_series((SELECT start_ts FROM params),(SELECT now_ts FROM params), interval '1 minute') AS ts
),
blackouts AS (
  SELECT u AS user_id, tstzrange(lower, upper, '[)') AS win
  FROM (VALUES
    ('U001', date_trunc('day', now()) + interval '03:00', date_trunc('day', now()) + interval '03:30'),
    ('U002', date_trunc('day', now()) + interval '11:00', date_trunc('day', now()) + interval '11:30'),
    ('U003', date_trunc('day', now()) + interval '17:30', date_trunc('day', now()) + interval '18:00'),
    ('U004', date_trunc('day', now()) + interval '07:45', date_trunc('day', now()) + interval '08:00'),
    ('U005', date_trunc('day', now()) + interval '22:00', date_trunc('day', now()) + interval '23:00')
  ) b(u, lower, upper)
),
expanded AS (
  SELECT u.user_id, m.ts::timestamp AS ts
  FROM (SELECT unnest(users) AS user_id FROM params) u
  CROSS JOIN minutes m
  WHERE NOT EXISTS (SELECT 1 FROM blackouts b WHERE b.user_id=u.user_id AND m.ts>=lower(b.win) AND m.ts<upper(b.win))
),
to_insert AS (
  SELECT user_id, ts AS "timestamp",
         CASE WHEN random() < 0.02 THEN NULL ELSE (60 + (random()*50)::int + CASE WHEN extract(hour from ts) BETWEEN 7 AND 21 THEN (random()*10)::int ELSE 0 END) END AS heart_rate,
         CASE WHEN random() < 0.02 THEN NULL ELSE GREATEST(50, (60 + (random()*30)::int)) END AS heart_rate_min,
         CASE WHEN random() < 0.02 THEN NULL ELSE LEAST(140, (90 + (random()*40)::int)) END AS heart_rate_max,
         CASE WHEN random() < 0.03 THEN NULL ELSE round((20 + random()*50)::numeric, 1) END AS heart_rate_variability,
         CASE WHEN random() < 0.03 THEN NULL ELSE round((12 + random()*8)::numeric, 1) END AS respiratory_rate,
         CASE WHEN random() < 0.05 THEN NULL ELSE CASE WHEN extract(hour from ts) BETWEEN 7 AND 21 THEN (random()*25)::int ELSE (random()*3)::int END END AS steps,
         CASE WHEN random() < 0.05 THEN NULL ELSE round((random()*5)::numeric, 2) END AS activity_energy,
         CASE WHEN random() < 0.05 THEN NULL ELSE round((1 + random()*2)::numeric, 2) END AS basal_energy,
         CASE WHEN random() < 0.05 THEN NULL ELSE round((CASE WHEN extract(hour from ts) BETWEEN 7 AND 21 THEN random()*25 ELSE random()*5 END)::numeric, 2) END AS distance,
         CASE WHEN random() < 0.98 THEN NULL ELSE (random()*2)::int END AS flights_climbed,
         CASE WHEN random() < 0.95 THEN NULL ELSE (random()*2)::int END AS exercise_minutes,
         CASE WHEN random() < 0.98 THEN NULL ELSE (random()*1)::int END AS stand_hours,
         CASE WHEN random() < 0.99 THEN NULL ELSE (random()*1)::int END AS workout_count,
         CASE WHEN random() < 0.05 THEN NULL ELSE round((65 + random()*20)::numeric, 1) END AS walking_heart_rate_avg,
         CASE WHEN random() < 0.99 THEN NULL ELSE round((random()*0.5)::numeric, 2) END AS cycling_distance
  FROM expanded
)
INSERT INTO public.health_data (
  user_id, "timestamp", heart_rate, heart_rate_min, heart_rate_max, heart_rate_variability,
  respiratory_rate, steps, activity_energy, basal_energy, distance, flights_climbed,
  exercise_minutes, stand_hours, workout_count, walking_heart_rate_avg, cycling_distance
) SELECT * FROM to_insert ORDER BY user_id, "timestamp";
