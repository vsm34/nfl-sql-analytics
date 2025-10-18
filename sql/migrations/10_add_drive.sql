-- 10_add_drive.sql
ALTER TABLE plays
  ADD COLUMN IF NOT EXISTS drive INTEGER;
