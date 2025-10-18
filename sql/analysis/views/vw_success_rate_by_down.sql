CREATE OR REPLACE VIEW vw_success_by_down AS
SELECT down,
       ROUND(AVG((success)::int)::numeric, 3) AS success_rate,
       COUNT(*) AS plays
FROM plays
GROUP BY down
ORDER BY down;
