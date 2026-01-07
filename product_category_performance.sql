-- Category performance: revenue, orders, and review score
WITH order_category AS (
  SELECT DISTINCT
    items.order_id,
    COALESCE(products.product_category_name, 'unknown') AS product_category_name
  FROM order_items AS items
  JOIN products AS products
    ON items.product_id = products.product_id
),
category_revenue AS (
  SELECT
    COALESCE(products.product_category_name, 'unknown') AS product_category_name,
    SUM(items.price) AS revenue,
    COUNT(DISTINCT items.order_id) AS num_orders
  FROM order_items AS items
  JOIN products AS products
    ON items.product_id = products.product_id
  GROUP BY COALESCE(products.product_category_name, 'unknown')
),
category_reviews AS (
  SELECT
    categories.product_category_name,
    ROUND(AVG(reviews.review_score), 2) AS avg_review_score,
    COUNT(DISTINCT reviews.order_id) AS num_reviews
  FROM order_category AS categories
  JOIN order_reviews AS reviews
    ON categories.order_id = reviews.order_id
  WHERE reviews.review_score IS NOT NULL
  GROUP BY categories.product_category_name
)
SELECT
  revenue_by_category.product_category_name,
  revenue_by_category.revenue,
  revenue_by_category.num_orders,
  reviews_by_category.avg_review_score,
  reviews_by_category.num_reviews
FROM category_revenue AS revenue_by_category
LEFT JOIN category_reviews AS reviews_by_category
  ON revenue_by_category.product_category_name =
     reviews_by_category.product_category_name
WHERE COALESCE(reviews_by_category.num_reviews, 0) >= 50
ORDER BY revenue_by_category.revenue DESC;
