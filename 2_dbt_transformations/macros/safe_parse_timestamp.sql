{% macro safe_timestamp_seconds(column) %}
  CASE 
    WHEN SAFE_CAST({{ column }} AS INT64) BETWEEN 0 AND 253402300799 THEN TIMESTAMP_SECONDS(SAFE_CAST({{ column }} AS INT64))
    ELSE NULL
  END
{% endmacro %}
