SELECT
    s.seller_id,
    s.seller_state,
    COUNT(*)                                AS num_items_sold,
    COUNT(DISTINCT oi.order_id)             AS num_orders,
    SUM(oi.price)                           AS revenue,
    ROUND(AVG(r.review_score), 2)           AS avg_review_score,
    COUNT(r.review_id)                      AS num_reviews
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o       ON oi.order_id = o.order_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
GROUP BY s.seller_id, s.seller_state
ORDER BY revenue DESC;