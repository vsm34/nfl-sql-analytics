-- analysis/queries/demo.sql
-- Example: per-team points for a given season, sorted desc
WITH season_games AS (
  SELECT g.game_id
  FROM games g
  JOIN seasons s ON s.season_id = g.season_id
  WHERE s.year = 2023
)
SELECT t.team_abbr,
       SUM(gt.points) AS total_points
FROM game_teams gt
JOIN season_games sg ON sg.game_id = gt.game_id
JOIN teams t ON t.team_id = gt.team_id
GROUP BY t.team_abbr
ORDER BY total_points DESC;
