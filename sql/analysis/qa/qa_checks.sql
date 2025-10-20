-- sql/analysis/qa/qa_checks.sql
\echo 'QA: start'

-- 1) EPA completeness should be > 60% of plays
WITH tot AS (SELECT COUNT(*) AS n FROM plays),
ep  AS (SELECT COUNT(*) AS n FROM plays WHERE epa IS NOT NULL)
SELECT CASE WHEN ep.n::numeric / NULLIF(tot.n,0) >= 0.60
            THEN 1 ELSE RAISE_EXCEPTION('QA FAIL: EPA completeness below 60%% (%.2f%%)',
                   100.0 * ep.n::numeric / NULLIF(tot.n,0)) END
FROM ep, tot;

-- 2) Third-down conversions cannot exceed attempts per team
WITH td AS (
  SELECT t.team_abbr,
         SUM((p.third_down)::int) AS atts,
         SUM((p.third_down_success)::int) AS convs
  FROM plays p JOIN teams t ON t.team_id = p.offense_team_id
  GROUP BY t.team_abbr
)
SELECT CASE WHEN COUNT(*) FILTER (WHERE convs > atts) = 0
            THEN 1 ELSE RAISE_EXCEPTION('QA FAIL: team(s) have 3rd-down conv > attempts') END
FROM td;

-- 3) Red-zone TD rate bounds [0,1]
WITH rz AS (
  SELECT t.team_abbr,
         SUM((p.red_zone_play)::int) AS rz_plays,
         SUM((p.red_zone_play AND p.touchdown)::int) AS rz_tds
  FROM plays p JOIN teams t ON t.team_id = p.offense_team_id
  GROUP BY t.team_abbr
)
SELECT CASE WHEN COUNT(*) FILTER (WHERE rz_plays > 0 AND (rz_tds::numeric/rz_plays < 0 OR rz_tds::numeric/rz_plays > 1)) = 0
            THEN 1 ELSE RAISE_EXCEPTION('QA FAIL: RZ TD rate out of bounds') END
FROM rz;

-- 4) No NULL team names
SELECT CASE WHEN COUNT(*) = 0
            THEN 1 ELSE RAISE_EXCEPTION('QA FAIL: teams with NULL team_name') END
FROM teams WHERE team_name IS NULL;

-- 5) League yards = sum of team yards (per season) within tolerance
WITH league AS (
  SELECT s.year,
         SUM(p.yards_gained) AS yards
  FROM plays p
  JOIN games g ON g.game_id = p.game_id
  JOIN seasons s ON s.season_id = g.season_id
  WHERE p.play_type IN ('pass','run','rush')
  GROUP BY s.year
),
team AS (
  SELECT s.year, t.team_abbr,
         SUM(p.yards_gained) AS yards
  FROM plays p
  JOIN games g ON g.game_id = p.game_id
  JOIN seasons s ON s.season_id = g.season_id
  JOIN teams t ON t.team_id = p.offense_team_id
  WHERE p.play_type IN ('pass','run','rush')
  GROUP BY s.year, t.team_abbr
),
agg AS (
  SELECT year, SUM(yards) AS team_sum
  FROM team GROUP BY year
)
SELECT CASE WHEN COUNT(*) FILTER (WHERE abs(l.yards - a.team_sum) > 1) = 0
            THEN 1 ELSE RAISE_EXCEPTION('QA FAIL: league yards != sum(team yards)') END
FROM league l JOIN agg a ON a.year = l.year;

\echo 'QA: ok'
