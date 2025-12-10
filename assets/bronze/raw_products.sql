/* @bruin
name: bronze.raw_products
type: bq.sql
materialization:
  type: table

description: |
  Bronze layer: Raw product catalog data from inventory system.
  Unprocessed product information including active and inactive items.
  
  Data Quality:
  - No data cleansing applied
  - Includes all product states
  - Preserves source formatting

owner: data-engineering@company.com
tags:
  - bronze
  - raw
  - products
  - source:inventory

columns:
  - name: product_id
    type: STRING
    description: Unique product identifier
    checks:
      - name: not_null
  - name: product_name
    type: STRING
    description: Product name/title
  - name: category
    type: STRING
    description: Product category
  - name: price
    type: FLOAT64
    description: Current product price
  - name: stock_quantity
    type: INTEGER
    description: Available stock quantity
  - name: is_active
    type: BOOLEAN
    description: Product active status flag
  - name: _ingested_at
    type: TIMESTAMP
    description: Bruin ingestion timestamp
@bruin */

-- This is a placeholder query for raw product data ingestion
-- Replace with your actual data source

SELECT
  product_id,
  product_name,
  category,
  price,
  stock_quantity,
  is_active,
  CURRENT_TIMESTAMP() AS _ingested_at
FROM `project.source_dataset.products_raw`
