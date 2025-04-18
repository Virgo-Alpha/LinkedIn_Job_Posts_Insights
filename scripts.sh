# Download the docker compose file

# Update the ports and volumes of the postgres container in the docker compose yml file
# Update the locations to airflow

# Build the containers
docker compose up -d

# Connect to postgres with password airflow
pgcli -h localhost -p 5432 -u airflow -d airflow

# Delete the data/linkedin_data when removing volumes then build again and restart
# After running the dag, you can view the files by running the commands below
 docker compose exec airflow-worker bash
 ls /tmp/linkedin_data/

#  In 0_cloud_infra/terraform create the main.tf and variables.ft files then run the commands
terraform init

terraform fmt

terraform validate

terraform plan

terraform apply

# Take the output from terraform apply and use it to edit the docker compose file: project_id and bucket_name

# You can use target in terraform to destroy only the storage module
terraform destroy -target=module.storage

# DBT
# Create project, upload the service account json and add this repo
# In the gear icon, add 2_dbt_transformations as the subfolder for dbt
# In the cloud IDE, initialize the project

# to create external tables, make the models then run
dbt run-operation stage_external_sources

dbt build # tests and doesn't just run the models


# TODO:
# // ? Rename airflow folder to 1_airflow_wf_orchestration
# *1. Using airflow DAG
#   - Curl to get the zip
#   - Unzip the folder
#   - Add the files to postgres in a new db
#   - Create a .airflowignore file to ignore some dags and file in the folder

# ! Create the Makefile for local command

# *2. Make a makefile with the following commands:
#  //   - make local: Does all the things in 1 above and deletes the downloads
#   - make gcs: Does all the things in 1 above and uploads the files to gcs
#   - make bq: Does all the things in 1 above and uploads the files to gcs and partitions the tables in bq
# ? - make dbt: makes local and runs dbt
# ? - make dashboard: makes local and creates the dashboard (metamask), or creates the dashboard in looker studio if make prod was run
#   - make prod: Download and upload to gcs, partition tables in bq and create the dashboard in looker studio
#   - make all: Runs both the make local and make prod

# *2. Terraform to create the assets in the 0_cloud_infra folder
#   // - Create the GCS Bucket and BigQuery Dataset (GCS Cred)
#   // - Using airflow DAG, upload the unzipped files to the GCS bucket
#   - Delete the zip and the unzipped folder
#   - Create the tables in BigQuery and partition them appropriately using Airflow / terraform. Import from GCS

# *3. Create the dbt models in a new folder e.g., 2_dbt_transformations
#   - Create models to transform the data in preparation for the dashboard

# *4. Create the dashboard in a new folder e.g., 3_looker_studio_dashboard
#   - Create the dashboard using Looker Studio (try code but also use the UI)
#   - Download the dashboard into this folder


# ! Reproducibility (README), Testing, CI/CD Pipeline
# ! Files (Benchmark Finamu folder) : README.md, LICENCE.md, 
#   ./github: CODE_OF_CONDUCT.md, CONTRIBUTING.md, SETTING.md