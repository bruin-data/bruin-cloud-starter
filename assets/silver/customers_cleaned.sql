/* @bruin
name: silver.customers_cleaned
type: bq.sql
materialization:
  type: table

depends:
  - bronze.raw_customers

description: |
  Silver layer: Cleaned and validated customer data.
  
  Transformations applied:
  - Deduplication (latest record per customer_id)
  - Email validation and standardization
  - Name formatting (proper case)
  - Invalid/test records filtered out
  - Business rules applied
  
  This layer provides clean, validated customer records ready for analytics.

owner: data-engineering@company.com
tags:
  - silver
  - cleaned
  - customers

columns:
  - name: customer_id
    type: STRING
    description: Unique customer identifier
    primary_key: true
    checks:
      - name: not_null
      - name: unique
  - name: email
    type: STRING
    description: Validated and lowercase email address
    checks:
      - name: not_null
  - name: full_name
    type: STRING
    description: Concatenated full name in proper case
  - name: first_name
    type: STRING
    description: Cleaned first name
  - name: last_name
    type: STRING
    description: Cleaned last name
  - name: created_at
    type: TIMESTAMP
    description: Customer creation timestamp
  - name: updated_at
    type: TIMESTAMP
    description: Last update timestamp
  - name: is_valid_email
    type: BOOLEAN
    description: Flag indicating valid email format
@bruin */

WITH deduplicated AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id 
      ORDER BY updated_at DESC
    ) AS row_num
  FROM bronze.raw_customers
),

cleaned AS (
  SELECT
    customer_id,
    LOWER(TRIM(email)) AS email,
    CONCAT(
      INITCAP(TRIM(first_name)), 
      ' ', 
      INITCAP(TRIM(last_name))
    ) AS full_name,
    INITCAP(TRIM(first_name)) AS first_name,
    INITCAP(TRIM(last_name)) AS last_name,
    created_at,
    updated_at,
    -- Email validation: basic regex check
    REGEXP_CONTAINS(email, r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') AS is_valid_email
  FROM deduplicated
  WHERE row_num = 1
    AND customer_id IS NOT NULL
    AND email IS NOT NULL
    AND email NOT LIKE '%test%'  -- Filter test accounts
    AND email NOT LIKE '%example.com%'  -- Filter example emails
)

SELECT * FROM cleaned
WHERE is_valid_email = TRUE
