SELECT 1 AS test_col FROM {{ source('linkedin_dataset', 'company_specialities') }} LIMIT 1