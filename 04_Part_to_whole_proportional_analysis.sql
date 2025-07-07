USE datawarehouseanalytics;

-- QUESTION (4): PART-TO-WHOLE ANALYSIS
-- IDENTIFY WHICH CATEGORIES CONTRIBUTE THE MOST TO OVERALL SALES

WITH category_sales AS (
    SELECT 
        p.category, 
        SUM(f.sales_amount) AS total_sales,
        COUNT(DISTINCT f.order_number) AS total_order
    FROM fact_sales f
    LEFT JOIN dim_products p ON p.product_key = f.product_key
    GROUP BY p.category
)

SELECT 
    category,
    total_sales,
    total_order,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(ROUND((total_sales / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total_sales,
    CONCAT(ROUND((total_order / SUM(total_order) OVER ()) * 100, 2), '%') AS percentage_of_total_orders
FROM category_sales;
