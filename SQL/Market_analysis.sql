select * from aisles;
select * from departments;
select * from order_products_train;
select * from orders;
select * from products;

-- ALL  joints orders with products, aisles, and departments to get all the required information.
-- 1. Join products with aisles
SELECT
    p.product_id,
    p.product_name,
    p.aisle_id,
    a.aisle
FROM
    products AS p
JOIN aisles AS a
    ON p.aisle_id = a.aisle_id;
-- 2. Join products with departments
SELECT
    p.product_id,
    p.product_name,
    p.department_id,
    d.department
FROM
    products AS p
JOIN departments AS d
    ON p.department_id = d.department_id;
-- 3 Join products with both aisles and departments(to get full product + aisle + department info)
SELECT
    p.product_id,
    p.product_name,
    a.aisle,
    d.department
FROM
    products AS p
JOIN aisles AS a
    ON p.aisle_id = a.aisle_id
JOIN departments AS d
    ON p.department_id = d.department_id;
-- 4. Join order_products__prior with products (to get product name in each order)
    SELECT
    opp.order_id,
    opp.product_id,
    p.product_name,
    opp.reordered,
    opp.add_to_cart_order
FROM
   order_products_train AS opp
JOIN products AS p
    ON opp.product_id = p.product_id;
--  5. Join order_products__prior → products → aisles → departments (to get full product, aisle, and department info for each order item)
    SELECT
    opp.order_id,
    p.product_name,
    a.aisle,
    d.department,
    opp.reordered
FROM
    order_products_train AS opp
JOIN products AS p
    ON opp.product_id = p.product_id
JOIN aisles AS a
    ON p.aisle_id = a.aisle_id
JOIN departments AS d
    ON p.department_id = d.department_id;
-- 6. Join all above with orders (to get user and time info for each order item)
    SELECT
    opp.order_id,
    o.user_id,
    o.order_number,
    o.order_dow,
    o.order_hour_of_day,
    o.days_since_prior_order,
    p.product_name,
    a.aisle,
    d.department,
    opp.add_to_cart_order,
    opp.reordered
FROM
    order_products_train AS opp
JOIN products AS p
    ON opp.product_id = p.product_id
JOIN aisles AS a
    ON p.aisle_id = a.aisle_id
JOIN departments AS d
    ON p.department_id = d.department_id
JOIN orders AS o
    ON opp.order_id = o.order_id;
    
-- 1] What are the top 10 aisles with the highest number of products?
SELECT a.aisle, COUNT(p.product_id) AS product_count
FROM products p
JOIN aisles a ON p.aisle_id = a.aisle_id
GROUP BY a.aisle
ORDER BY product_count DESC
LIMIT 10;

-- 2] How many unique departments are there in the dataset?
SELECT COUNT(DISTINCT department_id) AS unique_departments
FROM departments;

-- 3]What is the distribution of products across departments?
SELECT d.department, COUNT(p.product_id) AS product_count
FROM products p
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY product_count DESC;

-- 4]What are the top 10 products with the highest reorder rates?
SELECT p.product_name,
       SUM(op.reordered) * 1.0 / COUNT(op.reordered) AS reorder_rate
FROM order_products_train op
JOIN products p ON op.product_id = p.product_id
GROUP BY p.product_name
ORDER BY reorder_rate DESC
LIMIT 10;

-- 5]How many unique users have placed orders in the dataset?
SELECT COUNT(DISTINCT user_id) AS unique_users
FROM orders;

-- 6]What is the average number of days between orders for each user?
SELECT user_id, AVG(days_since_prior_order) AS avg_days_between_orders
FROM orders
WHERE days_since_prior_order IS NOT NULL
GROUP BY user_id;

-- 7]What are the peak hours of order placement during the day?
SELECT order_hour_of_day, COUNT(order_id) AS order_count
FROM orders
GROUP BY order_hour_of_day
ORDER BY order_count DESC;

-- 8]How does order volume vary by day of the week?
SELECT 
    order_dow,
    COUNT(*) AS total_orders
FROM 
    orders
GROUP BY 
    order_dow
ORDER BY 
    order_dow;

-- 9]What are the top 10 most ordered products?
SELECT p.product_name, COUNT(op.product_id) AS order_count
FROM order_products_train op
JOIN products p ON op.product_id = p.product_id
GROUP BY p.product_name
ORDER BY order_count DESC
LIMIT 10;

-- 10]How many users have placed orders in each department?

SELECT d.department,COUNT(DISTINCT o.user_id) AS user_count
FROM orders o
JOIN order_products_train opt ON o.order_id = opt.order_id
JOIN products p ON opt.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY user_count DESC;

-- 11]What is the average number of products per order?
SELECT AVG(product_count) AS avg_products_per_order
FROM (
    SELECT order_id, COUNT(product_id) AS product_count
    FROM order_products_train
    GROUP BY order_id
) AS order_sizes;

-- 12]What are the most reordered products in each department?
SELECT d.department, p.product_name, COUNT(*) AS reorder_count
FROM order_products_train op
JOIN products p ON op.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
WHERE op.reordered = 1
GROUP BY d.department, p.product_name
ORDER BY d.department, reorder_count DESC;

-- 13]How many products have been reordered more than once?
SELECT 
    COUNT(*) AS products_reordered_more_than_once
FROM (
    SELECT 
        product_id,
        SUM(reordered) AS total_reorders
    FROM 
        order_products_train
    GROUP BY 
        product_id
    HAVING 
        SUM(reordered) > 1
) AS reordered_products;

-- 14]What is the average number of products added to the cart per order?
SELECT 
    AVG(product_count) AS avg_products_per_order
FROM (
    SELECT 
        order_id, 
        COUNT(product_id) AS product_count
    FROM order_products_train
    GROUP BY order_id
) AS order_product_counts;

-- 15]How does the number of orders vary by hour of the day?
SELECT 
    order_hour_of_day,
    COUNT(*) AS total_orders
FROM 
    orders
GROUP BY 
    order_hour_of_day
ORDER BY 
    order_hour_of_day;

-- 16]What is the distribution of order sizes (number of products per order)?
SELECT 
    product_count AS order_size,
    COUNT(*) AS number_of_orders
FROM (
    SELECT 
        order_id, 
        COUNT(product_id) AS product_count
    FROM order_products_train
    GROUP BY order_id
) AS order_sizes
GROUP BY product_count
ORDER BY order_size;

-- 17]What is the average reorder rate for products in each aisle?
SELECT a.aisle, AVG(op.reordered) AS avg_reorder_rate
FROM order_products_train op
JOIN products p ON op.product_id = p.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
GROUP BY a.aisle
ORDER BY avg_reorder_rate DESC;

-- 18]How does the average order size vary by day of the week?
SELECT o.order_dow, AVG(p_count) AS avg_order_size
FROM (
    SELECT order_id, COUNT(product_id) AS p_count
    FROM order_products_train
    GROUP BY order_id
) AS order_sizes
JOIN orders o ON order_sizes.order_id = o.order_id
GROUP BY o.order_dow
ORDER BY o.order_dow;

-- 19]What are the top 10 users with the highest number of orders?
SELECT user_id, COUNT(order_id) AS order_count
FROM orders
GROUP BY user_id
ORDER BY order_count DESC
LIMIT 10;

-- 20]How many products belong to each aisle and department?
SELECT d.department, a.aisle, COUNT(p.product_id) AS product_count
FROM products p
JOIN aisles a ON p.aisle_id = a.aisle_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department, a.aisle
ORDER BY d.department, product_count DESC;











