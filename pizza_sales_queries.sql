/*
   PIZZA SALES ANALYSIS — KPI & INSIGHTS
   Purpose: KPI automation, peak hours, weekend analysis,
   and revenue optimization insights.
*/

/*
0) BASE VIEW: ORDER REVENUE
*/
CREATE OR REPLACE VIEW v_order_revenue AS
SELECT
    o.order_id,
    o.order_date,
    o.order_time,
    od.order_details_id,
    od.quantity,
    p.pizza_id,
    p.size,
    p.price,
    pt.category,
    (od.quantity * p.price) AS revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id;


/* 
1) CORE KPIs (AUTOMATED)
*/

-- Total Revenue
SELECT
    ROUND(SUM(revenue), 2) AS total_revenue
FROM v_order_revenue;

-- Total Orders
SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM v_order_revenue;

-- Total Pizzas Sold
SELECT
    SUM(quantity) AS total_pizzas_sold
FROM v_order_revenue;

-- Average Order Value (AOV)
SELECT
    ROUND(
        SUM(revenue) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM v_order_revenue;


/* 
2) PEAK HOURS ANALYSIS
Identifies high-demand time windows.
*/
SELECT
    EXTRACT(HOUR FROM order_time) AS order_hour,
    COUNT(DISTINCT order_id) AS total_orders
FROM v_order_revenue
GROUP BY order_hour
ORDER BY total_orders DESC;


/* 
3) DAILY / WEEKLY PATTERNS
*/

-- Orders by Day of Week
SELECT
    EXTRACT(DOW FROM order_date) AS day_of_week,  -- 0=Sunday (Postgres)
    COUNT(DISTINCT order_id) AS total_orders
FROM v_order_revenue
GROUP BY day_of_week
ORDER BY day_of_week;

-- Revenue Trend by Date
SELECT
    order_date,
    ROUND(SUM(revenue), 2) AS daily_revenue
FROM v_order_revenue
GROUP BY order_date
ORDER BY order_date;


/*
4) WEEKEND vs WEEKDAY ANALYSIS
Supports the ~19% weekend revenue surge claim.
*/
SELECT
    CASE
        WHEN EXTRACT(DOW FROM order_date) IN (0, 6)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM v_order_revenue
GROUP BY day_type;


/*
5) CATEGORY PERFORMANCE
Understands which pizza categories drive revenue.
*/
SELECT
    category,
    ROUND(SUM(revenue), 2) AS category_revenue
FROM v_order_revenue
GROUP BY category
ORDER BY category_revenue DESC;


/* 
6) SIZE-BASED UPSELLING INSIGHTS
 Core input for 12–15% revenue boost projection.
*/
SELECT
    size,
    ROUND(SUM(revenue), 2) AS size_revenue,
    ROUND(AVG(revenue), 2) AS avg_revenue_per_line
FROM v_order_revenue
GROUP BY size
ORDER BY size_revenue DESC;


/*
7) AOV BY SIZE MIX
Shows how larger sizes increase order value.
*/
SELECT
    size,
    ROUND(
        SUM(revenue) / COUNT(DISTINCT order_id),
        2
    ) AS aov_by_size
FROM v_order_revenue
GROUP BY size
ORDER BY aov_by_size DESC;


/*
8) TOP PERFORMING PIZZAS
Useful for menu optimization & promotions.
*/
SELECT
    pizza_id,
    category,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM v_order_revenue
GROUP BY pizza_id, category
ORDER BY total_revenue DESC
LIMIT 10;


/*  
9) INSIGHT SUMMARY (OPTIONAL)
One query to feed Tableau text annotations.
*/
SELECT
    ROUND(SUM(CASE WHEN EXTRACT(DOW FROM order_date) IN (0,6) THEN revenue END), 2)
        AS weekend_revenue,
    ROUND(SUM(CASE WHEN EXTRACT(DOW FROM order_date) NOT IN (0,6) THEN revenue END), 2)
        AS weekday_revenue
FROM v_order_revenue;
