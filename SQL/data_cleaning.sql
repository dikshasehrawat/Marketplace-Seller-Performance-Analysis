-- =========================================================
-- Data Cleaning & Exploration Queries
-- Marketplace Seller Performance Analysis
-- =========================================================
-- Note: These queries were developed and run via a Python/SQLite
-- connection in Python/eda.ipynb. This file documents the SQL logic
-- as the reference artifact for the cleaning/join process.

-- ---------------------------------------------------------
-- 1. Null value findings (full check done in eda.ipynb)
-- ---------------------------------------------------------
-- orders: order_approved_at (160), order_delivered_carrier_date (1,783),
--         order_delivered_customer_date (2,965) nulls
--         -> caused by orders that never completed their lifecycle
-- order_reviews: review_comment_title/message nulls are expected
--         (most customers don't leave written comments)
-- products: 610 rows missing category/name/description/photo count
--         (incomplete listings), 2 rows missing physical dimensions

-- ---------------------------------------------------------
-- 2. Order status breakdown -- explains the null delivery dates
-- ---------------------------------------------------------
SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Result: 96,478 of 99,441 orders (97%) are 'delivered'.
-- RULE: Any delivery-time / delay analysis must filter to
--       order_status = 'delivered' to avoid nulls and avoid counting
--       orders that never shipped.

-- ---------------------------------------------------------
-- 3. Duplicate row check across all tables
-- ---------------------------------------------------------
-- Result: every core table (customers, orders, order_items,
-- order_payments, order_reviews, products, sellers,
-- category_translation) had 0 duplicate rows.
-- geolocation had 261,831 duplicate rows out of 1,000,163
-- (1,000,163 rows -> only 19,015 unique zip codes).

-- ---------------------------------------------------------
-- 4. Geolocation deduplication
-- ---------------------------------------------------------
-- Reduced geolocation from 1,000,163 rows to 19,015 rows by grouping
-- on zip_code_prefix and averaging lat/lng (multiple GPS readings per
-- zip code collapsed into one representative coordinate).
-- Saved as table: geolocation_clean

-- ---------------------------------------------------------
-- 5. order_reviews: duplicate reviews per order
-- ---------------------------------------------------------
-- Found 547 orders with more than one review row (some with 3).
-- Left joining order_reviews directly onto order_items inflated the
-- row count from 112,650 to 113,314 (~0.6% overcounted).
-- FIX: keep only the most recent review per order using ROW_NUMBER()
-- partitioned by order_id, ordered by review_creation_date DESC.

SELECT order_id, COUNT(*) AS review_count
FROM order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY review_count DESC;

-- ---------------------------------------------------------
-- 6. Master aggregated table: order_master
-- ---------------------------------------------------------
-- Joins orders + order_items + customers + sellers + products +
-- category_translation + (deduplicated) order_reviews into one
-- order-item-level table. This is the base table all further
-- analysis (seller performance, delivery delay, revenue, regional)
-- is built on. Row count: 112,650 (matches order_items exactly --
-- confirms no join inflated or dropped rows).

SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    c.customer_city,
    c.customer_state,
    s.seller_city,
    s.seller_state,
    p.product_category_name,
    ct.product_category_name_english,
    r.review_score
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN sellers s ON oi.seller_id = s.seller_id
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
LEFT JOIN (
    SELECT order_id, review_score,
           ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_creation_date DESC) AS rn
    FROM order_reviews
) r ON o.order_id = r.order_id AND r.rn = 1;

-- ---------------------------------------------------------
-- 7. Derived metric: delivery_delay_days
-- ---------------------------------------------------------
-- Added in Python (pandas datetime arithmetic) after the join:
-- delivery_delay_days = order_delivered_customer_date - order_estimated_delivery_date
-- Positive = delivered late, Negative = delivered early, NULL = not
-- yet delivered (order never completed).
-- order_master saved back into olist.db with this column included.