WITH gm AS (
  SELECT g.game_id, g.gameday, th.team_abbr AS home_abbr, ta.team_abbr AS away_abbr
  FROM games g
  JOIN teams th ON th.team_id = g.home_team_id
  JOIN teams ta ON ta.team_id = g.away_team_id
),
joined AS (
  SELECT s.*
  FROM staging.pbp_raw s
  JOIN gm ON gm.gameday = s.gameday AND gm.home_abbr = s.home_team AND gm.away_abbr = s.away_team
  JOIN teams toff ON toff.team_abbr = s.posteam
  JOIN teams tdef ON tdef.team_abbr = s.defteam
)
SELECT COUNT(*) AS not_joined
FROM staging.pbp_raw s
LEFT JOIN joined j
  ON j.season = s.season AND j.week = s.week AND j.gameday = s.gameday
 AND j.home_team = s.home_team AND j.away_team = s.away_team
 AND j.posteam = s.posteam AND j.defteam = s.defteam
 AND j.quarter = s.quarter AND j.down = s.down
 AND j.distance = s.distance AND j.play_type = s.play_type
 AND j.yards_gained = s.yards_gained
WHERE j.season IS NULL;
