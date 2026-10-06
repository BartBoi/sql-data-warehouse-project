# Data Warehouse and Analytics Project

Welcome to my **Data Warehouse and Analytics Project** repository! 🚀

This project follows the process of building a SQL Server data warehouse, from importing source data to creating models for analytical queries. I am developing it as a learning and portfolio project while following **Data With Baraa's SQL course**, with my development environment adapted for MacOS (MS SQL Server -> Docker and VSC).

The structure and learning objectives are based on [Baraa's original data warehouse project](https://github.com/DataWithBaraa/sql-data-warehouse-project). This repository documents my implementation and progress.

> **Project status:** The GitHub repository contains the six source CSV files, Bronze, Silver, and Gold scripts, Silver and Gold quality checks, diagrams, and the Gold data dictionary. The analytics section below describes the intended reporting scope.

---

## 📖 Project Overview

This project involves:

1. **Data Architecture:** Designing a data warehouse using Medallion Architecture with **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines:** Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling:** Developing fact and dimension views organized into a star schema for analytical queries.
4. **Analytics & Reporting:** Preparing a model that can support SQL-based analysis of customers, products, and sales.

🎯 Through this project, I am developing practical skills in:

- SQL development
- Data architecture
- Data engineering
- ETL pipeline development
- Data modeling
- Data analytics

---

## 🛠️ Important Links & Tools

My development environment uses **SQL Server 2022 Developer edition**, running in Docker on a **MacBook Air M2**, and **Visual Studio Code** with Microsoft's SQL Server extension.

- **[Project datasets](datasets/):** Six CRM and ERP source CSV files, included in this repository and originally provided by [Data With Baraa](https://github.com/DataWithBaraa/sql-data-warehouse-project/tree/main/datasets).
- **SQL Server 2022 Developer:** The database engine used to build and query the warehouse.
- **[Docker Desktop](https://www.docker.com/products/docker-desktop/):** Runs the SQL Server container on my Mac.
- **[Visual Studio Code](https://code.visualstudio.com/):** Editor for SQL scripts and Markdown documentation.
- **[SQL Server extension for VS Code](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql):** Connects VS Code to SQL Server and runs SQL queries.
- **[GitHub Repository](https://github.com/BartBoi/sql-data-warehouse-project):** Stores the project files and tracks changes.
- **[Draw.io](https://app.diagrams.net/):** An optional tool for designing architecture, data-flow, and data-model diagrams.
- **[Course Project](https://github.com/DataWithBaraa/sql-data-warehouse-project):** Baraa's original project and learning materials.

For bulk imports, the SQL scripts use paths inside the container, such as `/datasets/source_crm/cust_info.csv`. The datasets folder must be made available to the container at `/datasets`.

---

## ▶️ How to Run

### Prerequisites

- SQL Server 2022 running and accessible from VS Code with the SQL Server extension.
- For Docker, the project's `datasets/` directory must be mounted inside the SQL Server container at `/datasets`, with its `source_crm/` and `source_erp/` subfolders intact. The CSVs are read by SQL Server, so a Mac file path in the editor is not sufficient.
- A connection to the intended SQL Server instance. My existing local connection uses `localhost`, port `1433`, and SQL authentication.

For my existing setup, open Docker Desktop before starting the container:

```sh
docker start sql-course
```

This command assumes the container has already been created with the dataset mount described above.

### Build and Load the Warehouse

The sequence below is for an initial setup or a deliberate full rebuild.

> **Warning:** The initialization script deletes and recreates `DataWarehouse` if it exists. The table DDL scripts also drop and recreate tables. Back up work you need to retain before rebuilding.

Run the initialization script first. Then select **DataWarehouse** as the database for each subsequent query in VS Code. Run each script as a whole file so its `GO` batch separators are respected.

| Step | Script or command | Purpose |
| --- | --- | --- |
| 1 | [Initialize database](scripts/init_database.sql) | Create `DataWarehouse` and the three schemas. |
| 2 | [Bronze DDL](scripts/bronze/ddl_bronze.SQL) | Create the Bronze tables. |
| 3 | [Bronze procedure](scripts/bronze/proc_load_bronze.sql) | Create or update `bronze.load_bronze`. |
| 4 | `EXEC bronze.load_bronze;` | Load the source CSVs into Bronze. |
| 5 | [Silver DDL](scripts/silver/ddl.silver.sql) | Create the Silver tables. |
| 6 | [Silver procedure](scripts/silver/proc_load_silver.sql) | Create or update `silver.load_silver`. |
| 7 | `EXEC silver.load_silver;` | Clean and load Bronze data into Silver. |
| 8 | [Gold DDL](scripts/gold/ddl_gold.sql) | Create the customer, product, and sales views. |
| 9 | [Silver quality checks](tests/quality_checks_silver.sql) | Inspect the cleaned data. |
| 10 | [Gold quality checks](tests/quality_checks_gold.sql) | Check the dimensions and their links to sales. |

Run each `EXEC` command in a separate query connected to `DataWarehouse`. Defining a stored procedure does not execute it. Check the Messages output after each load for errors; the procedures print caught errors there. The category mismatch described below is an accepted limitation of the course data.

### Query the Result

With `DataWarehouse` selected, try:

```sql
SELECT TOP (10) * FROM gold.dim_customers;
SELECT TOP (10) * FROM gold.dim_products;
SELECT TOP (10) * FROM gold.fact_sales;
```

---

## 🚀 Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective

Develop a SQL Server data warehouse to consolidate sales data from two source systems, enabling analytical reporting and informed decision-making.

#### Specifications

- **Data Sources:** Import data from ERP and CRM systems provided as CSV files.
- **Data Quality:** Cleanse and resolve data quality issues before analysis.
- **Integration:** Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope:** Focus on the current product records in the Gold Layer; historical product versions are retained in Silver.
- **Documentation:** Provide clear descriptions of the data model, its columns, and the purpose of each view.

### BI: Analytics & Reporting (Data Analytics)

#### Objective

Develop SQL-based analysis to provide insights into:

- **Customer behavior**
- **Product performance**
- **Sales trends**

The aim is to turn the warehouse data into useful business metrics that support decision-making.

---

## 🏗️ Data Architecture

The project follows **Medallion Architecture**, using Bronze, Silver, and Gold layers:

![Data warehouse architecture](docs/Data%20Warehouse%20Architecture.drawio.png)

Additional diagrams: [Integration model](docs/Integration%20Model.drawio.png), [Layer data flow](docs/Layer%20Data%20Flow%20Diagram.drawio.png), and [Gold star schema](docs/Sales%20Data%20Mart%20%28Star%20Schema%29%20Gold.drawio.png).

1. **Bronze Layer:** Stores raw data from the source CSV files in SQL Server tables. Stored procedures perform a full load using `TRUNCATE TABLE` and `BULK INSERT`.
2. **Silver Layer:** Cleans and standardizes Bronze data. Transformations include removing duplicates, trimming text, normalizing values, handling invalid dates, and removing hidden carriage-return characters from imported text.
3. **Gold Layer:** Presents business-ready data through views organized into a star schema. These views combine Silver data for reporting and analytics.

The Gold Layer consists of:

- **`gold.dim_customers`:** Customer details enriched with demographic and geographic data.
- **`gold.dim_products`:** Current products and their categories, costs, and attributes.
- **`gold.fact_sales`:** Sales transactions linked to the customer and product dimensions.

The Bronze and Silver procedures reload stored data. Gold views read the underlying data when queried and do not require a separate data-loading procedure.

See the [Gold data dictionary](docs/data_catalog.md) for column descriptions.

### Known Source Data Limitation

Seven current products have the category identifier `CO_PE`, which has no match in the supplied ERP category data. This also appears in the course's checks. The Gold product view retains these products through a `LEFT JOIN`, with `NULL` category, subcategory, and maintenance details. The original identifier is preserved.

---

## 📂 Repository Structure

The current GitHub repository contains the following files and folders:

```text
sql-data-warehouse-project/
│
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── docs/
│   ├── data_catalog.md
│   ├── Data Warehouse Architecture.drawio
│   ├── Data Warehouse Architecture.drawio.png
│   ├── Integration Model.drawio
│   ├── Integration Model.drawio.png
│   ├── Layer Data Flow Diagram.drawio
│   ├── Layer Data Flow Diagram.drawio.png
│   ├── Sales Data Mart (Star Schema) Gold.drawio
│   └── Sales Data Mart (Star Schema) Gold.drawio.png
│
├── scripts/
│   ├── init_database.sql           # Database and schema initialization
│   ├── bronze/
│   │   ├── ddl_bronze.SQL          # Bronze table definitions
│   │   └── proc_load_bronze.sql    # Bronze loading procedure
│   ├── silver/
│   │   ├── ddl.silver.sql         # Silver table definitions
│   │   └── proc_load_silver.sql   # Silver loading procedure
│   └── gold/
│       └── ddl_gold.sql           # Gold view definitions
│
├── tests/
│   ├── quality_checks_silver.sql
│   └── quality_checks_gold.sql
│
├── README.md                      # Project overview
└── LICENSE                        # License information
```

The diagrams are provided in both editable Draw.io format and PNG format. Data quality checks are stored separately from the loading procedures.

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE). The original course project is credited above; see the license file for the terms of use.

---

## 🌟 About Me

Hi, I'm **Bart**. I am learning SQL, data engineering, warehousing, and analysis through practical projects. This repository records my progress as I build a warehouse, understand the transformations, and document the results.

I am following Data With Baraa's course and adapting the development setup to work on my Mac using Docker and VS Code.

You can find my projects on **[GitHub — BartBoi](https://github.com/BartBoi)**.
