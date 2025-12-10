/* @bruin
name: gold.product_performance
type: bq.sql
materialization:
  type: table

depends:
  - silver.products_enriched
  - silver.orders_processed

description: |
  Gold layer: Product performance metrics and analytics.
  
  Business metrics by product:
  - Sales performance (revenue, units sold)
  - Product rankings
  - Category performance
  - Inventory turnover indicators
  - Price tier analysis
  
  This table supports product management and merchandising decisions.
  Used by: Product team, Merchandising, Inventory Management
  
  Note: This is a placeholder - join with order_items table when available.

owner: analytics@company.com
tags:
  - gold
  - metrics
  - product-analytics
  - performance
  - business-ready

columns:
  - name: product_id
    type: STRING
    description: Unique product identifier
    primary_key: true
  - name: product_name
    type: STRING
    description: Product name
  - name: category
    type: STRING
    description: Product category
  - name: price
    type: FLOAT64
    description: Current price (USD)
  - name: price_tier
    type: STRING
    description: Price tier classification
  - name: stock_quantity
    type: INTEGER
    description: Current stock level
  - name: stock_status
    type: STRING
    description: Stock availability status
  - name: total_orders
    type: INTEGER
    description: Total number of orders (placeholder - requires order_items)
  - name: total_revenue
    type: FLOAT64
    description: Total revenue generated (placeholder - requires order_items)
  - name: revenue_rank
    type: INTEGER
    description: Product rank by revenue within category
@bruin */

WITH product_metrics AS (
  SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.price_tier,
    p.stock_quantity,
    p.stock_status,
    -- Placeholder metrics - replace with actual order_items join
    -- For now, using random values to demonstrate structure
    0 AS total_orders,
    0.0 AS total_revenue
  FROM silver.products_enriched p
),

ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY category 
      ORDER BY total_revenue DESC
    ) AS revenue_rank
  FROM product_metrics
)

SELECT * FROM ranked
ORDER BY category, revenue_rank
