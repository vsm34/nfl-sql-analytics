-- 02_games.sql
CREATE TABLE IF NOT EXISTS games (
  game_id BIGSERIAL PRIMARY KEY,
  season_id BIGINT NOT NULL REFERENCES seasons(season_id),
  week INT NOT NULL CHECK (week BETWEEN 1 AND 22),
  gameday DATE NOT NULL,
  home_team_id BIGINT NOT NULL REFERENCES teams(team_id),
  away_team_id BIGINT NOT NULL REFERENCES teams(team_id),
  stadium_id BIGINT REFERENCES stadiums(stadium_id),
  home_points INT,
  away_points INT,
  result VARCHAR(5), -- 'H','A','T' or similar
  weather_json JSONB,
  UNIQUE (season_id, week, home_team_id, away_team_id)
);

CREATE TABLE IF NOT EXISTS game_teams (
  game_id BIGINT REFERENCES games(game_id) ON DELETE CASCADE,
  team_id BIGINT REFERENCES teams(team_id),
  is_home BOOLEAN NOT NULL,
  points INT,
  total_yards INT,
  turnovers INT,
  time_possession INTERVAL,
  PRIMARY KEY (game_id, team_id)
);
