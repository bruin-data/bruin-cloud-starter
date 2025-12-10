/* @bruin
name: bronze.raw_orders
type: bq.sql
materialization:
  type: table

description: |
  Bronze layer: Raw order transactions from e-commerce platform.
  Landing zone for all order data without transformations.
  
  Data Quality:
  - Preserves original data types and values
  - No deduplication or validation
  - Includes cancelled/failed orders

owner: data-engineering@company.com
tags:
  - bronze
  - raw
  - orders
  - source:ecommerce

columns:
  - name: order_id
    type: STRING
    description: Unique order identifier from source system
    checks:
      - name: not_null
  - name: customer_id
    type: STRING
    description: Foreign key to customer record
  - name: order_date
    type: TIMESTAMP
    description: Order placement timestamp
  - name: order_status
    type: STRING
    description: Order status (pending, completed, cancelled, etc.)
  - name: total_amount
    type: FLOAT64
    description: Total order amount in source currency
  - name: currency
    type: STRING
    description: Currency code (USD, EUR, etc.)
  - name: _ingested_at
    type: TIMESTAMP
    description: Bruin ingestion timestamp
@bruin */

-- This is a placeholder query for raw order data ingestion
-- Replace with your actual data source

SELECT
  order_id,
  customer_id,
  order_date,
  order_status,
  total_amount,
  currency,
  CURRENT_TIMESTAMP() AS _ingested_at
FROM `project.source_dataset.orders_raw`
WHERE DATE(order_date) = '{{ end_date }}'
