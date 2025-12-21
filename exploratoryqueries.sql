-- 04_exploratory_queries.sql

-- Customers by state
SELECT
  customer_state,
  COUNT(*) AS num_customers
FROM customers
GROUP BY customer_state
ORDER BY num_customers DESC;


-- Orders per month (purchase date)
SELECT
  DATE_TRUNC('month', order_purchase_timestamp) AS month,
  COUNT(*) AS num_orders
FROM orders
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY month
ORDER BY month;


-- Orders by status
SELECT
  order_status,
  COUNT(*) AS num_orders
FROM orders
GROUP BY order_status
ORDER BY num_orders DESC;


-- Top product categories (by number of products)
SELECT
  product_category_name,
  COUNT(DISTINCT product_id) AS num_products
FROM products
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
ORDER BY num_products DESC
LIMIT 20;


-- Sellers by state
SELECT
  seller_state,
  COUNT(*) AS num_sellers
FROM sellers
GROUP BY seller_state
ORDER BY num_sellers DESC;


-- Review score distribution
SELECT
  review_score,
  COUNT(*) AS num_reviews
FROM order_reviews
WHERE review_score IS NOT NULL
GROUP BY review_score
ORDER BY review_score;


-- Price & freight summary (avg + median)
SELECT
  AVG(price) AS avg_price,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price,
  AVG(freight_value) AS avg_freight
FROM order_items
WHERE price IS NOT NULL;


-- Average delivery time in days (delivered orders only)
SELECT
  AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)) / 86400.0)
    AS avg_delivery_days
FROM orders
WHERE order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL;
