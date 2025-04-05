# ? When submitting, change the name to the one that will display in the certificate
# ? When evaluating, go to tree/commit_id so that you evaluate what was submitted

# ! Project requirements:
# Develop a dashboard with two tiles by:

# // *1. Selecting a dataset of interest (see Datasets)
# *2. Creating a pipeline for processing this dataset and putting it to a datalake - airflow / gcs
# *3. Creating a pipeline for moving the data from the lake to a data warehouse - airflow
# *4. Transforming the data in the data warehouse: prepare it for the dashboard - dbt / spark
# *5. Building a dashboard to visualize the data - looker studio / PowerBI / Tableau

# ! Criteria:
# *1. Problem description: Problem is well described and it's clear what the problem the project solves
# *2. Cloud: The project is developed in the cloud and IaC tools are used
# *3. Data Ingestion:
#     - Batch/workflow orchestration: End-to-end pipeline: multiple steps in the DAG, uploading data to data lake
#     - Streaming: Using consumer/producers and streaming technologies (like Kafka streaming, Spark streaming, Flink, etc)
# *4. Data warehouse: Tables are partitioned and clustered in a way that makes sense for the upstream queries (with explanation)
# *5. Transformations: Tranformations are defined with dbt, Spark or similar technologies
# *6. Dashboard: A dashboard with @ least 2 tiles - categorical data and temporal line
# *7. Reproducibility: Instructions are clear, it's easy to run the code, and the code works

# ! Extra mile:
# *- Add tests
# *- Use make
# *- Add CI/CD pipeline

# It's highly recommended to create a new repository for your project (not inside an existing repo) with a meaningful title, such as "Quake Analytics Dashboard" or "Bike Data Insights" and include as many details as possible in the README file. ChatGPT can assist you with this. Doing so will not only make it easier to showcase your project for potential job opportunities but also have it featured on the Projects Gallery App. If you leave the README file empty or with minimal details, there may be point deductions as per the Evaluation Criteria.

# ! Dataset sources:
# ? Batch
# *statso.io
# *AWS Public Datasets (registry.opendata.aws) / Amazon Data Marketplace
# *Google Dataset Search (datasetsearch.research.google.com)
# *Data.gov
# *Kaggle Datasets
# *UCI Machine Learning Repository
# *World Bank Open Data: data.worldbank.org
# *Eurostat: ec.europa.eu/eurostat/data/database
# *Github archive: gharchive.org
# *Awesome Public Datasets: github.com/awesomedata/awesome-public-datasets

# ? Streaming
# *https://www.alphavantage.co/ - Stock market data
# *GCP Datasets - https://cloud.google.com/bigquery/public-data
# *https://www.kaggle.com/docs/datasets - Kaggle Datasets
# *Zindi - https://zindi.africa/

# ? Project 1 tools: terraform, airflow, gcs, bq, dbt, looker studio
# ? Project 2 tools: cloudformation, kestra, s3, redshift, spark / aws glue / sqlmesh, tableau / PowerBI / Amazon Quicksight
# ? Project 3 tools: prefect / mage, azure blob storage, azure sql, databricks, PowerBI / Tableau

# ! Dataset candidates:
# *1. Suicide Rates Overview 1985 to 2016 - https://www.kaggle.com/datasets/russellyates88/suicide-rates-overview-1985-to-2016
# *2. World Population Dataset - https://www.kaggle.com/datasets/iamsouravbanerjee/world-population-dataset
# *3. Amazon Prime Movies and TV Shows - https://www.kaggle.com/datasets/shivamb/amazon-prime-movies-and-tv-shows
# *4. LinkedIn Job Postings (2023 - 2024) ** several tables - https://www.kaggle.com/datasets/arshkon/linkedin-job-postings
# *5. Chess Game Dataset (Lichess) - https://www.kaggle.com/datasets/datasnaek/chess

# ! Winning dataset:
curl -L -o ~/Downloads/linkedin-job-postings.zip\
  https://www.kaggle.com/api/v1/datasets/download/arshkon/linkedin-job-postings

