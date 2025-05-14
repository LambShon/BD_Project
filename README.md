# База данных "Фермерский кооператив"

made by Шонгуров Андрей
## Краткое описание
Эта база данных предназначена для автоматизации учета продукции, заказов и логистики в фермерском кооперативе. Она включает информацию о фермерах, продукции, складах, покупателях, заказах и их деталях. Основная цель — обеспечить прозрачность поставок, контроль остатков товаров и учет заказов, а также сохранять историю изменений ключевых данных, таких как цены на продукцию.
## Концептуальная модель
![Концептуальная модель](https://github.com/user-attachments/assets/ecb0428e-92ab-48d3-875d-d5a78c675ad8)
## Логическая модель
![Логическая модель](https://github.com/user-attachments/assets/bf50c28d-d047-45c5-b882-4fe1bab97f49)
## Описание таблиц
1. Фермеры (Farmers)  
  Содержит информацию о поставщиках продукции:
    * `farmer_id` (PK) — уникальный ID фермера
    * `name` — ФИО фермера
    * `phone_number` — контактный телефон
    * `email` — электронная почта (опционально)
    * `farm_address` — адрес фермы  
  Связи:
   * Один фермер может поставлять несколько товаров (1:N с таблицей Продукция).
2. Склады (Warehouses)  
  Содержит данные о местах хранения товаров:
    * `warehouse_id` (PK) — уникальный ID склада
    * `address` — адрес склада
    * `storage_type` — тип хранения (например, "холодильник", "сухое помещение")
    * `capacity` — вместимость склада (в единицах товара)  
  Связи:
    * На одном складе может храниться несколько товаров (1:N с таблицей Продукция).
3. Продукция (Products)  
  Содержит информацию о товарах, их характеристиках и наличии:
    * `product_id` (PK) — уникальный ID товара
    * `farmer_id` (FK → Farmers) — ID фермера-поставщика
    * `warehouse_id` (FK → Warehouses) — ID склада хранения
    * `name` — название товара
    * `category` — категория (например, "молочное", "овощи", "фрукты")
    * `current_price` — текущая цена за единицу
    * `quantity_in_stock` — количество товара на складе
    * `shelf_life` — срок годности  
  Связи:
    * Каждый товар принадлежит одному фермеру и хранится на одном складе (N:1 с Farmers и Warehouses).
4. Покупатели (Customers)  
  Содержит данные о клиентах, оформляющих заказы:
    * `customer_id` (PK) — уникальный ID покупателя
    * `name` — ФИО покупателя
    * `phone_number` — контактный телефон
    * `address` — адрес доставки  
  Связи:
    * Один покупатель может оформить несколько заказов (1:N с таблицей Заказы).
5. Заказы (Orders)  
  Содержит информацию о заказах покупателей:
    * `order_id` (PK) — уникальный ID заказа
    * `customer_id` (FK → Customers) — ID покупателя
    * `order_date` — дата и время оформления заказа
    * `status` — статус заказа ("новый", "в обработке", "доставлен", "отменен")
    * `total_amount` — общая сумма заказа  
  Связи:
    * Каждый заказ принадлежит одному покупателю (N:1 с Customers).
    * Один заказ может включать несколько товаров (1:N с СоставЗаказа).
6. Состав заказа (OrderItems)  
  Содержит детализацию заказанных товаров:
    * `order_item_id` (PK) — уникальный ID позиции в заказе
    * `order_id` (FK → Orders) — ID заказа
    * `product_id` (FK → Products) — ID товара
    * `quantity` — количество товара
    * `price_at_order_time` — цена товара на момент заказа (версионирование)  
  Связи:
    * Каждая позиция связана с одним заказом и одним товаром (N:1 с Orders и Products).
    * Поле price_at_order_time фиксирует цену товара при оформлении заказа, даже если current_price изменится.

## Нормальная форма
База данных приведена к третьей нормальной форме (3NF).
  * 1NF (Первая нормальная форма):  
    Все атрибуты атомарны (нет повторяющихся групп).
  * 2NF (Вторая нормальная форма):  
    Нет частичных зависимостей от составного ключа (все таблицы имеют простой первичный ключ).
  * 3NF (Третья нормальная форма):  
    Устранены транзитивные зависимости (неключевые атрибуты зависят только от первичного ключа).

Обоснование выбора 3NF:
  - Минимизирует избыточность (например, цена товара не дублируется в разных записях).
  - Упрощает обновления (изменение цены в Продукция не требует правки во всех заказах — актуальная цена берется из OrderItems.price_at_order_time).
  - Обеспечивает целостность данных, что критично для учета продукции и финансовых операций.
## Тип версионирования
Выбран тип версионирования 2.  
Реализация: 
  Версионирование реализовано в таблице СоставЗаказа через поле price_at_order_time, которое фиксирует цену товара на момент оформления заказа.  
Обоснование выбора версионирования типа 2:
  1. Минимальные накладные расходы  
    * Не требуется отдельная таблица для истории цен — достаточно одного поля в OrderItems.
    * Экономия места: хранится только релевантная информация (цена в заказе), а не все изменения.
  2. Упрощение запросов  
    * Для формирования отчетов о продажах не нужно обращаться к истории — данные уже записаны в заказе.
  3. Соответствие бизнес-требованиям  
    * В фермерском кооперативе критична финансовая отчетность, а не полный аудит изменений цен.
    * Если цена товара изменилась, это не влияет на уже завершенные заказы.
  4. Легкое масштабирование  
    * Мы всегда можем легко добавить таблицу которая бы сохраняла изменения цен, без изменения существующей схемы
## Физическая модель  
![Физическая модель часть1](https://github.com/user-attachments/assets/f5bc22bd-49c3-4716-8261-03d230163dfa)  
![Физическая модель часть2](https://github.com/user-attachments/assets/b06e46bd-570c-4cfc-abcc-89cd3a85f5f8)  
![Физическая модель часть3](https://github.com/user-attachments/assets/827b6ef7-8381-40a4-82b6-e6121620ae6e)  
Создание таблиц, их заполнение и запросы к ним можно найти [в этой папке](./scripts)

# Дополнительные стадии проекта 
Были выполнены некоторые дополнительные стадии проекта: представления, индексы, хранимые процедуры и триггеры. Анализ данных не был завершен и отменился. 
## 1. Создание представлений
```sql 
-- Представление отображающее информацию о продукции вместе с именем фермера и адресом склада
CREATE OR REPLACE VIEW View_ProductInfo AS
SELECT 
    p.product_id,
    p.name AS product_name,
    f.name AS farmer_name,
    w.address AS warehouse_address,
    p.category,
    p.current_price,
    p.quantity_in_stock,
    p.shelf_life
FROM Products p
JOIN Farmers f ON p.farmer_id = f.farmer_id
JOIN Warehouses w ON p.warehouse_id = w.warehouse_id;

-- Представление отображающее сводную информацию по заказам: покупатель, сумма и статус
CREATE OR REPLACE VIEW View_OrderSummary AS
SELECT 
    o.order_id,
    c.name AS customer_name,
    o.order_date,
    o.total_amount,
    o.status
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id;

-- Представление отображающее статистику продаж по категориям
CREATE OR REPLACE VIEW category_sales_stats AS
SELECT 
    p.category,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.price_at_order_time) AS total_revenue
FROM 
    Products p
JOIN 
    OrderItems oi ON p.product_id = oi.product_id
JOIN 
    Orders o ON oi.order_id = o.order_id
GROUP BY 
    p.category
ORDER BY 
    total_revenue DESC;
```
## 2. Создание индексов для технических таблиц
```sql
-- Индекс по имени продукции
CREATE INDEX idx_products_name ON Products(name);

-- Индекс по дате заказа
CREATE INDEX idx_orders_order_date ON Orders(order_date);
```
## 3. Создание хранимых процедур и функций
```sql
-- Функция: Расчёт стоимости позиции заказа
CREATE OR REPLACE FUNCTION calculate_item_total(qty INT, price NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN qty * price;
END;
$$ LANGUAGE plpgsql;

-- Функция: Вернуть общее количество заказов покупателя
CREATE OR REPLACE FUNCTION get_order_count(customer_id INT)
RETURNS INT AS $$
DECLARE
    total INT;
BEGIN
    SELECT COUNT(*) INTO total
    FROM Orders
    WHERE Orders.customer_id = customer_id;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Процедура: Изменение статуса заказа
CREATE OR REPLACE PROCEDURE update_order_status(p_order_id INT, new_status VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Orders
    SET status = new_status
    WHERE order_id = p_order_id;
END;
$$;

-- Процедура: Оформление нового заказа
CREATE OR REPLACE PROCEDURE create_order(
    p_customer_id INT,
    p_product_ids INT[],
    p_quantities INT[],
    OUT p_order_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
    v_total DECIMAL(10,2) := 0;
    v_product_price DECIMAL(10,2);
BEGIN
    -- Создаем запись заказа
    INSERT INTO Orders(customer_id, status, total_amount)
    VALUES (p_customer_id, 'Новый', 0)
    RETURNING order_id INTO p_order_id;
    
    -- Добавляем товары в заказ
    FOR i IN 1..array_length(p_product_ids, 1) LOOP
        -- Получаем текущую цену товара
        SELECT current_price INTO v_product_price
        FROM Products WHERE product_id = p_product_ids[i];
        
        -- Добавляем товар в состав заказа
        INSERT INTO OrderItems(order_id, product_id, quantity, price_at_order_time)
        VALUES (p_order_id, p_product_ids[i], p_quantities[i], v_product_price);
        
        -- Уменьшаем количество товара на складе
        UPDATE Products 
        SET quantity_in_stock = quantity_in_stock - p_quantities[i]
        WHERE product_id = p_product_ids[i];
        
        -- Суммируем общую стоимость
        v_total := v_total + (v_product_price * p_quantities[i]);
    END LOOP;
    
    -- Обновляем общую сумму заказа
    UPDATE Orders SET total_amount = v_total WHERE order_id = p_order_id;
    
    COMMIT;
END;
$$;
```
4. Создание триггеров
```sql
-- Автоматическое уменьшение остатков после добавления в заказ
CREATE OR REPLACE FUNCTION reduce_stock() RETURNS TRIGGER AS $$
BEGIN
    UPDATE Products
    SET quantity_in_stock = quantity_in_stock - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reduce_stock
AFTER INSERT ON OrderItems
FOR EACH ROW
EXECUTE FUNCTION reduce_stock();

-- Проверка срока годности перед добавлением продукции
CREATE OR REPLACE FUNCTION check_shelf_life() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.shelf_life IS NOT NULL AND NEW.shelf_life < CURRENT_DATE THEN
        RAISE EXCEPTION 'Срок годности не может быть в прошлом';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_shelf_life
BEFORE INSERT OR UPDATE ON Products
FOR EACH ROW
EXECUTE FUNCTION check_shelf_life();

-- Логирование изменений заказов
CREATE TABLE OrderLogs (
    log_id SERIAL PRIMARY KEY,
    order_id INT,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_order_status_change() RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO OrderLogs(order_id, old_status, new_status)
        VALUES (OLD.order_id, OLD.status, NEW.status);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_order_status
AFTER UPDATE ON Orders
FOR EACH ROW
EXECUTE FUNCTION log_order_status_change();
```
