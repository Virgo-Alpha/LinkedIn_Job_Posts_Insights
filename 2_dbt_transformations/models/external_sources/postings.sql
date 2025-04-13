-- Reference the external source as a view
select * from {{ source('external_sources', 'postings') }}
