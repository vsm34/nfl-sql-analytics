# NFL SQL Analytics (PostgreSQL)

A portfolio-ready SQL project that models NFL seasons, games, plays, teams, and players in **PostgreSQL**, with ready-to-run Docker, schema scripts, and example queries.

## What this project demonstrates
- Sound relational modeling (star-ish schema with bridges for many-to-many).
- Clean SQL: primary/foreign keys, constraints, indexes, and views.
- Real analytics examples (EPA/success placeholders you can extend later).

## Quick Start (Beginner-Friendly)
### 1) Prereqs
- **Git** installed and a GitHub account.
- **Docker Desktop** installed and running (or a local PostgreSQL if you prefer).
- **VS Code** with the “PostgreSQL” or “SQLTools” extension (optional but handy).

### 2) Set environment values
Copy `.env.example` → `.env` and adjust as needed:
```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=nfl
```

### 3) Launch PostgreSQL
```bash
docker compose up -d
# Postgres on localhost:5432, Adminer on http://localhost:8080
```

### 4) Load the schema
Run from repo root:
```bash
# Using docker exec into the Postgres container and psql the scripts in order
docker compose exec db psql -U $POSTGRES_USER -d $POSTGRES_DB -f /sql/schema/00_extensions.sql
docker compose exec db psql -U $POSTGRES_USER -d $POSTGRES_DB -f /sql/schema/01_dimensions.sql
docker compose exec db psql -U $POSTGRES_USER -d $POSTGRES_DB -f /sql/schema/02_games.sql
docker compose exec db psql -U $POSTGRES_USER -d $POSTGRES_DB -f /sql/schema/03_plays.sql
```

Or, connect via Adminer (http://localhost:8080), log in to `nfl`, and run each script manually.

### 5) Try sample queries
```bash
docker compose exec db psql -U $POSTGRES_USER -d $POSTGRES_DB -f /sql/analysis/queries/demo.sql
```

---

## Project Structure
```
sql/
  schema/
    00_extensions.sql
    01_dimensions.sql
    02_games.sql
    03_plays.sql
  analysis/
    queries/
      demo.sql
data/              # put sample CSVs here later
docs/
  ERD.md           # Mermaid ERD
.env.example
docker-compose.yml
README.md
```

## Next steps
- Add CSV loaders (Python or \\copy), indexes for performance, and derived analytical views.
- Bring in a public NFL play-by-play dataset and map its columns into this schema.
