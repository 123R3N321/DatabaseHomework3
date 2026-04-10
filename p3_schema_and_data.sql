-- Problem 3 – Warehouse Inventory and Membership
-- Schema (DDL) and sample data (PostgreSQL)

DROP TABLE IF EXISTS TransactionItem CASCADE;
DROP TABLE IF EXISTS "Transaction" CASCADE;
DROP TABLE IF EXISTS Membership CASCADE;
DROP TABLE IF EXISTS Member CASCADE;
DROP TABLE IF EXISTS MembershipPlan CASCADE;
DROP TABLE IF EXISTS InventoryBatch CASCADE;
DROP TABLE IF EXISTS Product CASCADE;
DROP TABLE IF EXISTS Warehouse CASCADE;

CREATE TABLE Warehouse (
    warehouse_id INT PRIMARY KEY,
    address      TEXT NOT NULL,
    phone        TEXT NOT NULL
);

CREATE TABLE Product (
    sku                INT PRIMARY KEY,
    name               TEXT NOT NULL,
    category           TEXT NOT NULL,
    current_unit_price NUMERIC(10,2) NOT NULL CHECK (current_unit_price >= 0)
);

CREATE TABLE InventoryBatch (
    batch_id          INT PRIMARY KEY,
    warehouse_id      INT NOT NULL REFERENCES Warehouse(warehouse_id),
    sku               INT NOT NULL REFERENCES Product(sku),
    arrival_date      DATE NOT NULL,
    expiration_date   DATE,
    quantity_remaining INT NOT NULL CHECK (quantity_remaining >= 0)
);

CREATE TABLE MembershipPlan (
    plan_id       INT PRIMARY KEY,
    plan_name     TEXT UNIQUE NOT NULL,
    annual_fee    NUMERIC(10,2) NOT NULL CHECK (annual_fee >= 0),
    discount_rate NUMERIC(4,3) NOT NULL CHECK (discount_rate >= 0 AND discount_rate <= 1)
);

CREATE TABLE Member (
    member_id INT PRIMARY KEY,
    name      TEXT NOT NULL,
    phone     TEXT NOT NULL
);

CREATE TABLE Membership (
    member_id  INT NOT NULL REFERENCES Member(member_id),
    plan_id    INT NOT NULL REFERENCES MembershipPlan(plan_id),
    start_date DATE NOT NULL,
    end_date   DATE,
    PRIMARY KEY (member_id, start_date)
);

CREATE TABLE "Transaction" (
    tx_id       INT PRIMARY KEY,
    tx_timestamp TIMESTAMP NOT NULL,
    member_id   INT NOT NULL REFERENCES Member(member_id),
    warehouse_id INT NOT NULL REFERENCES Warehouse(warehouse_id)
);

CREATE TABLE TransactionItem (
    tx_id           INT NOT NULL REFERENCES "Transaction"(tx_id),
    line_no         INT NOT NULL,
    batch_id        INT NOT NULL REFERENCES InventoryBatch(batch_id),
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price_paid NUMERIC(10,2) NOT NULL CHECK (unit_price_paid >= 0),
    PRIMARY KEY (tx_id, line_no)
);

-- =====================================
-- Sample data
-- =====================================

-- Warehouses
INSERT INTO Warehouse VALUES
(1, '123 Main St, Seattle, WA', '206-555-0001'),
(2, '456 Market Rd, Bellevue, WA', '425-555-0002'),
(3, '789 Industrial Ave, Portland, OR', '503-555-0003');

-- Products
INSERT INTO Product VALUES
(1001, 'Kirkland Paper Towels', 'Grocery', 20.00),
(1002, 'Kirkland Olive Oil', 'Grocery', 15.00),
(1003, 'Organic Apples 5lb', 'Grocery', 7.50),
(2001, '4K LED TV', 'Electronics', 499.99),
(2002, 'Noise-Cancelling Headphones', 'Electronics', 199.99),
(3001, 'Office Chair', 'Home', 129.99);

-- Membership plans
INSERT INTO MembershipPlan VALUES
(1, 'Basic', 60.00, 0.000),
(2, 'Executive', 120.00, 0.020);

-- Members
INSERT INTO Member VALUES
(1, 'Alice Johnson', '206-555-1001'),
(2, 'Bob Smith', '206-555-1002'),
(3, 'Carol Davis', '425-555-1003'),
(4, 'Dan Lee', '425-555-1004'),
(5, 'Eva Patel', '503-555-1005'),
(6, 'Frank Wu', '503-555-1006'),
(7, 'Grace Kim', '206-555-1007'),
(8, 'Henry Brown', '425-555-1008');

