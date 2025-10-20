-- Pressure & Sack rates per dropback.
-- Uses p.dropback (from enrichment) and qb_hit as a proxy for pressures.
CREATE OR REPLACE VIEW public.vw_pressure_sack_rate AS
SELECT
  t.team_abbr,
  COUNT(*) FILTER (WHERE p.dropback)                    AS dropbacks,
  COUNT(*) FILTER (WHERE p.sack)                        AS sacks,
  COUNT(*) FILTER (WHERE p.qb_hit OR p.sack)            AS pressures,
  ROUND(
    (COUNT(*) FILTER (WHERE p.qb_hit OR p.sack))::numeric
    / NULLIF( COUNT(*) FILTER (WHERE p.dropback), 0 )
  , 3) AS pressure_rate,
  ROUND(
    (COUNT(*) FILTER (WHERE p.sack))::numeric
    / NULLIF( COUNT(*) FILTER (WHERE p.dropback), 0 )
  , 3) AS sack_rate
FROM plays p
JOIN teams t ON t.team_id = p.offense_team_id
GROUP BY t.team_abbr
ORDER BY pressure_rate DESC NULLS LAST;
