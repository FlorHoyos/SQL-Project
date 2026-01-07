-- 04_exploratory_queries.sql

-- Customers by state
SELECT
  cust.customer_state,
  COUNT(*) AS num_customers
FROM customers AS cust
GROUP BY 1
ORDER BY num_customers DESC;


-- Orders per month (purchase date)
SELECT
  DATE_TRUNC('month', ord.order_purchase_timestamp) AS month,
  COUNT(DISTINCT ord.order_id) AS num_orders
FROM orders AS ord
WHERE ord.order_purchase_timestamp IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- Orders by status
SELECT
  ord.order_status,
  COUNT(*) AS num_orders
FROM orders AS ord
GROUP BY 1
ORDER BY num_orders DESC;


-- Top product categories (by number of products)
SELECT
  prod.product_category_name,
  COUNT(DISTINCT prod.product_id) AS num_products
FROM products AS prod
WHERE prod.product_category_name IS NOT NULL
GROUP BY 1
ORDER BY num_products DESC
LIMIT 20;


-- Sellers by state
SELECT
  sell.seller_state,
  COUNT(*) AS num_sellers
FROM sellers AS sell
GROUP BY 1
ORDER BY num_sellers DESC;


-- Review score distribution
SELECT
  rev.review_score,
  COUNT(*) AS num_reviews
FROM order_reviews AS rev
WHERE rev.review_score IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- Price & freight summary (avg + median)
SELECT
  AVG(item.price) AS avg_price,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY item.price) AS median_price,
  AVG(item.freight_value) AS avg_freight
FROM order_items AS item
WHERE item.price IS NOT NULL;


-- Average delivery time in days (delivered orders only)
SELECT
  AVG(
    EXTRACT(EPOCH FROM (ord.order_delivered_customer_date - ord.order_purchase_timestamp)) / 86400.0
  ) AS avg_delivery_days
FROM orders AS ord
WHERE ord.order_purchase_timestamp IS NOT NULL
  AND ord.order_delivered_customer_date IS NOT NULL;
