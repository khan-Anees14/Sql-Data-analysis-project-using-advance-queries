/*
================================================================================
    CUSTOMER REPORT
================================================================================
PURPOSE:
    - THIS REPORT CONSOLIDATES KEY CUSTOMER METRICS AND BEHAVIORS
HIGHLIGHTS:
    1. GATHER ESSENTIAL FIELDS SUCH AS NAMES, AGES, AND TRANSACTION DETAILS.
    2. SEGMENT CUSTOMERS INTO CATEGORIES (VIP, REGULAR, NEW) AND AGE GROUPS.
    3. AGGREGATE CUSTOMER-LEVEL METRICS:
        - TOTAL ORDERS
        - TOTAL SALES
        - TOTAL QUANTITY PURCHASED
        - TOTAL PRODUCTS
        - LIFESPAN (IN MONTHS)
    4. CALCULATE VALUABLE KPIs:
        - RECENCY (MONTHS SINCE LAST ORDER)
        - AVERAGE ORDER VALUES
        - AVERAGE MONTHLY SPEND
================================================================================
*/

USE datawarehouseanalytics;

/*------------------------------------------------------------------------------
 FINAL STEP: CREATE A VIEW TO BE USED FOR DASHBOARDS AND CUSTOMER INSIGHT REPORTS
------------------------------------------------------------------------------*/
CREATE VIEW report_customer AS

WITH base_query AS (
    /*------------------------------------------------------------------------------
    1) BASE QUERY: RETRIEVE CORE COLUMNS FROM TABLES
    ------------------------------------------------------------------------------*/
    SELECT 
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        TIMESTAMPDIFF(YEAR, c.birthdate, SYSDATE()) AS age
    FROM fact_sales f
    LEFT JOIN dim_customers c ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
),

customer_aggregation AS (
    /*------------------------------------------------------------------------------
    2) CUSTOMER AGGREGATION: SUMMARIZE KEY METRICS AT CUSTOMER LEVEL
    ------------------------------------------------------------------------------*/
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_order,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_product,
        MAX(order_date) AS last_order_date,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)

SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,

    -- AGE GROUP SEGMENTATION
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,

    -- ---------------CUSTOMER SEGMENTATION BASED ON LIFESPAN AND SALES
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    last_order_date,
    TIMESTAMPDIFF(MONTH, last_order_date, SYSDATE()) AS recency,
    total_order,
    total_sales,
    total_quantity,
    total_product,
    lifespan,

    -- ----------------------AVERAGE ORDER VALUE
    CASE 
        WHEN total_order = 0 THEN 0
        ELSE total_sales / total_order
    END AS avg_order,

    -- ------------------------AVERAGE MONTHLY SPEND
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE CAST(total_sales / lifespan AS DECIMAL(10))
    END AS avg_monthly_spend

FROM customer_aggregation;
