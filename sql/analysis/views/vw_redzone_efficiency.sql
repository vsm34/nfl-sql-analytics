-- Red-zone efficiency (TD rate on snaps inside opponent 20).
CREATE OR REPLACE VIEW public.vw_redzone_efficiency AS
SELECT
  t.team_abbr,
  COUNT(*) FILTER (WHERE p.red_zone_play) AS rz_plays,
  COUNT(*) FILTER (WHERE p.red_zone_play AND COALESCE(p.touchdown, FALSE)) AS rz_tds,
  CASE
    WHEN COUNT(*) FILTER (WHERE p.red_zone_play) = 0 THEN NULL
    ELSE ROUND(
      AVG(CASE WHEN p.red_zone_play THEN (COALESCE(p.touchdown, FALSE))::int END)::numeric
    , 3)
  END AS td_rate_in_red_zone
FROM plays p
JOIN teams t ON t.team_id = p.offense_team_id
GROUP BY t.team_abbr
ORDER BY td_rate_in_red_zone DESC NULLS LAST, t.team_abbr;
