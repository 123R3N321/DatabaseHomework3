## CS 6083 – Problem Set 2, Problem 3

Warehouse inventory and membership schema, data, and analytical queries in PostgreSQL.

### Files
- `p3_er_and_schema.md`: ER description and relational schema design.
- `p3_schema_and_data.sql`: DDL plus sample data (warehouses, products, batches, members, memberships, transactions, and line items).
- `p3_queries.sql`: SQL solutions for the four analytical questions in part (c).

### Prerequisites
- PostgreSQL installed and accessible via `psql`.
- Run commands from the project root: `/home/ren/projects/databaseStuff`.

### Create and load the database

In `psql`, create a database (e.g., `warehouse_db`) and connect:

```sql
CREATE DATABASE warehouse_db;
\c warehouse_db
```

Load the schema and sample data:

```sql
\i p3_schema_and_data.sql
```

This will:
- Create tables: `Warehouse`, `Product`, `InventoryBatch`, `MembershipPlan`,
  `Member`, `Membership`, `"Transaction"`, and `TransactionItem`.
- Insert sample data that supports all four queries.

### Run the analytical queries (part c)

Execute:

```sql
\i p3_queries.sql
```

This file contains:

1. **Members who would have saved money on Executive tier**  
   - Treats 2024 as the analysis year.  
   - Computes each current Basic member’s total 2024 spending and the hypothetical 2% Executive savings, comparing that with the Executive–Basic fee difference.

2. **Warehouses that had Kirkland Paper Towels but are now out of stock**  
   - Identifies warehouses that have ever had batches of product `'Kirkland Paper Towels'` and where the sum of `quantity_remaining` for that product is now zero.

3. **Grocery products fully sold out during Dec 18–24, 2025**  
   - For category `'Grocery'`, finds `(warehouse, product)` pairs that have no positive inventory overlapping the week of 2025-12-18 to 2025-12-24, using batch-level quantity information.

4. **Members who purchased at >1 warehouse and spent >$500 in 2024**  
   - Aggregates 2024 spending per member from `Transaction` and `TransactionItem`.  
   - Filters to those with more than one distinct warehouse and total spending over 500.

### Key assumptions

- **Discount modeling**:  
  - `MembershipPlan` encodes annual fees and discount rates (0% Basic, 2% Executive).  
  - `unit_price_paid` on `TransactionItem` is treated as the actual price paid; hypothetical Executive savings are computed as 2% of total 2024 spend for comparison.

- **Sold-out semantics**:  
  - For the “fully sold out during the week before Christmas” query, the sample data and query logic assume that if any batch for a `(warehouse, sku)` has positive `quantity_remaining` overlapping the 2025-12-18–24 window, the product is not considered fully sold out there; otherwise it is.\n+
