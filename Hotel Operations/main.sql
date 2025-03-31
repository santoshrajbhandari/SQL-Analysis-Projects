/* QUICK CHECK THE DATA */
SELECT * 
FROM service;

-- 1. THE LOCATION OF THE PARTICULAR HOTEL. ONE OF FOUR POSSIBLE VALUES, 'EMEA', 'NA', 'LATAM' AND 'APAC'.
--    MISSING VALUES SHOULD BE REPLACED WITH “UNKNOWN”.
-- 2. THE TOTAL NUMBER OF ROOMS IN THE HOTEL. MUST BE A POSITIVE INTEGER BETWEEN 1 AND 400.
--    MISSING VALUES SHOULD BE REPLACED WITH THE DEFAULT NUMBER OF ROOMS, 100.
-- 3. THE NUMBER OF STAFF EMPLOYED IN THE HOTEL SERVICE DEPARTMENT.
--    MISSING VALUES SHOULD BE REPLACED WITH THE TOTAL_ROOMS MULTIPLIED BY 1.5.
-- 4. THE YEAR IN WHICH THE HOTEL OPENED. THIS CAN BE ANY VALUE BETWEEN 2000 AND 2023.
--    MISSING VALUES SHOULD BE REPLACED WITH 2023.
-- 5. THE PRIMARY TYPE OF GUEST THAT IS EXPECTED TO USE THE HOTEL. CAN BE ONE OF 'LEISURE' OR 'BUSINESS'.
--    MISSING VALUES SHOULD BE REPLACED WITH 'LEISURE'.
SELECT id, 
       CASE 
           WHEN location IS NULL THEN 'Unknown'
           ELSE location 
       END AS location,
       CASE 
           WHEN total_rooms IS NULL THEN 100
           ELSE total_rooms 
       END AS total_rooms,
       CASE 
           WHEN staff_count IS NULL THEN CAST(total_rooms * 1.5 AS INTEGER)
           ELSE staff_count 
       END AS staff_count, 
       CASE 
           WHEN opening_date = '-' THEN CAST('2023' AS INTEGER)
           ELSE CAST(opening_date AS INTEGER) 
       END AS opening_date,
       CASE 
           WHEN target_guests IS NULL THEN 'Leisure'
           WHEN target_guests IN ('B.', 'Busniess') THEN 'Business'
           ELSE target_guests 
       END AS target_guests
FROM branch;

-- AVERAGE AND MAXIMUM DURATION FOR EACH BRANCH AND SERVICE.
SELECT r.service_id,
       r.branch_id,
       ROUND(AVG(time_taken), 2) AS avg_time_taken,
       ROUND(MAX(time_taken), 2) AS max_time_taken
FROM request AS r
JOIN branch AS b
ON r.branch_id = b.id
GROUP BY r.service_id, r.branch_id;

-- TARGET IMPROVEMENTS IN MEAL AND LAUNDRY SERVICE IN EUROPE (EMEA) AND LATIN AMERICA (LATAM)
SELECT s.description,
       b.id,
       b.location,
       r.id AS request_id, 
       r.rating
FROM service AS s 
JOIN request AS r
ON s.id = r.service_id
JOIN branch AS b
ON r.branch_id = b.id
WHERE s.description IN ('Meal', 'Laundry') 
  AND b.location IN ('EMEA', 'LATAM');


-- Take a more detailed look at the lowest performing hotels, 
-- you want to get service and branch information where the average rating for the branch and service combination is lower than 4.5 - the target set by management.
SELECT s.id AS service_id,
       r.branch_id,
       ROUND(AVG(r.rating), 2) AS avg_rating
FROM service AS s 
JOIN request AS r
ON s.id = r.service_id
JOIN branch AS b
ON r.branch_id = b.id
GROUP BY s.id, r.branch_id
HAVING AVG(r.rating) < 4.5;