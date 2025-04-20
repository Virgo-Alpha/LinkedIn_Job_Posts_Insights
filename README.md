# LinkedIn Job Posts Insights
This is a Data Engineering project that uses Docker, Terraform, GCS, BigQuery, Airflow, dbt and Looker studio to turn data into actionable insights in terms of career choice and job prospects using LinkedIn job postings from 2023-2024.

![Data Engineering on the Cloud_ A Summary](https://github.com/user-attachments/assets/5db8126f-4ba6-4966-830b-0abdd73e6429)

---

## 🔍 1. Problem Description
Choosing a career can be overwhelming. This project helps make informed decisions using real job data.

### Questions Answered:
1. Which job titles offer the highest salaries?
2. Which companies, industries, and skills are most lucrative?
3. What percentage of companies offer remote work (for work-life balance)?
4. What are the highest salaries and average experience levels?
5. Which countries have the most job postings?

---

## ☁️ 2. Cloud Infrastructure (Terraform)
The project was developed in Google Cloud platform using Terraform as an IaC tool. I modularized the different aspects and had outputs to show the resources created. We create everything starting from the project itself to the service account, gcs bucket and big query, iam management for permissions and even enabling the apis.
I also make use of variables.
In the outputs displayed on the terminal, copy the project id, bucket name and service account name for use in airflow's docker-compose.yml file.

All Terraform code is in `0_cloud_infra/terraform`.

### Commands:
```bash
cd 0_cloud_infra/terraform
terraform init
terraform apply
```

Copy the `project_id`, `bucket name`, and `service account` for Airflow configuration.

---

## 🚚 3. Data Ingestion (GCS via Airflow)
I use airflow as my work orchestration tool to fetch and upload the data to a datalake. I build airflow using a docker-compose.yml file and Dockerfile which installs google sdk. I then create a dag that has multiple steps which include downloading, unzipping and uploading the data to the created gcs bucket. To run the dag, please replace the BUCKET_NAME variable in the dag file with the one that was output when you run terraform apply.

### Airflow Setup:
```bash
docker-compose build
docker-compose up airflow-init
docker-compose up -d
```
Then visit [http://localhost:8080](http://localhost:8080) to run the DAG.

![Screenshot from 2025-04-14 11-42-02](https://github.com/user-attachments/assets/b92a9280-80ce-477b-937b-c9ac3b3bc123)

---

## 📊 4. Data Warehouse (BigQuery)
BigQuery is provisioned via Terraform.

External tables are defined using **dbt**. For performance:
- Partitioned by month: `TIMESTAMP_TRUNC(original_listed_time, MONTH)`
- Clustered by: `company_id`, `formatted_work_type`, `formatted_experience_level`, `company_country`

### 🏋️ Why Partitioning & Clustering?
- **Partitioning** helps scan only relevant time ranges.
- **Clustering** optimizes filter operations, joins, and aggregations by organizing data on disk.

---

## ⚖️ 5. Transformations (dbt)
I used dbt to model my data and apply transformations necessary for use in making of the dashboard. I made models, staging and dimension tables as well as tests and exposures.
All transformations are done using **dbt Cloud IDE**:
- Models: `staging/`, `marts/core/`
- Sources: Defined in `sources.yml`
- Tests & schema validation

### Key Models:
- `stg_linkedin__postings`, `stg_linkedin__salaries`, `stg_linkedin__benefits`, etc.
- `fct_postings` joins staging + dimension tables for dashboard consumption.

### Run Commands:
```bash
dbt run-operation stage_external_sources
dbt build
```

Please see my models and tables below:

![models](https://github.com/user-attachments/assets/52051e2a-c579-4f46-b878-65360a2be076)


> Use dbt Cloud IDE for dependencies & permissions. Project uses GCS + BigQuery access via service account.

---

## 📊 6. Dashboard (Looker Studio)
The dashboard visualizes insights based on the `fct_postings` fact table.

![Screenshot from 2025-04-14 11-31-33](https://github.com/user-attachments/assets/55c58d11-8c35-402f-8809-7926d152d2f1)


**Link to Dashboard**: [Open in Looker Studio](https://lookerstudio.google.com/s/r0sYLY6crpE)

---

## 🔄 7. Reproducibility
Step-by-step to reproduce the project:

```bash
# Step 1: Provision Infra
cd 0_cloud_infra/terraform
terraform init
terraform apply
# Note down the project_id, bucket name, and service account name

# Step 2: Run Airflow for data ingestion
cd ../..
docker-compose build
docker-compose up airflow-init
docker-compose up -d
# Visit localhost:8080 and trigger the DAG

# Step 3: Run dbt transformations (in dbt Cloud)
cd 2_dbt_transformations
dbt run-operation stage_external_sources
dbt build
```

---

## ✅ 8. Testing
Some dbt tests added for schema + uniqueness + nulls.

![Screenshot from 2025-04-14 11-35-07](https://github.com/user-attachments/assets/effe899a-33fb-4331-9743-21515c146c76)


> Future: Add CI testing via GitHub Actions and unit tests for DAGs.

---

## 📃 9. Makefile
An alternative to the DAG for manual local testing:
```makefile
download  # downloads zip file to ./data/.data/
unzip     # unzips contents
delete    # deletes .data folder
```
Used during local dev before uploading to GCS.

---

## ⚙️ 10. Further Work
- Add ingestion into local Postgres (test mode)
- Expand dbt test coverage
- Add CI/CD with GitHub Actions
- Use dbt seed for static dimension tables
- Snapshotting for slowly changing dimensions
- Generate dbt documentation
- Improve Looker Studio with parameters and filters

---

