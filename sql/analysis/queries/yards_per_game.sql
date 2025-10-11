SELECT g.game_id,
       COUNT(*) AS plays,
       ROUND(AVG(p.yards_gained)::numeric, 2) AS avg_yards
FROM plays p
JOIN games g ON g.game_id = p.game_id
GROUP BY g.game_id
ORDER BY g.game_id;
