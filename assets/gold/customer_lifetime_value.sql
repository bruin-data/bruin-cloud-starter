/* @bruin
name: gold.customer_lifetime_value
type: bq.sql
materialization:
  type: table

depends:
  - silver.customers_cleaned
  - silver.orders_processed

description: |
  Gold layer: Customer Lifetime Value (CLV) metrics.
  
  Business-ready analytics table providing comprehensive customer value metrics:
  - Total revenue per customer
  - Order frequency and recency
  - Average order value
  - Customer segmentation
  - Lifetime value calculations
  
  This table is optimized for business intelligence and reporting.
  Used by: Marketing, Sales, Customer Success teams

owner: analytics@company.com
tags:
  - gold
  - metrics
  - customer-analytics
  - clv
  - business-ready

columns:
  - name: customer_id
    type: STRING
    description: Unique customer identifier
    primary_key: true
  - name: full_name
    type: STRING
    description: Customer full name
  - name: email
    type: STRING
    description: Customer email address
  - name: first_order_date
    type: TIMESTAMP
    description: Date of first order
  - name: last_order_date
    type: TIMESTAMP
    description: Date of most recent order
  - name: total_orders
    type: INTEGER
    description: Total number of orders
  - name: total_revenue
    type: FLOAT64
    description: Total revenue generated (USD)
  - name: average_order_value
    type: FLOAT64
    description: Average order value (USD)
  - name: days_since_last_order
    type: INTEGER
    description: Days since last order
  - name: customer_segment
    type: STRING
    description: Customer value segment (high-value, medium-value, low-value, at-risk)
  - name: is_repeat_customer
    type: BOOLEAN
    description: Flag indicating repeat customer (2+ orders)
@bruin */

WITH customer_orders AS (
  SELECT
    c.customer_id,
    c.full_name,
    c.email,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount_usd) AS total_revenue,
    AVG(o.total_amount_usd) AS average_order_value,
    DATE_DIFF(CURRENT_DATE(), DATE(MAX(o.order_date)), DAY) AS days_since_last_order
  FROM silver.customers_cleaned c
  LEFT JOIN silver.orders_processed o
    ON c.customer_id = o.customer_id
    AND o.is_completed = TRUE
  GROUP BY c.customer_id, c.full_name, c.email
),

segmented AS (
  SELECT
    *,
    CASE
      WHEN total_orders >= 10 AND total_revenue >= 1000 THEN 'high-value'
      WHEN total_orders >= 5 OR total_revenue >= 500 THEN 'medium-value'
      WHEN total_orders >= 1 AND days_since_last_order <= 90 THEN 'low-value'
      WHEN total_orders >= 1 AND days_since_last_order > 90 THEN 'at-risk'
      ELSE 'new-customer'
    END AS customer_segment,
    CASE
      WHEN total_orders >= 2 THEN TRUE
      ELSE FALSE
    END AS is_repeat_customer
  FROM customer_orders
)

SELECT * FROM segmented
ORDER BY total_revenue DESC
