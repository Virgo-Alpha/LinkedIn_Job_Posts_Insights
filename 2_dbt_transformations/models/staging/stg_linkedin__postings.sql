{{
  config(
    materialized='view'
  )
}}

WITH source_data AS (
    -- It's safer to list columns explicitly if source schema might drift
    SELECT
        job_id,
        company_id,
        company_name,
        title,
        description,
        location,
        max_salary,
        med_salary,
        min_salary,
        pay_period,
        currency,
        compensation_type,
        formatted_work_type,
        formatted_experience_level,
        skills_desc,
        work_type,
        views,
        applies,
        job_posting_url,
        application_url,
        application_type,
        posting_domain,
        remote_allowed, -- Keep original for casting check
        sponsored, -- Keep original for casting check
        original_listed_time, -- Keep original for parsing
        expiry, -- Keep original for parsing
        closed_time, -- Keep original for parsing
        listed_time, -- Keep original for parsing
        normalized_salary,
        zip_code,
        fips
    FROM {{ source('linkedin_dataset', 'postings') }}
)

SELECT
    -- IDs
    CAST(job_id AS INT64) AS job_id,
    CAST(company_id AS INT64) AS company_id,

    -- Job Details
    CAST(company_name AS STRING) AS posting_company_name, -- Renamed
    CAST(title AS STRING) AS job_title,
    CAST(description AS STRING) AS job_description,
    CAST(location AS STRING) AS job_location,
    CAST(formatted_work_type AS STRING) AS formatted_work_type,
    CAST(formatted_experience_level AS STRING) AS formatted_experience_level,
    CAST(skills_desc AS STRING) AS skills_description_unstructured,
    CAST(work_type AS STRING) AS work_type,

    -- Compensation
    SAFE_CAST(max_salary AS NUMERIC) AS max_salary, -- Use SAFE_CAST for robustness
    SAFE_CAST(med_salary AS NUMERIC) AS med_salary,
    SAFE_CAST(min_salary AS NUMERIC) AS min_salary,
    CAST(pay_period AS STRING) AS pay_period,
    CAST(currency AS STRING) AS currency,
    CAST(compensation_type AS STRING) AS compensation_type,
    SAFE_CAST(normalized_salary AS NUMERIC) AS normalized_salary,

    -- Engagement & Application
    SAFE_CAST(views AS INT64) AS views,
    SAFE_CAST(applies AS INT64) AS applies,
    CAST(job_posting_url AS STRING) AS job_posting_url,
    CAST(application_url AS STRING) AS application_url,
    CAST(application_type AS STRING) AS application_type,
    CAST(posting_domain AS STRING) AS posting_domain,

    -- Flags (Handle potential numeric or string '0'/'1' - adjust if values differ)
    SAFE_CAST(remote_allowed = 1 AS BOOLEAN) OR SAFE_CAST(remote_allowed = '1' AS BOOLEAN) AS is_remote_allowed,
    SAFE_CAST(sponsored = 1 AS BOOLEAN) OR SAFE_CAST(sponsored = '1' AS BOOLEAN) AS is_sponsored,

    -- Timestamps (Using SAFE.PARSE_TIMESTAMP - *Adjust format string as needed!*)
    {{ safe_parse_timestamp('original_listed_time', '%Y-%m-%d %H:%M:%S') }} AS original_listed_at_utc, -- Example format, adjust!
    {{ safe_parse_timestamp('expiry', '%Y-%m-%d %H:%M:%S') }} AS expires_at_utc, -- Example format, adjust!
    {{ safe_parse_timestamp('closed_time', '%Y-%m-%d %H:%M:%S') }} AS closed_at_utc, -- Example format, adjust!
    {{ safe_parse_timestamp('listed_time', '%Y-%m-%d %H:%M:%S') }} AS listed_at_utc, -- Example format, adjust!

    -- Location details from posting
    CAST(zip_code AS STRING) AS posting_zip_code,
    CAST(fips AS STRING) AS posting_fips_code

FROM source_data