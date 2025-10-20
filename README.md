# 🏈 NFL SQL Analytics  

![Built with Docker](https://img.shields.io/badge/Built%20with-Docker-blue?logo=docker)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-blue?logo=postgresql)
![SQL Analytics](https://img.shields.io/badge/Language-SQL-orange?logo=sqlite)
![Status](https://img.shields.io/badge/Version-v1.0-success)

---

## 📘 Overview  

**NFL SQL Analytics** is a containerized data-engineering and analytics project built with **PostgreSQL**, **Docker**, and **Adminer**.  
It models professional football play-by-play data using a clean, normalized schema and demonstrates a full ETL (Extract-Transform-Load) pipeline — from raw CSV ingestion to analytical views.  

This project mirrors how a real data team structures an analytics database:  

- **Staging → Core ETL** from `nfl_data_py` CSVs
- **Enriched plays** (EPA, explosive, turnover, dropback, red-zone, penalties, sack/pressure flags)
- **Analytics views** (team/league): YPP, EPA/play, turnover rate, third-down %, red-zone TD%, explosive rate, penalty yards (off/def), pressure/sack rate, punts per game, yards/game by season
- **Materialized views** for heavier rollups (optional)
- **One-command pipeline** via Makefile or PowerShell script
- **Adminer UI** for SQL browsing at `http://localhost:8080`

---



## 🚀 Quick Start  

### 1️⃣ Start the containers 
```bash 
docker compose up -d 
```
### 2️⃣ Create the schema
```bash
make schema
```
```bash
make seed_meta
```

### 3️⃣ Downlaod Data (2022-2023 Season)
```bash
python etl/python/download_pbp_subset.py 2022 2023
```
### 4️⃣ Load --> ETL --> Views --> QA
```bash
make load_staging CSV=data/pbp_2022_2023_subset.csv
make etl_core
make etl_metrics
make views
```
### 5️⃣ optional materialized views
```bash
make mviews
make refresh_mviews
make qa
```

##  One Command Pipeline
```bash
make all YEARS="2022 2023" CSV=data/pbp_2022_2023_subset.csv
```

## One-Button Pipeline
```bash
.\scripts\run_pipeline.ps1 -StartYear 2022 -EndYear 2023
```

### Load 2024 PBP (nfl_data_py)
```bash
# venv (Windows)
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -U pip
pip install "pandas==2.2.2" "nfl_data_py>=0.3.0,<0.4"
```
download and write CSV to ./data
``` bash
python etl\python\download_pbp_subset.py 2024 2025  # 2025 skips if not published
```
load -> staging -> core
```bash
docker compose exec db psql -U postgres -d nfl -f /sql/staging/00_create_staging.sql
docker compose exec db psql -U postgres -d nfl -c "\copy staging.pbp_raw FROM '/data/pbp_2024_2025_subset.csv' CSV HEADER"
docker compose exec db psql -U postgres -d nfl -c "TRUNCATE plays RESTART IDENTITY CASCADE;"
docker compose exec db psql -U postgres -d nfl -f /sql/etl/21_stage_to_core_offdef.sql
```

# 🧱 Project Structure
- sql/
  -  schema/        → base tables (seasons, teams, games, plays)
  -  staging/       → raw data tables for CSV ingestion
  -  etl/           → staging → core transformations
  -  migrations/    → schema upgrades (FKs, indexes)
  -  analysis/
      - queries/    → reusable analytical queries
      - views/      → persistent analytical views
      - qa_checks.sql → consistency checks
- etl/
   - python/download_pbp_subset.py
- app/
   - app.py → streamlit dashboard
   - requirements.txt
- scripts/
   - run_pipeline.ps1 → one button pipeline 
- .github/workflows/
   - ci.yml  → smoke checks 
- data/      → Download CSVs (gitignored)
- Makefile
- docker-compose.yml   → container setup for Postgres + Adminer
- README.md            → project documentation

# 🏁 How to Stop & Restart

Stop containers (keep data):
```bash
docker compose down
```
Stop & delete data (fresh start):
```bash
docker compose down -v
```
Restart later
```bash
make schema seed_meta
python etl/python/download_pbp_subset.py 2022 2023
make load_staging CSV=data/pbp_2022_2023_subset.csv
make etl_core etl_metrics views mviews refresh_mviews qa
```

# 🧠 Key Features

- 🧩 Normalized Schema – professional ER model (seasons, teams, games, plays)
- ⚙️ ETL Pipeline – staging → core workflow using SQL scripts
- 🐳 Dockerized Setup – portable environment with PostgreSQL & Adminer
- 📈 Analytical Views – vw_offense_ypp, vw_success_by_down
- ⚡ Performance Indexes – faster lookups on high-usage columns
- 💻 Adminer UI – accessible at http://localhost:8080
- 📚 Fully Scripted & Reproducible – every step version-controlled