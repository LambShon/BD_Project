-- Создание таблицы Фермеры
CREATE TABLE Farmers (
    farmer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100),
    farm_address TEXT NOT NULL
); 

-- Создание таблицы Склады
CREATE TABLE Warehouses (
    warehouse_id SERIAL PRIMARY KEY,
    address TEXT NOT NULL,
    storage_type VARCHAR(50) NOT NULL CHECK (storage_type IN ('Холодильник', 'Сухое', 'Морозильник')),
    capacity INT NOT NULL CHECK (capacity > 0)
);

-- Создание таблицы Продукция
CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    farmer_id INT NOT NULL REFERENCES Farmers(farmer_id),
    warehouse_id INT NOT NULL REFERENCES Warehouses(warehouse_id),
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL CHECK (category IN ('Молочное', 'Овощи', 'Фрукты', 'Мясо', 'Зерно')),
    current_price DECIMAL(10, 2) NOT NULL CHECK (current_price > 0),
    quantity_in_stock INT NOT NULL CHECK (quantity_in_stock >= 0),
    shelf_life DATE
);

-- Создание таблицы Покупатели
CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    address TEXT NOT NULL
);

-- Создание таблицы Заказы
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customers(customer_id),
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Новый', 'В обработке', 'Доставлен', 'Отменен')),
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0)
);

-- Создание таблицы Состав заказа
CREATE TABLE OrderItems (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES Orders(order_id),
    product_id INT NOT NULL REFERENCES Products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_order_time DECIMAL(10, 2) NOT NULL CHECK (price_at_order_time > 0)
);
