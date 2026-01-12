-- Aggregations: COUNT/SUM/AVG + GROUP BY + HAVING 

CREATE TABLE customers (
customer_id INT PRIMARY KEY, 
customer_name VARCHAR(50),
city VARCHAR(50)
);

INSERT INTO customers VALUES
(101, 'Anu', 'Dallas'),
(102, 'Ravi', 'Austin'),
(103, 'Meera', 'Houston'),
(104, 'John', 'Dallas'),
(105, 'Sara', 'Irving'),
(106, 'Kiran', 'Plano'),
(107, 'Leela', 'Frisco'),
(108, 'Tom', 'Austin');

-- How many total orders? 
SELECT COUNT(*) as total_orders 
FROM orders; 

-- Total revenue (ignore cancelled + invalid) 
-- We don’t want cancelled orders, NULL amounts, or negative amounts.
-- as basic revenue 
SELECT SUM(amount) as Total_Revenue 
FROM orders 
WHERE status = 'Completed' 
-- Production -safe revenue calculation for business numbers to avoid negative numbers, and null for missing info 
SELECT SUM(amount) as total_revenue 
FROM orders 
WHERE status = 'completed'
AND amount is NOT NULL 
AND amount > 0;

-- Revenue Per day 
SELECT order_date, SUM(amount) 
FROM orders 
WHERE status = 'completed' 
AND amount IS NOT NULL 
AND amount > 0 
GROUP BY ORDER_DATE 
ORDER BY order_Date

-- Orders per customer -- 

SELECT customer_id, COUNT(*) as order_count
FROM orders 
GROUP BY customer_id 
ORDER BY order_count DESC;

-- Total spend per customer (completed + valid only) 
SELECT customer_id, SUM(amount) as total_spend
FROM orders
WHERE status = 'Completed'
AND amount > 0
AND amount IS NOT NULL
GROUP BY customer_id 
ORDER BY total_spend DESC;

--- customers with more than 1 completed order(HAVING) 
SELECT customer_id, COUNT(*) as total_orders 
FROM orders 
WHERE status = 'Completed' 
AND amount IS NOT NULL 
AND amount > 0
GROUP BY customer_id 
HAVING COUNT(*) > 1
ORDER BY total_orders DESC;

--- Revenue by City (JOIN + Group BY) 
SELECT c.city, SUM(o.amount) as city_revenue 
FROM orders o 
JOIN customers c
ON o.customer_id = c.customer_id 
WHERE status = 'completed' 
AND o.amount IS NOT NULL 
AND o.amount > 0 
GROUP BY c.city 
ORDER BY city_revenue DESC;

-- Remember:
-- WHERE filters rows before grouping
-- HAVING filters groups after grouping