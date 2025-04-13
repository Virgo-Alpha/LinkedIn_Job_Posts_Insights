{{
  config(
    materialized='view'
  )
}}

WITH source_data AS (
    SELECT * FROM {{ source('linkedin_dataset', 'employee_counts') }}
)

SELECT
    CAST(company_id AS INT64) AS company_id,
    CAST(employee_count AS INT64) AS employee_count,
    CAST(follower_count AS INT64) AS follower_count,
    TIMESTAMP_SECONDS(CAST(time_recorded AS INT64)) AS recorded_at_utc -- Convert epoch seconds to timestamp
FROM source_data