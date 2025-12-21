-- Seller performance: items, orders, revenue, and review score 
WITH seller_sales AS (
  SELECT
    oi.seller_id,
    COUNT(*) AS num_items_sold,
    COUNT(DISTINCT oi.order_id) AS num_orders,
    SUM(oi.price) AS revenue
  FROM order_items oi
  GROUP BY oi.seller_id
),
seller_order AS (
  SELECT DISTINCT
    oi.seller_id,
    oi.order_id
  FROM order_items oi
),
seller_reviews AS (
  SELECT
    so.seller_id,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(*) AS num_reviews
  FROM seller_order so
  JOIN order_reviews r ON so.order_id = r.order_id
  WHERE r.review_score IS NOT NULL
  GROUP BY so.seller_id
)
SELECT
  s.seller_id,
  s.seller_state,
  ss.num_items_sold,
  ss.num_orders,
  ss.revenue,
  sr.avg_review_score,
  sr.num_reviews
FROM sellers s
JOIN seller_sales ss ON s.seller_id = ss.seller_id
LEFT JOIN seller_reviews sr ON s.seller_id = sr.seller_id
ORDER BY ss.revenue DESC;
