-- sql/etl/20_stage_to_core.sql
-- Move staging rows into core tables.

-- 1) Seasons
INSERT INTO seasons(year)
SELECT DISTINCT season
FROM staging.pbp_raw s
WHERE NOT EXISTS (SELECT 1 FROM seasons x WHERE x.year = s.season);

-- 2) Teams
INSERT INTO teams (team_abbr, team_name, conference, division)
SELECT DISTINCT abbr, abbr, NULL, NULL
FROM (
  SELECT home_team AS abbr FROM staging.pbp_raw
  UNION SELECT away_team FROM staging.pbp_raw
  UNION SELECT posteam FROM staging.pbp_raw
  UNION SELECT defteam FROM staging.pbp_raw
) u
WHERE NOT EXISTS (SELECT 1 FROM teams t WHERE t.team_abbr = u.abbr);

-- 3) Games
INSERT INTO games (season_id, week, gameday, home_team_id, away_team_id)
SELECT s.season_id, r.week, r.gameday, th.team_id, ta.team_id
FROM (
  SELECT DISTINCT season, week, gameday, home_team, away_team
  FROM staging.pbp_raw
) r
JOIN seasons s ON s.year = r.season
JOIN teams th  ON th.team_abbr = r.home_team
JOIN teams ta  ON ta.team_abbr = r.away_team
ON CONFLICT (season_id, week, home_team_id, away_team_id) DO NOTHING;

-- 4) Plays
INSERT INTO plays (game_id, quarter, down, distance, play_type, yards_gained, success, penalty_flag)
SELECT g.game_id, r.quarter, r.down, r.distance, r.play_type, r.yards_gained,
       CASE WHEN r.yards_gained >= r.distance AND r.down IS NOT NULL AND r.distance IS NOT NULL THEN TRUE ELSE FALSE END,
       FALSE
FROM staging.pbp_raw r
JOIN seasons s ON s.year = r.season
JOIN teams th  ON th.team_abbr = r.home_team
JOIN teams ta  ON ta.team_abbr = r.away_team
JOIN games g   ON g.season_id = s.season_id
              AND g.week = r.week
              AND g.home_team_id = th.team_id
              AND g.away_team_id = ta.team_id;
