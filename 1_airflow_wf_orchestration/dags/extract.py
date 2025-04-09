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
DATA_DIR = os.path.join('/opt/data', '.data')
ZIP_FILE = os.path.join(DATA_DIR, 'linkedin-job-postings.zip')
UNZIP_DIR = os.path.join(DATA_DIR, 'linkedin-job-postings')
KAGGLE_URL = 'https://www.kaggle.com/api/v1/datasets/download/arshkon/linkedin-job-postings'

# Define the DAG
with DAG(
    'download_and_unzip_data',
    default_args=default_args,
    description='A DAG to download and unzip data',
    schedule_interval=timedelta(days=1),
    start_date=datetime(2024, 1, 1),
    catchup=False,
) as dag:

    # Task to create the data directory
    create_data_dir = BashOperator(
        task_id='create_data_dir',
        bash_command=f'mkdir -p {DATA_DIR}',
    )

    # Task to download the ZIP file
    download_zip = BashOperator(
        task_id='download_zip',
        bash_command=f'curl -L -o {ZIP_FILE} {KAGGLE_URL}',
    )

    # Task to unzip the downloaded file
    #  TODO: Debug why the below is not working
    unzip_file = BashOperator(
        task_id='unzip_file',
        bash_command=f'unzip -o {ZIP_FILE} -d {DATA_DIR}',
    )

    # Set task dependencies
    create_data_dir >> download_zip >> unzip_file
