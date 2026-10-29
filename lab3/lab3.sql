-- задание 1
SET search_path TO marketplace;

SELECT
    p.id AS product_id,
    p.title AS product_name,
    c.name AS category_name,
    s.store_name AS seller_name,
    p.price
FROM products p
INNER JOIN categories c
    ON p.category_id = c.id
INNER JOIN sellers s
    ON p.seller_id = s.id;

-- задание 2
SELECT
    p.id AS product_id,
    p.title AS product_name,
    p.price,
    r.id AS review_id
FROM marketplace.products p
LEFT JOIN marketplace.reviews r
    ON p.id = r.product_id
WHERE r.id IS NULL;

-- заданме 3
SELECT
    c.name AS category_name,
    COUNT(p.id) AS product_count,
    ROUND(AVG(p.price), 2) AS average_price
FROM marketplace.categories c
JOIN marketplace.products p
    ON c.id = p.category_id
GROUP BY c.id, c.name
ORDER BY c.name;

-- задание 4
SELECT
    s.store_name AS seller_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM marketplace.sellers s
JOIN marketplace.products p
    ON s.id = p.seller_id
JOIN marketplace.order_items oi
    ON p.id = oi.product_id
JOIN marketplace.orders o
    ON oi.order_id = o.id
WHERE o.status IN ('paid', 'processing', 'shipped', 'delivered')
GROUP BY s.id, s.store_name
HAVING SUM(oi.quantity * oi.unit_price) > 100000
ORDER BY total_revenue DESC;

-- задание 5.1
SELECT
    title,
    price,
    (SELECT ROUND(AVG(price), 2)
     FROM marketplace.products) AS average_price
FROM marketplace.products
WHERE price > (
    SELECT AVG(price)
    FROM marketplace.products
);

--задание 5.2
SELECT
    title,
    price
FROM marketplace.products
WHERE category_id IN (
    SELECT id
    FROM marketplace.categories
    WHERE name = 'Одежда'
);

-- задание 5.3
SELECT
    s.store_name
FROM marketplace.sellers s
WHERE EXISTS (
    SELECT 1
    FROM marketplace.products p
    WHERE p.seller_id = s.id
);

-- задание 6.1
WITH seller_revenue AS (
    SELECT
        p.seller_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM marketplace.products p
    JOIN marketplace.order_items oi
        ON p.id = oi.product_id
    GROUP BY p.seller_id
)
SELECT
    s.store_name,
    sr.revenue
FROM seller_revenue sr
JOIN marketplace.sellers s
    ON sr.seller_id = s.id
ORDER BY sr.revenue DESC; 

-- задание 6.2

-- добавление подкатегорий
INSERT INTO marketplace.categories (name, parent_id)
VALUES
    ('Смартфоны',
        (SELECT id FROM marketplace.categories
         WHERE name = 'Электроника')),
    ('Ноутбуки',
        (SELECT id FROM marketplace.categories
         WHERE name = 'Электроника')),
    ('Мужская одежда',
        (SELECT id FROM marketplace.categories
         WHERE name = 'Одежда')),
    ('Женская одежда',
        (SELECT id FROM marketplace.categories
         WHERE name = 'Одежда'));

-- рекурсивный CTE
WITH RECURSIVE category_tree AS (
    SELECT
        id,
        name,
        parent_id,
        1 AS level
    FROM marketplace.categories
    WHERE parent_id IS NULL
    UNION ALL
    SELECT
        c.id,
        c.name,
        c.parent_id,
        ct.level + 1
    FROM marketplace.categories c
    JOIN category_tree ct
        ON c.parent_id = ct.id
)
SELECT
    id,
    name,
    parent_id,
    level
FROM category_tree
ORDER BY level, parent_id, id;

--задание 7
CREATE OR REPLACE VIEW marketplace.category_statistics AS
SELECT
    c.name AS category_name,
    COUNT(p.id) AS product_count,
    ROUND(AVG(p.price), 2) AS average_price
FROM marketplace.categories c
LEFT JOIN marketplace.products p
    ON c.id = p.category_id
GROUP BY c.id, c.name;

SELECT *
FROM marketplace.category_statistics;

CREATE OR REPLACE VIEW marketplace.seller_revenue AS
SELECT
    s.store_name AS seller_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM marketplace.sellers s
JOIN marketplace.products p
    ON s.id = p.seller_id
JOIN marketplace.order_items oi
    ON p.id = oi.product_id
JOIN marketplace.orders o
    ON oi.order_id = o.id
WHERE o.status IN ('paid', 'processing', 'shipped', 'delivered')
GROUP BY s.id, s.store_name;

SELECT *
FROM marketplace.seller_revenue
ORDER BY total_revenue DESC;
		 