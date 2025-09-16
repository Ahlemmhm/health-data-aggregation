# Health Data Aggregation & Analytics (PostgreSQL + pgAdmin 4)

This repository simulates health data (Apple HealthKit type), stores it in PostgreSQL and produces aggregations in **15 min** and **30 min* slices* (with *gaps*).

## Prerequisites
- PostgreSQL 17 + pgAdmin 4
- Base `health`

## Steps (pgAdmin 4)
1.Schema: run schema.sql in the health database.

2.Seed (24h, 5 users): run seed.sql.

3.Rollup 15 min: run rollup_15m.sql → export the result as CSV health_15m_last24h.csv.

4.Rollup 30 min (gaps): run rollup_30m.sql → export the result as CSV health_30m_last24h.csv.

5.(Bonus) 30m MV: run materialized_view.sql, then:
   ```sql
   REFRESH MATERIALIZED VIEW public.mv_health_30m;
 

## Verifications
```sql
SELECT COUNT(*) FROM public.health_data;
SELECT COUNT(DISTINCT user_id) FROM public.health_data;
SELECT MIN("timestamp"), MAX("timestamp") FROM public.health_data;
```

## Git Publication 
```bash
git init
git add .
git commit -m "Health data aggregation: schema, seed, rollups, MV, README"
git branch -M main
git remote add origin https://github.com/<>/<>.git
git push -u origin main
```
