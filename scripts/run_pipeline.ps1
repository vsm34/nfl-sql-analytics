# scripts/run_pipeline.ps1
param(
  [int]$StartYear = 2022,
  [int]$EndYear   = 2023
)

$ErrorActionPreference = "Stop"
Write-Host "=== NFL SQL Analytics: pipeline start ($StartYear-$EndYear) ==="

# 0) Ensure containers are up
docker compose up -d

# 1) Download PBP subset (writes to data/pbp_<years>_subset.csv)
python .\etl\python\download_pbp_subset.py $StartYear $EndYear

# 2) (Re)create staging & load CSV
docker compose exec db psql -U postgres -d nfl -f /sql/staging/00_create_staging.sql
docker compose exec db psql -U postgres -d nfl -c "TRUNCATE staging.pbp_raw;"
# Find latest CSV in /data inside the container
$LatestCsv = (Get-ChildItem .\data\pbp_*_subset.csv | Sort-Object LastWriteTime -Descending | Select-Object -First 1).Name
docker compose exec db psql -U postgres -d nfl -c "\copy staging.pbp_raw FROM '/data/$LatestCsv' CSV HEADER"

# 3) Core ETL + metrics enrich
docker compose exec db psql -U postgres -d nfl -f /sql/etl/21_stage_to_core_offdef.sql
docker compose exec db psql -U postgres -d nfl -f /sql/migrations/08_backfill_play_flags_robust.sql
docker compose exec db psql -U postgres -d nfl -f /sql/etl/22_stage_to_core_metrics.sql

# 4) Views (regular + materialized)
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_yards_per_play.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_success_rate_by_down.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_turnover_rate.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_epa_per_play.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_epa_split_by_playtype.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_penalty_yards_offense.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_penalty_yards_defense.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_team_third_down.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_team_punts.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_pressure_sack_rate.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_team_yards_per_game_by_season.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_redzone_efficiency.sql

# 5) QA checks (fail script if any check fails)
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/qa/qa_checks.sql

Write-Host "=== Pipeline complete ==="
