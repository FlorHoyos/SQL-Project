
-- 05_business_insights.sql
-- 1) MONTHLY SALES & REVENUE TRENDS ------------------------------

-- Monthly order volume
SELECT
  DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
  COUNT(*) AS total_orders
FROM orders o
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY month
ORDER BY month;


-- Monthly revenue (items only)
SELECT
  DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
  SUM(oi.price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY month
ORDER BY month;


-- Revenue growth month-over-month
WITH revenue AS (
  SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    SUM(oi.price) AS revenue
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_purchase_timestamp IS NOT NULL
  GROUP BY month
)
SELECT
  month,
  revenue,
  LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
  ROUND(
    100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
    / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
    2
  ) AS pct_growth
FROM revenue
ORDER BY month;



-- 2) CUSTOMER BEHAVIOR & RETENTION -------------------------------

-- New vs repeat (counts orders, not customers)
WITH first_order AS (
  SELECT
    c.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_purchase
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  WHERE o.order_purchase_timestamp IS NOT NULL
  GROUP BY c.customer_unique_id
),
order_classification AS (
  SELECT
    o.order_id,
    c.customer_unique_id,
    CASE
      WHEN o.order_purchase_timestamp = f.first_purchase THEN 'New Customer'
      ELSE 'Repeat Customer'
    END AS customer_type
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  JOIN first_order f ON c.customer_unique_id = f.customer_unique_id
  WHERE o.order_purchase_timestamp IS NOT NULL
)
SELECT
  customer_type,
  COUNT(*) AS num_orders
FROM order_classification
GROUP BY customer_type;


-- Top customer states by revenue
SELECT
  c.customer_state,
  SUM(oi.price) AS revenue
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10;



-- 3) PRODUCT & CATEGORY INSIGHTS --------------------------------

-- Top 10 categories by revenue
SELECT
  p.product_category_name,
  SUM(oi.price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;


-- Average review score by category
-- (reviews are per order)
WITH order_category AS (
  SELECT DISTINCT
    oi.order_id,
    p.product_category_name
  FROM order_items oi
  JOIN products p ON oi.product_id = p.product_id
  WHERE p.product_category_name IS NOT NULL
),
category_reviews AS (
  SELECT
    oc.product_category_name,
    r.review_score
  FROM order_category oc
  JOIN order_reviews r ON oc.order_id = r.order_id
  WHERE r.review_score IS NOT NULL
)
SELECT
  product_category_name,
  COUNT(*) AS num_reviews,
  ROUND(AVG(review_score), 2) AS avg_review_score
FROM category_reviews
GROUP BY product_category_name
HAVING COUNT(*) > 50
ORDER BY avg_review_score DESC;



-- 4) DELIVERY PERFORMANCE ----------------------------------------

-- Average delivery time in days (delivered orders only)
SELECT
  ROUND(
    AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)) / 86400.0),
    2
  ) AS avg_delivery_days
FROM orders
WHERE order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL;


-- Delay vs review score (days late vs estimated date)
SELECT
  r.review_score,
  ROUND(
    AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)) / 86400.0),
    2
  ) AS avg_days_late
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND r.review_score IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;



-- 5) Late delivery rate by month (% of delivered orders that were late)
SELECT
  DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
  COUNT(*) FILTER (
    WHERE o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
  ) AS delivered_orders,
  ROUND(
    100.0 * AVG(
      CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
         AND o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1 ELSE 0 END
    ),
    2
  ) AS late_delivery_rate_pct
FROM orders o
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY month
ORDER BY month;


-- 6) Top sellers by revenue + average review score
-- (seller revenue from items; seller review score from delivered order reviews)
WITH seller_revenue AS (
  SELECT
    oi.seller_id,
    SUM(oi.price) AS revenue
  FROM order_items oi
  GROUP BY oi.seller_id
),
seller_reviews AS (
  SELECT
    oi.seller_id,
    AVG(r.review_score) AS avg_review_score,
    COUNT(*) AS num_reviews
  FROM order_items oi
  JOIN order_reviews r ON oi.order_id = r.order_id
  WHERE r.review_score IS NOT NULL
  GROUP BY oi.seller_id
)
SELECT
  s.seller_id,
  s.seller_state,
  ROUND(sr.revenue, 2) AS revenue,
  ROUND(srv.avg_review_score, 2) AS avg_review_score,
  srv.num_reviews
FROM seller_revenue sr
JOIN sellers s ON sr.seller_id = s.seller_id
LEFT JOIN seller_reviews srv ON sr.seller_id = srv.seller_id
ORDER BY sr.revenue DESC
LIMIT 10;
