DROP DATABASE IF EXISTS OnlineSales;
CREATE DATABASE OnlineSales;
USE OnlineSales;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(10) NOT NULL UNIQUE
);

INSERT INTO customers (customer_name, email, phone) VALUES
('Nguyen Van An',  'an@gmail.com',   '0901111111'),
('Tran Thi Binh',  'binh@gmail.com', '0902222222'),
('Le Van Cuong',   'cuong@gmail.com','0903333333'),
('Pham Thi Dung',  'dung@gmail.com', '0904444444'),
('Hoang Van Em',   'em@gmail.com',   '0905555555'),
('Do Minh Giang',  'giang@gmail.com','0906666666');


/* =======================
   BẢNG CATEGORIES
   ======================= */

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL UNIQUE
);

INSERT INTO categories (category_name) VALUES
('Dien thoai'),
('Laptop'),
('Phu kien'),
('Tablet');


/* =======================
   BẢNG PRODUCTS
   ======================= */

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    category_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

INSERT INTO products (product_name, price, category_id) VALUES
('iPhone 14',          20000000, 1),
('Samsung Galaxy S23', 18000000, 1),
('MacBook Air M2',     28000000, 2),
('Dell XPS 13',        25000000, 2),
('Tai nghe Bluetooth', 1500000,  3),
('Chuot khong day',     800000,  3),
('iPad Gen 10',        12000000, 4),
('iPad Air',           16000000, 4);


CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending','Completed','Cancel') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2025-01-05', 'Completed'),
(1, '2025-01-10', 'Completed'),
(2, '2025-01-06', 'Completed'),
(3, '2025-01-07', 'Pending'),
(4, '2025-01-08', 'Completed'),
(5, '2025-01-09', 'Cancel'),
(6, '2025-01-10', 'Completed'),
(2, '2025-01-12', 'Completed');


CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 5, 2),
(2, 3, 1),
(2, 6, 1),
(3, 2, 1),
(3, 6, 2),
(4, 4, 1),
(5, 7, 2),
(5, 6, 1),
(6, 5, 3),
(7, 8, 1),
(7, 1, 1),
(8, 2, 1),
(8, 5, 2);

SELECT COUNT(*) AS customers FROM customers;
SELECT COUNT(*) AS categories FROM categories;
SELECT COUNT(*) AS products FROM products;
SELECT COUNT(*) AS orders FROM orders;
SELECT COUNT(*) AS order_items FROM order_items;

-- Câu 1: Lấy danh sách tất cả danh mục sản phẩm
SELECT *
FROM categories;

-- Câu 2: Lấy danh sách đơn hàng có trạng thái COMPLETED
SELECT *
FROM orders
WHERE status = 'Completed';

-- Câu 3: Lấy danh sách sản phẩm, sắp xếp theo giá giảm dần
SELECT *
FROM products
ORDER BY price DESC;

-- Câu 4: Lấy 5 sản phẩm có giá cao nhất, bỏ qua 2 sản phẩm đầu tiên
SELECT *
FROM products
ORDER BY price DESC
LIMIT 5 OFFSET 2;


-- PHẦN B – TRUY VẤN NÂNG CAO (JOIN – GROUP BY – HAVING)

-- Câu 5: Lấy danh sách sản phẩm kèm tên danh mục
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    c.category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id;

-- Câu 6: Lấy danh sách đơn hàng gồm order_id, order_date, customer_name, status
SELECT 
    o.order_id,
    o.order_date,
    c.customer_name,
    o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- Câu 7: Tính tổng số lượng sản phẩm trong từng đơn hàng
SELECT 
    oi.order_id,
    SUM(oi.quantity) AS total_quantity
FROM order_items oi
GROUP BY oi.order_id;

-- Câu 8: Thống kê số đơn hàng của mỗi khách hàng
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- Câu 9: Lấy danh sách khách hàng có tổng số đơn hàng ≥ 2
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) >= 2;

-- Câu 10: Thống kê giá trung bình, thấp nhất, cao nhất theo danh mục
SELECT 
    c.category_name,
    AVG(p.price) AS avg_price,
    MIN(p.price) AS min_price,
    MAX(p.price) AS max_price
FROM categories c
JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_name;

-- PHẦN C – TRUY VẤN LỒNG (SUBQUERY)

-- Câu 11: Sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
SELECT *
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
);

-- Câu 12: Khách hàng đã từng đặt ít nhất một đơn hàng
SELECT *
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM orders
);

-- Câu 13: Lấy đơn hàng có tổng số lượng sản phẩm lớn nhất
SELECT order_id
FROM order_items
GROUP BY order_id
HAVING SUM(quantity) = (
    SELECT MAX(total_qty)
    FROM (
        SELECT SUM(quantity) AS total_qty
        FROM order_items
        GROUP BY order_id
    ) t
);

-- Câu 14: Tên khách hàng đã mua sản phẩm thuộc danh mục có giá trung bình cao nhất
SELECT DISTINCT c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.category_id = (
    SELECT category_id
    FROM products
    GROUP BY category_id
    ORDER BY AVG(price) DESC
    LIMIT 1
);

-- Câu 15: Từ bảng tạm (subquery), thống kê tổng số lượng sản phẩm đã mua của từng khách hàng
SELECT 
    t.customer_id,
    c.customer_name,
    SUM(t.quantity) AS total_quantity
FROM (
    SELECT 
        o.customer_id,
        oi.quantity
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
) t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY t.customer_id, c.customer_name;

-- Câu 16: Lấy sản phẩm có giá cao nhất (subquery chỉ trả về một giá trị)
SELECT *
FROM products
WHERE price = (
    SELECT MAX(price)
    FROM products
);