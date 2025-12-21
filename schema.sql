/* =========================================
   Olist E-Commerce Dataset – Database Schema
   ========================================= */

-- Customers: basic customer info + location
CREATE TABLE customers (
    customer_id                VARCHAR PRIMARY KEY,
    customer_unique_id         VARCHAR,
    customer_zip_code_prefix   INTEGER,
    customer_city              VARCHAR,
    customer_state             VARCHAR(2)
);

-- Orders: one row per order 
CREATE TABLE orders (
    order_id                       VARCHAR PRIMARY KEY,
    customer_id                    VARCHAR NOT NULL REFERENCES customers(customer_id),
    order_status                   VARCHAR,
    order_purchase_timestamp       TIMESTAMP,
    order_approved_at              TIMESTAMP,
    order_delivered_carrier_date   TIMESTAMP,
    order_delivered_customer_date  TIMESTAMP,
    order_estimated_delivery_date  TIMESTAMP
);

-- Products: product details and dimensions
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

-- Sellers: seller information and location
CREATE TABLE sellers (
    seller_id               VARCHAR PRIMARY KEY,
    seller_zip_code_prefix  INTEGER,
    seller_city             VARCHAR,
    seller_state            VARCHAR(2)
);

-- Order items: products within each order
CREATE TABLE order_items (
    order_id             VARCHAR NOT NULL REFERENCES orders(order_id),
    order_item_id        INTEGER NOT NULL,
    product_id           VARCHAR NOT NULL REFERENCES products(product_id),
    seller_id            VARCHAR NOT NULL REFERENCES sellers(seller_id),
    shipping_limit_date  TIMESTAMP,
    price                NUMERIC(10,2),
    freight_value        NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

-- Payments: payment details per order
CREATE TABLE order_payments (
    order_id             VARCHAR NOT NULL REFERENCES orders(order_id),
    payment_sequential   INTEGER NOT NULL,
    payment_type         VARCHAR,
    payment_installments INTEGER,
    payment_value        NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- Reviews: customer reviews and scores (1–5)
CREATE TABLE order_reviews (
    review_id               VARCHAR,
    order_id                VARCHAR NOT NULL REFERENCES orders(order_id),
    review_score            INTEGER CHECK (review_score BETWEEN 1 AND 5),
    review_comment_title    VARCHAR,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- Geolocation: zip prefix to latitude/longitude
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat             NUMERIC(9,6),
    geolocation_lng             NUMERIC(9,6),
    geolocation_city            VARCHAR,
    geolocation_state           VARCHAR(2)
);

-- Category translation: Portuguese → English
CREATE TABLE product_category_name_translation (
    product_category_name         VARCHAR PRIMARY KEY,
    product_category_name_english VARCHAR
);
