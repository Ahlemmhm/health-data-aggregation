-- rollup_30m.sql
WITH params AS (
  SELECT now() AS now_ts, now() - interval '24 hours' AS start_ts
),
users AS (SELECT DISTINCT user_id FROM public.health_data),
series AS (
  SELECT generate_series(date_trunc('hour',(SELECT start_ts FROM params)),
                         date_trunc('hour',(SELECT now_ts FROM params)),
                         interval '30 minutes') AS bucket_start
),
raw AS (
  SELECT * FROM public.health_data h
  WHERE h."timestamp" >= (SELECT start_ts FROM params) AND h."timestamp" < (SELECT now_ts FROM params)
),
agg AS (
  SELECT user_id,
         (date_trunc('hour',"timestamp") + make_interval(mins := (extract(minute from "timestamp")::int/30)*30)) AS bucket_start,
         COUNT(*) AS samples,
         round(AVG(heart_rate)::numeric,1) AS heart_rate_avg,
         MIN(heart_rate_min) AS heart_rate_min,
         MAX(heart_rate_max) AS heart_rate_max,
         SUM(steps) AS steps_sum,
         round(AVG(respiratory_rate)::numeric,1) AS respiratory_rate_avg,
         round(SUM(activity_energy)::numeric,2) AS activity_energy_sum,
         round(SUM(distance)::numeric,2) AS distance_sum
  FROM raw GROUP BY user_id, bucket_start
)
SELECT u.user_id, s.bucket_start, COALESCE(a.samples,0) AS samples,
       a.heart_rate_avg, a.heart_rate_min, a.heart_rate_max,
       a.steps_sum, a.respiratory_rate_avg, a.activity_energy_sum, a.distance_sum
FROM users u CROSS JOIN series s
LEFT JOIN agg a ON a.user_id=u.user_id AND a.bucket_start=s.bucket_start
ORDER BY u.user_id, s.bucket_start;
