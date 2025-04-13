{{
  config(
    materialized='view'
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('linkedin_dataset', 'job_skills') }}
)

SELECT
    CAST(job_id AS INT64) AS job_id,
    CAST(skill_abr AS STRING) AS skill_abr -- Keeping abbreviation as the key
FROM source_data
WHERE job_id IS NOT NULL -- Basic filtering
  AND skill_abr IS NOT NULL