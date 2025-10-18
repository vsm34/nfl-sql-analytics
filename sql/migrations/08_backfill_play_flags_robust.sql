-- 08_backfill_play_flags_robust.sql
-- Goal: robustly backfill pass/rush/play_action flags on plays
-- Strategy:
--   1) Map staging rows to game_id via the game signature (gameday + home/away).
--   2) Enumerate potentially duplicate rows with ROW_NUMBER() in both staging and plays.
--   3) Join on (game_id, quarter, down, distance, play_type, yards_gained, rn) for a 1:1 match.
--   4) Update flags with safe fallbacks.

WITH game_sig AS (
  SELECT
    g.game_id,
    g.gameday,
    th.team_abbr AS home_abbr,
    ta.team_abbr AS away_abbr
  FROM games g
  JOIN teams th ON th.team_id = g.home_team_id
  JOIN teams ta ON ta.team_id = g.away_team_id
),

-- Staging rows tied to game_id and enumerated to disambiguate duplicates
s_enum AS (
  SELECT
    gs.game_id,
    s.quarter,
    s.down,
    s.distance,
    s.play_type,
    s.yards_gained,
    -- normalize flags; fallback to play_type for rush
    (s.pass::boolean)                                    AS s_pass_flag,
    (COALESCE(s.rush::boolean, s.play_type IN ('run','rush'))) AS s_rush_flag,
    (COALESCE(s.play_action::boolean, FALSE))            AS s_play_action,
    ROW_NUMBER() OVER (
      PARTITION BY gs.game_id, s.quarter, s.down, s.distance, s.play_type, s.yards_gained
      ORDER BY s.drive NULLS LAST, s.yardline_100 DESC NULLS LAST
    ) AS rn
  FROM staging.pbp_raw s
  JOIN game_sig gs
    ON gs.gameday   = s.gameday
   AND gs.home_abbr = s.home_team
   AND gs.away_abbr = s.away_team
),

-- Plays enumerated the same way so we can 1:1 match
p_enum AS (
  SELECT
    p.play_id,
    p.game_id,
    p.quarter,
    p.down,
    p.distance,
    p.play_type,
    p.yards_gained,
    ROW_NUMBER() OVER (
      PARTITION BY p.game_id, p.quarter, p.down, p.distance, p.play_type, p.yards_gained
      ORDER BY p.play_id
    ) AS rn
  FROM plays p
)

UPDATE plays p
SET
  pass_flag   = COALESCE(p.pass_flag,   s.s_pass_flag,   (p.play_type = 'pass')),
  rush_flag   = COALESCE(p.rush_flag,   s.s_rush_flag,   (p.play_type IN ('run','rush'))),
  play_action = COALESCE(p.play_action, s.s_play_action, FALSE)
FROM p_enum pe
JOIN s_enum s
  ON s.game_id      = pe.game_id
 AND s.quarter      = pe.quarter
 AND s.down         = pe.down
 AND s.distance     = pe.distance
 AND s.play_type    = pe.play_type
 AND s.yards_gained = pe.yards_gained
 AND s.rn           = pe.rn
WHERE p.play_id = pe.play_id;
