CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.pbp_raw;

CREATE TABLE staging.pbp_raw (
  season          INT,
  week            INT,
  gameday         DATE,
  home_team       TEXT,
  away_team       TEXT,
  posteam         TEXT,
  defteam         TEXT,
  quarter         INT,
  down            INT,
  distance        INT,
  play_type       TEXT,
  yards_gained    INT,

  epa             NUMERIC,
  success         BOOLEAN,
  first_down      BOOLEAN,

  pass            BOOLEAN,
  rush            BOOLEAN,
  play_action     BOOLEAN,
  pass_attempt    BOOLEAN,

  sack            BOOLEAN,
  qb_hit          BOOLEAN,
  punt            BOOLEAN,

  interception    BOOLEAN,
  fumble_lost     BOOLEAN,

  penalty         BOOLEAN,
  penalty_team    TEXT,
  penalty_yards   INT,

  yardline_100    INT,
  touchdown       BOOLEAN,
  drive           INT
);
