-- Monthly sales trend: orders and revenue
SELECT
  DATE_TRUNC('month', ord.order_purchase_timestamp) AS month,
  COUNT(DISTINCT ord.order_id) AS total_orders,
  SUM(items.price) AS revenue
FROM orders ord
JOIN order_items items
  ON ord.order_id = items.order_id
WHERE ord.order_purchase_timestamp IS NOT NULL
GROUP BY month
ORDER BY month;
