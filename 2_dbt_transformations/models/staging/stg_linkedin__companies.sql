{{
  config(
    materialized='view'
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('linkedin_dataset', 'companies') }}
)

SELECT
    CAST(company_id AS INT64) AS company_id,
    CAST(name AS STRING) AS company_name,
    CAST(description AS STRING) AS company_description,
    CAST(company_size AS INT64) AS company_size_category, -- Assuming 1, 2, 3 are categories
    CAST(state AS STRING) AS state,
    CAST(country AS STRING) AS country,
    CAST(city AS STRING) AS city,
    CAST(zip_code AS STRING) AS company_zip_code,
    CAST(address AS STRING) AS company_address,
    CAST(url AS STRING) AS company_url
FROM source_data