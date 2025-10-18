-- 09_add_touchdown_flag.sql
ALTER TABLE plays
  ADD COLUMN IF NOT EXISTS touchdown BOOLEAN;
