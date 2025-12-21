-- ===============================================================
-- customer_geography.sql
-- Customer distribution, orders, and revenue by state
-- Tableau-ready final dataset
-- ===============================================================

SELECT
  c.customer_state,
  COUNT(DISTINCT c.customer_unique_id) AS num_customers,
  COUNT(DISTINCT o.order_id)           AS num_orders,
  ROUND(SUM(oi.price), 2)              AS revenue,
  ROUND(
    AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400.0),
    2
  ) AS avg_delivery_days
FROM customers c
JOIN orders o
  ON c.customer_id = o.customer_id
JOIN order_items oi
  ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY c.customer_state
ORDER BY revenue DESC;
