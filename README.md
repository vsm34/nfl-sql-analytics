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

- **Staging layer** for raw data  
- **Core layer** for cleaned relational tables  
- **Views and indexes** for performance and reporting  
- **Adminer UI** for easy data exploration  

---



## 🚀 Quick Start  

### 1️⃣ Start the containers 
```bash 
docker compose up -d 
```
### 2️⃣ Create the schema

Run these once to build all base tables:
```bash
docker compose exec db psql -U postgres -d nfl -f /sql/schema/00_extensions.sql
docker compose exec db psql -U postgres -d nfl -f /sql/schema/01_dimensions.sql
docker compose exec db psql -U postgres -d nfl -f /sql/schema/02_games.sql
docker compose exec db psql -U postgres -d nfl -f /sql/schema/03_plays.sql
docker compose exec db psql -U postgres -d nfl -f /sql/migrations/04_add_off_def.sql
```
### 3️⃣ Load sample data (10 plays from 2023)
```bash
docker compose exec db psql -U postgres -d nfl -f /sql/staging/00_create_staging.sql
docker compose exec db psql -U postgres -d nfl -c "\copy staging.pbp_raw FROM '/sql/staging/nfl_pbp_sample.csv' CSV HEADER"
docker compose exec db psql -U postgres -d nfl -f /sql/etl/21_stage_to_core_offdef.sql
```
### 4️⃣ Add performance indexes
```bash
docker compose exec db psql -U postgres -d nfl -f /sql/migrations/05_perf_indexes.sql
```
### 5️⃣ Create analytical views
```bash
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_offense_ypp.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/views/vw_success_by_down.sql
```
### 6️⃣ Run example queries
```bash
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/queries/ypp_by_offense.sql
docker compose exec db psql -U postgres -d nfl -f /sql/analysis/queries/success_rate_by_down.sql
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
- data/
   - nfl_pbp_sample.csv  → small real-like dataset (10 plays)
- docker-compose.yml   → container setup for Postgres + Adminer
- README.md            → project documentation

# 📊 Example Outputs

Average yards per play by offense:

- team_abbr	       ypp	 plays
-  KC	             8.20	    5
-  DAL	           4.80	    5

Success rate by down:

- down	success_rate	plays
-  1	        0.000	    2
-  2 	        0.500	    2
-  3 	        0.800	    5
-  4 	        0.000	    1

# 🧠 Key Features

- 🧩 Normalized Schema – professional ER model (seasons, teams, games, plays)
- ⚙️ ETL Pipeline – staging → core workflow using SQL scripts
- 🐳 Dockerized Setup – portable environment with PostgreSQL & Adminer
- 📈 Analytical Views – vw_offense_ypp, vw_success_by_down
- ⚡ Performance Indexes – faster lookups on high-usage columns
- 💻 Adminer UI – accessible at http://localhost:8080
- 📚 Fully Scripted & Reproducible – every step version-controlled


# 🖥️ Accessing the Database

- Adminer Login
- Field	    Value
- System	PostgreSQL
- Server	    db
- Username	postgres
- Password	postgres
- Database	nfl

Command Line
```bash
docker compose exec db psql -U postgres -d nfl
```

# 🔧 Performance & Indexes

Indexes added in 05_perf_indexes.sql accelerate joins and aggregations:

- plays(game_id)
- plays(offense_team_id)
- plays(defense_team_id)
- plays(down)
- games(season_id, week)
- teams(team_abbr)

# 📈 Future Enhancements (Planned)
- Automate data refresh with a Python ETL script
- Add advanced metrics (EPA, success splits, 3rd-down efficiency)
- Visualization layer in Tableau or Power BI
- Adminer screenshots and query examples in docs

# 🏁 How to Stop & Restart

Stop containers (keep data):
```bash
docker compose down
```
Stop & delete data (fresh start):
```bash
docker compose down -v
```
Restart later:
```bash
docker compose up -d
