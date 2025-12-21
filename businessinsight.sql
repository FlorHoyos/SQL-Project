-- ===============================================================
-- 05_business_insights.sql
-- High-impact business analysis queries for the Olist dataset
-- ===============================================================


-- 1. MONTHLY SALES & REVENUE TRENDS ------------------------------

-- Monthly order volume
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    COUNT(*) AS total_orders
FROM orders o
GROUP BY month
ORDER BY month;

-- Monthly revenue (sum of order_items price)
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    SUM(oi.price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

-- Revenue growth month-over-month
WITH revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(((revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0)) * 100, 2) AS pct_growth
FROM revenue
ORDER BY month;


-- 2. CUSTOMER BEHAVIOR & RETENTION -------------------------------

-- Count of repeat vs new customers
WITH first_order AS (
    SELECT
        customer_unique_id,
        MIN(order_purchase_timestamp) AS first_purchase
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY customer_unique_id
),
order_classification AS (
    SELECT
        o.customer_id,
        c.customer_unique_id,
        CASE
            WHEN o.order_purchase_timestamp = f.first_purchase THEN 'New Customer'
            ELSE 'Repeat Customer'
        END AS customer_type
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN first_order f ON c.customer_unique_id = f.customer_unique_id
)
SELECT customer_type, COUNT(*) AS num_orders
FROM order_classification
GROUP BY customer_type;


-- Top customer states by revenue
SELECT
    c.customer_state,
    SUM(oi.price) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10;


-- 3. PRODUCT & CATEGORY INSIGHTS --------------------------------

-- Top 10 categories by revenue
SELECT
    p.product_category_name,
    SUM(oi.price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;

-- Average review score by category
SELECT
    p.product_category_name,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY p.product_category_name
HAVING COUNT(r.review_id) > 50   -- filter for reliability
ORDER BY avg_review_score DESC;


-- 4. DELIVERY PERFORMANCE ----------------------------------------

-- Average delivery time
SELECT
    AVG(order_delivered_customer_date - order_purchase_timestamp) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Delivery delay vs review score correlation
SELECT
    review_score,
    AVG(order_delivered_customer_date - order_estimated_delivery_date) AS avg_delay
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY review_score
ORDER BY review_score
