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
#   - Create the GCS Bucket and BigQuery Dataset (GCS Cred)
#   - Using airflow DAG, upload the unzipped files to the GCS bucket
#   - Delete the zip and the unzipped folder
#   - Create the tables in BigQuery and partition them appropriately using Airflow / terraform. Import from GCS

# *3. Create the dbt models in a new folder e.g., 2_dbt_transformations
#   - Create models to traform the data in preparation for the dashboard

# *4. Create the dashboard in a new folder e.g., 3_looker_studio_dashboard
#   - Create the dashboard using Looker Studio (try code but also use the UI)
#   - Download the dashboard into this folder


# ! Reproducibility (README), Testing, CI/CD Pipeline
# ! Files (Benchmark Finamu folder) : README.md, LICENCE.md, 
#   ./github: CODE_OF_CONDUCT.md, CONTRIBUTING.md, SETTING.md