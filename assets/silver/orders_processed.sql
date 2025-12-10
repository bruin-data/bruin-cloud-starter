/* @bruin
name: silver.orders_processed
type: bq.sql
materialization:
  type: table

depends:
  - bronze.raw_orders
  - silver.customers_cleaned

description: |
  Silver layer: Processed and validated order transactions.
  
  Transformations applied:
  - Deduplication of order records
  - Currency normalization to USD
  - Status standardization
  - Invalid orders filtered (negative amounts, missing data)
  - Customer validation (only orders from valid customers)
  - Business logic applied (e.g., cancelled orders marked)
  
  This layer provides clean order data ready for business analysis.

owner: data-engineering@company.com
tags:
  - silver
  - processed
  - orders
  - transactions

columns:
  - name: order_id
    type: STRING
    description: Unique order identifier
    primary_key: true
    checks:
      - name: not_null
      - name: unique
  - name: customer_id
    type: STRING
    description: Foreign key to silver.customers_cleaned
    checks:
      - name: not_null
  - name: order_date
    type: TIMESTAMP
    description: Order placement timestamp
  - name: order_status
    type: STRING
    description: Standardized order status
  - name: total_amount_usd
    type: FLOAT64
    description: Order total normalized to USD
    checks:
      - name: positive
  - name: original_currency
    type: STRING
    description: Original currency code
  - name: is_completed
    type: BOOLEAN
    description: Flag indicating completed orders
@bruin */

WITH deduplicated AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY order_id 
      ORDER BY _ingested_at DESC
    ) AS row_num
  FROM bronze.raw_orders
),

-- Currency conversion rates (placeholder - replace with actual rates table)
currency_rates AS (
  SELECT 'USD' AS currency, 1.0 AS rate_to_usd
  UNION ALL SELECT 'EUR', 1.1
  UNION ALL SELECT 'GBP', 1.27
  UNION ALL SELECT 'CAD', 0.74
),

processed AS (
  SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    UPPER(TRIM(o.order_status)) AS order_status,
    o.total_amount * COALESCE(cr.rate_to_usd, 1.0) AS total_amount_usd,
    o.currency AS original_currency,
    CASE 
      WHEN UPPER(o.order_status) IN ('COMPLETED', 'DELIVERED', 'SHIPPED') THEN TRUE
      ELSE FALSE
    END AS is_completed
  FROM deduplicated o
  LEFT JOIN currency_rates cr ON o.currency = cr.currency
  WHERE o.row_num = 1
    AND o.order_id IS NOT NULL
    AND o.customer_id IS NOT NULL
    AND o.total_amount > 0  -- Filter invalid amounts
    AND o.order_date IS NOT NULL
)

-- Only include orders from valid customers
SELECT p.*
FROM processed p
INNER JOIN silver.customers_cleaned c
  ON p.customer_id = c.customer_id
