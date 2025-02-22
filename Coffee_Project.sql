Create database Coffee
use Coffee

---2.1. Store-Wise Sales***
	---2.1.1. Average revenue generated by each store in this 6 months
		SELECT
			store_location,
			round(AVG(unit_price * transaction_qty),2) AS average_revenue
		FROM
			coffee_sales
		GROUP BY
			store_location
		ORDER BY
			average_revenue desc

			
	---2.1.2. Top 3 best selling product categories in each store
		WITH RankedCategories AS (
			SELECT
				store_location,
				product_category,
				SUM(transaction_qty) AS total_quantity_sold,
				ROW_NUMBER() OVER(PARTITION BY store_location ORDER BY SUM(transaction_qty) DESC) AS category_rank
			FROM
				coffee_sales
			GROUP BY
				store_location,
				product_category
		)
		SELECT
			store_location,
			category_rank,
			product_category,
			total_quantity_sold
			
		FROM
			RankedCategories
		WHERE
			category_rank <= 3
		ORDER BY
			store_location,category_rank;


	---2.1.3. Total revenue generated by each product category
		SELECT
			product_category,
			round(SUM(transaction_qty * unit_price),0) AS total_revenue
		FROM
			coffee_sales
		GROUP BY
			product_category
		ORDER BY
			total_revenue DESC;


	---2.1.4. Top five best selling products of all times
		SELECT TOP 5
			product_type,
			SUM(transaction_qty) AS total_quantity_sold
		FROM
			Coffee_sales
		GROUP BY
			product_type
		ORDER BY
			total_quantity_sold DESC;


	---2.1.5. Bottom 5 products

		SELECT TOP 5
			product_type,
			SUM(transaction_qty) AS total_quantity_sold
		FROM
			Coffee_sales
		GROUP BY
			product_type
		ORDER BY
			total_quantity_sold asc;


----2.2. Sales Trend
	---2.2.1. Hourly sales trend 
			SELECT
				DATEPART(HOUR, transaction_time) AS hour_of_day,
				SUM(transaction_qty) AS total_sales
			FROM
				Coffee_sales
			GROUP BY
				DATEPART(HOUR, transaction_time)
			ORDER BY
				SUM(transaction_qty) desc;

	---2.2.2. Daily sales trend
			SELECT 
				DATENAME(dw, transaction_date) AS day_of_week,
				COUNT(transaction_id) AS number_of_order
			FROM 
			   Coffee_sales
			GROUP BY 
				DATENAME(dw, transaction_date)
			ORDER BY
				COUNT(transaction_id) DESC

			
---.3. Business growth
	--- 2.3.1. Revenue growth of the business by month
		
			CREATE VIEW m_growth AS
			SELECT 
				DATENAME(month, transaction_date) AS month_,
				ROUND(SUM(transaction_qty * unit_price), 0) AS total_revenue,
				LAG(ROUND(SUM(transaction_qty * unit_price), 0)) OVER (ORDER BY MIN(transaction_date)) AS previous_month_revenue,
				CASE
					WHEN LAG(ROUND(SUM(transaction_qty * unit_price), 0)) OVER (ORDER BY MIN(transaction_date)) = 0 THEN NULL
					ELSE ROUND(((SUM(transaction_qty * unit_price) - LAG(SUM(transaction_qty * unit_price)) OVER (ORDER BY MIN(transaction_date))) / LAG(SUM(transaction_qty * unit_price)) OVER (ORDER BY MIN(transaction_date))) * 100, 2)
				END AS percentage_growth
			FROM 
				Coffee_sales
			GROUP BY 
				DATENAME(month, transaction_date);


	----2.3.2. Average growth rate of the business
			SELECT 
				round(AVG(percentage_growth),2) AS average_growth_rate
			FROM 
				m_growth
			WHERE 
				previous_month_revenue IS NOT NULL;
