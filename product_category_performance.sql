SELECT
    COALESCE(p.product_category_name, 'unknown')       AS product_category_name,
    SUM(oi.price)                                      AS revenue,
    COUNT(DISTINCT o.order_id)                         AS num_orders,
    ROUND(AVG(r.review_score), 2)                      AS avg_review_score,
    COUNT(r.review_id)                                 AS num_reviews
FROM products p
JOIN order_items oi ON p.product_id   = oi.product_id
JOIN orders o       ON oi.order_id    = o.order_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
GROUP BY COALESCE(p.product_category_name, 'unknown')
HAVING COUNT(r.review_id) >= 50      -- keep categories with enough reviews
ORDER BY revenue DESC;