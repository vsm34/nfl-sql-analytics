CREATE OR REPLACE VIEW public.vw_epa_split_by_playtype AS
SELECT
  t.team_abbr,
  ROUND(AVG(CASE WHEN p.play_type IN ('pass') THEN p.epa END)::numeric, 3) AS epa_pass,
  ROUND(AVG(CASE WHEN p.play_type IN ('run','rush') THEN p.epa END)::numeric, 3) AS epa_run,
  ROUND(AVG(p.epa)::numeric, 3) AS epa_overall,
  COUNT(*) AS plays
FROM plays p
JOIN teams t ON t.team_id = p.offense_team_id
WHERE p.epa IS NOT NULL
GROUP BY t.team_abbr
ORDER BY epa_overall DESC;
