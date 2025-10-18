CREATE OR REPLACE VIEW vw_turnover_rate AS
SELECT
  t.team_abbr,
  ROUND(AVG(CASE WHEN p.turnover THEN 1 ELSE 0 END)::numeric, 3) AS turnover_rate,
  COUNT(*) AS plays
FROM plays p
JOIN teams t ON t.team_id = p.offense_team_id
GROUP BY t.team_abbr;
