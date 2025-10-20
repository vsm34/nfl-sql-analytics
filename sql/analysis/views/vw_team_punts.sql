-- Punts per game + per season by offense team
CREATE OR REPLACE VIEW public.vw_team_punts AS
WITH season_map AS (
  SELECT g.game_id, s.year
  FROM games g
  JOIN seasons s ON s.season_id = g.season_id
),
per_game AS (
  SELECT p.offense_team_id, p.game_id,
         SUM( (p.punt IS TRUE)::int ) AS punts
  FROM plays p
  GROUP BY p.offense_team_id, p.game_id
),
per_season AS (
  SELECT g.offense_team_id, sm.year,
         SUM(g.punts)                          AS punts_in_season,
         COUNT(*)                              AS games_in_season
  FROM per_game g
  JOIN season_map sm ON sm.game_id = g.game_id
  GROUP BY g.offense_team_id, sm.year
)
SELECT
  t.team_abbr,
  ps.year,
  ps.punts_in_season,
  ps.games_in_season,
  ROUND( (ps.punts_in_season::numeric / NULLIF(ps.games_in_season,0)), 2) AS punts_per_game
FROM per_season ps
JOIN teams t ON t.team_id = ps.offense_team_id
ORDER BY ps.year DESC, punts_per_game DESC;
