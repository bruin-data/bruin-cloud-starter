/* @bruin
name: silver.products_enriched
type: bq.sql
materialization:
  type: table

depends:
  - bronze.raw_products

description: |
  Silver layer: Enriched and standardized product catalog.
  
  Transformations applied:
  - Deduplication (latest product state)
  - Category standardization
  - Price validation
  - Stock status calculation
  - Product name cleaning
  - Inactive products filtered
  - Derived attributes added
  
  This layer provides clean product data for analytics and reporting.

owner: data-engineering@company.com
tags:
  - silver
  - enriched
  - products
  - catalog

columns:
  - name: product_id
    type: STRING
    description: Unique product identifier
    primary_key: true
    checks:
      - name: not_null
      - name: unique
  - name: product_name
    type: STRING
    description: Cleaned product name
  - name: category
    type: STRING
    description: Standardized product category
  - name: price
    type: FLOAT64
    description: Current product price (USD)
    checks:
      - name: positive
  - name: stock_quantity
    type: INTEGER
    description: Current stock quantity
  - name: stock_status
    type: STRING
    description: Derived stock status (in_stock, low_stock, out_of_stock)
  - name: price_tier
    type: STRING
    description: Price tier classification (budget, mid-range, premium)
  - name: is_active
    type: BOOLEAN
    description: Product active status
@bruin */

WITH deduplicated AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY product_id 
      ORDER BY _ingested_at DESC
    ) AS row_num
  FROM bronze.raw_products
),

enriched AS (
  SELECT
    product_id,
    TRIM(product_name) AS product_name,
    UPPER(TRIM(category)) AS category,
    price,
    stock_quantity,
    -- Derive stock status
    CASE
      WHEN stock_quantity = 0 THEN 'out_of_stock'
      WHEN stock_quantity < 10 THEN 'low_stock'
      ELSE 'in_stock'
    END AS stock_status,
    -- Derive price tier
    CASE
      WHEN price < 20 THEN 'budget'
      WHEN price < 100 THEN 'mid-range'
      ELSE 'premium'
    END AS price_tier,
    is_active
  FROM deduplicated
  WHERE row_num = 1
    AND product_id IS NOT NULL
    AND product_name IS NOT NULL
    AND price > 0
    AND is_active = TRUE  -- Only active products
)

SELECT * FROM enriched
