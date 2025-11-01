# End-to-End Retail Sales Performance Analysis

### (PostgreSQL + Power BI)

This project is a complete, end-to-end demonstration of a Business Intelligence workflow. I transformed raw, multi-year transaction data from a flat CSV file into a high-performance **Star Schema Data Warehouse** in **PostgreSQL**. I then built an interactive analytical dashboard in **Power BI** to extract actionable business insights.

---
### 1. Problem Statement
The organization's sales reporting was previously reliant on **manual, Excel-based processes**. This created several critical business problems:

- **Fragmented Data:** Data was siloed in separate, inconsistent spreadsheets, making it impossible to maintain data continuity or perform long-term trend analysis (like Year-over-Year).
- **Inefficient & Error-Prone:** Man-hours were spent on manually copying and pasting data rather than analyzing it, leading to a high risk of human error.
- **Static & Non-Interactive:** Final reports were static. Stakeholders could not interactively filter, drill-down, or explore the data to find the root cause of a specific trend.

---
### 2. The Final Dashboard (The Solution)
To solve this, I designed and built a 1-page, self-service analytical dashboard in Power BI. This report connects directly to the clean, centralized, and high-performance PostgreSQL data warehouse.

![sales-dashboard](sales-dashboard)

**Key Features:**
- **Executive KPIs:** At-a-glance cards for `Total Revenue`, `Avg. Transaction`, and `Transaction Count`.
- **Trend Analysis:** An interactive line chart (`Sales Trend Over Time`) to identify seasonal patterns and long-term performance.
- **Performance Drivers:** Bar charts (`Sales by Product Category`, `Sales by Store Location`) and a Treemap (`Sale Proportion`) to identify top-performing segments.
- **Root Cause Analysis:** Interactive Slicers for `Date Range`, `Product Category`, and `Store Location` allow any user to drill-down and answer their own questions.

---
### 3. Key Insights & Actionable Recommendations
This dashboard immediately revealed several key business insights:

|**Insight**|**Actionable Recommendation**|
|---|---|
|**Sales are highly seasonal**, peaking significantly in Q4.|**Optimize Q4 Inventory:** Double-down on inventory for top-performing categories (like 'Electronics') in Q3 to prepare for the Q4 rush.|
|**Performance is not uniform.** The top 5 store locations drive 40% of all revenue.|**Audit Underperforming Stores:** Launch an operational review of the bottom 10 stores to identify and address issues (e.g., staffing, stock, local marketing).|
|**'Electronics' & 'Books' are the primary revenue drivers**, while 'Clothing' is a low-volume category.|**Run Targeted Promotions:** Launch off-season (Q1/Q2) promotions for mid-tier categories like 'Clothing' to smooth out revenue and increase volume.|

---
### 4. Technical Architecture & Data Workflow

This project's key differentiator is its robust back-end architecture. Unlike a simple CSV-to-Power BI project, this solution is built on a scalable database foundation.

#### 4.1. Data Warehouse Design: The Star Schema
Instead of loading one giant, slow table into Power BI, I designed and implemented a **Star Schema Data Warehouse** in PostgreSQL. This is the industry best-practice for BI.
**Why a Star Schema?**

- **Query Speed:** It's thousands of times faster. Filtering a fact table on an **integer key** (e.g., `product_fk = 4`) is far more efficient than searching a massive table for a **text string** (e.g., `category_name = 'Electronics'`).
- **Storage Efficiency:** It reduces data redundancy. The string "Electronics" is stored _once_ in `dim_product`, not millions of times in the main table. This dramatically shrinks the data model size in Power BI.

![data-model](data_model)

#### 4.2. ETL & Data Cleansing Workflow

The raw CSV data was unusable due to critical data integrity issues (non-standard `MM/DD/YYYY` dates and `.` decimals).

**Solution:** I used the **`psql` command-line tool** for ingestion, which allowed me to set session variables (`SET DateStyle`, `SET lc_numeric`) to correctly parse the non-standard formats during the `\COPY` command.

The transformation was executed using SQL scripts to populate the 5 Star Schema tables from the raw staging table.

#### 4.3. Code Repository

This repository contains a `/sql_scripts` folder with the complete, documented SQL code for this project:

- `01_create_tables.sql`: Contains all `CREATE TABLE` scripts for the 5-table Star Schema.
- `02_transform_load.sql`: Contains the `INSERT INTO ... SELECT ... JOIN` queries used to transform the staging data and load it into the final production tables.

---
### 5. Tools & Technologies Used

- **Database:** **PostgreSQL** (for Data Warehousing & Star Schema implementation).
- **ETL (Data Transformation):** **SQL** (PostgreSQL) and **`psql`** (for cleansing and ingestion of raw data).
- **Visualization & Modeling:** **Power BI** (for data modeling, relationships, and dashboard design).
- **Calculation:** **DAX** (for formatting currency and creating KPI measures like `Total Revenue` and `Transaction Count`).
- **Dataset Source:** [Retail Transaction Dataset](https://www.kaggle.com/datasets/fahadrehman07/retail-transaction-dataset) by Fahad Rehman
