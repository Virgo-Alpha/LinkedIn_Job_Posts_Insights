SELECT 1 AS test_col FROM {{ source('linkedin_dataset', 'job_skills') }} LIMIT 1