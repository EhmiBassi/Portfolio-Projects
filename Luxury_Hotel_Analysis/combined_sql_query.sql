SELECT id, COALESCE(location, 'Unknown') AS location,
			COALESCE(total_rooms, 100) AS total_rooms,
			COALESCE(staff_count, CAST(total_rooms * 1.5 AS UNSIGNED)) AS staff_count,
			COALESCE(NULLIF(opening_date, '-') + 0, '2023') AS opening_date,
			CASE
				WHEN target_guests = 'B.' THEN 'Business'
				ELSE target_guests
				END AS target_guests
FROM branch;



SELECT service_id,
		branch_id,
		ROUND(AVG(time_taken), 2) AS avg_time_taken,
		MAX(time_taken) AS max_time_taken
FROM request
GROUP BY service_id, branch_id;



SELECT s.description, 
		b.id, 
		b.location, 
		r.id AS request_id, 
		r.rating
FROM service as s
INNER JOIN request AS r
ON s.id = r.service_id
INNER JOIN branch as b
ON r.branch_id = b.id
WHERE s.description IN ('Meal', 'Laundry') 
AND b.location IN ('EMEA', 'LATAM');



SELECT service_id,
		branch_id,
		ROUND(AVG(rating), 2) AS avg_rating
FROM request
GROUP BY service_id, branch_id
HAVING AVG(rating) < 4.5;