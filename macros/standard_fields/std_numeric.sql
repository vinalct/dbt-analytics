{% macro std_numeric(expr, precision=38, scale=9) -%}
  safe_cast({{ expr }} as numeric)
{%- endmacro %}
