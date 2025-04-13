{{
  config(
    materialized='view'
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('linkedin_dataset', 'salaries') }}
)

SELECT
    CAST(salary_id AS INT64) AS salary_id,
    CAST(job_id AS INT64) AS job_id,
    CAST(max_salary AS NUMERIC) AS max_salary,
    CAST(med_salary AS NUMERIC) AS med_salary,
    CAST(min_salary AS NUMERIC) AS min_salary,
    CAST(pay_period AS STRING) AS pay_period,
    CAST(currency AS STRING) AS currency,
    CAST(compensation_type AS STRING) AS compensation_type
FROM source_data
WHERE salary_id IS NOT NULL -- Basic filtering