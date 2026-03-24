WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
class_best AS (
    SELECT
        car_class,
        MIN(average_position) AS min_average_position
    FROM car_stats
    GROUP BY car_class
)
SELECT
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count
FROM car_stats cs
JOIN class_best cb
    ON cs.car_class = cb.car_class
   AND cs.average_position = cb.min_average_position
ORDER BY cs.average_position;