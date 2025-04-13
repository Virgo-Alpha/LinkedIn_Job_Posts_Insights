SELECT 1 AS test_col FROM {{ source('linkedin_dataset', 'benefits') }} LIMIT 1
