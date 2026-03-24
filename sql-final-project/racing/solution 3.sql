WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        cl.country AS car_country,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Classes cl ON c.class = cl.class
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class, cl.country
),
class_stats AS (
    SELECT
        car_class,
        AVG(average_position) AS class_average_position,
        SUM(race_count) AS total_races
    FROM car_stats
    GROUP BY car_class
),
best_classes AS (
    SELECT
        car_class,
        total_races
    FROM class_stats
    WHERE class_average_position = (
        SELECT MIN(class_average_position)
        FROM class_stats
    )
)
SELECT
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count,
    cs.car_country,
    bc.total_races
FROM car_stats cs
JOIN best_classes bc ON cs.car_class = bc.car_class
ORDER BY cs.car_name;