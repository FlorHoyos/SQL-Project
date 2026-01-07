-- ===============================================================
-- customer_geography.sql
-- Customer distribution, orders, and revenue by state
-- ===============================================================

SELECT
  cust.customer_state,
  COUNT(DISTINCT cust.customer_unique_id) AS num_customers,
  COUNT(DISTINCT ord.order_id)            AS num_orders,
  ROUND(SUM(items.price), 2)              AS revenue,
  ROUND(
    AVG(
      EXTRACT(EPOCH FROM (ord.order_delivered_customer_date - ord.order_purchase_timestamp)) / 86400.0
    ),
    2
  ) AS avg_delivery_days
FROM customers AS cust
JOIN orders AS ord
  ON cust.customer_id = ord.customer_id
LEFT JOIN order_items AS items
  ON ord.order_id = items.order_id
WHERE ord.order_purchase_timestamp IS NOT NULL
GROUP BY cust.customer_state
ORDER BY revenue DESC;
