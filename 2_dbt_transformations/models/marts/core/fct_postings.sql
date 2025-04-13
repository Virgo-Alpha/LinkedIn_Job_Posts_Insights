{{
  config(
    materialized='table',
    partition_by={
      "field": "original_listed_at_utc",
      "data_type": "timestamp",
      "granularity": "month"
    },
    cluster_by=['company_id', 'formatted_work_type', 'formatted_experience_level', 'company_country', 'company_state']
  )
}}

WITH postings AS (
    SELECT * FROM {{ ref('stg_linkedin__postings') }}
),
companies AS (
    -- Selecting only needed fields from dim_companies to avoid large joins
    SELECT
      company_id,
      company_name,
      company_size_category,
      employee_count,
      country AS company_country,
      state AS company_state,
      city AS company_city
    FROM {{ ref('dim_companies') }}
),
job_skills AS (
    SELECT
        job_id,
        ARRAY_AGG(DISTINCT s.skill_name IGNORE NULLS) AS skill_names
    FROM {{ ref('stg_linkedin__job_skills') }} js
    JOIN {{ ref('dim_skills') }} s ON js.skill_abr = s.skill_abr
    GROUP BY 1
),
job_industries AS (
    SELECT
        job_id,
        ARRAY_AGG(DISTINCT i.industry_name IGNORE NULLS ORDER BY i.industry_name) AS industry_names
    FROM {{ ref('stg_linkedin__job_industries') }} ji
    -- Change LEFT JOIN to INNER JOIN to exclude jobs with missing industry definitions
    INNER JOIN {{ ref('dim_industries') }} i ON ji.industry_id = i.industry_id
    GROUP BY 1
),
job_benefits AS (
     SELECT
        job_id,
        ARRAY_AGG(DISTINCT type IGNORE NULLS) AS benefits
    FROM {{ ref('stg_linkedin__benefits') }}
    GROUP BY 1
),
salaries AS (
    -- Assuming one salary record per job_id from this table is relevant
    -- Adjust logic if salaries table has multiple entries per job_id you need to handle
    SELECT
        job_id,
        max_salary,
        med_salary,
        min_salary,
        pay_period,
        currency,
        compensation_type
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY salary_id DESC) as rn -- Example: take latest salary entry
        FROM {{ ref('stg_linkedin__salaries') }}
    )
    WHERE rn = 1
)

SELECT
    -- Posting Info
    p.job_id,
    p.job_title,
    p.job_description,
    p.job_location,
    p.formatted_work_type,
    p.formatted_experience_level,
    p.work_type,
    p.job_posting_url,
    p.application_url,
    p.application_type,
    p.posting_domain,
    p.posting_zip_code,
    p.posting_fips_code,

    -- Company Info (Joined)
    p.company_id,
    c.company_name,
    c.company_size_category,
    c.employee_count AS company_employee_count, -- Renamed
    c.company_country,
    c.company_state,
    c.company_city,

    -- Compensation (Prefer data from salaries table if available, fallback to postings)
    COALESCE(s.max_salary, p.max_salary) AS max_salary,
    COALESCE(s.med_salary, p.med_salary) AS med_salary,
    COALESCE(s.min_salary, p.min_salary) AS min_salary,
    COALESCE(s.pay_period, p.pay_period) AS pay_period,
    COALESCE(s.currency, p.currency) AS currency,
    COALESCE(s.compensation_type, p.compensation_type) AS compensation_type,
    p.normalized_salary, -- Keep from postings for now

    -- Engagement
    p.views,
    p.applies,

    -- Flags
    p.is_remote_allowed,
    p.is_sponsored,

    -- Timestamps
    p.original_listed_at_utc,
    p.expires_at_utc,
    p.closed_at_utc,
    p.listed_at_utc,
    TIMESTAMP_DIFF(p.closed_at_utc, p.original_listed_at_utc, DAY) AS days_to_close, -- For Q9

    -- Aggregated Attributes
    js.skill_names,
    ji.industry_names,
    jb.benefits

FROM postings p
LEFT JOIN companies c ON p.company_id = c.company_id
LEFT JOIN salaries s ON p.job_id = s.job_id
LEFT JOIN job_skills js ON p.job_id = js.job_id
LEFT JOIN job_industries ji ON p.job_id = ji.job_id
LEFT JOIN job_benefits jb ON p.job_id = jb.job_id