-- Monthly sales trend: orders and revenue
SELECT
  DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
  COUNT(DISTINCT o.order_id) AS total_orders,
  SUM(oi.price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY month
ORDER BY month;
