-- models/staging/test_stg_postings_source.sql
-- Purpose: Test connectivity and basic reading from the GCS external source for postings.

SELECT *
FROM {{ source('linkedin_dataset', 'raw_postings') }}
LIMIT 10