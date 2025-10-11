ALTER TABLE plays ADD COLUMN IF NOT EXISTS offense_team_id BIGINT;
ALTER TABLE plays ADD COLUMN IF NOT EXISTS defense_team_id BIGINT;

ALTER TABLE plays
  ADD CONSTRAINT plays_offense_fk FOREIGN KEY (offense_team_id) REFERENCES teams(team_id),
  ADD CONSTRAINT plays_defense_fk FOREIGN KEY (defense_team_id) REFERENCES teams(team_id);
