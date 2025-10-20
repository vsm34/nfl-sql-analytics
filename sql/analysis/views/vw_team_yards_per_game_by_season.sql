CREATE OR REPLACE VIEW public.vw_team_yards_per_game_by_season AS
WITH plays_season AS (
  SELECT
    p.offense_team_id,
    g.season_id,
    SUM(p.yards_gained) FILTER (WHERE p.play_type IN ('run','rush','pass')) AS scrimmage_yards
  FROM plays p
  JOIN games g ON g.game_id = p.game_id
  GROUP BY p.offense_team_id, g.season_id
),
games_season AS (
  SELECT team_id, season_id, COUNT(DISTINCT game_id) AS games
  FROM (
    SELECT p.offense_team_id AS team_id, g.season_id, p.game_id
    FROM plays p JOIN games g ON g.game_id = p.game_id
    UNION
    SELECT p.defense_team_id AS team_id, g.season_id, p.game_id
    FROM plays p JOIN games g ON g.game_id = p.game_id
  ) x
  GROUP BY team_id, season_id
)
SELECT
  t.team_abbr,
  s.year AS season,
  ROUND( (ps.scrimmage_yards::numeric / NULLIF(gs.games,0)), 1 ) AS yards_per_game,
  gs.games
FROM plays_season ps
JOIN games_season gs ON gs.team_id = ps.offense_team_id AND gs.season_id = ps.season_id
JOIN teams t   ON t.team_id = ps.offense_team_id
JOIN seasons s ON s.season_id = ps.season_id
ORDER BY season DESC, yards_per_game DESC;
