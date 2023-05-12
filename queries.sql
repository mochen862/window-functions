DROP TABLE IF EXISTS bookings;

-- =================================

CREATE TABLE bookings (
	booking_id INT PRIMARY KEY,
	listing_name VARCHAR,
	host_id INT,
	host_name VARCHAR(50),
	neighbourhood_group VARCHAR(30),
	neighbourhood VARCHAR(30),	
	latitude DECIMAL(11,8),
	longitude DECIMAL(11,8),
	room_type VARCHAR(30),
	price INT,
	minimum_nights INT,
	num_of_reviews INT,
	last_review DATE,
	reviews_per_month DECIMAL(4,2),
	calculated_host_listings_count INT,
	availability_365 INT
);

-- =================================

-- my psql command line command

-- \COPY bookings FROM 'C:/Users/moche/Downloads/AB_NYC_2019.csv' DELIMITER ',' CSV HEADER ENCODING 'utf8'

-- =================================

-- Window Functions with OVER

-- Average price with OVER
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	AVG(price) OVER()
FROM bookings;

-- Average, minimum and maximum price with OVER
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	AVG(price) OVER(),
	MIN(price) OVER(),
	MAX(price) OVER()
FROM bookings;

-- Difference from average price with OVER
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	price,
	ROUND(AVG(price) OVER(), 2),
	ROUND((price - AVG(price) OVER()), 2) AS diff_from_avg
FROM bookings;

-- Percent of average price with OVER()
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	price,
	ROUND(AVG(price) OVER(), 2) AS avg_price,
	ROUND((price / AVG(price) OVER() * 100), 2) AS percent_of_avg_price
FROM bookings;

-- Percent difference from average price
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	price,
	ROUND(AVG(price) OVER(), 2) AS avg_price,
	ROUND((price / AVG(price) OVER() - 1) * 100, 2) AS percent_diff_from_avg_price
FROM bookings;

--****************************************************

-- PARTITION BY

-- PARTITION BY neighbourhood group
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	price,
	AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group
FROM bookings;

-- PARTITION BY neighbourhood group and neighbourhood
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	price,
	AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group,
	AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood) AS avg_price_by_group_and_neigh
FROM bookings;

-- Neighbourhood group and neighbourhood group and neighbourhood delta
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	price,
	AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group,
	AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood) AS avg_price_by_group_and_neigh,
	ROUND(price - AVG(price) OVER(PARTITION BY neighbourhood_group), 2) AS neigh_group_delta,
	ROUND(price - AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood), 2) AS group_and_neigh_delta
FROM bookings;

--******************************************************

-- ROW_NUMBER

-- overall price rank
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank
FROM bookings;

-- neighbourhood price rank
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank
FROM bookings;

-- Top 3
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
	CASE
		WHEN ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <= 3 THEN 'Yes'
		ELSE 'No'
	END AS top3_flag
FROM bookings;

--*********************************************************

-- RANK
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_rank,
	ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
	RANK() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank_with_rank
FROM bookings;

-- DENSE_RANK
SELECT
	booking_id,
	listing_name,
	neighbourhood_group,
	neighbourhood,
	price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_rank,
	DENSE_RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_dense_rank
FROM bookings;

--*********************************************************

-- LAG BY 1 period
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LAG(price) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

-- LAG BY 2 periods
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LAG(price, 2) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

-- LEAD by 1 period
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LEAD(price) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

-- LEAD by 2 periods
SELECT
	booking_id,
	listing_name,
	host_name,
	price,
	last_review,
	LEAD(price, 2) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings;

--******************************************************

-- Top 3 with subquery to select only the 'Yes' values in the top3_flag column
SELECT * FROM (
	SELECT
		booking_id,
		listing_name,
		neighbourhood_group,
		neighbourhood,
		price,
		ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
		ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank,
		CASE
			WHEN ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <= 3 THEN 'Yes'
			ELSE 'No'
		END AS top3_flag
	FROM bookings
	) a
WHERE top3_flag = 'Yes'

