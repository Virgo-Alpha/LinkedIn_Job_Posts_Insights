{% macro create_all_externals() %}
  {% do dbt_external_tables.create_external_tables() %}
{% endmacro %}
