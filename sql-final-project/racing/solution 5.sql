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
class_race_stats AS (
    SELECT
        c.class AS car_class,
        COUNT(r.race) AS total_races
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
),
low_position_stats AS (
    SELECT
        car_class,
        COUNT(*) AS low_position_count
    FROM car_stats
    WHERE average_position > 3.0
    GROUP BY car_class
)
SELECT
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count,
    cs.car_country,
    crs.total_races,
    lps.low_position_count
FROM car_stats cs
JOIN class_race_stats crs ON cs.car_class = crs.car_class
JOIN low_position_stats lps ON cs.car_class = lps.car_class
WHERE cs.average_position > 3.0
ORDER BY lps.low_position_count DESC, cs.car_name;