{{
  config(
    materialized='view'
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('linkedin_dataset', 'industries') }}
)

SELECT
    CAST(industry_id AS INT64) AS industry_id,
    CAST(industry_name AS STRING) AS industry_name
FROM source_data
WHERE industry_id IS NOT NULL -- Basic filtering
  AND industry_name IS NOT NULL