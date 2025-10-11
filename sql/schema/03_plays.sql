-- 03_plays.sql
CREATE TABLE IF NOT EXISTS plays (
  play_id BIGSERIAL PRIMARY KEY,
  game_id BIGINT NOT NULL REFERENCES games(game_id) ON DELETE CASCADE,
  quarter INT CHECK (quarter BETWEEN 1 AND 5),
  clock TIME,                -- game clock in mm:ss can be normalized to time
  down INT CHECK (down BETWEEN 1 AND 4),
  distance INT,
  yard_line VARCHAR(12),     -- normalized like 'NE 43' or 'NYG 12'
  play_type VARCHAR(20),     -- pass, rush, punt, kick, penalty, etc.
  yards_gained INT,
  epa NUMERIC(8,4),
  success BOOLEAN,
  penalty_flag BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS play_players (
  play_id BIGINT REFERENCES plays(play_id) ON DELETE CASCADE,
  player_id BIGINT REFERENCES players(player_id),
  role VARCHAR(20) NOT NULL, -- passer, rusher, receiver, tackler, etc.
  PRIMARY KEY (play_id, player_id, role)
);

CREATE TABLE IF NOT EXISTS player_teams (
  player_team_id BIGSERIAL PRIMARY KEY,
  player_id BIGINT NOT NULL REFERENCES players(player_id),
  team_id BIGINT NOT NULL REFERENCES teams(team_id),
  season_id BIGINT NOT NULL REFERENCES seasons(season_id),
  start_week INT,
  end_week INT,
  jersey_number INT
);
