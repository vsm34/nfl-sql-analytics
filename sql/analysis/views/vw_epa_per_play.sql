CREATE OR REPLACE VIEW vw_epa_per_play AS
SELECT
  t.team_abbr,
  ROUND(AVG(p.epa)::numeric, 3) AS epa_per_play,
  COUNT(*) AS plays_with_epa
FROM plays p
JOIN teams t ON t.team_id = p.offense_team_id
WHERE p.epa IS NOT NULL
GROUP BY t.team_abbr
ORDER BY epa_per_play DESC;
