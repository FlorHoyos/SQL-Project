

-- =====================
-- Customers
-- CSV: olist_customers_dataset.csv
-- =====================
CREATE TABLE customers (
    customer_id                VARCHAR PRIMARY KEY,
    customer_unique_id         VARCHAR,
    customer_zip_code_prefix   INTEGER,
    customer_city              VARCHAR,
    customer_state             VARCHAR(2)
);

-- =====================
-- Orders
-- CSV: olist_orders_dataset.csv
-- =====================
CREATE TABLE orders (
    order_id                       VARCHAR PRIMARY KEY,
    customer_id                    VARCHAR REFERENCES customers(customer_id),
    order_status                   VARCHAR,
    order_purchase_timestamp       TIMESTAMP,
    order_approved_at              TIMESTAMP,
    order_delivered_carrier_date   TIMESTAMP,
    order_delivered_customer_date  TIMESTAMP,
    order_estimated_delivery_date  TIMESTAMP
);

-- =====================
-- Products
-- CSV: olist_products_dataset.csv
-- (typo 'lenght' matches the real CSV)
-- =====================
CREATE TABLE products (
    product_id                    VARCHAR PRIMARY KEY,
    product_category_name         VARCHAR,
    product_name_lenght           INTEGER,
    product_description_lenght    INTEGER,
    product_photos_qty            INTEGER,
    product_weight_g              NUMERIC,
    product_length_cm             NUMERIC,
    product_height_cm             NUMERIC,
    product_width_cm              NUMERIC
);

-- =====================
-- Sellers
-- CSV: olist_sellers_dataset.csv
-- =====================
CREATE TABLE sellers (
    seller_id               VARCHAR PRIMARY KEY,
    seller_zip_code_prefix  INTEGER,
    seller_city             VARCHAR,
    seller_state            VARCHAR(2)
);

-- =====================
-- Order items
-- CSV: olist_order_items_dataset.csv
-- =====================
CREATE TABLE order_items (
    order_id             VARCHAR REFERENCES orders(order_id),
    order_item_id        INTEGER,
    product_id           VARCHAR REFERENCES products(product_id),
    seller_id            VARCHAR REFERENCES sellers(seller_id),
    shipping_limit_date  TIMESTAMP,
    price                NUMERIC,
    freight_value        NUMERIC,
    PRIMARY KEY (order_id, order_item_id)
);

-- =====================
-- Order payments
-- CSV: olist_order_payments_dataset.csv
-- =====================
CREATE TABLE order_payments (
    order_id             VARCHAR REFERENCES orders(order_id),
    payment_sequential   INTEGER,
    payment_type         VARCHAR,
    payment_installments INTEGER,
    payment_value        NUMERIC
);

-- =====================
-- Order reviews
-- CSV: olist_order_reviews_dataset.csv
-- (no PK so duplicate review_id values from the CSV won't break import)
-- =====================
CREATE TABLE order_reviews (
    review_id               VARCHAR,
    order_id                VARCHAR REFERENCES orders(order_id),
    review_score            INTEGER,
    review_comment_title    VARCHAR,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- =====================
-- Geolocation
-- CSV: olist_geolocation_dataset.csv
-- =====================
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat             NUMERIC,
    geolocation_lng             NUMERIC,
    geolocation_city            VARCHAR,
    geolocation_state           VARCHAR(2)
);

-- =====================
-- Product category translation
-- CSV: product_category_name_translation.csv
-- =====================
CREATE TABLE product_category_name_translation (
    product_category_name         VARCHAR,
    product_category_name_english VARCHAR
);
