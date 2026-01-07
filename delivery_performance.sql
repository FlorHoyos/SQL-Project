-- Delivery performance with delay, reviews, and customer location
WITH reviews_per_order AS (
  SELECT
    rev.order_id,
    AVG(rev.review_score) AS review_score
  FROM order_reviews AS rev
  WHERE rev.review_score IS NOT NULL
  GROUP BY rev.order_id
)
SELECT
  ord.order_id,
  ord.order_purchase_timestamp AS purchase_ts,
  ord.order_delivered_customer_date AS delivered_ts,
  ord.order_estimated_delivery_date AS est_ts,

  -- Total delivery time (days)
  ROUND(
    EXTRACT(EPOCH FROM (ord.order_delivered_customer_date - ord.order_purchase_timestamp)) / 86400.0,
    2
  ) AS delivery_days,

  -- Days late or early (positive = late, negative = early)
  ROUND(
    EXTRACT(EPOCH FROM (ord.order_delivered_customer_date - ord.order_estimated_delivery_date)) / 86400.0,
    2
  ) AS delay_days,

  rpo.review_score,
  cust.customer_state
FROM orders AS ord
JOIN customers AS cust
  ON ord.customer_id = cust.customer_id
LEFT JOIN reviews_per_order AS rpo
  ON ord.order_id = rpo.order_id
WHERE ord.order_purchase_timestamp IS NOT NULL
  AND ord.order_delivered_customer_date IS NOT NULL
  AND ord.order_estimated_delivery_date IS NOT NULL;
