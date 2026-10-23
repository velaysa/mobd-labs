SET search_path TO marketplace;

-- задание 1
INSERT INTO users (full_name, email, phone, role)
SELECT
    'Пользователь ' || g,
    'user' || g || '@mail.ru',
    '+7900' || LPAD(g::TEXT, 7, '0'),
    CASE WHEN g <= 20 THEN 'buyer_seller' ELSE 'buyer' END
FROM generate_series(1, 100) AS g;

INSERT INTO sellers (user_id, store_name, description)
SELECT
    id,
    'Магазин ' || id,
    'Описание магазина ' || id
FROM users
WHERE id <= 20;

INSERT INTO categories (name)
VALUES
    ('Электроника'),
    ('Одежда'),
    ('Обувь'),
    ('Книги'),
    ('Красота'),
    ('Спорт'),
    ('Дом'),
    ('Игрушки'),
    ('Продукты'),
    ('Аксессуары');

INSERT INTO products (seller_id, category_id, title, price, is_active)
SELECT
    floor(random() * 20)::INT + 1,
    floor(random() * 10)::INT + 1,
    'Товар ' || g,
    (random() * 9000 + 1000)::NUMERIC(12,2),
    random() > 0.1
FROM generate_series(1, 1000) AS g;

INSERT INTO stock (product_id, quantity)
SELECT
    id,
    floor(random() * 100)::INT
FROM products;

INSERT INTO carts (user_id)
SELECT id
FROM users;

INSERT INTO cart_items (cart_id, product_id, quantity)
SELECT
    ((g - 1) % 100) + 1,
    g,
    floor(random() * 5)::INT + 1
FROM generate_series(1, 200) AS g;

INSERT INTO orders (user_id, status, created_at)
SELECT
    floor(random() * 100)::INT + 1,
    CASE g % 6
        WHEN 0 THEN 'new'
        WHEN 1 THEN 'paid'
        WHEN 2 THEN 'processing'
        WHEN 3 THEN 'shipped'
        WHEN 4 THEN 'delivered'
        ELSE 'cancelled'
    END,
    CURRENT_TIMESTAMP - (g || ' hours')::INTERVAL
FROM generate_series(1, 1000) AS g;

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    o.id,
    p.id,
    floor(random() * 3)::INT + 1,
    p.price
FROM orders o
JOIN products p ON p.id = o.id;

UPDATE orders o
SET total_amount = (
    SELECT SUM(oi.quantity * oi.unit_price)
    FROM order_items oi
    WHERE oi.order_id = o.id
);

INSERT INTO payments (order_id, amount, status, paid_at)
SELECT
    id,
    total_amount,
    CASE
        WHEN status = 'cancelled' THEN 'failed'
        WHEN status = 'new' THEN 'pending'
        ELSE 'paid'
    END,
    CASE
        WHEN status IN ('paid', 'processing', 'shipped', 'delivered')
        THEN created_at + INTERVAL '10 minutes'
        ELSE NULL
    END
FROM orders;

INSERT INTO reviews (user_id, product_id, score, comment)
SELECT
    floor(random() * 100)::INT + 1,
    g,
    floor(random() * 5)::INT + 1,
    'Отзыв на товар ' || g
FROM generate_series(1, 500) AS g;

INSERT INTO addresses (user_id, city, street, house, apartment)
SELECT
    id,
    CASE id % 4
        WHEN 0 THEN 'Москва'
        WHEN 1 THEN 'Санкт-Петербург'
        WHEN 2 THEN 'Казань'
        ELSE 'Самара'
    END,
    'Улица ' || id,
    (id % 50 + 1)::TEXT,
    (id % 100 + 1)::TEXT
FROM users;

INSERT INTO deliveries (order_id, address_id, delivery_status, delivery_date)
SELECT
    o.id,
    a.id,
    CASE o.status
        WHEN 'delivered' THEN 'delivered'
        WHEN 'shipped' THEN 'shipped'
        WHEN 'cancelled' THEN 'cancelled'
        ELSE 'preparing'
    END,
    CASE
        WHEN o.status = 'delivered'
        THEN o.created_at + INTERVAL '3 days'
        ELSE NULL
    END
FROM orders o
JOIN addresses a ON a.user_id = o.user_id;

COMMIT;


--задание 2
SELECT DISTINCT
    category_id AS category,
    is_active AS availability
FROM marketplace.products;

--задание 3
SELECT id, title, price, category_id, is_active
FROM marketplace.products
WHERE (price BETWEEN 2000 AND 5000 AND is_active = TRUE)
   OR (category_id = 1 AND price < 2000);

-- задание 4
SELECT id, title, price, category_id
FROM marketplace.products
WHERE price BETWEEN 2000 AND 5000
  AND category_id IN (1, 2, 3)
  AND title ILIKE '%товар%';

SELECT id, order_id, paid_at
FROM marketplace.payments
WHERE paid_at IS NULL;

-- задание 5
SELECT id, title, category_id, price
FROM marketplace.products
ORDER BY category_id ASC, price DESC;

-- задание 6
SELECT id, title, price
FROM marketplace.products
ORDER BY id
LIMIT 10 OFFSET 0;

SELECT id, title, price
FROM marketplace.products
ORDER BY id
LIMIT 10 OFFSET 10;

--задание 7