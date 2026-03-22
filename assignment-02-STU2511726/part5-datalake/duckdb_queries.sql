-- ============================================================
-- Answer 5.1 — Cross-Format Queries using DuckDB
-- File: part5-datalake/duckdb_queries.sql
-- Description: DuckDB queries reading directly from raw files
--              (customers.csv, orders.json, products.parquet)
-- ============================================================

-- ============================================================
-- REAL DATA STRUCTURE (confirmed from actual files):
--
-- customers.csv    → customer_id, name, city, signup_date, email
-- orders.json      → order_id, customer_id, order_date, status,
--                    total_amount, num_items
-- products.parquet → line_item_id, order_id, product_id,
--                    product_name, category, quantity,
--                    unit_price, total_price
--
-- HOW DUCKDB READS FILES:
--   read_csv_auto('path.csv')      → reads CSV directly
--   read_json_auto('path.json')    → reads JSON directly
--   read_parquet('path.parquet')   → reads Parquet directly
-- ============================================================


-- ============================================================
-- Q1: List all customers along with the total number of
--     orders they have placed
-- ============================================================
-- Logic:
--   - Read customers.csv and orders.json
--   - LEFT JOIN on customer_id (LEFT JOIN keeps all customers
--     even if they have placed 0 orders)
--   - COUNT orders per customer
--   - Sort by most orders first
-- ============================================================

-- Q1: Total orders placed by each customer
SELECT
    c.customer_id,
    c.name                    AS customer_name,
    c.city,
    COUNT(o.order_id)         AS total_orders
FROM
    read_csv_auto('datasets/customers.csv')  AS c
LEFT JOIN
    read_json_auto('datasets/orders.json')   AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name,
    c.city
ORDER BY
    total_orders DESC;


-- ============================================================
-- Q2: Find the top 3 customers by total order value
-- ============================================================
-- Logic:
--   - Read customers.csv and orders.json
--   - JOIN on customer_id
--   - SUM the total_amount per customer
--     (total_amount is the real column in orders.json)
--   - Sort descending and LIMIT to 3
-- ============================================================

-- Q2: Top 3 customers by total order value
SELECT
    c.customer_id,
    c.name                          AS customer_name,
    c.city,
    COUNT(o.order_id)               AS total_orders,
    SUM(o.total_amount)             AS total_order_value
FROM
    read_csv_auto('datasets/customers.csv')  AS c
JOIN
    read_json_auto('datasets/orders.json')   AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name,
    c.city
ORDER BY
    total_order_value DESC
LIMIT 3;


-- ============================================================
-- Q3: List all products purchased by customers from Bangalore
-- ============================================================
-- Logic:
--   - Filter customers WHERE city = 'Bangalore'
--     (Real Bangalore customers: Neha Shah, Divya Patel,
--      Rohan Pillai, Aarav Sharma, Sneha Mehta)
--   - JOIN customers → orders on customer_id
--   - JOIN orders → products on order_id
--     (products.parquet links to orders via order_id)
--   - DISTINCT avoids showing same product multiple times
-- ============================================================

-- Q3: Products purchased by customers from Bangalore
SELECT DISTINCT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    c.name                    AS customer_name,
    c.city
FROM
    read_csv_auto('datasets/customers.csv')    AS c
JOIN
    read_json_auto('datasets/orders.json')     AS o
    ON c.customer_id = o.customer_id
JOIN
    read_parquet('datasets/products.parquet')  AS p
    ON o.order_id = p.order_id
WHERE
    c.city = 'Bangalore'
ORDER BY
    p.category,
    p.product_name;


-- ============================================================
-- Q4: Join all three files to show:
--     customer name, order date, product name, and total price
-- ============================================================
-- Logic:
--   - This is the MASTER query joining ALL 3 different file
--     formats in a single DuckDB SQL statement
--   - customers.csv   → gives customer name and city
--   - orders.json     → gives order date and status
--   - products.parquet→ gives product name and total price
--   - Join path:
--       customers → orders   (on customer_id)
--       orders    → products (on order_id)
--   - total_price already exists in products.parquet
--     (pre-calculated as quantity × unit_price)
-- ============================================================

-- Q4: Full cross-format join across all 3 files
SELECT
    c.name                    AS customer_name,
    c.city                    AS customer_city,
    o.order_id,
    o.order_date,
    o.status                  AS order_status,
    p.product_name,
    p.category,
    p.quantity,
    p.unit_price,
    p.total_price
FROM
    read_csv_auto('datasets/customers.csv')    AS c
JOIN
    read_json_auto('datasets/orders.json')     AS o
    ON c.customer_id = o.customer_id
JOIN
    read_parquet('datasets/products.parquet')  AS p
    ON o.order_id = p.order_id
ORDER BY
    o.order_date DESC,
    c.name;
