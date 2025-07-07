USE datawarehouseanalytics;

-- QUESTION (1): CHANGE OVER TIME
-- SALES PERFORMANCE OVER TIME (BY YEAR AND MONTH)

SELECT 
    YEAR(order_date) AS order_year, 
    MONTH(order_date) AS order_month, 
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity 
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- NOTE: DATETRUNC IS NOT SUPPORTED IN MYSQL.
-- FOR APPLICATIONS LIKE POSTGRESQL OR ANALYTICAL TOOLS (LOOKER, TABLEAU, etc.) YOU CAN USE:
-- SELECT DATE_TRUNC('month', order_date) ...

-- ALTERNATIVE (MYSQL-FRIENDLY) FORMAT: USE DATE_FORMAT FOR CLEAN MONTHLY GROUPING
SELECT 
    DATE_FORMAT(order_date, '%Y-%b') AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%b'), MONTH(order_date), YEAR(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- CONCLUSION:
-- CHANGES OVER TIME → A HIGH-LEVEL OVERVIEW INSIGHT THAT HELPS WITH STRATEGIC DECISION-MAKING.
-- CHANGES OVER TIME BY MONTH → DETAILED INSIGHTS TO DISCOVER SEASONALITY IN YOUR DATA.
