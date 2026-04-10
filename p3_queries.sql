-- Problem 3(c) – Analytical queries
-- Assumes schema and data from p3_schema_and_data.sql

------------------------------------------------------------
-- (1) Members in Basic who would have saved money on Executive
--     over 2024
------------------------------------------------------------

WITH plan_fees AS (
    SELECT
        MAX(CASE WHEN plan_name = 'Basic' THEN annual_fee END) AS basic_fee,
        MAX(CASE WHEN plan_name = 'Executive' THEN annual_fee END) AS exec_fee
    FROM MembershipPlan
),
spending_2024 AS (
    SELECT
        t.member_id,
        SUM(ti.quantity * ti.unit_price_paid) AS total_spent
    FROM "Transaction" AS t
    JOIN TransactionItem AS ti
      ON ti.tx_id = t.tx_id
    WHERE t.tx_timestamp >= TIMESTAMP '2024-01-01'
      AND t.tx_timestamp < TIMESTAMP '2025-01-01'
    GROUP BY t.member_id
),
current_basic_members AS (
    SELECT DISTINCT m.member_id
    FROM Membership AS m
    JOIN MembershipPlan AS p
      ON p.plan_id = m.plan_id
    WHERE p.plan_name = 'Basic'
      AND (m.end_date IS NULL OR m.end_date >= DATE '2024-12-31')
      AND m.start_date <= DATE '2024-01-01'
)
SELECT
    mem.member_id,
    mem.name,
    s.total_spent,
    (s.total_spent * 0.02) AS hypothetical_savings,
    (pf.exec_fee - pf.basic_fee) AS extra_fee
FROM current_basic_members AS cb
JOIN Member AS mem
  ON mem.member_id = cb.member_id
JOIN spending_2024 AS s
  ON s.member_id = cb.member_id
JOIN plan_fees AS pf
  ON TRUE
WHERE (s.total_spent * 0.02) > (pf.exec_fee - pf.basic_fee)
ORDER BY mem.member_id;


------------------------------------------------------------
-- (2) Warehouses that ever had Kirkland Paper Towels but
--     are now completely out of stock for that product
------------------------------------------------------------

WITH kpt AS (
    SELECT sku
    FROM Product
    WHERE name = 'Kirkland Paper Towels'
),
warehouses_with_kpt AS (
    SELECT DISTINCT
        ib.warehouse_id
    FROM InventoryBatch AS ib
    JOIN kpt
      ON kpt.sku = ib.sku
),
current_kpt_stock AS (
    SELECT
        ib.warehouse_id,
        SUM(ib.quantity_remaining) AS qty_remaining
    FROM InventoryBatch AS ib
    JOIN kpt
      ON kpt.sku = ib.sku
    GROUP BY ib.warehouse_id
)
SELECT
    w.warehouse_id,
    w.address
FROM warehouses_with_kpt AS wk
JOIN current_kpt_stock AS cs
  ON cs.warehouse_id = wk.warehouse_id
JOIN Warehouse AS w
  ON w.warehouse_id = wk.warehouse_id
WHERE cs.qty_remaining = 0
ORDER BY w.warehouse_id;


------------------------------------------------------------
-- (3) Grocery products fully sold out during Dec 18–24, 2025
--     in a store (warehouse)
--
-- For this sample, we treat "fully sold out during the week"
-- as: there exists at least one batch for that (warehouse, sku)
-- with expiration_date <= '2025-12-24' and quantity_remaining = 0,
-- and there is no batch with positive quantity remaining that
-- overlaps that week.
------------------------------------------------------------

WITH grocery_products AS (
    SELECT sku, name
    FROM Product
    WHERE category = 'Grocery'
),
candidate_pairs AS (
    SELECT DISTINCT
        ib.warehouse_id,
        ib.sku
    FROM InventoryBatch AS ib
    JOIN grocery_products AS gp
      ON gp.sku = ib.sku
),
positive_during_week AS (
    SELECT DISTINCT
        ib.warehouse_id,
        ib.sku
    FROM InventoryBatch AS ib
    JOIN grocery_products AS gp
      ON gp.sku = ib.sku
    WHERE ib.quantity_remaining > 0
      AND ib.arrival_date <= DATE '2025-12-24'
      AND (ib.expiration_date IS NULL OR ib.expiration_date >= DATE '2025-12-18')
),
zero_or_none_during_week AS (
    SELECT
        c.warehouse_id,
        c.sku
    FROM candidate_pairs AS c
    LEFT JOIN positive_during_week AS p
      ON p.warehouse_id = c.warehouse_id
     AND p.sku = c.sku
    WHERE p.warehouse_id IS NULL
)
SELECT
    z.sku,
    gp.name,
    w.warehouse_id,
    w.address
FROM zero_or_none_during_week AS z
JOIN grocery_products AS gp
  ON gp.sku = z.sku
JOIN Warehouse AS w
  ON w.warehouse_id = z.warehouse_id
ORDER BY z.sku, w.warehouse_id;


------------------------------------------------------------
-- (4) Members who have made purchases at >1 warehouse and
--     spent more than $500 in total across all warehouses
--     during 2024
------------------------------------------------------------

WITH member_spending_2024 AS (
    SELECT
        t.member_id,
        COUNT(DISTINCT t.warehouse_id) AS num_warehouses,
        SUM(ti.quantity * ti.unit_price_paid) AS total_spent
    FROM "Transaction" AS t
    JOIN TransactionItem AS ti
      ON ti.tx_id = t.tx_id
    WHERE t.tx_timestamp >= TIMESTAMP '2024-01-01'
      AND t.tx_timestamp < TIMESTAMP '2025-01-01'
    GROUP BY t.member_id
)
SELECT
    m.member_id,
    m.name,
    s.num_warehouses,
    s.total_spent
FROM member_spending_2024 AS s
JOIN Member AS m
  ON m.member_id = s.member_id
WHERE s.num_warehouses > 1
  AND s.total_spent > 500
ORDER BY m.member_id;

