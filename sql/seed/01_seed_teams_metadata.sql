-- 01_seed_teams_metadata.sql
-- Purpose: Seed the teams table with official NFL conference and division data.
-- Safe to re-run (ON CONFLICT upserts based on team_abbr).

INSERT INTO teams (team_abbr, team_name, conference, division)
VALUES
  ('BUF', 'Buffalo Bills', 'AFC', 'East'),
  ('MIA', 'Miami Dolphins', 'AFC', 'East'),
  ('NE',  'New England Patriots', 'AFC', 'East'),
  ('NYJ', 'New York Jets', 'AFC', 'East'),

  ('BAL', 'Baltimore Ravens', 'AFC', 'North'),
  ('CIN', 'Cincinnati Bengals', 'AFC', 'North'),
  ('CLE', 'Cleveland Browns', 'AFC', 'North'),
  ('PIT', 'Pittsburgh Steelers', 'AFC', 'North'),

  ('HOU', 'Houston Texans', 'AFC', 'South'),
  ('IND', 'Indianapolis Colts', 'AFC', 'South'),
  ('JAX', 'Jacksonville Jaguars', 'AFC', 'South'),
  ('TEN', 'Tennessee Titans', 'AFC', 'South'),

  ('DEN', 'Denver Broncos', 'AFC', 'West'),
  ('KC',  'Kansas City Chiefs', 'AFC', 'West'),
  ('LV',  'Las Vegas Raiders', 'AFC', 'West'),
  ('LAC', 'Los Angeles Chargers', 'AFC', 'West'),

  ('DAL', 'Dallas Cowboys', 'NFC', 'East'),
  ('NYG', 'New York Giants', 'NFC', 'East'),
  ('PHI', 'Philadelphia Eagles', 'NFC', 'East'),
  ('WAS', 'Washington Commanders', 'NFC', 'East'),

  ('CHI', 'Chicago Bears', 'NFC', 'North'),
  ('DET', 'Detroit Lions', 'NFC', 'North'),
  ('GB',  'Green Bay Packers', 'NFC', 'North'),
  ('MIN', 'Minnesota Vikings', 'NFC', 'North'),

  ('ATL', 'Atlanta Falcons', 'NFC', 'South'),
  ('CAR', 'Carolina Panthers', 'NFC', 'South'),
  ('NO',  'New Orleans Saints', 'NFC', 'South'),
  ('TB',  'Tampa Bay Buccaneers', 'NFC', 'South'),

  ('ARI', 'Arizona Cardinals', 'NFC', 'West'),
  ('LA',  'Los Angeles Rams', 'NFC', 'West'),
  ('SF',  'San Francisco 49ers', 'NFC', 'West'),
  ('SEA', 'Seattle Seahawks', 'NFC', 'West')
ON CONFLICT (team_abbr) DO UPDATE
SET
  team_name  = EXCLUDED.team_name,
  conference = EXCLUDED.conference,
  division   = EXCLUDED.division;
