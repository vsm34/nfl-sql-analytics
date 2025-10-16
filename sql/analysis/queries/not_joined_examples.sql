WITH game_sig AS (
  SELECT g.gameday, th.team_abbr AS home_abbr, ta.team_abbr AS away_abbr
  FROM games g
  JOIN teams th ON th.team_id = g.home_team_id
  JOIN teams ta ON ta.team_id = g.away_team_id
)
SELECT
  s.season, s.week, s.gameday, s.home_team, s.away_team,
  s.posteam, s.defteam, s.play_type, s.down, s.distance, s.yards_gained
FROM staging.pbp_raw s
LEFT JOIN game_sig gs
  ON gs.gameday = s.gameday
 AND gs.home_abbr = s.home_team
 AND gs.away_abbr = s.away_team
WHERE gs.gameday IS NULL
   OR s.posteam IS NULL OR s.posteam = ''
   OR s.defteam IS NULL OR s.defteam = ''
LIMIT 20;
