## Problem 3(a) – ER Diagram (Warehouse Inventory and Membership)

Below is an ER-style sketch using mermaid notation that corresponds to the schema in `p3_er_and_schema.md`.

```mermaid
erDiagram
    Warehouse ||--o{ InventoryBatch : has
    Product   ||--o{ InventoryBatch : supplies

    MembershipPlan ||--o{ Membership : config_for
    Member         ||--o{ Membership : enrolls_in

    Warehouse  ||--o{ Transaction : occurs_at
    Member     ||--o{ Transaction : makes

    Transaction   ||--o{ TransactionItem : contains
    InventoryBatch ||--o{ TransactionItem : drawn_from

    Warehouse {
        INT warehouse_id PK
        TEXT address
        TEXT phone
    }

    Product {
        INT sku PK
        TEXT name
        TEXT category
        NUMERIC current_unit_price
    }

    InventoryBatch {
        INT batch_id PK
        INT warehouse_id FK
        INT sku FK
        DATE arrival_date
        DATE expiration_date
        INT quantity_remaining
    }

    MembershipPlan {
        INT plan_id PK
        TEXT plan_name
        NUMERIC annual_fee
        NUMERIC discount_rate
    }

    Member {
        INT member_id PK
        TEXT name
        TEXT phone
    }

    Membership {
        INT member_id FK
        INT plan_id FK
        DATE start_date
        DATE end_date
    }

    Transaction {
        INT tx_id PK
        TIMESTAMP tx_timestamp
        INT member_id FK
        INT warehouse_id FK
    }

    TransactionItem {
        INT tx_id FK
        INT line_no
        INT batch_id FK
        INT quantity
        NUMERIC unit_price_paid
    }
```

This diagram matches the entities, keys, and relationships described in `p3_er_and_schema.md` and can be used as the ER “drawing” for part (a).

