from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
import os

# Define default arguments
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define constants
TMP_DIR = "/tmp/linkedin_data"  # Use a temporary directory
ZIP_FILE = os.path.join(TMP_DIR, "linkedin-job-postings.zip")
UNZIP_DIR = os.path.join(TMP_DIR, 'linkedin-job-postings')
BUCKET_NAME = 'linkedin-job-insights-e1058fc3'
KAGGLE_URL = 'https://www.kaggle.com/api/v1/datasets/download/arshkon/linkedin-job-postings'

# Define the DAG
with DAG(
    'download_unzip_and_upload_data',
    default_args=default_args,
    description='A DAG to download and unzip data',
    schedule_interval=timedelta(days=1),
    start_date=datetime(2024, 1, 1),
    catchup=False,
) as dag:

    # Task to create the data directory
    create_data_dir = BashOperator(
        task_id='create_data_dir',
        bash_command=f'mkdir -p {TMP_DIR}',
    )

    # Task to download the ZIP file
    download_zip = BashOperator(
        task_id='download_zip',
        bash_command=f'curl -L -o {ZIP_FILE} {KAGGLE_URL}',
    )

    # Task to unzip the downloaded file
    unzip_file = BashOperator(
        task_id='unzip_file',
        bash_command=f'unzip -o {ZIP_FILE} -d {UNZIP_DIR}',
    )

    # Task to remove the ZIP file after extraction
    remove_zip = BashOperator(
        task_id='remove_zip',
        bash_command=f'rm -f {ZIP_FILE}',
    )

    upload_to_gcs = BashOperator(
        task_id='upload_to_gcs',
        bash_command=(
            '/opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS && '
            '/opt/google-cloud-sdk/bin/gsutil -m -o "GSUtil:parallel_composite_upload_threshold=50M" cp -r {unzip}/* gs://{bucket}/linkedin-job-insights-datalake/'
        ).format(
            unzip=UNZIP_DIR,
            bucket=BUCKET_NAME,
        ),
        execution_timeout=timedelta(minutes=45),
        env={
            "GOOGLE_APPLICATION_CREDENTIALS": "/opt/airflow/gcloud/service-account.json",
            "CLOUDSDK_PYTHON": "/usr/bin/python3"
        },
    )

    # TODO: Add a task to process the unzipped data (input into postgres then upload to a datalake) - need to generate schema for each table
    # TODO: Using terraform create GCS (Upload the unzipped date) then create BQ and partition appropriately
    # TODO: dbt transformations
    # TODO: Dashboard in looker studio using commands (Maybe terraform)

    # Set task dependencies
    create_data_dir >> download_zip >> unzip_file >> remove_zip >> upload_to_gcs
