-- 11_add_indexes.sql
-- High-value indexes to keep analytics snappy
-- Safe to re-run
CREATE INDEX IF NOT EXISTS idx_plays_game_id            ON plays(game_id);
CREATE INDEX IF NOT EXISTS idx_plays_offense_team_id    ON plays(offense_team_id);
CREATE INDEX IF NOT EXISTS idx_plays_defense_team_id    ON plays(defense_team_id);
CREATE INDEX IF NOT EXISTS idx_plays_down               ON plays(down);
CREATE INDEX IF NOT EXISTS idx_plays_play_type          ON plays(play_type);
CREATE INDEX IF NOT EXISTS idx_plays_third_down         ON plays(third_down);
CREATE INDEX IF NOT EXISTS idx_plays_dropback           ON plays(dropback);
CREATE INDEX IF NOT EXISTS idx_plays_explosive          ON plays(explosive);
CREATE INDEX IF NOT EXISTS idx_plays_turnover           ON plays(turnover);
CREATE INDEX IF NOT EXISTS idx_plays_red_zone_play      ON plays(red_zone_play);
CREATE INDEX IF NOT EXISTS idx_plays_epa_notnull        ON plays(epa) WHERE epa IS NOT NULL;
