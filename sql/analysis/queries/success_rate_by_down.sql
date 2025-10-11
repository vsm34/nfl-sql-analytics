SELECT down,
       ROUND(AVG(CASE WHEN success THEN 1 ELSE 0 END)::numeric, 3) AS success_rate
FROM plays
GROUP BY down
ORDER BY down;
