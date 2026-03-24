

-- solution 1
SELECT
    c.name,
    c.email,
    c.phone,
    COUNT(b.ID_booking) AS total_bookings,
    GROUP_CONCAT(DISTINCT h.name ORDER BY h.name SEPARATOR ', ') AS hotels,
    ROUND(AVG(DATEDIFF(b.check_out_date, b.check_in_date)), 4) AS average_stay_duration
FROM Customer c
JOIN Booking b ON c.ID_customer = b.ID_customer
JOIN Room r ON b.ID_room = r.ID_room
JOIN Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY c.ID_customer, c.name, c.email, c.phone
HAVING COUNT(b.ID_booking) > 2
   AND COUNT(DISTINCT h.ID_hotel) > 1
ORDER BY total_bookings DESC;

-- solution 2
WITH customer_booking_stats AS (
    SELECT
        c.ID_customer,
        c.name,
        COUNT(b.ID_booking) AS total_bookings,
        COUNT(DISTINCT h.ID_hotel) AS unique_hotels,
        SUM(r.price) AS total_spent
    FROM Customer c
    JOIN Booking b ON c.ID_customer = b.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    GROUP BY c.ID_customer, c.name
)
SELECT
    ID_customer,
    name,
    total_bookings,
    ROUND(total_spent, 2) AS total_spent,
    unique_hotels
FROM customer_booking_stats
WHERE total_bookings > 2
  AND unique_hotels > 1
  AND total_spent > 500
ORDER BY total_spent ASC;

-- soluion 3
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