-- Reference the external source as a view
select * from {{ source('linkedin_dataset', 'postings') }}
