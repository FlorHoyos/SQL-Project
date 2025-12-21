SELECT
    o.order_id,
    o.order_purchase_timestamp                  AS purchase_ts,
    o.order_delivered_customer_date             AS delivered_ts,
    o.order_estimated_delivery_date             AS est_ts,
    (o.order_delivered_customer_date - o.order_purchase_timestamp) AS delivery_days,
    (o.order_delivered_customer_date - o.order_estimated_delivery_date) AS delay_days,
    r.review_score,
    c.customer_state
FROM orders o
JOIN customers c       ON o.customer_id = c.customer_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL;