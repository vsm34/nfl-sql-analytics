-- Penalty yards committed by the OFFENSE per game.
-- (Defensive splits require us to store who the penalty was on; we can add that later.)
CREATE OR REPLACE VIEW public.vw_penalty_yards_per_game AS
WITH game_penalties AS (
  SELECT
    p.game_id,
    p.offense_team_id AS team_id,
    COALESCE(SUM(p.penalty_yards), 0) AS offense_penalty_yards
  FROM plays p
  GROUP BY p.game_id, p.offense_team_id
)
SELECT
  t.team_abbr,
  ROUND(AVG(gp.offense_penalty_yards)::numeric, 2) AS penalty_yards_per_game,
  COUNT(*) AS games
FROM game_penalties gp
JOIN teams t ON t.team_id = gp.team_id
GROUP BY t.team_abbr
ORDER BY penalty_yards_per_game DESC, games DESC;
