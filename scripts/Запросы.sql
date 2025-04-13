-- 1. Товары с ценой выше средней по категории (WHERE, подзапрос)
SELECT p.name, p.category, p.current_price
FROM Products p
WHERE p.current_price > (
    SELECT AVG(current_price) 
    FROM Products 
    WHERE category = p.category
)
ORDER BY p.category, p.current_price DESC;

-- 2. Фермеры с количеством товаров > 3 (GROUP BY, HAVING)
SELECT f.name, COUNT(p.product_id) AS product_count
FROM Farmers f
JOIN Products p ON f.farmer_id = p.farmer_id
GROUP BY f.farmer_id, f.name
HAVING COUNT(p.product_id) > 3
ORDER BY product_count DESC;

-- 3. Заказы с общей суммой > 10 000 ₽ (подзапрос с IN)
SELECT o.order_id, o.total_amount, c.name AS customer
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE o.order_id IN (
    SELECT order_id 
    FROM Orders 
    WHERE total_amount > 10000
)
ORDER BY o.total_amount DESC;

-- 4. Фермеры без товаров (LEFT JOIN + IS NULL)
SELECT f.name, f.phone_number
FROM Farmers f
LEFT JOIN Products p ON f.farmer_id = p.farmer_id
WHERE p.product_id IS NULL;

-- 5. Рейтинг фермеров по количеству товаров (оконная функция RANK())
SELECT 
    f.name,
    COUNT(p.product_id) AS products_count,
    RANK() OVER (ORDER BY COUNT(p.product_id) DESC AS farmer_rank
FROM Farmers f
LEFT JOIN Products p ON f.farmer_id = p.farmer_id
GROUP BY f.farmer_id, f.name
ORDER BY farmer_rank;

-- 6. Клиенты с максимальным количеством заказов (подзапрос с EXISTS)
SELECT c.name, COUNT(o.order_id) AS order_count
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE EXISTS (
    SELECT 1 
    FROM Orders 
    WHERE customer_id = c.customer_id
)
GROUP BY c.customer_id, c.name
ORDER BY order_count DESC
LIMIT 5;

-- 7. Накопительный итог по складам (оконная функция SUM())
SELECT 
    w.warehouse_id,
    w.address,
    p.category,
    SUM(p.quantity_in_stock) OVER (
        PARTITION BY w.warehouse_id
        ORDER BY p.category
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_quantity
FROM Warehouses w
JOIN Products p ON w.warehouse_id = p.warehouse_id
ORDER BY w.warehouse_id, p.category;

-- 8. Фермеры и их количество товаров (GROUP BY, JOIN)
SELECT f.name, COUNT(p.product_id) AS products_count
FROM Farmers f
LEFT JOIN Products p ON f.farmer_id = p.farmer_id
GROUP BY f.farmer_id, f.name
ORDER BY products_count DESC;

-- 9. Клиенты с буквой "А" в имени (LIKE)
SELECT name, phone_number
FROM Customers
WHERE name LIKE '%А%'
ORDER BY name;

-- 10. Товары дороже 300 ₽ с сортировкой (WHERE, ORDER BY)
SELECT name, category, current_price
FROM Products
WHERE current_price > 300
ORDER BY current_price DESC;

-- 11. Разница между текущим и следующим товаром по цене (оконная функция LEAD())
SELECT 
    product_id,
    name,
    current_price,
    LEAD(current_price) OVER (ORDER BY current_price) AS next_product_price,
    LEAD(current_price) OVER (ORDER BY current_price) - current_price AS price_diff
FROM Products
ORDER BY current_price;
