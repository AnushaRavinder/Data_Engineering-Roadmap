-- JOINS 
-- Know INNER vs LEFT JOIN deeply
-- Detect missing data
-- Understand why LEFT JOIN is used in pipelines
-- Avoid duplicate explosion bugs
-- 
-- Tables quick check 
-- I have Orders Table with columns and Customers table with columns 

-- Orders with customer details (INNER JOIN) -- Meaning: Only orders with matching customers appear 
SELECT o.customer_id, c.customer_name, o.order_id, o.order_date, o.amount, o.status, c.city
FROM orders o 
INNER JOIN customers c 
ON o.customer_id = c.customer_id; 

-- or 
-- Works below, but not recommended 
SELECT *
FROM orders o 
INNER JOIN customers c 
ON o.customer_id = c.customer_id;

-- GOLDEN RULES
-- Why the above *  is risky in real systems
-- Duplicate columns (customer_id appears twice)
-- Pulls unnecessary data
-- Breaks downstream pipelines when schema changes
-- Harder to debug and read
-- Use SELECT * only for exploration.
-- Use explicit columns for pipelines.
-- Reporting Table is confusion chaos 


-- Orders with customer Details(LEFT JOIN) When to use? (All orders appear - even if customer data is missing) 
SELECT o.order_id, o.amount, c.customer_name, c.city
FROM orders o 
LEFT JOIN customers c 
ON o.customer_id = c.customer_id; 

-- Orders with missing customers(DATA Quality) 
-- “In pipelines, I use LEFT JOIN + NULL checks to detect orphan records before loading analytics tables.”
-- 
SELECT o.*
FROM orders o 
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Total revenue per customer ( JOIN + GROUP BY) 
-- Why LEFT JOIN? So, customers with zero orders still appear
SELECT c.customer_id, c.customer_name, SUM(o.amount) as total_revenue 
FROM orders o 
LEFT JOIN customers c 
ON o.customer_id = c.customer_id 
WHERE o.customer_id IS NOT NULL 
AND o.status = 'completed'
AND o.amount > 0 
GROUP BY c.customer_id 
ORDER BY total_revenue DESC;

-- JOIN EXPLOSION awarness -
SELECT COUNT(*) 
FROM ORDERS 
-- With above how many order rows exist before any join? 
-- THEN 
-- 
SELECT COUNT(*) 
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id;
-- This is not about data, it's about data check. 
-- After I join orders with customers, did the number of rows change? NO, since the output is same. 
-- So, the data is safe
-- if counts jump unexpectedly in real life - bad join Ex below 
-- customer_id | name
-- 101         | Anu
-- 101         | Anusha   ← duplicate!
-- order_id | customer_id
-- 1        | 101

-- Business QUERIES 
-- Q1 - Who are the top customers by total revenue? 
SELECT c.customer_name, c.customer_id, SUM(o.amount) as total_revenue 
FROM customers c 
JOIN orders o 
ON o.customer_id = c.customer_id 
AND o.status = 'completed' 
AND o.status IS NOT NULL
AND o.amount > 0 
GROUP BY c.customer_id, c.customer_name 
ORDER BY total_revenue DESC

-- below is wrong WHY? LEFT JOIN is correct when you want: customers with zero orders, inactive customers, missing reference detection 
-- Q1 - Who are the top customers by total revenue? 
-- BIG Data Engineer Rule (memorize this)
-- If you filter the LEFT table in WHERE, a LEFT JOIN becomes an INNER JOIN.
-- So ask yourself:
-- Do I want unmatched rows?
-- If not → use INNER JOIN
-- If yes → LEFT JOIN + filter only RIGHT table in WHERE

SELECT c.customer_name, c.customer_id, SUM(o.amount) as total_revenue 
FROM orders o 
LEFT JOIN customers c 
ON o.customer_id = c.customer_id 
AND o.status = 'completed' 
AND o.status IS NOT NULL
AND o.amount > 0 
GROUP BY c.customer_id, c.customer_name 
ORDER BY total_revenue DESC;

-- * Use INNER JOIN for analytics; use LEFT JOIN for completeness and data quality.

-- Q2- How much revenue do we make each day? 
-- Below, you don't need JOIN and also order by order_date becz revenue per day but not asking Highest amount so no DESC
SELECT order_date, SUM(amount) as revenue 
FROM orders 
WHERE status = 'completed' 
AND amount > 0 
AND status IS NOT NULL 
GROUP BY order_date 
ORDER BY order_date;

-- Q3 - Which cutomers are inactive in the last 30 days? 
SELECT c.customer_id, c.customer_name, MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o 
ON c.customer_id = o.customer_id 
GROUP BY c.customer_name, c.customer_id 
ORDER BY MAX(o.order_date) < curdate() - INTERVAL 30 DAY, 
         MAX(o.order_date) IS NULL;

-- For above Q notes: 
-- Start from customers (everyone matters)
-- LEFT JOIN keeps customers with no orders
-- MAX(order_date) finds last activity
-- HAVING filters after aggregation
-- IS NULL catches customers who never ordered
 
-- Q4 - What is total revenue by city? 
SELECT c.city, SUM(o.amount) as total_revenue 
FROM customers c 
JOIN orders o 
ON o.customer_id = c.customer_id 
WHERE status = 'completed' 
AND o.amount > 0 
AND status IS NOT NULL 
GROUP BY c.city 
ORDER BY total_revenue DESC;

-- *** Pattern you should notice (very important)
-- Question type	            JOIN type
-- Revenue / metrics	        INNER JOIN
-- Missing / inactive data	    LEFT JOIN
-- Data quality checks	        LEFT JOIN + NULL
-- Simple summaries	            No JOIN

