
-- solution 1
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

-- solution 2
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
)
SELECT
    car_name,
    car_class,
    ROUND(average_position, 4) AS average_position,
    race_count,
    car_country
FROM car_stats
ORDER BY average_position ASC, car_name ASC
LIMIT 1;

-- solution 3
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

-- solution 4
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
        COUNT(*) AS car_count
    FROM car_stats
    GROUP BY car_class
)
SELECT
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count,
    cs.car_country
FROM car_stats cs
JOIN class_stats cls ON cs.car_class = cls.car_class
WHERE cls.car_count >= 2
  AND cs.average_position < cls.class_average_position
ORDER BY cs.car_class ASC, cs.average_position ASC;

-- solution 5
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