-- 01_dimensions.sql
CREATE TABLE IF NOT EXISTS seasons (
  season_id BIGSERIAL PRIMARY KEY,
  year INT UNIQUE NOT NULL CHECK (year BETWEEN 1920 AND 2100)
);

CREATE TABLE IF NOT EXISTS teams (
  team_id BIGSERIAL PRIMARY KEY,
  team_abbr VARCHAR(5) NOT NULL,
  team_name VARCHAR(80) NOT NULL,
  conference VARCHAR(10),
  division VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS players (
  player_id BIGSERIAL PRIMARY KEY,
  first_name VARCHAR(60),
  last_name VARCHAR(60),
  position VARCHAR(5),
  birthdate DATE,
  college VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS stadiums (
  stadium_id BIGSERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  city VARCHAR(80),
  state VARCHAR(30),
  roof VARCHAR(20),
  surface VARCHAR(20)
);
