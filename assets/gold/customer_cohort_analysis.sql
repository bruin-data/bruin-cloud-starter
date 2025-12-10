/* @bruin
name: gold.customer_cohort_analysis
type: bq.sql
materialization:
  type: table

depends:
  - silver.customers_cleaned
  - silver.orders_processed

description: |
  Gold layer: Customer cohort retention and behavior analysis.
  
  Cohort-based analytics:
  - Customer acquisition cohorts (by month)
  - Retention rates by cohort
  - Revenue per cohort over time
  - Cohort size and growth
  
  This table enables cohort analysis for understanding customer retention
  and lifetime value trends over time.
  Used by: Marketing, Growth team, Customer Success

owner: analytics@company.com
tags:
  - gold
  - metrics
  - cohort-analysis
  - retention
  - business-ready

columns:
  - name: cohort_month
    type: DATE
    description: First day of the month when customers first ordered
    primary_key: true
  - name: cohort_size
    type: INTEGER
    description: Number of customers in this cohort
  - name: total_orders
    type: INTEGER
    description: Total orders from this cohort
  - name: total_revenue
    type: FLOAT64
    description: Total revenue from this cohort (USD)
  - name: average_revenue_per_customer
    type: FLOAT64
    description: Average revenue per customer in cohort (USD)
  - name: repeat_customer_rate
    type: FLOAT64
    description: Percentage of customers with 2+ orders
  - name: average_days_to_second_order
    type: FLOAT64
    description: Average days between first and second order
@bruin */

WITH customer_first_order AS (
  SELECT
    o.customer_id,
    DATE_TRUNC(MIN(o.order_date), MONTH) AS cohort_month,
    MIN(o.order_date) AS first_order_date
  FROM silver.orders_processed o
  WHERE o.is_completed = TRUE
  GROUP BY o.customer_id
),

customer_orders_with_cohort AS (
  SELECT
    cfo.customer_id,
    cfo.cohort_month,
    cfo.first_order_date,
    o.order_id,
    o.order_date,
    o.total_amount_usd,
    ROW_NUMBER() OVER (
      PARTITION BY cfo.customer_id 
      ORDER BY o.order_date
    ) AS order_number
  FROM customer_first_order cfo
  INNER JOIN silver.orders_processed o
    ON cfo.customer_id = o.customer_id
    AND o.is_completed = TRUE
),

cohort_metrics AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) AS cohort_size,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_amount_usd) AS total_revenue,
    ROUND(SUM(total_amount_usd) / COUNT(DISTINCT customer_id), 2) AS average_revenue_per_customer,
    ROUND(
      COUNT(DISTINCT CASE WHEN order_number >= 2 THEN customer_id END) * 100.0 
      / COUNT(DISTINCT customer_id),
      2
    ) AS repeat_customer_rate
  FROM customer_orders_with_cohort
  GROUP BY cohort_month
),

second_order_timing AS (
  SELECT
    cohort_month,
    AVG(DATE_DIFF(
      DATE(order_date),
      DATE(first_order_date),
      DAY
    )) AS average_days_to_second_order
  FROM customer_orders_with_cohort
  WHERE order_number = 2
  GROUP BY cohort_month
)

SELECT
  cm.*,
  ROUND(COALESCE(sot.average_days_to_second_order, 0), 1) AS average_days_to_second_order
FROM cohort_metrics cm
LEFT JOIN second_order_timing sot
  ON cm.cohort_month = sot.cohort_month
ORDER BY cohort_month DESC
