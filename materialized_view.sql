-- materialized_view.sql
DROP MATERIALIZED VIEW IF EXISTS public.mv_health_30m;
CREATE MATERIALIZED VIEW public.mv_health_30m AS
WITH agg AS (
  SELECT user_id,
         (date_trunc('hour',"timestamp") + make_interval(mins := (extract(minute from "timestamp")::int/30)*30)) AS bucket_30m,
         COUNT(*) AS samples,
         ROUND(AVG(heart_rate)::numeric,1) AS heart_rate_avg,
         MIN(heart_rate_min) AS heart_rate_min,
         MAX(heart_rate_max) AS heart_rate_max,
         SUM(steps) AS steps_sum,
         ROUND(AVG(respiratory_rate)::numeric,1) AS respiratory_rate_avg,
         ROUND(SUM(activity_energy)::numeric,2) AS activity_energy_sum,
         ROUND(SUM(distance)::numeric,2) AS distance_sum
  FROM public.health_data GROUP BY user_id, bucket_30m
)
SELECT * FROM agg WITH NO DATA;
CREATE UNIQUE INDEX IF NOT EXISTS mv_health_30m_uid_time ON public.mv_health_30m (user_id, bucket_30m);
-- REFRESH MATERIALIZED VIEW public.mv_health_30m;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY public.mv_health_30m;
