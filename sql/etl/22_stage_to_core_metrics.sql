-- Enrich plays using staging.pbp_raw, matching games by (date, home_abbr, away_abbr)
WITH gm AS (
  SELECT
    g.game_id,
    g.gameday,
    th.team_abbr AS home_abbr,
    ta.team_abbr AS away_abbr
  FROM games g
  JOIN teams th ON th.team_id = g.home_team_id
  JOIN teams ta ON ta.team_id = g.away_team_id
),
j AS (
  SELECT
    p.play_id,
    s.epa,
    s.first_down,
    (p.down = 3) AS third_down,
    (p.down = 3 AND s.first_down IS TRUE) AS third_down_success,
    (COALESCE(s.interception,false) OR COALESCE(s.fumble_lost,false)) AS turnover,
    (COALESCE(s.pass_attempt,false) OR COALESCE(s.sack,false) OR COALESCE(s.qb_hit,false)) AS dropback,
    -- explosive: ≥15 pass or ≥10 rush
    ((s.pass AND s.yards_gained >= 15) OR (s.rush AND s.yards_gained >= 10)) AS explosive,
    (s.yardline_100 <= 20) AS red_zone_play,
    s.play_action,
    s.sack, s.qb_hit, s.punt,
    s.penalty, s.penalty_yards
  FROM plays p
  JOIN gm            ON gm.game_id = p.game_id
  JOIN teams toff    ON toff.team_id = p.offense_team_id
  JOIN teams tdef    ON tdef.team_id = p.defense_team_id
  JOIN staging.pbp_raw s
    ON s.gameday     = gm.gameday
   AND s.home_team   = gm.home_abbr
   AND s.away_team   = gm.away_abbr
   AND s.posteam     = toff.team_abbr
   AND s.defteam     = tdef.team_abbr
   AND s.quarter     = p.quarter
   AND s.down        = p.down
   AND s.distance    = p.distance
   AND s.play_type   = p.play_type
   AND s.yards_gained= p.yards_gained
)
UPDATE plays p
SET epa                 = j.epa,
    first_down          = j.first_down,
    third_down          = j.third_down,
    third_down_success  = j.third_down_success,
    turnover            = j.turnover,
    dropback            = j.dropback,
    explosive           = j.explosive,
    red_zone_play       = j.red_zone_play,
    play_action         = j.play_action,
    sack                = j.sack,
    qb_hit              = j.qb_hit,
    punt                = j.punt,
    penalty             = j.penalty,
    penalty_yards       = j.penalty_yards
FROM j
WHERE j.play_id = p.play_id;
