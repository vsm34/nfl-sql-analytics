SELECT t.team_abbr,
       ROUND(AVG(p.yards_gained)::numeric, 2) AS ypp
FROM plays p
JOIN teams t ON t.team_id = p.offense_team_id
GROUP BY t.team_abbr
ORDER BY ypp DESC;
