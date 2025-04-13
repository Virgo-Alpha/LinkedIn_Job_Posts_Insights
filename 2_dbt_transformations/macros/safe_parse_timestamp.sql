{% macro safe_parse_timestamp(column_name, format_string='%Y-%m-%d %H:%M:%S %Z') %}
    SAFE.PARSE_TIMESTAMP('{{ format_string }}', {{ column_name }})
{% endmacro %}