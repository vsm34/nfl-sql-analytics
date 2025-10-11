BEGIN;

WITH
s AS (
  INSERT INTO seasons(year) VALUES (2023)
  RETURNING season_id
),
t AS (
  INSERT INTO teams(team_abbr, team_name, conference, division) VALUES
    ('KC',  'Kansas City Chiefs',      'AFC', 'West'),
    ('PHI', 'Philadelphia Eagles',     'NFC', 'East')
  RETURNING team_id, team_abbr
),
kc AS (SELECT team_id FROM t WHERE team_abbr = 'KC'),
phi AS (SELECT team_id FROM t WHERE team_abbr = 'PHI'),
stad AS (
  INSERT INTO stadiums(name, city, state, roof, surface)
  VALUES ('Arrowhead Stadium','Kansas City','MO','open','grass')
  RETURNING stadium_id
),
g AS (
  INSERT INTO games(season_id, week, gameday, home_team_id, away_team_id, stadium_id, home_points, away_points, result)
  SELECT s.season_id, 1, DATE '2023-09-10', kc.team_id, phi.team_id, stad.stadium_id, 27, 24, 'H'
  FROM s, kc, phi, stad
  RETURNING game_id
),
gt AS (
  INSERT INTO game_teams(game_id, team_id, is_home, points, total_yards, turnovers)
  SELECT g.game_id, kc.team_id, TRUE, 27, 400, 1 FROM g, kc
  UNION ALL
  SELECT g.game_id, phi.team_id, FALSE, 24, 385, 2 FROM g, phi
  RETURNING game_id
),
ppl AS (
  INSERT INTO players(first_name, last_name, position) VALUES
    ('Patrick','Mahomes','QB'),
    ('Travis','Kelce','TE')
  RETURNING player_id, first_name, last_name
),
qb AS (SELECT player_id FROM ppl WHERE first_name='Patrick' AND last_name='Mahomes'),
te AS (SELECT player_id FROM ppl WHERE first_name='Travis'  AND last_name='Kelce'),
p1 AS (
  INSERT INTO plays(game_id, quarter, down, distance, play_type, yards_gained, success)
  SELECT g.game_id, 1, 3,  8, 'pass', 12, TRUE FROM g
  RETURNING play_id
),
p2 AS (
  INSERT INTO plays(game_id, quarter, down, distance, play_type, yards_gained, success)
  SELECT g.game_id, 2, 2,  5, 'pass', 15, TRUE FROM g
  RETURNING play_id
),
p3 AS (
  INSERT INTO plays(game_id, quarter, down, distance, play_type, yards_gained, success)
  SELECT g.game_id, 4, 3, 10, 'rush',  7, FALSE FROM g
  RETURNING play_id
)
INSERT INTO play_players (play_id, player_id, role)
SELECT p1.play_id, qb.player_id, 'passer'   FROM p1, qb
UNION ALL
SELECT p1.play_id, te.player_id, 'receiver' FROM p1, te
UNION ALL
SELECT p2.play_id, qb.player_id, 'passer'   FROM p2, qb
UNION ALL
SELECT p2.play_id, te.player_id, 'receiver' FROM p2, te;

COMMIT;
