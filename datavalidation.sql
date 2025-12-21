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
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'order_items without orders', COUNT(*)
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'order_items without products', COUNT(*)
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'order_items without sellers', COUNT(*)
FROM order_items oi
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL
UNION ALL
SELECT 'reviews without orders', COUNT(*)
FROM order_reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 4) Duplicate checks (should be 0 for PK tables)
SELECT 'duplicate customers.customer_id' AS check_name, COUNT(*) AS dup_keys
FROM (
  SELECT customer_id
  FROM customers
  GROUP BY customer_id
  HAVING COUNT(*) > 1
) d
UNION ALL
SELECT 'duplicate orders.order_id', COUNT(*)
FROM (
  SELECT order_id
  FROM orders
  GROUP BY order_id
  HAVING COUNT(*) > 1
) d
UNION ALL
SELECT 'duplicate products.product_id', COUNT(*)
FROM (
  SELECT product_id
  FROM products
  GROUP BY product_id
  HAVING COUNT(*) > 1
) d
UNION ALL
SELECT 'duplicate sellers.seller_id', COUNT(*)
FROM (
  SELECT seller_id
  FROM sellers
  GROUP BY seller_id
  HAVING COUNT(*) > 1
) d;


-- 5) Value checks (should be 0)
SELECT 'negative item price/freight' AS check_name, COUNT(*) AS issue_count
FROM order_items
WHERE price < 0 OR freight_value < 0
UNION ALL
SELECT 'negative payment_value', COUNT(*)
FROM order_payments
WHERE payment_value < 0
UNION ALL
SELECT 'review_score outside 1-5', COUNT(*)
FROM order_reviews
WHERE review_score < 1 OR review_score > 5;


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
