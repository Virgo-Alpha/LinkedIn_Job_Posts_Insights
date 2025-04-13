{{
  config(
    materialized='view'
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('linkedin_dataset', 'company_specialities') }}
)

SELECT
    CAST(company_id AS INT64) AS company_id,
    CAST(speciality AS STRING) AS speciality_name
FROM source_data
WHERE company_id IS NOT NULL -- Basic filtering
  AND speciality IS NOT NULL