/* ===========================
   Data Validation Checks
   =========================== */

-- 1) Row counts
SELECT 'customers'  AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders',     COUNT(*) FROM orders
UNION ALL
SELECT 'products',   COUNT(*) FROM products
UNION ALL
SELECT 'sellers',    COUNT(*) FROM sellers
UNION ALL
SELECT 'order_items',COUNT(*) FROM order_items
UNION ALL
SELECT 'payments',   COUNT(*) FROM order_payments
UNION ALL
SELECT 'reviews',    COUNT(*) FROM order_reviews
UNION ALL
SELECT 'geolocation',COUNT(*) FROM geolocation
UNION ALL
SELECT 'category_translation', COUNT(*) FROM product_category_name_translation;


-- 2) NULL checks (should be 0)
SELECT 'customers.customer_id NULLs' AS check_name, COUNT(*) AS issue_count
FROM customers
WHERE customer_id IS NULL
UNION ALL
SELECT 'orders.order_id NULLs', COUNT(*)
FROM orders
WHERE order_id IS NULL
UNION ALL
SELECT 'orders.customer_id NULLs', COUNT(*)
FROM orders
WHERE customer_id IS NULL
UNION ALL
SELECT 'products.product_id NULLs', COUNT(*)
FROM products
WHERE product_id IS NULL
UNION ALL
SELECT 'sellers.seller_id NULLs', COUNT(*)
FROM sellers
WHERE seller_id IS NULL
UNION ALL
SELECT 'order_items key NULLs', COUNT(*)
FROM order_items
WHERE order_id IS NULL OR order_item_id IS NULL OR product_id IS NULL OR seller_id IS NULL
UNION ALL
SELECT 'order_payments.order_id NULLs', COUNT(*)
FROM order_payments
WHERE order_id IS NULL
UNION ALL
SELECT 'order_reviews.order_id NULLs', COUNT(*)
FROM order_reviews
WHERE order_id IS NULL;


-- 3) Orphan checks (broken relationships, should be 0)
SELECT 'orders without customers' AS check_name, COUNT(*) AS issue_count
FROM orders AS ord
LEFT JOIN customers AS cust
  ON ord.customer_id = cust.customer_id
WHERE ord.customer_id IS NOT NULL
  AND cust.customer_id IS NULL
UNION ALL
SELECT 'order_items without orders', COUNT(*)
FROM order_items AS items
LEFT JOIN orders AS ord
  ON items.order_id = ord.order_id
WHERE items.order_id IS NOT NULL
  AND ord.order_id IS NULL
UNION ALL
SELECT 'order_items without products', COUNT(*)
FROM order_items AS items
LEFT JOIN products AS prod
  ON items.product_id = prod.product_id
WHERE items.product_id IS NOT NULL
  AND prod.product_id IS NULL
UNION ALL
SELECT 'order_items without sellers', COUNT(*)
FROM order_items AS items
LEFT JOIN sellers AS sell
  ON items.seller_id = sell.seller_id
WHERE items.seller_id IS NOT NULL
  AND sell.seller_id IS NULL
UNION ALL
SELECT 'reviews without orders', COUNT(*)
FROM order_reviews AS rev
LEFT JOIN orders AS ord
  ON rev.order_id = ord.order_id
WHERE rev.order_id IS NOT NULL
  AND ord.order_id IS NULL;


-- 4) Duplicate checks (should be 0 for PK tables)
SELECT 'duplicate customers.customer_id' AS check_name, COUNT(*) AS dup_keys
FROM (
  SELECT customer_id
  FROM customers
  GROUP BY customer_id
  HAVING COUNT(*) > 1
) AS dup
UNION ALL
SELECT 'duplicate orders.order_id', COUNT(*)
FROM (
  SELECT order_id
  FROM orders
  GROUP BY order_id
  HAVING COUNT(*) > 1
) AS dup
UNION ALL
SELECT 'duplicate products.product_id', COUNT(*)
FROM (
  SELECT product_id
  FROM products
  GROUP BY product_id
  HAVING COUNT(*) > 1
) AS dup
UNION ALL
SELECT 'duplicate sellers.seller_id', COUNT(*)
FROM (
  SELECT seller_id
  FROM sellers
  GROUP BY seller_id
  HAVING COUNT(*) > 1
) AS dup;


-- 5) Value checks (should be 0)
SELECT 'negative item price/freight' AS check_name, COUNT(*) AS issue_count
FROM order_items AS items
WHERE items.price < 0 OR items.freight_value < 0
UNION ALL
SELECT 'negative payment_value', COUNT(*)
FROM order_payments AS pay
WHERE pay.payment_value < 0
UNION ALL
SELECT 'review_score outside 1-5', COUNT(*)
FROM order_reviews AS rev
WHERE rev.review_score < 1 OR rev.review_score > 5;


-- 6) Quick samples (optional)
SELECT * FROM customers LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM sellers LIMIT 5;
SELECT * FROM order_items LIMIT 5;
SELECT * FROM order_payments LIMIT 5;
SELECT * FROM order_reviews LIMIT 5;
SELECT * FROM geolocation LIMIT 5;
SELECT * FROM product_category_name_translation LIMIT 5;
