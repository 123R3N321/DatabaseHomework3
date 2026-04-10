## Problem 3 (a) – Warehouse Inventory and Membership

### ER Model (Mermaid syntax)

#### Entities

- **Warehouse**
  - Attributes: `warehouse_id` (PK), `address`, `phone`.

- **Product**
  - Attributes: `sku` (PK), `name`, `category` (e.g., `Electronics`, `Grocery`), `current_unit_price`.

- **InventoryBatch**
  - Attributes: `batch_id` (PK), `arrival_date`, `expiration_date` (nullable), `quantity_remaining`.
  - Each batch belongs to exactly one warehouse and exactly one product.

- **MembershipPlan**
  - Attributes: `plan_id` (PK), `plan_name` (e.g., `Basic`, `Executive`, UNIQUE), `annual_fee`, `discount_rate` (0.00 for Basic, 0.02 for Executive).

- **Member**
  - Attributes: `member_id` (PK), `name`, `phone`.

- **Membership**
  - Attributes: `member_id` (FK), `plan_id` (FK), `start_date`, `end_date` (nullable if current).
  - Key: (`member_id`, `start_date`).
  - Models a member’s enrollment in a plan over time (allows upgrades/downgrades).

- **Transaction**
  - Attributes: `tx_id` (PK), `tx_timestamp`, `member_id` (FK), `warehouse_id` (FK).
  - Represents a purchase event at a warehouse by a member.

- **TransactionItem**
  - Attributes: `tx_id` (FK), `line_no`, `batch_id` (FK), `quantity`, `unit_price_paid`.
  - Key: (`tx_id`, `line_no`).
  - Each row is a line item, tied to a specific inventory batch and recording the actual price paid.

#### Relationships and Cardinalities

- **Warehouse–InventoryBatch**
  - One warehouse has many batches; each batch belongs to exactly one warehouse.

- **Product–InventoryBatch**
  - One product has many batches; each batch is for exactly one product.

- **Member–Membership–MembershipPlan**
  - One member can have many membership periods (Membership rows) over time.
  - Each membership row refers to exactly one plan.
  - Membership has total participation in Member (a membership cannot exist without a member) and partial participation in MembershipPlan (a plan may exist with no assigned members yet).

- **Warehouse–Transaction**
  - One warehouse has many transactions; each transaction occurs at exactly one warehouse.

- **Member–Transaction**
  - One member can have many transactions; each transaction is made by exactly one member.

- **Transaction–TransactionItem–InventoryBatch**
  - One transaction has many line items; each line item belongs to exactly one transaction.
  - Each line item uses exactly one inventory batch; one batch can appear in many line items over time, decrementing `quantity_remaining`.

#### Design Justifications

- **Inventory tracked by batch**:
  - Captures arrival and expiration dates and remaining quantity per shipment, which is important for “sold out” logic and stock history.

- **Membership vs MembershipPlan**:
  - Separating plan definition (`MembershipPlan`) from actual enrollments (`Membership`) allows:
    - Multiple members on the same plan.
    - Plan fee/discount changes over time.
    - Members upgrading from Basic to Executive with date ranges.

- **Storing `unit_price_paid` on TransactionItem**:
  - Product prices can change; storing `unit_price_paid` allows exact reconstruction of spending and savings at transaction time, independent of `Product.current_unit_price`.
  - This is crucial for “would have saved money with Executive” calculations.

### Relational Schema (Logical)

Below is the target relational schema; the DDL implementation lives in `p3_schema_and_data.sql`.

- **Warehouse**
  - `warehouse_id` INT PRIMARY KEY
  - `address` TEXT NOT NULL
  - `phone` TEXT NOT NULL

- **Product**
  - `sku` INT PRIMARY KEY
  - `name` TEXT NOT NULL
  - `category` TEXT NOT NULL
  - `current_unit_price` NUMERIC(10,2) NOT NULL CHECK (current_unit_price >= 0)

- **InventoryBatch**
  - `batch_id` INT PRIMARY KEY
  - `warehouse_id` INT NOT NULL REFERENCES Warehouse(warehouse_id)
  - `sku` INT NOT NULL REFERENCES Product(sku)
  - `arrival_date` DATE NOT NULL
  - `expiration_date` DATE
  - `quantity_remaining` INT NOT NULL CHECK (quantity_remaining >= 0)

- **MembershipPlan**
  - `plan_id` INT PRIMARY KEY
  - `plan_name` TEXT UNIQUE NOT NULL
  - `annual_fee` NUMERIC(10,2) NOT NULL CHECK (annual_fee >= 0)
  - `discount_rate` NUMERIC(4,3) NOT NULL CHECK (discount_rate >= 0 AND discount_rate <= 1)

- **Member**
  - `member_id` INT PRIMARY KEY
  - `name` TEXT NOT NULL
  - `phone` TEXT NOT NULL

- **Membership**
  - `member_id` INT NOT NULL REFERENCES Member(member_id)
  - `plan_id` INT NOT NULL REFERENCES MembershipPlan(plan_id)
  - `start_date` DATE NOT NULL
  - `end_date` DATE
  - PRIMARY KEY (`member_id`, `start_date`)

- **Transaction**
  - `tx_id` INT PRIMARY KEY
  - `tx_timestamp` TIMESTAMP NOT NULL
  - `member_id` INT NOT NULL REFERENCES Member(member_id)
  - `warehouse_id` INT NOT NULL REFERENCES Warehouse(warehouse_id)

- **TransactionItem**
  - `tx_id` INT NOT NULL REFERENCES Transaction(tx_id)
  - `line_no` INT NOT NULL
  - `batch_id` INT NOT NULL REFERENCES InventoryBatch(batch_id)
  - `quantity` INT NOT NULL CHECK (quantity > 0)
  - `unit_price_paid` NUMERIC(10,2) NOT NULL CHECK (unit_price_paid >= 0)
  - PRIMARY KEY (`tx_id`, `line_no`)

