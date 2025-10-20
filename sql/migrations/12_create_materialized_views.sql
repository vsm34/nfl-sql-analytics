-- 12_create_materialized_views.sql
-- Create MVs and unique indexes (so we can REFRESH CONCURRENTLY)

-- 1) EPA per play by team
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_epa_per_play AS
SELECT
  t.team_abbr,
  ROUND(AVG(p.epa)::numeric, 3) AS epa_per_play,
  COUNT(*) AS plays_with_epa
FROM plays p
JOIN teams t ON t.team_id = p.offense_team_id
WHERE p.epa IS NOT NULL
GROUP BY t.team_abbr;

-- unique index required for REFRESH CONCURRENTLY
CREATE UNIQUE INDEX IF NOT EXISTS ux_mv_epa_per_play
ON mv_epa_per_play(team_abbr);

-- 2) Conversion rate by down (1–4)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_conversion_by_down AS
SELECT
  t.team_abbr,
  p.down,
  COUNT(*) AS plays,
  SUM((p.success)::int) AS conversions,
  ROUND(AVG((p.success)::int)::numeric, 3) AS conversion_rate
FROM plays p
JOIN teams t ON t.team_id = p.offense_team_id
WHERE p.down IN (1,2,3,4)
GROUP BY t.team_abbr, p.down;

CREATE UNIQUE INDEX IF NOT EXISTS ux_mv_conversion_by_down
ON mv_conversion_by_down(team_abbr, down);
