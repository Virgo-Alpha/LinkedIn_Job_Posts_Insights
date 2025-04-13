{{
  config(
    materialized='view'
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('linkedin_dataset', 'skills') }}
)

SELECT
    CAST(string_field_0 AS STRING) AS skill_abr,
    CAST(string_field_1 AS STRING) AS skill_name
FROM source_data
WHERE string_field_0 IS NOT NULL -- Basic filtering
  AND string_field_1 IS NOT NULL