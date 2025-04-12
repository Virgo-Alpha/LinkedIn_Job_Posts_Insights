# ? Commands:
# make download: downloads the data into the .data folder
# make unzip: unzips the data into the .data folder
# make all: downloads and unzips the data
# make clean: deletes the zipped and unzipped data in the .data folder

# TODO: Run airflow dags, terraform to create assets, change the make all command action


# Download the docker-compose.yml file and build (up -d)

# Variables
PYTHON_SCRIPT := ./data/infer_schema.py
DATA_DIR := ./data/.data
ZIP_FILE := $(DATA_DIR)/linkedin-job-postings.zip
UNZIP_DIR := $(DATA_DIR)/linkedin-job-postings
PG_HOST := localhost
PG_PORT := 5432
PG_USER := airflow
PG_DB := airflow
NEW_DB := linkedin_data
PGPASSWORD := airflow
PG_ENCODING := UTF8
SHELL := /bin/bash

# ? Default target for make all is downloading an unzipping
all: download unzip

# Download the ZIP file into the data directory
.PHONY: download
download: $(ZIP_FILE)

$(ZIP_FILE):
	@mkdir -p $(DATA_DIR)
	curl -L -o $@ https://www.kaggle.com/api/v1/datasets/download/arshkon/linkedin-job-postings

# Unzip the downloaded file
.PHONY: unzip
unzip: $(UNZIP_DIR)

$(UNZIP_DIR): $(ZIP_FILE)
	unzip $(ZIP_FILE) -d $(UNZIP_DIR)
	touch $@

# TODO: Run a DAG for the below
# Ingest CSV files into PostgreSQL
.PHONY: ingest_local
ingest_local: $(UNZIP_DIR)
	@echo "Creating new database '$(NEW_DB)'..."
	@export PGPASSWORD=$(PGPASSWORD); export PGCLIENTENCODING=$(PG_ENCODING); psql -h $(PG_HOST) -p $(PG_PORT) -U $(PG_USER) -d $(PG_DB) -c "DROP DATABASE IF EXISTS $(NEW_DB);"
	@export PGPASSWORD=$(PGPASSWORD); export PGCLIENTENCODING=$(PG_ENCODING); psql -h $(PG_HOST) -p $(PG_PORT) -U $(PG_USER) -d $(PG_DB) -c "CREATE DATABASE $(NEW_DB);"
	@find $(DATA_DIR) -type f -name "*.csv" -print0 | while IFS= read -r -d $'\0' csv_file; do \
		relative_path=$$(echo "$$csv_file" | sed "s|^$(DATA_DIR)/||"); \
		table_name=$$(echo "$$relative_path" | sed "s/\.csv$$//; s/[^a-zA-Z0-9_]/_/g"); \
		echo "Creating table '$$table_name' and importing data from '$$csv_file'..."; \
		create_table_stmt=$$(python3 $(PYTHON_SCRIPT) "$$csv_file" "$$table_name"); \
		echo "Create table statement: $$create_table_stmt"; \
		export PGPASSWORD=$(PGPASSWORD); export PGCLIENTENCODING=$(PG_ENCODING); \
		psql -h $(PG_HOST) -p $(PG_PORT) -U $(PG_USER) -d $(NEW_DB) -c "DROP TABLE IF EXISTS \"$$table_name\";"; \
		export PGPASSWORD=$(PGPASSWORD); export PGCLIENTENCODING=$(PG_ENCODING); \
		psql -h $(PG_HOST) -p $(PG_PORT) -U $(PG_USER) -d $(NEW_DB) -c "$$create_table_stmt"; \
		export PGPASSWORD=$(PGPASSWORD); export PGCLIENTENCODING=$(PG_ENCODING); \
		psql -h $(PG_HOST) -p $(PG_PORT) -U $(PG_USER) -d $(NEW_DB) -c "\\copy \"$$table_name\" FROM '$${csv_file}' WITH (FORMAT csv, HEADER true);"; \
	done

# Clean up: delete the ZIP file and the unzipped directory
.PHONY: clean
clean:
	rm -rf $(DATA_DIR)/*

