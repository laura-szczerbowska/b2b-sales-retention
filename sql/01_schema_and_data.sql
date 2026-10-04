-- NOTE: All data contained in this script is synthetic/mock data created solely for project demonstration.

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- 1. Customers Table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    segment VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- 2. Orders Table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    net_amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL
);

-- 3. Seed Customers
INSERT INTO customers (customer_id, company_name, segment, country) VALUES
(1, 'Apex Solutions Ltd', 'Key Account', 'Poland'),
(2, 'Vanguard Retail Inc', 'Key Account', 'Germany'),
(3, 'Nordic Logistics AS', 'Key Account', 'Sweden'),
(4, 'Syllable Tech Sp. z o.o.', 'Key Account', 'Poland'),
(5, 'Local Bistro Group', 'Standard', 'Poland'),
(6, 'Metro Supplies S.A.', 'Standard', 'Germany');

-- 4. Seed Orders (Full Year 2025 across 4 quarters)
INSERT INTO orders (customer_id, order_date, net_amount, status) VALUES
-- Customer 1: Apex Solutions (Pattern: Clear Decline / Churn Risk)
(1, '2025-01-15', 75000.00, 'Completed'),
(1, '2025-02-20', 45000.00, 'Completed'), -- Q1 total: 120,000
(1, '2025-04-10', 50000.00, 'Completed'), -- Q2 total: 50,000 (Decline)
(1, '2025-07-12', 30000.00, 'Completed'), -- Q3 total: 30,000 (Decline)
(1, '2025-10-05', 20000.00, 'Completed'), -- Q4 total: 20,000 (Decline)

-- Customer 2: Vanguard Retail (Pattern: Consistent Strong Growth)
(2, '2025-03-01', 25000.00, 'Completed'), -- Q1 total: 25,000
(2, '2025-05-18', 70000.00, 'Completed'), -- Q2 total: 70,000 (Growth)
(2, '2025-08-22', 85000.00, 'Completed'), -- Q3 total: 85,000 (Growth)
(2, '2025-11-15', 110000.00, 'Completed'), -- Q4 total: 110,000 (Growth)

-- Customer 3: Nordic Logistics (Pattern: Fluctuation / Recovery)
(3, '2025-02-10', 60000.00, 'Completed'), -- Q1 total: 60,000
(3, '2025-04-25', 62000.00, 'Completed'), -- Q2 total: 62,000 (Growth/Stable)
(3, '2025-09-05', 40000.00, 'Completed'), -- Q3 total: 40,000 (Decline)
(3, '2025-11-28', 65000.00, 'Completed'), -- Q4 total: 65,000 (Growth/Rebound)

-- Customer 4: Syllable Tech (Pattern: Newly Acquired Account in Q3)
(4, '2025-08-14', 45000.00, 'Completed'), -- Q3 total: 45,000 (New Period)
(4, '2025-10-20', 55000.00, 'Completed'), -- Q4 total: 55,000 (Growth)

-- Standard Segment & Cancelled Orders (Boundary testing for WHERE filters)
(5, '2025-01-20', 12000.00, 'Completed'),
(6, '2025-03-15', 8000.00, 'Completed'),
(1, '2025-05-01', 99000.00, 'Cancelled');
