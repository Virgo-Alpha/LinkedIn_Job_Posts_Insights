{{
  config(
    materialized='view'
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('linkedin_dataset', 'company_industries') }}
)

SELECT
    CAST(company_id AS INT64) AS company_id,
    CAST(industry AS STRING) AS industry_name -- Assuming this column contains the name directly
FROM source_data
WHERE company_id IS NOT NULL -- Basic filtering
  AND industry IS NOT NULL