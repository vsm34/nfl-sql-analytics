-- Conversion rate by down (offense perspective).
-- Uses p.success (true if the play achieved a conversion per your ETL rule).
CREATE OR REPLACE VIEW public.vw_conversion_by_down AS
SELECT
  t.team_abbr,
  p.down,
  COUNT(*) AS plays,
  COUNT(*) FILTER (WHERE p.success) AS conversions,
  ROUND(AVG((p.success)::int)::numeric, 3) AS conversion_rate
FROM plays p
JOIN teams t ON t.team_id = p.offense_team_id
WHERE p.down BETWEEN 1 AND 4
GROUP BY t.team_abbr, p.down
ORDER BY t.team_abbr, p.down;
