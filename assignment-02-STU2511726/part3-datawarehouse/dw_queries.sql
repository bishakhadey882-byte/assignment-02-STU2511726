-- ============================================================
-- Answer 3.2 — Analytical Queries
-- Description: Business Intelligence queries on the Star Schema
-- ============================================================


-- ============================================================
-- Q1: Total Sales Revenue by Product Category for Each Month
-- ============================================================
-- Purpose: Helps management understand which product categories
--          generate the most revenue month by month.
-- Logic:   We JOIN fact_sales with dim_date (to get month/year)
--          and dim_product (to get category), then GROUP BY
--          category and month to SUM total_revenue.
-- ============================================================

SELECT
    dp.category                          AS product_category,
    dd.year                              AS sale_year,
    dd.month                             AS month_number,
    dd.month_name                        AS month_name,
    SUM(fs.total_revenue)                AS total_revenue,
    SUM(fs.units_sold)                   AS total_units_sold,
    COUNT(fs.transaction_id)             AS total_transactions
FROM
    fact_sales    fs
JOIN dim_date     dd ON fs.date_id    = dd.date_id
JOIN dim_product  dp ON fs.product_id = dp.product_id
GROUP BY
    dp.category,
    dd.year,
    dd.month,
    dd.month_name
ORDER BY
    dd.year,
    dd.month,
    total_revenue DESC;


-- ============================================================
-- Q2: Top 2 Performing Stores by Total Revenue
-- ============================================================
-- Purpose: Identifies which store branches contribute the most
--          to the company's overall revenue — useful for
--          resource allocation and performance benchmarking.
-- Logic:   We JOIN fact_sales with dim_store, SUM total_revenue
--          per store, ORDER BY revenue DESC, then LIMIT to 2.
-- ============================================================

SELECT
    ds.store_id                          AS store_id,
    ds.store_name                        AS store_name,
    ds.store_city                        AS city,
    SUM(fs.total_revenue)                AS total_revenue,
    SUM(fs.units_sold)                   AS total_units_sold,
    COUNT(fs.transaction_id)             AS total_transactions,
    ROUND(AVG(fs.total_revenue), 2)      AS avg_transaction_value
FROM
    fact_sales   fs
JOIN dim_store   ds ON fs.store_id = ds.store_id
GROUP BY
    ds.store_id,
    ds.store_name,
    ds.store_city
ORDER BY
    total_revenue DESC
LIMIT 2;


-- ============================================================
-- Q3: Month-Over-Month Sales Trend Across All Stores
-- ============================================================
-- Purpose: Tracks how total sales revenue changes from one
--          month to the next — critical for spotting growth
--          trends, seasonal dips, and business momentum.
-- Logic:   We SUM revenue per month, then use the LAG() window
--          function to access the previous month's revenue and
--          calculate the % change (MoM growth rate).
-- ============================================================

WITH monthly_revenue AS (
    -- Step 1: Calculate total revenue per month
    SELECT
        dd.year                              AS sale_year,
        dd.month                             AS month_number,
        dd.month_name                        AS month_name,
        SUM(fs.total_revenue)                AS total_revenue,
        COUNT(fs.transaction_id)             AS total_transactions
    FROM
        fact_sales  fs
    JOIN dim_date   dd ON fs.date_id = dd.date_id
    GROUP BY
        dd.year,
        dd.month,
        dd.month_name
)

SELECT
    sale_year,
    month_number,
    month_name,
    total_revenue,
    total_transactions,
    -- Step 2: Get previous month's revenue using LAG()
    LAG(total_revenue) OVER (
        ORDER BY sale_year, month_number
    )                                        AS prev_month_revenue,
    -- Step 3: Calculate Month-over-Month % change
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY sale_year, month_number))
        / LAG(total_revenue) OVER (ORDER BY sale_year, month_number) * 100,
        2
    )                                        AS mom_growth_percent
FROM
    monthly_revenue
ORDER BY
    sale_year,
    month_number;
