{{
  config(
    materialized='table',
    cluster_by=['country', 'state', 'company_size_category']
  )
}}

WITH companies AS (
    SELECT * FROM {{ ref('stg_linkedin__companies') }}
),
employee_counts AS (
    -- Get the latest employee count per company
    SELECT
        company_id,
        employee_count,
        follower_count,
        recorded_at_utc
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER(PARTITION BY company_id ORDER BY recorded_at_utc DESC) as rn
        FROM {{ ref('stg_linkedin__employee_counts') }}
    )
    WHERE rn = 1
),
company_industries AS (
    -- Aggregate industries into an array per company
    SELECT
        company_id,
        -- CORRECTED LINE: Use industry_name from staging model
        ARRAY_AGG(DISTINCT industry_name IGNORE NULLS ORDER BY industry_name) AS industries
    FROM {{ ref('stg_linkedin__company_industries') }}
    GROUP BY 1
),
company_specialities AS (
    -- Aggregate specialities into an array per company
    SELECT
        company_id,
        -- CORRECTED LINE: Use speciality_name from staging model
        ARRAY_AGG(DISTINCT speciality_name IGNORE NULLS ORDER BY speciality_name) AS specialities
    FROM {{ ref('stg_linkedin__company_specialities') }}
    GROUP BY 1
)

SELECT
    c.company_id,
    c.company_name,
    c.company_description,
    c.company_size_category,
    -- Add logic to decode company_size_category here if needed
    -- e.g., CASE c.company_size_category WHEN 1 THEN '1-10' ... END AS company_size_range,
    c.state,
    c.country,
    c.city,
    c.company_zip_code,
    c.company_address,
    c.company_url,
    ec.employee_count,
    ec.follower_count,
    ec.recorded_at_utc AS counts_recorded_at_utc,
    ci.industries AS company_industries,
    cs.specialities AS company_specialities

FROM companies c
LEFT JOIN employee_counts ec ON c.company_id = ec.company_id
LEFT JOIN company_industries ci ON c.company_id = ci.company_id
LEFT JOIN company_specialities cs ON c.company_id = cs.company_id