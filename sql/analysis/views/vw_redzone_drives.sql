-- Red-zone trips (drives that enter the RZ) and TD rate per drive.
CREATE OR REPLACE VIEW public.vw_redzone_drives AS
WITH drive_rollup AS (
  SELECT
    p.game_id,
    p.offense_team_id AS team_id,
    p.drive,
    BOOL_OR(p.red_zone_play)                    AS entered_rz,
    BOOL_OR(COALESCE(p.touchdown, FALSE))       AS drive_td
  FROM plays p
  WHERE p.drive IS NOT NULL
  GROUP BY p.game_id, p.offense_team_id, p.drive
)
SELECT
  t.team_abbr,
  COUNT(*) FILTER (WHERE d.entered_rz)                       AS rz_trips,
  COUNT(*) FILTER (WHERE d.entered_rz AND d.drive_td)        AS rz_td_drives,
  CASE WHEN COUNT(*) FILTER (WHERE d.entered_rz) = 0
       THEN NULL
       ELSE ROUND(
         AVG(CASE WHEN d.entered_rz THEN (d.drive_td)::int END)::numeric
       , 3)
  END AS td_rate_per_rz_drive
FROM drive_rollup d
JOIN teams t ON t.team_id = d.team_id
GROUP BY t.team_abbr
ORDER BY td_rate_per_rz_drive DESC NULLS LAST, rz_trips DESC, t.team_abbr;
