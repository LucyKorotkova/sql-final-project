WITH hotel_categories AS (
    SELECT
        h.ID_hotel,
        h.name AS hotel_name,
        CASE
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) <= 300 THEN 'Средний'
            ELSE 'Дорогой'
        END AS hotel_category
    FROM Hotel h
    JOIN Room r ON h.ID_hotel = r.ID_hotel
    GROUP BY h.ID_hotel, h.name
),
customer_hotel_visits AS (
    SELECT DISTINCT
        c.ID_customer,
        c.name,
        hc.hotel_name,
        hc.hotel_category
    FROM Customer c
    JOIN Booking b ON c.ID_customer = b.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    JOIN hotel_categories hc ON h.ID_hotel = hc.ID_hotel
),
customer_preferences AS (
    SELECT
        ID_customer,
        name,
        CASE
            WHEN SUM(CASE WHEN hotel_category = 'Дорогой' THEN 1 ELSE 0 END) > 0 THEN 'Дорогой'
            WHEN SUM(CASE WHEN hotel_category = 'Средний' THEN 1 ELSE 0 END) > 0 THEN 'Средний'
            ELSE 'Дешевый'
        END AS preferred_hotel_type
    FROM customer_hotel_visits
    GROUP BY ID_customer, name
),
customer_hotels AS (
    SELECT
        ID_customer,
        GROUP_CONCAT(hotel_name ORDER BY hotel_name SEPARATOR ',') AS visited_hotels
    FROM customer_hotel_visits
    GROUP BY ID_customer
)
SELECT
    cp.ID_customer,
    cp.name,
    cp.preferred_hotel_type,
    ch.visited_hotels
FROM customer_preferences cp
JOIN customer_hotels ch ON cp.ID_customer = ch.ID_customer
ORDER BY
    CASE
        WHEN cp.preferred_hotel_type = 'Дешевый' THEN 1
        WHEN cp.preferred_hotel_type = 'Средний' THEN 2
        WHEN cp.preferred_hotel_type = 'Дорогой' THEN 3
    END,
    cp.ID_customer;