-- Memberships (plan assignments over time)
-- Assume all memberships start 2024-01-01; Carol upgrades mid-year.
INSERT INTO Membership VALUES
(1, 1, DATE '2024-01-01', NULL),          -- Alice: Basic
(2, 1, DATE '2024-01-01', NULL),          -- Bob: Basic
(3, 1, DATE '2024-01-01', DATE '2024-06-30'), -- Carol: Basic first half
(3, 2, DATE '2024-07-01', NULL),          -- Carol: Executive second half
(4, 2, DATE '2024-01-01', NULL),          -- Dan: Executive
(5, 1, DATE '2024-01-01', NULL),          -- Eva: Basic
(6, 2, DATE '2024-01-01', NULL),          -- Frank: Executive
(7, 1, DATE '2024-01-01', NULL),          -- Grace: Basic
(8, 2, DATE '2024-01-01', NULL);          -- Henry: Executive

-- Inventory batches
-- Some batches have remaining quantity; some are sold out (0).
INSERT INTO InventoryBatch VALUES
-- Kirkland Paper Towels (1001)
(101, 1, 1001, DATE '2024-01-05', DATE '2025-01-05', 0),
(102, 1, 1001, DATE '2024-06-10', DATE '2025-06-10', 0),
(103, 2, 1001, DATE '2024-02-01', DATE '2025-02-01', 10),
(104, 3, 1001, DATE '2024-03-01', DATE '2025-03-01', 0),
-- Other grocery items
(201, 1, 1002, DATE '2024-01-10', DATE '2024-12-31', 20),
(202, 2, 1002, DATE '2024-01-15', DATE '2024-12-31', 0),
(203, 3, 1003, DATE '2025-12-10', DATE '2025-12-30', 0),
(204, 3, 1003, DATE '2025-12-17', DATE '2025-12-31', 0),
-- Non-grocery
(301, 1, 2001, DATE '2024-01-20', NULL, 5),
(302, 2, 2001, DATE '2024-01-25', NULL, 0),
(303, 1, 2002, DATE '2024-02-10', NULL, 8),
(304, 3, 3001, DATE '2024-03-15', NULL, 2);

-- Transactions in 2024 (multiple warehouses per some members)
INSERT INTO "Transaction" VALUES
-- Alice: shops at warehouses 1 and 2
(10001, TIMESTAMP '2024-02-10 10:15:00', 1, 1),
(10002, TIMESTAMP '2024-07-20 14:30:00', 1, 2),
-- Bob: shops only at warehouse 1
(10003, TIMESTAMP '2024-03-05 11:00:00', 2, 1),
-- Carol: shops at warehouses 2 and 3
(10004, TIMESTAMP '2024-04-12 16:45:00', 3, 2),
(10005, TIMESTAMP '2024-11-25 13:20:00', 3, 3),
-- Dan: shops at warehouses 1 and 3
(10006, TIMESTAMP '2024-06-01 09:05:00', 4, 1),
(10007, TIMESTAMP '2024-08-15 18:10:00', 4, 3),
-- Eva: small spender at one warehouse
(10008, TIMESTAMP '2024-05-02 15:40:00', 5, 2),
-- Frank: big spender at multiple warehouses
(10009, TIMESTAMP '2024-02-18 12:05:00', 6, 1),
(10010, TIMESTAMP '2024-09-10 19:30:00', 6, 3),
-- Grace & Henry: a few smaller purchases
(10011, TIMESTAMP '2024-10-05 10:00:00', 7, 1),
(10012, TIMESTAMP '2024-12-22 17:45:00', 8, 2);

-- Transaction items (with unit_price_paid reflecting discount where applicable)
INSERT INTO TransactionItem VALUES
-- 10001 Alice at warehouse 1
(10001, 1, 101, 2, 20.00),   -- 2 x Paper Towels
(10001, 2, 201, 1, 15.00),   -- Olive Oil
-- 10002 Alice at warehouse 2
(10002, 1, 103, 3, 19.50),   -- slightly different price
-- 10003 Bob at warehouse 1
(10003, 1, 201, 2, 14.50),
-- 10004 Carol at warehouse 2
(10004, 1, 103, 2, 19.00),
-- 10005 Carol at warehouse 3
(10005, 1, 304, 1, 120.00),
-- 10006 Dan at warehouse 1
(10006, 1, 301, 1, 480.00),  -- 4K TV discounted
-- 10007 Dan at warehouse 3
(10007, 1, 304, 1, 129.99),
-- 10008 Eva at warehouse 2
(10008, 1, 202, 1, 15.00),
-- 10009 Frank at warehouse 1
(10009, 1, 301, 1, 499.99),
(10009, 2, 303, 2, 190.00),
-- 10010 Frank at warehouse 3
(10010, 1, 304, 2, 125.00),
-- 10011 Grace at warehouse 1
(10011, 1, 201, 1, 15.00),
-- 10012 Henry at warehouse 2
(10012, 1, 103, 1, 20.00);

