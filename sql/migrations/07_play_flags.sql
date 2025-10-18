-- Add flags to plays
ALTER TABLE plays ADD COLUMN IF NOT EXISTS pass_flag boolean;
ALTER TABLE plays ADD COLUMN IF NOT EXISTS rush_flag boolean;
ALTER TABLE plays ADD COLUMN IF NOT EXISTS play_action boolean;

-- Populate from staging (one-time backfill; safe to re-run)
WITH gm AS (
  SELECT g.game_id, g.gameday, th.team_abbr AS home_abbr, ta.team_abbr AS away_abbr
  FROM games g
  JOIN teams th ON th.team_id = g.home_team_id
  JOIN teams ta ON ta.team_id = g.away_team_id
)
UPDATE plays p
SET
  pass_flag    = COALESCE(s.pass::boolean,    p.play_type = 'pass'),
  rush_flag    = COALESCE(s.rush::boolean,    p.play_type IN ('run','rush')),
  play_action  = COALESCE(s.play_action::boolean, FALSE)
FROM staging.pbp_raw s
JOIN gm ON gm.gameday = s.gameday AND gm.home_abbr = s.home_team AND gm.away_abbr = s.away_team
JOIN teams off ON off.team_abbr = s.posteam
JOIN teams def ON def.team_abbr = s.defteam
WHERE p.game_id = (SELECT game_id FROM games g WHERE g.gameday = s.gameday AND g.home_team_id = off.team_id AND g.away_team_id = def.team_id LIMIT 1)
  AND p.quarter   = s.quarter
  AND p.down      = s.down
  AND p.distance  = s.distance
  AND p.play_type = s.play_type
  AND p.yards_gained = s.yards_gained;