# ! Questions:
# ? Categorical
# *1. Relationship between employee_count and the salary in the job posting?
# *2. Salary Trends Over Time by Experience Level
    # Question: How do median salaries change over time across different experience levels (entry, associate, executive, etc.)?
    # Chart Type: Temporal line chart or multi-series bar chart (one series per experience level)
# *3. Job Postings Distribution by Work Type
    # Question: What is the distribution of job postings by work type (Fulltime, Parttime, Contract)?
    # Chart Type: Pie chart
# *4. Remote vs. Non-Remote Job Engagement Over Time
    # Question: How do the numbers of views and applications compare over time for remote-allowed versus non-remote jobs?
    # Chart Type: Dual-line chart (or grouped bar chart with time on the x-axis)
# *5. Job Postings by Company Size
    # Question: What is the distribution of job postings by company size (1-10, 11-50, etc.)?
    # Chart Type: Categorical Bar chart
# *6. Question: What are the top 10 most frequently listed job titles, and what is the average salary range (min-max) for each?
    # Chart Type: Horizontal Bar Chart. X-axis: Job Title. Y-axis: Average Salary Range (represent the range with error bars or a shaded region on the bar).
    # Query: Count the occurrences of each title. Calculate the average min_salary and max_salary for each title.
    # Benefit: Provides an overview of the most in-demand jobs and their corresponding salary expectations.
# *7. Question: How does the average number of views and applications vary across different work types (Fulltime, Parttime, etc.)?
    # Chart Type: Spider/Radar Chart. Each axis represents a formatted_work_type. Values on the axes represent the average views and average applies for each work type. Use two separate lines/areas for views and applies.
    # Query: Calculate the average views and average applies for each formatted_work_type.
    # Benefit: Reveals which work types attract the most attention and applications.

# ? Temporal - over time
# *7. Job Posting Frequency by Application Type Over Time
    # Question: How does the frequency of job postings vary over time when segmented by application type (offsite vs. onsite)?
    # Chart Type: Stacked area chart or multi-line chart
# *8. Question: How has the trend of job postings changed over time, broken down by work type (Fulltime, Parttime, etc.)?
    # Chart Type: Line Chart. X-axis: Time (monthly/weekly). Y-axis: Count of job postings. Color-coded lines for each formatted_work_type.
    # Query: Aggregate job postings count by month/week and formatted_work_type. Use original_listed_time (or listed_time if original_listed_time is consistently missing) for the time axis.
    # Benefit: Shows trends, seasonality, and the changing popularity of different work types.
# *9. Question: What is the average time it takes to close a job posting, and how does this duration vary across different experience levels?
    # Chart Type: Bar Chart. X-axis: formatted_experience_level. Y-axis: Average time to close (calculated from original_listed_time and closed_time).
    # Query: Calculate the difference between closed_time and original_listed_time for each job posting, then average this difference by formatted_experience_level.
    # Benefit: Highlights hiring efficiency across different experience levels, indicating potentially more competitive or specialized roles.

# ? Geographical data
# *10. Question: What is the geographical distribution of job postings across countries and states? (Focus on a single country if your data is primarily from one country.)
    # Chart Type: Choropleth Map (World or Country). Color intensity represents the number of job postings in each region.
    # Query: Aggregate job postings count by country (or state if focusing on a specific country). Join with geographical data to create the map. Use the companies.csv table for the company's location, not job_postings.location, for more accurate aggregation.
    # Benefit: Visualizes job market hotspots and regional demand.
# *11. Question: Within a specific country (e.g., USA), which cities have the highest average salaries for Software Engineer roles?
    # Chart Type: Bar Chart or Map with markers sized by salary. X-axis/Map Markers: City from companies.csv. Y-axis/Marker Size: Average median salary for jobs titled "Software Engineer" (or a similar common role).
    # Query: Join job_postings.csv and companies.csv on company_id. Filter for title containing "Software Engineer" (or a similar common role). Calculate the average med_salary by city.
    # Benefit: Identifies cities with high earning potential in specific fields.