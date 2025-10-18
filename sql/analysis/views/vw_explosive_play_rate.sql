-- Explosive play rate (share of plays marked explosive).
-- Your ETL flags p.explosive using yard thresholds.
CREATE OR REPLACE VIEW public.vw_explosive_play_rate AS
SELECT
  t.team_abbr,
  ROUND(AVG((p.explosive)::int)::numeric, 3) AS explosive_rate,
  COUNT(*) AS plays
FROM plays p
JOIN teams t ON t.team_id = p.offense_team_id
GROUP BY t.team_abbr
ORDER BY explosive_rate DESC, plays DESC;
