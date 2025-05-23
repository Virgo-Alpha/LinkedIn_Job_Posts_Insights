# First-time build can take upto 10 mins.

FROM apache/airflow:2.7.0

ENV AIRFLOW_HOME=/opt/airflow

USER root
RUN apt-get update -qq && apt-get install vim -qqq
# git gcc g++ -qqq

COPY requirements.txt .

RUN apt-get install -qq vim unzip gcc

USER airflow
RUN pip install --no-cache-dir -r requirements.txt

RUN pip install --upgrade pip
RUN pip install pandas sqlalchemy psycopg2-binary fastparquet pyarrow

# Ref: https://airflow.apache.org/docs/docker-stack/recipes.html

SHELL ["/bin/bash", "-o", "pipefail", "-e", "-u", "-x", "-c"]

ARG CLOUD_SDK_VERSION=322.0.0
ENV GCLOUD_HOME=/opt/google-cloud-sdk

ENV PATH="${GCLOUD_HOME}/bin/:${PATH}"

ENV CLOUDSDK_PYTHON=/usr/bin/python3

USER root

RUN DOWNLOAD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz" \
    && TMP_DIR="$(mktemp -d)" \
    && curl -fL "${DOWNLOAD_URL}" --output "${TMP_DIR}/google-cloud-sdk.tar.gz" \
    && mkdir -p "${GCLOUD_HOME}" \
    && tar xzf "${TMP_DIR}/google-cloud-sdk.tar.gz" -C "${GCLOUD_HOME}" --strip-components=1 \
    && "${GCLOUD_HOME}/install.sh" \
       --bash-completion=false \
       --path-update=false \
       --usage-reporting=false \
       --quiet \
    && rm -rf "${TMP_DIR}" \
    && gcloud --version

RUN echo 'export PATH=$PATH:/opt/google-cloud-sdk/bin' >> /etc/profile && \
    echo 'export PATH=$PATH:/opt/google-cloud-sdk/bin' >> /home/airflow/.bashrc

# Create directory and copy credentials
# TODO: In the container, check the creds for that service account
RUN mkdir -p /opt/airflow/gcloud
COPY ./0_cloud_infra/gcloud_creds/service-account.json /opt/airflow/gcloud/service-account.json
RUN chown -R airflow:root /opt/airflow/gcloud && \
    chmod 0644 /opt/airflow/gcloud/service-account.json
RUN chown -R airflow:root /opt/airflow/gcloud && \
    gcloud auth activate-service-account --key-file=/opt/airflow/gcloud/service-account.json && \
    gcloud config set project linkedin-job-insights-e1058fc3

# RUN gcloud services enable cloudresourcemanager.googleapis.com --quiet --project=linkedin-job-insights-e1058fc3 || true

RUN gcloud auth activate-service-account --key-file=/opt/airflow/gcloud/service-account.json && \
    gcloud config set project linkedin-job-insights-e1058fc3 && \
    gcloud config set account linkedin-job-insights-sa@linkedin-job-insights-e1058fc3.iam.gserviceaccount.com

# Verify authentication works
RUN gcloud auth list && \
    gcloud config list

WORKDIR $AIRFLOW_HOME

COPY 1_airflow_wf_orchestration/scripts scripts
RUN chmod +x scripts

USER $AIRFLOW_UID
