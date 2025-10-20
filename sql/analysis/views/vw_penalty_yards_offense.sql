-- Penalty yards COMMITTED BY the offense (per game, averaged)
CREATE OR REPLACE VIEW public.vw_penalty_yards_offense AS
WITH gm AS (
  SELECT g.game_id, g.gameday,
         th.team_abbr AS home_abbr,
         ta.team_abbr AS away_abbr
  FROM games g
  JOIN teams th ON th.team_id = g.home_team_id
  JOIN teams ta ON ta.team_id = g.away_team_id
),
joined AS (
  SELECT
    p.game_id,
    toff.team_abbr AS offense_abbr,
    COALESCE(s.penalty_yards, 0) AS pen_yds,
    (s.penalty IS TRUE AND s.penalty_team = toff.team_abbr) AS off_pen
  FROM plays p
  JOIN gm         ON gm.game_id = p.game_id
  JOIN teams toff ON toff.team_id = p.offense_team_id
  JOIN teams tdef ON tdef.team_id = p.defense_team_id
  JOIN staging.pbp_raw s
    ON s.gameday      = gm.gameday
   AND s.home_team    = gm.home_abbr
   AND s.away_team    = gm.away_abbr
   AND s.posteam      = toff.team_abbr
   AND s.defteam      = tdef.team_abbr
   AND s.quarter      = p.quarter
   AND s.down         = p.down
   AND s.distance     = p.distance
   AND s.play_type    = p.play_type
   AND s.yards_gained = p.yards_gained
)
, per_game AS (
  SELECT offense_abbr, game_id,
         SUM(CASE WHEN off_pen THEN pen_yds ELSE 0 END) AS off_penalty_yards
  FROM joined
  GROUP BY offense_abbr, game_id
)
SELECT
  offense_abbr AS team_abbr,
  ROUND(AVG(off_penalty_yards)::numeric, 2) AS offense_penalty_yards_per_game,
  COUNT(*) AS games
FROM per_game
GROUP BY offense_abbr
ORDER BY offense_penalty_yards_per_game DESC, games DESC;
