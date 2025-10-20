# -------- NFL SQL Analytics Makefile --------
# Requires: Docker, docker compose, GNU make
# Optional: Python 3.11+ (for downloader), Streamlit

# Env (falls back to sensible defaults if .env not loaded by compose)
DB_USER   ?= postgres
DB_NAME   ?= nfl

# Convenience
DC = docker compose
PSQL = $(DC) exec db psql -U $(DB_USER) -d $(DB_NAME)

# ------------- Containers -------------
up:
	$(DC) up -d

down:
	$(DC) down

down-v:
	$(DC) down -v

# ------------- Database schema -------------
schema:
	$(PSQL) -f /sql/schema/00_extensions.sql
	$(PSQL) -f /sql/schema/01_dimensions.sql
	$(PSQL) -f /sql/schema/02_games.sql
	$(PSQL) -f /sql/schema/03_plays.sql
	# migrations
	$(PSQL) -f /sql/migrations/04_add_off_def.sql
	$(PSQL) -f /sql/migrations/05_perf_indexes.sql
	$(PSQL) -f /sql/migrations/06_enhance_plays_metrics.sql
	$(PSQL) -f /sql/migrations/07_play_flags.sql
	$(PSQL) -f /sql/migrations/08_backfill_play_flags_robust.sql
	$(PSQL) -f /sql/migrations/09_add_touchdown_flag.sql
	$(PSQL) -f /sql/migrations/11_add_indexes.sql
	# keep 12/13 for mviews (see mviews target)

seed_meta:
	$(PSQL) -f /sql/seed/01_seed_teams_metadata.sql

# ------------- Data download (host) -------------
# Usage: make download YEARS="2022 2023"
download:
	python etl/python/download_pbp_subset.py $(YEARS)

# ------------- Load to staging (container COPY) -------------
# Usage: make load_staging CSV=data/pbp_2022_2023_subset.csv
load_staging:
	$(PSQL) -f /sql/staging/00_create_staging.sql
	$(PSQL) -c "\copy staging.pbp_raw FROM '/$(CSV)' CSV HEADER"

# ------------- ETL to core -------------
etl_core:
	$(PSQL) -f /sql/etl/21_stage_to_core_offdef.sql

etl_metrics:
	$(PSQL) -f /sql/etl/22_stage_to_core_metrics.sql
	# robust play flags pass/rush/PA
	$(PSQL) -f /sql/migrations/08_backfill_play_flags_robust.sql

# ------------- Views -------------
views:
	# team/league analytics
	$(PSQL) -f /sql/analysis/views/vw_yards_per_play.sql
	$(PSQL) -f /sql/analysis/views/vw_success_rate_by_down.sql
	$(PSQL) -f /sql/analysis/views/vw_turnover_rate.sql
	$(PSQL) -f /sql/analysis/views/vw_epa_per_play.sql
	$(PSQL) -f /sql/analysis/views/vw_epa_split_by_playtype.sql
	$(PSQL) -f /sql/analysis/views/vw_team_yards_per_game_by_season.sql
	$(PSQL) -f /sql/analysis/views/vw_team_third_down.sql
	$(PSQL) -f /sql/analysis/views/vw_team_punts.sql
	$(PSQL) -f /sql/analysis/views/vw_redzone_efficiency.sql
	$(PSQL) -f /sql/analysis/views/vw_explosive_play_rate.sql
	$(PSQL) -f /sql/analysis/views/vw_pressure_sack_rate.sql
	$(PSQL) -f /sql/analysis/views/vw_penalty_yards_offense.sql
	$(PSQL) -f /sql/analysis/views/vw_penalty_yards_defense.sql

# ------------- Materialized views -------------
# Needs migrations/12_create_mviews.sql and migrations/13_refresh_mviews.sql
mviews:
	$(PSQL) -f /sql/migrations/12_create_mviews.sql

refresh_mviews:
	$(PSQL) -f /sql/migrations/13_refresh_mviews.sql

# ------------- QA -------------
qa:
	$(PSQL) -f /sql/analysis/qa_checks.sql

# ------------- One-shot end-to-end (assumes CSV is already downloaded) -------------
# Usage: make all YEARS="2022 2023" CSV=data/pbp_2022_2023_subset.csv
all: up schema seed_meta download load_staging etl_core etl_metrics views mviews refresh_mviews qa

# ------------- Streamlit (dev) -------------
app:
	streamlit run app/app.py
