-- 04_exploratory_queries.sql
-- High-level exploration of Olist e-commerce data

-- Customers by state
SELECT customer_state, COUNT(*) AS num_customers
FROM customers
GROUP BY customer_state
ORDER BY num_customers DESC;

-- Orders per month
SELECT DATE_TRUNC('month', order_purchase_timestamp) AS month,
       COUNT(*) AS num_orders
FROM orders
GROUP BY month
ORDER BY month;

-- Orders by status
SELECT order_status, COUNT(*) AS num_orders
FROM orders
GROUP BY order_status
ORDER BY num_orders DESC;

-- Products by category
SELECT product_category_name, COUNT(*) AS num_products
FROM products
GROUP BY product_category_name
ORDER BY num_products DESC
LIMIT 20;

-- Sellers by state
SELECT seller_state, COUNT(*) AS num_sellers
FROM sellers
GROUP BY seller_state
ORDER BY num_sellers DESC;

-- Distribution of review scores
SELECT review_score, COUNT(*) AS num_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

-- Basic price & freight stats
SELECT
    AVG(price)         AS avg_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price,
    AVG(freight_value) AS avg_freight
FROM order_items;

-- Average delivery time (days)
SELECT
    AVG(order_delivered_customer_date - order_purchase_timestamp) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;
