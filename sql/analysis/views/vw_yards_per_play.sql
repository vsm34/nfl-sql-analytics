CREATE OR REPLACE VIEW vw_yards_per_play AS
SELECT
  t.team_abbr,
  ROUND(AVG(p.yards_gained)::numeric, 3) AS ypp,
  COUNT(*) AS plays
FROM plays p
JOIN teams t ON t.team_id = p.offense_team_id
GROUP BY t.team_abbr;
