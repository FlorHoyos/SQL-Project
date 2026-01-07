-- 05_business_insights.sql
-- 1) MONTHLY SALES & REVENUE TRENDS ------------------------------

-- Monthly order volume
SELECT
  DATE_TRUNC('month', ord.order_purchase_timestamp) AS month,
  COUNT(DISTINCT ord.order_id) AS total_orders
FROM orders AS ord
WHERE ord.order_purchase_timestamp IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- Monthly revenue (items only)
SELECT
  DATE_TRUNC('month', ord.order_purchase_timestamp) AS month,
  SUM(items.price) AS revenue
FROM orders AS ord
JOIN order_items AS items
  ON ord.order_id = items.order_id
WHERE ord.order_purchase_timestamp IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- Revenue growth month-over-month
WITH monthly_revenue AS (
  SELECT
    DATE_TRUNC('month', ord.order_purchase_timestamp) AS month,
    SUM(items.price) AS revenue
  FROM orders AS ord
  JOIN order_items AS items
    ON ord.order_id = items.order_id
  WHERE ord.order_purchase_timestamp IS NOT NULL
  GROUP BY 1
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
FROM monthly_revenue
ORDER BY month;



-- 2) CUSTOMER BEHAVIOR & RETENTION -------------------------------

-- New vs repeat (counts orders, not customers)
WITH first_order AS (
  SELECT
    cust.customer_unique_id,
    MIN(ord.order_purchase_timestamp) AS first_purchase
  FROM orders AS ord
  JOIN customers AS cust
    ON ord.customer_id = cust.customer_id
  WHERE ord.order_purchase_timestamp IS NOT NULL
  GROUP BY cust.customer_unique_id
),
order_classification AS (
  SELECT
    ord.order_id,
    cust.customer_unique_id,
    CASE
      WHEN ord.order_purchase_timestamp = fo.first_purchase THEN 'New Customer'
      ELSE 'Repeat Customer'
    END AS customer_type
  FROM orders AS ord
  JOIN customers AS cust
    ON ord.customer_id = cust.customer_id
  JOIN first_order AS fo
    ON cust.customer_unique_id = fo.customer_unique_id
  WHERE ord.order_purchase_timestamp IS NOT NULL
)
SELECT
  customer_type,
  COUNT(*) AS num_orders
FROM order_classification
GROUP BY 1;


-- Top customer states by revenue
SELECT
  cust.customer_state,
  SUM(items.price) AS revenue
FROM customers AS cust
JOIN orders AS ord
  ON cust.customer_id = ord.customer_id
JOIN order_items AS items
  ON ord.order_id = items.order_id
GROUP BY 1
ORDER BY revenue DESC
LIMIT 10;



-- 3) PRODUCT & CATEGORY INSIGHTS --------------------------------

-- Top 10 categories by revenue
SELECT
  prod.product_category_name,
  SUM(items.price) AS revenue
FROM products AS prod
JOIN order_items AS items
  ON prod.product_id = items.product_id
WHERE prod.product_category_name IS NOT NULL
GROUP BY 1
ORDER BY revenue DESC
LIMIT 10;


-- Average review score by category
-- (reviews are per order)
WITH order_category AS (
  SELECT DISTINCT
    items.order_id,
    prod.product_category_name
  FROM order_items AS items
  JOIN products AS prod
    ON items.product_id = prod.product_id
  WHERE prod.product_category_name IS NOT NULL
),
category_reviews AS (
  SELECT
    oc.product_category_name,
    rev.order_id,
    rev.review_score
  FROM order_category AS oc
  JOIN order_reviews AS rev
    ON oc.order_id = rev.order_id
  WHERE rev.review_score IS NOT NULL
)
SELECT
  product_category_name,
  COUNT(DISTINCT order_id) AS num_reviews,
  ROUND(AVG(review_score), 2) AS avg_review_score
FROM category_reviews
GROUP BY 1
HAVING COUNT(DISTINCT order_id) > 50
ORDER BY avg_review_score DESC;



-- 4) DELIVERY PERFORMANCE ----------------------------------------

-- Average delivery time in days (delivered orders only)
SELECT
  ROUND(
    AVG(EXTRACT(EPOCH FROM (ord.order_delivered_customer_date - ord.order_purchase_timestamp)) / 86400.0),
    2
  ) AS avg_delivery_days
FROM orders AS ord
WHERE ord.order_purchase_timestamp IS NOT NULL
  AND ord.order_delivered_customer_date IS NOT NULL;


-- Delay vs review score (days late vs estimated date)
SELECT
  rev.review_score,
  ROUND(
    AVG(EXTRACT(EPOCH FROM (ord.order_delivered_customer_date - ord.order_estimated_delivery_date)) / 86400.0),
    2
  ) AS avg_days_late
FROM orders AS ord
JOIN order_reviews AS rev
  ON ord.order_id = rev.order_id
WHERE ord.order_delivered_customer_date IS NOT NULL
  AND ord.order_estimated_delivery_date IS NOT NULL
  AND rev.review_score IS NOT NULL
GROUP BY 1
ORDER BY 1;



-- 5) Late delivery rate by month (% of delivered orders that were late)
SELECT
  DATE_TRUNC('month', ord.order_purchase_timestamp) AS month,
  COUNT(*) FILTER (
    WHERE ord.order_delivered_customer_date IS NOT NULL
      AND ord.order_estimated_delivery_date IS NOT NULL
  ) AS delivered_orders,
  ROUND(
    100.0 * AVG(
      CASE
        WHEN ord.order_delivered_customer_date IS NOT NULL
         AND ord.order_estimated_delivery_date IS NOT NULL
         AND ord.order_delivered_customer_date > ord.order_estimated_delivery_date
        THEN 1 ELSE 0 END
    ),
    2
  ) AS late_delivery_rate_pct
FROM orders AS ord
WHERE ord.order_purchase_timestamp IS NOT NULL
GROUP BY 1
ORDER BY 1;



-- 6) Top sellers by revenue + average review score
-- seller revenue from items; seller review score from delivered order reviews
WITH seller_revenue AS (
  SELECT
    items.seller_id,
    SUM(items.price) AS revenue
  FROM order_items AS items
  GROUP BY 1
),
seller_order_reviews AS (
  -- Deduplicate to 1 row per (seller_id, order_id) before joining reviews,
  -- so orders with multiple items don't overweight review score.
  SELECT DISTINCT
    items.seller_id,
    items.order_id
  FROM order_items AS items
),
seller_reviews AS (
  SELECT
    sor.seller_id,
    ROUND(AVG(rev.review_score), 2) AS avg_review_score,
    COUNT(DISTINCT sor.order_id) AS num_reviews
  FROM seller_order_reviews AS sor
  JOIN order_reviews AS rev
    ON sor.order_id = rev.order_id
  WHERE rev.review_score IS NOT NULL
  GROUP BY 1
)
SELECT
  sell.seller_id,
  sell.seller_state,
  ROUND(sr.revenue, 2) AS revenue,
  srv.avg_review_score,
  srv.num_reviews
FROM seller_revenue AS sr
JOIN sellers AS sell
  ON sr.seller_id = sell.seller_id
LEFT JOIN seller_reviews AS srv
  ON sr.seller_id = srv.seller_id
ORDER BY sr.revenue DESC
LIMIT 10;
