CREATE OR REPLACE VIEW public.vw_team_third_down AS
WITH base AS (
  SELECT
    p.offense_team_id,
    (p.down = 3) AS third_down,
    (p.down = 3 AND p.third_down_success) AS third_down_success
  FROM plays p
)
, agg AS (
  SELECT
    offense_team_id,
    COUNT(*) FILTER (WHERE third_down)         AS attempts_3rd,
    COUNT(*) FILTER (WHERE third_down_success) AS conversions_3rd
  FROM base
  GROUP BY offense_team_id
)
SELECT
  t.team_abbr,
  a.attempts_3rd,
  a.conversions_3rd,
  ROUND( (a.conversions_3rd::numeric / NULLIF(a.attempts_3rd,0)), 3 ) AS third_down_rate
FROM agg a
JOIN teams t ON t.team_id = a.offense_team_id
ORDER BY third_down_rate DESC NULLS LAST;
