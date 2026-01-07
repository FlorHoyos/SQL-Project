-- Seller performance: items, orders, revenue, and review score
WITH seller_sales AS (
  SELECT
    items.seller_id,
    COUNT(*) AS num_items_sold,
    COUNT(DISTINCT items.order_id) AS num_orders,
    SUM(items.price) AS revenue
  FROM order_items AS items
  GROUP BY items.seller_id
),
seller_reviews AS (
  SELECT
    dedup.seller_id,
    ROUND(AVG(reviews.review_score), 2) AS avg_review_score,
    COUNT(DISTINCT reviews.order_id) AS num_reviews
  FROM (
    SELECT DISTINCT
      seller_id,
      order_id
    FROM order_items
  ) AS dedup
  JOIN order_reviews AS reviews
    ON dedup.order_id = reviews.order_id
  WHERE reviews.review_score IS NOT NULL
  GROUP BY dedup.seller_id
)
SELECT
  sellers.seller_id,
  sellers.seller_state,
  sales.num_items_sold,
  sales.num_orders,
  sales.revenue,
  reviews.avg_review_score,
  reviews.num_reviews
FROM sellers
JOIN seller_sales AS sales
  ON sellers.seller_id = sales.seller_id
LEFT JOIN seller_reviews AS reviews
  ON sellers.seller_id = reviews.seller_id
ORDER BY sales.revenue DESC;
