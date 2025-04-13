{{
  config(
    materialized='view'
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('linkedin_dataset', 'skills') }}
)

SELECT
    CAST(skill_abr AS STRING) AS skill_abr,
    CAST(skill_name AS STRING) AS skill_name
FROM source_data
WHERE skill_abr IS NOT NULL -- Basic filtering
  AND skill_name IS NOT NULL