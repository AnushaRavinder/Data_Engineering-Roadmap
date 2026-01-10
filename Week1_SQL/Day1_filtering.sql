CREATE TABLE orders ( 
order_id INT, 
customer_id INT, 
order_date DATE, 
amount DECIMAL(10,2),
status VARCHAR(20)
);

INSERT INTO orders VALUES
(1, 101, '2025-12-01', 120.50, 'completed'),
(2, 102, '2025-12-02', 75.00, 'completed'),
(3, 101, '2025-12-03', 200.00, 'cancelled'),
(4, 103, '2025-12-04', 50.00, 'completed'),
(5, 104, '2025-12-05', NULL, 'completed'),
(6, 105, '2025-12-06', 300.00, 'completed'),
(7, 106, '2025-12-07', -20.00, 'completed'),
(8, 102, '2025-12-08', 90.00, 'pending'),
(9, 107, '2025-12-09', 500.00, 'completed'),
(10, 108, '2025-12-10', 60.00, 'completed');

-- View All Data 
SELECT * 
FROM orders;

-- Only completed orders -- 
SELECT *
FROM orders 
WHERE status = 'completed';

-- High value orders (amount > 100) 
SELECT * 
FROM orders 
WHERE amount > 100;

-- orders with invalid data, Find null amounts, negative amounts 
	SELECT * 
	FROM orders 
	WHERE amount is NULL 
    OR amount < 0;
    
-- NULL is not a value
-- NULL' (with quotes) is just a string
-- In your table, amount is a DECIMAL, not text
-- SQL will never match NULL using =
-- Think of NULL as:
-- “unknown / missing / not available”
-- You can’t compare unknown with =.

SELECT amount, amount = NULL is equals_null 
FROM orders; -- Is error never true 

-- orders in a date range of december month specific dates 
SELECT * 
FROM orders 
WHERE ORDER_DATE BETWEEN '2025-12-05' AND '2025-12-10';

-- sort orders by highest amount 
SELECT * 
FROM orders 
ORDER BY amount DESC;
-- 🧠 Engineer note:
Sorting is expensive on large datasets — use only when needed.

-- top 5 highest orders 
SELECT * 
FROM orders 
ORDER BY amount DESC
LIMIT 5;
