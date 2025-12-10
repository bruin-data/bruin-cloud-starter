/* @bruin
name: gold.daily_revenue_summary
type: bq.sql
materialization:
  type: table

depends:
  - silver.orders_processed

description: |
  Gold layer: Daily revenue and order metrics summary.
  
  Business KPIs aggregated by day:
  - Total revenue and order counts
  - Average order values
  - Day-over-day growth rates
  - Running totals
  - Order status breakdown
  
  This table powers executive dashboards and daily reporting.
  Used by: Executive team, Finance, Operations

owner: analytics@company.com
tags:
  - gold
  - metrics
  - revenue
  - daily-summary
  - kpi
  - business-ready

columns:
  - name: order_date
    type: DATE
    description: Order date (date dimension)
    primary_key: true
  - name: total_orders
    type: INTEGER
    description: Total number of orders
  - name: completed_orders
    type: INTEGER
    description: Number of completed orders
  - name: total_revenue
    type: FLOAT64
    description: Total revenue (USD)
  - name: completed_revenue
    type: FLOAT64
    description: Revenue from completed orders (USD)
  - name: average_order_value
    type: FLOAT64
    description: Average order value (USD)
  - name: unique_customers
    type: INTEGER
    description: Number of unique customers who ordered
  - name: revenue_growth_pct
    type: FLOAT64
    description: Day-over-day revenue growth percentage
  - name: running_total_revenue
    type: FLOAT64
    description: Cumulative revenue to date (USD)
@bruin */

WITH daily_metrics AS (
  SELECT
    DATE(order_date) AS order_date,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN is_completed THEN order_id END) AS completed_orders,
    SUM(total_amount_usd) AS total_revenue,
    SUM(CASE WHEN is_completed THEN total_amount_usd ELSE 0 END) AS completed_revenue,
    AVG(total_amount_usd) AS average_order_value,
    COUNT(DISTINCT customer_id) AS unique_customers
  FROM silver.orders_processed
  GROUP BY DATE(order_date)
),

with_growth AS (
  SELECT
    *,
    -- Calculate day-over-day growth
    ROUND(
      ((total_revenue - LAG(total_revenue) OVER (ORDER BY order_date)) 
       / NULLIF(LAG(total_revenue) OVER (ORDER BY order_date), 0)) * 100,
      2
    ) AS revenue_growth_pct,
    -- Running total
    SUM(total_revenue) OVER (ORDER BY order_date) AS running_total_revenue
  FROM daily_metrics
)

SELECT * FROM with_growth
ORDER BY order_date DESC
