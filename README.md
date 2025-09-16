# Health Data Aggregation & Analytics (PostgreSQL + pgAdmin 4)

Ce dépôt simule des données santé (type Apple HealthKit), les stocke dans PostgreSQL et produit des agrégations en tranches **15 min** et **30 min** (avec *gaps*).

## Prérequis
- PostgreSQL 17 + pgAdmin 4
- Base `health`

## Étapes (pgAdmin 4)
1. **Schéma** : exécuter `schema.sql` dans `health`.
2. **Seed (24h, 5 users)** : exécuter `seed.sql`.
3. **Rollup 15 min** : exécuter `rollup_15m.sql` → exporter CSV `health_15m_last24h.csv`.
4. **Rollup 30 min (gaps)** : exécuter `rollup_30m.sql` → exporter CSV `health_30m_last24h.csv`.
5. **(Bonus) MV 30m** : exécuter `materialized_view.sql`, puis:
   ```sql
   REFRESH MATERIALIZED VIEW public.mv_health_30m;
   -- ou
   REFRESH MATERIALIZED VIEW CONCURRENTLY public.mv_health_30m;
   ```

## Vérifications
```sql
SELECT COUNT(*) FROM public.health_data;
SELECT COUNT(DISTINCT user_id) FROM public.health_data;
SELECT MIN("timestamp"), MAX("timestamp") FROM public.health_data;
```

## Publication Git (exemple)
```bash
git init
git add .
git commit -m "Health data aggregation: schema, seed, rollups, MV, README"
git branch -M main
git remote add origin https://github.com/<votre_user>/<votre_repo>.git
git push -u origin main
```
