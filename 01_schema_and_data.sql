-- 1. Table: customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    segment VARCHAR(50) NOT NULL -- 'Key Account', 'Standard'
);

-- 2. Table: orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date TIMESTAMP NOT NULL,
    net_amount NUMERIC(12, 2) NOT NULL,
    status VARCHAR(50) NOT NULL -- 'Completed', 'Cancelled'
);

-- 3. Mock Data Insertion
INSERT INTO customers (customer_id, company_name, segment) VALUES
(1, 'Apex Solutions Ltd', 'Key Account'),
(2, 'Vanguard Retail Inc', 'Key Account'),
(3, 'Local Corner Shop', 'Standard'); -- Control record: should be filtered out

INSERT INTO orders (order_id, customer_id, order_date, net_amount, status) VALUES
-- Apex Solutions (Revenue Drop)
(101, 1, '2026-01-15 10:00:00', 80000.00, 'Completed'),
(102, 1, '2026-02-20 14:00:00', 40000.00, 'Completed'),
(103, 1, '2026-05-10 11:30:00', 50000.00, 'Completed'),

-- Vanguard Retail (Revenue Growth)
(104, 2, '2026-02-01 09:00:00', 25000.00, 'Completed'),
(105, 2, '2026-04-12 16:00:00', 70000.00, 'Completed'),

-- Cancelled order (should be excluded from revenue)
(106, 2, '2026-05-01 12:00:00', 100000.00, 'Cancelled'),

-- Standard customer order (should be excluded by customer segment filter)
(107, 3, '2026-01-10 10:00:00', 5000.00, 'Completed');