#!/usr/bin/env bash

# Set environment variables
export GOOGLE_APPLICATION_CREDENTIALS=/opt/airflow/gcloud/service-account.json
export AIRFLOW_CONN_GOOGLE_CLOUD_DEFAULT=${AIRFLOW_CONN_GOOGLE_CLOUD_DEFAULT}

# Added GCloud authentication
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
gcloud config set project linkedin-job-insights-e1058fc3

# Airflow initialization
airflow db upgrade
airflow users create -r Admin -u admin -p admin -e admin@example.com -f admin -l airflow

# Start webserver
exec airflow webserver