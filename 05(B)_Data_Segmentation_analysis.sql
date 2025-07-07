USE datawarehouseanalytics;

-- SQL TASK: GROUP CUSTOMERS INTO 3 SEGMENTS BASED ON SPENDING BEHAVIOR
-- (A) VIP: AT LEAST 12 MONTHS OF HISTORY AND SPENDING > $5000
-- (B) REGULAR: AT LEAST 12 MONTHS OF HISTORY AND SPENDING <= $5000
-- (C) NEW: LIFESPAN LESS THAN 12 MONTHS

WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM fact_sales f
    LEFT JOIN dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)

SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
