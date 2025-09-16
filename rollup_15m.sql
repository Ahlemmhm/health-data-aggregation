-- rollup_15m.sql
WITH buckets AS (
  SELECT user_id,
         (date_trunc('hour', "timestamp") + make_interval(mins := (extract(minute from "timestamp")::int/15)*15)) AS bucket_start,
         heart_rate, heart_rate_min, heart_rate_max, respiratory_rate, steps, activity_energy, distance
  FROM public.health_data
  WHERE "timestamp" >= now() - interval '24 hours'
)
SELECT user_id, bucket_start, COUNT(*) AS samples,
       round(AVG(heart_rate)::numeric,1) AS heart_rate_avg,
       MIN(heart_rate_min) AS heart_rate_min,
       MAX(heart_rate_max) AS heart_rate_max,
       SUM(steps) AS steps_sum,
       round(AVG(respiratory_rate)::numeric,1) AS respiratory_rate_avg,
       round(SUM(activity_energy)::numeric,2) AS activity_energy_sum,
       round(SUM(distance)::numeric,2) AS distance_sum
FROM buckets
GROUP BY user_id, bucket_start
ORDER BY user_id, bucket_start;
