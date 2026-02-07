{% macro std_date(expr) -%}
  safe_cast({{ expr }} as date)
{%- endmacro %}
