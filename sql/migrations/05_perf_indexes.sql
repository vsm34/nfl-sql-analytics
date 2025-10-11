-- 05_perf_indexes.sql

-- Joins & filters on plays
CREATE INDEX IF NOT EXISTS idx_plays_game_id       ON plays(game_id);
CREATE INDEX IF NOT EXISTS idx_plays_offense_team  ON plays(offense_team_id);
CREATE INDEX IF NOT EXISTS idx_plays_defense_team  ON plays(defense_team_id);
CREATE INDEX IF NOT EXISTS idx_plays_down          ON plays(down);

-- Common filters/grouping on games
CREATE INDEX IF NOT EXISTS idx_games_season_week   ON games(season_id, week);

-- Helpful when looking up teams by abbr (not unique here, but speeds joins)
CREATE INDEX IF NOT EXISTS idx_teams_abbr          ON teams(team_abbr);
