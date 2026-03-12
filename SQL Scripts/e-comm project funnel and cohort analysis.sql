CREATE DATABASE IF NOT EXISTS ecommerce_project;
USE ecommerce_project;

CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    signup_date DATE,
    country VARCHAR(50)
);

CREATE TABLE sessions (
    session_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    session_date DATE,
    device VARCHAR(50),
    utm_source VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE add_to_cart (
    cart_id VARCHAR(50) PRIMARY KEY,
    session_id VARCHAR(50),
    user_id VARCHAR(50),
    product_id VARCHAR(50),
    cart_date DATE,
    FOREIGN KEY (session_id) REFERENCES sessions(session_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    order_date DATE,
    product_id VARCHAR(50),
    quantity INT,
    price DECIMAL(10,2),
    order_value DECIMAL(10,2),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE stock_out (
    stockout_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50),
    stockout_date DATE,
    stockout_reason VARCHAR(100),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE marketing (
    marketing_id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE,
    utm_source VARCHAR(50),
    ad_spend DECIMAL(10,2)
);

SELECT COUNT(*) FROM marketing;

SELECT * FROM sessions LIMIT 5;

SELECT COUNT(*) 
FROM sessions s
LEFT JOIN users u ON s.user_id = u.user_id
WHERE u.user_id IS NULL;

SELECT COUNT(*) 
FROM orders o
LEFT JOIN products p ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Funnel Analysis: Sessions → Add to Cart → Orders → Revenue
WITH funnel AS (
    -- All users with sessions
    SELECT DISTINCT user_id
    FROM sessions
),
cart AS (
    -- Users who added to cart
    SELECT DISTINCT user_id
    FROM add_to_cart
),
orders AS (
    -- Users who placed orders
    SELECT
        user_id,
        SUM(order_value) AS revenue
    FROM orders
    GROUP BY user_id
)

SELECT
    COUNT(f.user_id) AS total_users_with_sessions,
    COUNT(c.user_id) AS users_added_to_cart,
    COUNT(o.user_id) AS users_placed_orders,
    SUM(o.revenue) AS total_revenue,
    ROUND((COUNT(c.user_id) / COUNT(f.user_id)) * 100, 2) AS add_to_cart_rate,
    ROUND((COUNT(o.user_id) / COUNT(c.user_id)) * 100, 2) AS conversion_rate_from_cart,
    ROUND((COUNT(o.user_id) / COUNT(f.user_id)) * 100, 2) AS overall_conversion_rate
FROM funnel f
LEFT JOIN cart c
    ON f.user_id = c.user_id
LEFT JOIN orders o
    ON f.user_id = o.user_id;
    
-- Funnel by Day/Week
SELECT
    DATE(s.session_date) AS session_day,
    COUNT(DISTINCT s.user_id) AS total_users_with_sessions,
    
    -- Count users who had a session today AND have an add-to-cart history
    COUNT(DISTINCT c.user_id) AS users_added_to_cart,
    
    -- Count users who had a session today AND have an order history
    COUNT(DISTINCT hist_o.user_id) AS users_placed_orders_history, 
    
    -- Calculate Revenue for orders placed ON THIS SPECIFIC DAY
    IFNULL(SUM(daily_o.order_value), 0.00) AS total_daily_revenue
    
FROM sessions s

-- Check for Cart History
LEFT JOIN add_to_cart c
    ON s.user_id = c.user_id

-- Check for Order History 
LEFT JOIN orders hist_o
    ON s.user_id = hist_o.user_id
    
-- Calculate Revenue for Orders Placed TODAY 
LEFT JOIN orders daily_o
    ON s.user_id = daily_o.user_id
    AND s.session_date = daily_o.order_date 
GROUP BY session_day
ORDER BY session_day
LIMIT 0, 1000;

SELECT
    DATE(s.session_date) AS session_day,
    COUNT(DISTINCT s.user_id) AS total_users_with_sessions,
    COUNT(DISTINCT c.user_id) AS users_added_to_cart,
    COUNT(DISTINCT hist_o.user_id) AS users_placed_orders_history, 
    
    -- Add-to-Cart Rate 
    (COUNT(DISTINCT c.user_id) * 100.0 / COUNT(DISTINCT s.user_id)) AS historical_add_to_cart_rate,
    
    -- Order Conversion Rate 
    (COUNT(DISTINCT hist_o.user_id) * 100.0 / COUNT(DISTINCT s.user_id)) AS historical_order_conversion_rate,
    
    IFNULL(SUM(daily_o.order_value), 0.00) AS total_daily_revenue
    
FROM sessions s
LEFT JOIN add_to_cart c ON s.user_id = c.user_id
LEFT JOIN orders hist_o ON s.user_id = hist_o.user_id
LEFT JOIN orders daily_o
    ON s.user_id = daily_o.user_id AND s.session_date = daily_o.order_date

GROUP BY session_day
ORDER BY session_day;

-- Cohort Retention
WITH 
-- Identifying first purchase month for each user
user_first_order AS (
    SELECT
        user_id,
        MIN(DATE_FORMAT(order_date, '%Y-%m-01')) AS cohort_month
    FROM orders
    GROUP BY user_id
),

-- Mapping all orders to months
orders_by_month AS (
    SELECT
        user_id,
        DATE_FORMAT(order_date, '%Y-%m-01') AS order_month
    FROM orders
),

-- Count active users per cohort per month
cohort_analysis AS (
    SELECT
        u.cohort_month,
        o.order_month,
        COUNT(DISTINCT o.user_id) AS users_active
    FROM user_first_order u
    JOIN orders_by_month o
        ON u.user_id = o.user_id
    GROUP BY u.cohort_month, o.order_month
),

-- Calculate cohort sizes
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM user_first_order
    GROUP BY cohort_month
)

-- Calculate retention %
SELECT
    c.cohort_month,
    c.order_month,
    ROUND((c.users_active / s.cohort_size) * 100, 2) AS retention_rate
FROM cohort_analysis c
JOIN cohort_sizes s
    ON c.cohort_month = s.cohort_month
ORDER BY c.cohort_month, c.order_month;


-- Customer Lifetime Value (LTV) per Cohort
SELECT
    u.cohort_month,
    COUNT(u.user_id) AS total_users,
    
    -- LTV is the total lifetime revenue of the cohort divided by the cohort size
    ROUND(SUM(u.total_revenue) / COUNT(u.user_id), 2) AS LTV_per_user,
    
    -- ARPU (First Month) - Calculated by joining to the first-month revenue subquery
    ROUND(fmr.first_month_revenue_total / COUNT(u.user_id), 2) AS ARPU_first_month,
    
    -- Repeat Rate: Percentage of users in the cohort who placed more than one order
    ROUND(SUM(CASE WHEN u.total_orders > 1 THEN 1 ELSE 0 END) / COUNT(u.user_id) * 100, 2) AS repeat_rate
    
FROM (
    -- Aggregating ALL orders per user (Total Lifetime Values - LTV)
    SELECT
        o.user_id,
        ufo.cohort_month,
        COUNT(o.order_value) AS total_orders,
        SUM(o.order_value) AS total_revenue
    FROM orders o
    JOIN (
        -- Identifying first purchase month for each user
        SELECT
            user_id,
            MIN(DATE_FORMAT(order_date, '%Y-%m-01')) AS cohort_month
        FROM orders
        GROUP BY user_id
    ) ufo ON o.user_id = ufo.user_id
    GROUP BY o.user_id, ufo.cohort_month
) u
JOIN (
    -- Calculating FIRST MONTH Revenue (ARPU)
    SELECT
        ufo.cohort_month,
        SUM(o.order_value) AS first_month_revenue_total
    FROM orders o
    JOIN (
        SELECT
            user_id,
            MIN(DATE_FORMAT(order_date, '%Y-%m-01')) AS cohort_month
        FROM orders
        GROUP BY user_id
    ) ufo ON o.user_id = ufo.user_id
    WHERE DATE_FORMAT(o.order_date, '%Y-%m-01') = ufo.cohort_month
    GROUP BY ufo.cohort_month
) fmr ON u.cohort_month = fmr.cohort_month

GROUP BY u.cohort_month, fmr.first_month_revenue_total
ORDER BY u.cohort_month;

-- RFM Segmentation
WITH rfm AS (
    SELECT
        user_id,
        DATEDIFF(CURDATE(), MAX(order_date)) AS recency_days,
        COUNT(order_value) AS frequency,
        SUM(order_value) AS monetary
    FROM orders
    GROUP BY user_id
)
SELECT
    CASE
        WHEN recency_days <= 400 AND frequency >= 2 AND monetary >= 1000 THEN 'Loyal Customers'
        WHEN recency_days <= 400 AND frequency = 1 THEN 'Recent Customers'
        WHEN recency_days > 400 AND frequency >= 2 THEN 'Frequent but Inactive'
        WHEN recency_days > 400 AND frequency = 1 THEN 'At Risk'
        ELSE 'Others'
    END AS segment,
    COUNT(*) AS customer_count
FROM rfm
GROUP BY segment
ORDER BY customer_count DESC;

-- Marketing Attribution
SELECT
    s.utm_source,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(DISTINCT o.user_id) AS converted_users,
    SUM(o.order_value) AS total_revenue,
    ROUND((COUNT(DISTINCT o.user_id) / COUNT(DISTINCT s.session_id)) * 100, 2) AS conversion_rate
FROM sessions s
LEFT JOIN orders o
    ON s.user_id = o.user_id
    AND DATE(o.order_date) >= DATE(s.session_date) 
GROUP BY s.utm_source
ORDER BY total_revenue DESC;
