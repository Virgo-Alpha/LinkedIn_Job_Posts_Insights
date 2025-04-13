{{
  config(
    materialized='view'
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('linkedin_dataset', 'benefits') }}
)

SELECT
    CAST(job_id AS INT64) AS job_id,
    -- CORRECTED LINE: Compare inferred (as INT64) to the integer 1
    SAFE_CAST(inferred = 1 AS BOOLEAN) AS is_inferred,
    CAST(type AS STRING) AS benefit_type
FROM source_data
-- CORRECTED WHERE CLAUSE: Referencing original column name from source_data
WHERE source_data.job_id IS NOT NULL -- Basic filtering
  AND source_data.type IS NOT NULL
