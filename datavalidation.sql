SELECT COUNT(*) AS customers_count
FROM customers;

SELECT COUNT(*) AS orders_count
FROM orders;

SELECT COUNT(*) AS products_count
FROM products;

SELECT COUNT(*) AS order_items_count
FROM order_items;

SELECT COUNT(*) AS payments_count
FROM order_payments;

SELECT COUNT(*) AS reviews_count
FROM order_reviews;

SELECT COUNT(*) AS geolocation_count
FROM geolocation;

SELECT COUNT(*) AS category_translation_count
FROM product_category_name_translation;

SELECT COUNT(*) AS sellers_count
FROM sellers;


-- 2. NULL CHECKS ON KEY COLUMNS -----------------------------------------

-- Primary-key style columns should not be NULL
SELECT * FROM customers WHERE customer_id IS NULL;
SELECT * FROM orders    WHERE order_id    IS NULL;
SELECT * FROM products  WHERE product_id  IS NULL;
SELECT * FROM sellers   WHERE seller_id   IS NULL;

-- Important foreign keys
SELECT * FROM orders       WHERE customer_id IS NULL;
SELECT * FROM order_items  WHERE order_id    IS NULL
                           OR product_id     IS NULL
                           OR seller_id      IS NULL;
SELECT * FROM order_payments WHERE order_id IS NULL;
SELECT * FROM order_reviews  WHERE order_id IS NULL;


-- 3. ORPHAN FOREIGN KEYS (BROKEN RELATIONSHIPS) -------------------------

-- Orders whose customer_id doesn't exist in customers
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order items whose order_id doesn't exist in orders
SELECT oi.order_id, COUNT(*) AS num_items
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
GROUP BY oi.order_id;

-- Order items whose product_id doesn't exist in products
SELECT oi.product_id, COUNT(*) AS num_items
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
GROUP BY oi.product_id;

-- Order items whose seller_id doesn't exist in sellers
SELECT oi.seller_id, COUNT(*) AS num_items
FROM order_items oi
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL
GROUP BY oi.seller_id;

-- Reviews whose order_id doesn't exist in orders
SELECT r.review_id, r.order_id
FROM order_reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 4. DUPLICATE KEY CHECKS -----------------------------------------------

-- Any duplicate customer_id?
SELECT customer_id, COUNT(*) AS dup_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Any duplicate order_id?
SELECT order_id, COUNT(*) AS dup_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Any duplicate product_id?
SELECT product_id, COUNT(*) AS dup_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Any duplicate seller_id?
SELECT seller_id, COUNT(*) AS dup_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- Note: order_reviews.review_id can be duplicated in raw data, 
-- so this is informational, not necessarily an error.
SELECT review_id, COUNT(*) AS dup_count
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;


-- 5. BASIC VALUE QUALITY CHECKS -----------------------------------------

-- Negative prices or freight should not exist
SELECT *
FROM order_items
WHERE price < 0
   OR freight_value < 0;

-- Negative payment values
SELECT *
FROM order_payments
WHERE payment_value < 0;

-- Review scores should be between 1 and 5
SELECT *
FROM order_reviews
WHERE review_score < 1
   OR review_score > 5;

-- 6. OPTIONAL: SAMPLE A FEW ROWS FROM EACH TABLE ------------------------

SELECT * FROM customers  LIMIT 5;
SELECT * FROM orders     LIMIT 5;
SELECT * FROM products   LIMIT 5;
SELECT * FROM sellers    LIMIT 5;
SELECT * FROM order_items LIMIT 5;
SELECT * FROM order_payments LIMIT 5;
SELECT * FROM order_reviews LIMIT 5;
SELECT * FROM geolocation LIMIT 5;
SELECT * FROM product_category_name_translation LIMIT 5;