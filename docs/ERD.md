# ERD (Mermaid)

```mermaid
erDiagram
  seasons ||--o{ games : includes
  teams ||--o{ game_teams : appears_in
  players }o--o{ plays : participates_via_play_players
  games ||--o{ plays : contains
  teams }o--o{ players : via_player_teams
  stadiums ||--o{ games : hosted_at

  seasons {
    bigserial season_id PK
    int year UNIQUE
  }

  teams {
    bigserial team_id PK
    varchar team_abbr
    varchar team_name
    varchar conference
    varchar division
  }

  players {
    bigserial player_id PK
    varchar first_name
    varchar last_name
    varchar position
    date birthdate
    varchar college
  }

  stadiums {
    bigserial stadium_id PK
    varchar name
    varchar city
    varchar state
    varchar roof
    varchar surface
  }

  games {
    bigserial game_id PK
    bigint season_id FK
    int week
    date gameday
    bigint home_team_id FK
    bigint away_team_id FK
    bigint stadium_id FK
    int home_points
    int away_points
    varchar result
    jsonb weather_json
  }

  game_teams {
    bigint game_id FK
    bigint team_id FK
    boolean is_home
    int points
    int total_yards
    int turnovers
    interval time_possession
  }

  plays {
    bigserial play_id PK
    bigint game_id FK
    int quarter
    time clock
    int down
    int distance
    varchar yard_line
    varchar play_type
    int yards_gained
    numeric epa
    boolean success
    boolean penalty_flag
  }

  play_players {
    bigint play_id FK
    bigint player_id FK
    varchar role
  }

  player_teams {
    bigserial player_team_id PK
    bigint player_id FK
    bigint team_id FK
    bigint season_id FK
    int start_week
    int end_week
    int jersey_number
  }
```
