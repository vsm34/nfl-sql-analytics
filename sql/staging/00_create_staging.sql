-- sql/staging/00_create_staging.sql
CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.pbp_raw;
CREATE TABLE staging.pbp_raw (
  season       INT,
  week         INT,
  gameday      DATE,
  home_team    VARCHAR(5),
  away_team    VARCHAR(5),
  posteam      VARCHAR(5),
  defteam      VARCHAR(5),
  quarter      INT,
  down         INT,
  distance     INT,
  play_type    VARCHAR(20),
  yards_gained INT
);
