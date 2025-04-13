{{ config(materialized='view') }}

WITH source_data AS (
    SELECT * FROM {{ source('linkedin_dataset', 'job_industries') }}
),
valid_industries AS (
    SELECT DISTINCT industry_id from {{ ref('stg_linkedin__industries') }}
)
SELECT
    CAST(s.job_id AS INT64) AS job_id,
    CAST(s.industry_id AS INT64) AS industry_id
FROM source_data s
-- Add JOIN to filter
INNER JOIN valid_industries v ON CAST(s.industry_id AS INT64) = v.industry_id
WHERE s.job_id IS NOT NULL
  AND s.industry_id IS NOT NULL