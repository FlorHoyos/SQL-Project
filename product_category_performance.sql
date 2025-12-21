-- Category performance: revenue, orders, and review score 
WITH order_category AS (
  SELECT DISTINCT
    oi.order_id,
    COALESCE(p.product_category_name, 'unknown') AS product_category_name
  FROM order_items oi
  JOIN products p ON oi.product_id = p.product_id
),
category_revenue AS (
  SELECT
    COALESCE(p.product_category_name, 'unknown') AS product_category_name,
    SUM(oi.price) AS revenue,
    COUNT(DISTINCT oi.order_id) AS num_orders
  FROM order_items oi
  JOIN products p ON oi.product_id = p.product_id
  GROUP BY COALESCE(p.product_category_name, 'unknown')
),
category_reviews AS (
  SELECT
    oc.product_category_name,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(*) AS num_reviews
  FROM order_category oc
  JOIN order_reviews r ON oc.order_id = r.order_id
  WHERE r.review_score IS NOT NULL
  GROUP BY oc.product_category_name
)
SELECT
  cr.product_category_name,
  cr.revenue,
  cr.num_orders,
  rv.avg_review_score,
  rv.num_reviews
FROM category_revenue cr
LEFT JOIN category_reviews rv
  ON cr.product_category_name = rv.product_category_name
WHERE COALESCE(rv.num_reviews, 0) >= 50
ORDER BY cr.revenue DESC;
