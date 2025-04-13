# Key Concepts

## 🧩 1. **Integrations**
**What:** dbt integrates with data warehouses like **BigQuery**, GitHub, Slack, Airflow, and more.

**Use in your case:**
- You'll integrate **dbt with BigQuery** as your data warehouse.
- Integrate **GitHub** to manage version control.
- Eventually, integrate **Looker Studio** for visualization (more on that later).

---

## 📸 2. **Snapshots**
**What:** Snapshots let you track **slowly changing dimensions** (SCDs), like changes in job titles or company names over time.

**Use in your case:**
- If you want to track changes in job postings or salaries **over time**, use snapshots to store historical values.
- For example: `job_postings_snapshot` can track changes in salary offers per job over weeks/months.

---

## 🏗️ 3. **Models**
**What:** dbt models are **SQL SELECT statements** that build your data transformations step-by-step. They're the core of dbt.

**Use in your case:**
- You’ll use **staging models** to clean GCS-imported raw tables (e.g., `stg_jobs`, `stg_companies`).
- Then **intermediate models** to join and structure them (e.g., `int_job_details`).
- Then **final models** for dashboard-ready data (e.g., `fct_job_summary`, `dim_company`).

---

## ✅ 4. **Tests**
**What:** Tests validate your data quality. You can do **schema tests** (like nulls, uniqueness) and **custom tests**.

**Use in your case:**
- Test for missing foreign keys between jobs and companies.
- Validate that salary values are non-negative.
- Ensure job postings always have a company and title.

---

## 📚 5. **Documentation**
**What:** dbt auto-generates a data **catalog** with lineage and descriptions, which is incredibly helpful for stakeholders and future you.

**Use in your case:**
- Document tables like `dim_company`, `fct_job_summary`, etc.
- Preview relationships and lineage from raw to final tables.
- This makes onboarding and dashboarding easier.

---

## 🌱 6. **Seeding**
**What:** Seed files are **CSV files** you can load directly into your warehouse via dbt.

**Use in your case:**
- Use seeds for **static mapping tables**, e.g., job industry codes, skill labels, benefit categories.
- Helps standardize lookups.

---

## 🔁 7. **Macros**
**What:** Macros are **templated SQL functions** using Jinja.

**Use in your case:**
- Create a macro for **partitioning logic**, so all your partitioned models reuse the same SQL snippet.
- Example: `{{ partition_by('posting_date') }}` used across models.

---

## 🗂️ 8. **Schema**
**What:** In dbt, `schema.yml` files define **tests, descriptions, and relationships** for models.

**Use in your case:**
- Use `schema.yml` to declare:
  - Required fields (e.g., `company_id` is not null).
  - Relationships (foreign keys).
  - Descriptions for documentation.
  - Column-level tests.

---

## 🧪 9. **Analyses**
**What:** These are **ad hoc SQL analyses** (not part of dbt's DAG) that can be committed and shared.

**Use in your case:**
- Do ad hoc exploration like "Top 10 companies with highest avg salary."
- Validate assumptions before writing production-ready models.

---

## 🎯 10. **Exposures**
**What:** Exposures describe **external tools (like dashboards)** that depend on your dbt models.

**Use in your case:**
- Track which models power your **Looker Studio dashboard**.
- Helps with **data lineage**, knowing that `fct_job_summary` feeds the salary dashboard.

---

## 📦 11. **Packages**
**What:** Reusable community plugins or internal shared logic. Think of it like importing libraries.

**Use in your case:**
- Use the [`dbt-utils`](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/) package to simplify common logic like `surrogate_key`, `date_spine`, `pivot`, etc.
- Install with:
  ```yaml
  packages:
    - package: dbt-labs/dbt_utils
      version: 1.1.1
  ```

---

## 🔁 Your Full Pipeline: Tied Together

Here’s how this all comes together from **GCS → BigQuery → dbt → Looker Studio**:

```mermaid
graph TD
  A[GCS Raw CSV Files] --> B[Terraform]
  B --> C[BigQuery External Tables (partitioned by date)]
  C --> D[dbt Staging Models]
  D --> E[dbt Intermediate Models]
  E --> F[dbt Final Models (Fact/Dim)]
  F --> G[Tests, Docs, Snapshots]
  F --> H[Exposures: Looker Studio Dashboard]
```
