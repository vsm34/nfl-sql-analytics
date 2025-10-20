-- 13_refresh_materialized_views.sql
-- Safe to run anytime after ETL metrics are updated
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_epa_per_play;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_conversion_by_down;
