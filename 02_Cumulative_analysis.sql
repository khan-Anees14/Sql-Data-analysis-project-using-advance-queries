USE datawarehouseanalytics;
aggregate the data progressively over time
help to understand our business is growing or declining

Question(2)  Cumulative Analysis
-- calculate the total sales over a month
-- and the running total sales over the time

SELECT 
    order_month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_month) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_average_price
FROM (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
) AS monthly_sales;


