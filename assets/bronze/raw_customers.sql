/* @bruin
name: bronze.raw_customers
type: bq.sql
materialization:
  type: table

description: |
  Bronze layer: Raw customer data ingested from source system.
  This is the landing zone for unprocessed customer records.
  
  Data Quality:
  - Minimal transformations applied
  - Preserves source data structure
  - Includes all records (even duplicates/invalid)

owner: data-engineering@company.com
tags:
  - bronze
  - raw
  - customers
  - source:crm

columns:
  - name: customer_id
    type: STRING
    description: Unique identifier from source CRM system
    checks:
      - name: not_null
  - name: email
    type: STRING
    description: Customer email address (unvalidated)
  - name: first_name
    type: STRING
    description: Customer first name
  - name: last_name
    type: STRING
    description: Customer last name
  - name: created_at
    type: TIMESTAMP
    description: Record creation timestamp in source system
  - name: updated_at
    type: TIMESTAMP
    description: Last update timestamp in source system
  - name: _ingested_at
    type: TIMESTAMP
    description: Bruin ingestion timestamp
@bruin */

-- This is a placeholder query for raw customer data ingestion
-- Replace with your actual data source (e.g., external table, API, file)

SELECT
  customer_id,
  email,
  first_name,
  last_name,
  created_at,
  updated_at,
  CURRENT_TIMESTAMP() AS _ingested_at
FROM `project.source_dataset.customers_raw`
WHERE DATE(updated_at) = '{{ end_date }}'
