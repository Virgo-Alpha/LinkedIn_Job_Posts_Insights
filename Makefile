# ? Commands:
# make download: downloads the data into the .data folder
# make unzip: unzips the data into the .data folder
# make all: downloads and unzips the data
# make clean: deletes the zipped and unzipped data in the .data folder

# TODO: Run airflow dags, terraform to create assets, 


# Download the docker-compose.yml file and build (up -d)

# Variables
DATA_DIR := ./data/.data
ZIP_FILE := $(DATA_DIR)/linkedin-job-postings.zip
UNZIP_DIR := $(DATA_DIR)/linkedin-job-postings

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
	unzip $(ZIP_FILE) -d $(DATA_DIR)
	touch $@

# Clean up: delete the ZIP file and the unzipped directory
.PHONY: clean
clean:
	rm -rf $(DATA_DIR)/*

