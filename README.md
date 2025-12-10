# Bruin Medallion Architecture Starter Pipeline

A production-ready starter template demonstrating the **Medallion Architecture** pattern (Bronze → Silver → Gold) using Bruin CLI.

## 🏗️ Architecture Overview

This pipeline implements a three-layer data architecture pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                     BRONZE LAYER (Raw)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │raw_customers │  │  raw_orders  │  │ raw_products │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                    SILVER LAYER (Cleaned)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  customers_  │  │   orders_    │  │  products_   │     │
│  │   cleaned    │  │  processed   │  │  enriched    │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          └────────┬─────────┴─────────┬────────┘
                   ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                  GOLD LAYER (Business Ready)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  customer_   │  │    daily_    │  │   product_   │     │
│  │  lifetime_   │  │   revenue_   │  │ performance  │     │
│  │    value     │  │   summary    │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐                                           │
│  │  customer_   │                                           │
│  │   cohort_    │                                           │
│  │  analysis    │                                           │
│  └──────────────┘                                           │
└─────────────────────────────────────────────────────────────┘
```

## 📂 Project Structure

```
.
├── pipeline.yml                          # Pipeline configuration
├── assets/
│   ├── bronze/                          # Raw data ingestion layer
│   │   ├── raw_customers.sql           # Raw customer data
│   │   ├── raw_orders.sql              # Raw order transactions
│   │   └── raw_products.sql            # Raw product catalog
│   ├── silver/                          # Cleaned & validated layer
│   │   ├── customers_cleaned.sql       # Deduplicated, validated customers
│   │   ├── orders_processed.sql        # Processed orders with currency normalization
│   │   └── products_enriched.sql       # Enriched product data
│   └── gold/                            # Business-ready analytics layer
│       ├── customer_lifetime_value.sql  # CLV metrics & segmentation
│       ├── daily_revenue_summary.sql    # Daily KPIs & growth metrics
│       ├── product_performance.sql      # Product analytics
│       └── customer_cohort_analysis.sql # Cohort retention analysis
└── README.md
```

## 🎯 Layer Descriptions

### Bronze Layer (Raw Data)
**Purpose**: Landing zone for raw, unprocessed data from source systems

**Characteristics**:
- Minimal transformations
- Preserves source data structure
- Includes all records (duplicates, invalid data)
- Timestamped ingestion metadata
- Immutable historical record

**Assets**:
- `raw_customers` - Customer records from CRM
- `raw_orders` - Order transactions from e-commerce platform
- `raw_products` - Product catalog from inventory system

### Silver Layer (Cleaned & Validated)
**Purpose**: Clean, conformed, and validated data ready for analytics

**Characteristics**:
- Deduplication applied
- Data quality rules enforced
- Standardized formats and naming
- Business logic applied
- Invalid records filtered

**Transformations**:
- Email validation and normalization
- Currency conversion to USD
- Status standardization
- Name formatting (proper case)
- Foreign key validation

**Assets**:
- `customers_cleaned` - Validated customer records
- `orders_processed` - Processed orders with currency normalization
- `products_enriched` - Enriched product data with derived attributes

### Gold Layer (Business Ready)
**Purpose**: Aggregated, business-ready analytics tables for reporting and BI

**Characteristics**:
- Pre-aggregated metrics
- Business KPIs calculated
- Optimized for query performance
- Domain-specific models
- Ready for dashboards and reports

**Assets**:
- `customer_lifetime_value` - CLV metrics, segmentation, and customer health
- `daily_revenue_summary` - Daily revenue KPIs with growth rates
- `product_performance` - Product sales and performance metrics
- `customer_cohort_analysis` - Retention and cohort behavior analysis

## 🚀 Getting Started

### Prerequisites
- [Bruin CLI](https://github.com/bruin-data/bruin) installed
- Database connection configured (BigQuery, Snowflake, etc.)

### Setup

1. **Clone this repository**:
```bash
git clone https://github.com/bruin-data/bruin-cloud-starter.git
cd bruin-cloud-starter
```

2. **Configure your connections**:
```bash
bruin connections add
```

3. **Update `pipeline.yml`** with your connection names:
```yaml
default_connections:
  google_cloud_platform: your-bigquery-connection
  snowflake: your-snowflake-connection
```

4. **Update asset queries** to point to your actual data sources:
   - Replace placeholder table references in bronze layer assets
   - Update source table names in SQL queries

### Running the Pipeline

**Validate the pipeline**:
```bash
bruin validate .
```

**Run the entire pipeline**:
```bash
bruin run .
```

**Run a specific layer**:
```bash
bruin run assets/bronze/
bruin run assets/silver/
bruin run assets/gold/
```

**Run a single asset**:
```bash
bruin run assets/gold/customer_lifetime_value.sql
```

**Run with downstream dependencies**:
```bash
bruin run assets/silver/customers_cleaned.sql --downstream
```

## 🔧 Customization Guide

### Adding New Assets

1. **Bronze Layer**: Add new source data ingestion
```bash
# Create new bronze asset
touch assets/bronze/raw_your_table.sql
```

2. **Silver Layer**: Add transformations
```bash
# Create new silver asset with dependencies
touch assets/silver/your_table_cleaned.sql
```

3. **Gold Layer**: Add business metrics
```bash
# Create new gold asset
touch assets/gold/your_business_metric.sql
```

### Modifying Transformations

Each asset includes detailed comments explaining:
- Business logic applied
- Data quality rules
- Transformation steps
- Column descriptions

Edit the SQL files to customize transformations for your use case.

### Connecting to Your Data Sources

Update the `FROM` clauses in bronze layer assets:

```sql
-- Replace this placeholder:
FROM `project.source_dataset.customers_raw`

-- With your actual source:
FROM `your-project.your-dataset.your-table`
```

## 📊 Data Quality

The pipeline includes built-in data quality checks:

- **NOT NULL checks** on primary keys
- **UNIQUE checks** on identifiers
- **Positive value checks** on amounts
- **Email validation** with regex
- **Foreign key validation** between layers

Add custom checks in asset definitions:
```yaml
columns:
  - name: customer_id
    checks:
      - name: not_null
      - name: unique
```

## 🔄 Lineage

View the data lineage:
```bash
bruin lineage .
```

This shows the dependency graph between all assets across layers.

## 📅 Scheduling

The pipeline is configured to run daily. Modify in `pipeline.yml`:

```yaml
schedule: daily  # Options: hourly, daily, weekly, monthly, or cron expression
start_date: "2024-01-01"
```

## 🔔 Notifications

Configure Slack notifications in `pipeline.yml`:

```yaml
notifications:
  slack:
    - channel: data-pipelines
      success: false  # Only notify on failures
```

## 📈 Use Cases

This starter template is ideal for:

- **E-commerce analytics** - Customer, order, and product analysis
- **SaaS metrics** - User behavior and revenue tracking
- **Retail analytics** - Sales performance and inventory
- **Customer analytics** - CLV, retention, and segmentation

## 🤝 Contributing

Contributions welcome! Please open an issue or PR.

## 📝 License

MIT License - feel free to use this template for your projects.

## 🆘 Support

- [Bruin Documentation](https://bruin-data.github.io/bruin/)
- [Bruin GitHub](https://github.com/bruin-data/bruin)
- [Community Slack](https://join.slack.com/t/bruindata/shared_invite/zt-2dl2i8foy-WEYFE8n~jvJQd4FHwx0j0A)

---

**Built with ❤️ using [Bruin](https://getbruin.com)**
