-- ============================================================
-- Answer 1.3 — SQL Queries
-- Source tables: customers, products, sales_reps, orders
-- ============================================================


-- Q1: List all customers from Mumbai along with their total order value
-- Total order value = unit_price × quantity for all their orders

SELECT
    c.customer_id,
    c.customer_name,
    c.customer_city,
    SUM(p.unit_price * o.quantity) AS total_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products  p ON o.product_id  = p.product_id
WHERE c.customer_city = 'Mumbai'
GROUP BY c.customer_id, c.customer_name, c.customer_city
ORDER BY total_order_value DESC;

-- Expected output (from data analysis):
-- Vikram Singh  → ₹8,54,280
-- Rohan Mehta   → ₹3,26,390


-- Q2: Find the top 3 products by total quantity sold

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(o.quantity) AS total_quantity_sold
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_quantity_sold DESC
LIMIT 3;

-- Expected output:
-- Notebook  → 91 units
-- Mouse     → 89 units
-- Pen Set   → 80 units


-- Q3: List all sales representatives and the number of unique customers they have served

SELECT
    sr.sales_rep_id,
    sr.sales_rep_name,
    COUNT(DISTINCT o.customer_id) AS unique_customers_served
FROM orders o
JOIN sales_reps sr ON o.sales_rep_id = sr.sales_rep_id
GROUP BY sr.sales_rep_id, sr.sales_rep_name
ORDER BY unique_customers_served DESC;

-- Expected output:
-- Anita Desai  → 8 unique customers
-- Deepak Joshi → 8 unique customers
-- Ravi Kumar   → 8 unique customers


-- Q4: Find all orders where the total value exceeds 10,000, sorted by value descending

SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    o.quantity,
    p.unit_price,
    (p.unit_price * o.quantity) AS total_order_value,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products  p ON o.product_id  = p.product_id
WHERE (p.unit_price * o.quantity) > 10000
ORDER BY total_order_value DESC;

-- Expected output: 79 orders, led by Laptop × 5 = ₹2,75,000


-- Q5: Identify any products that have never been ordered
-- Uses LEFT JOIN to find products with no matching order records

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;

-- Expected output: No products found (all 8 products have been ordered).
-- This confirms full product catalog utilization in 2023.


