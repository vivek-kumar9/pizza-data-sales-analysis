-- Total revenue
SELECT SUM(total_price) AS total_revenue FROM pizza_sales;

-- Most ordered pizza types
SELECT pizza_type, SUM(quantity) AS total_sold
FROM pizza_sales
GROUP BY pizza_type
ORDER BY total_sold DESC;

-- Monthly revenue
SELECT MONTH(date) AS month, SUM(total_price) AS revenue
FROM pizza_sales
GROUP BY MONTH(date);
