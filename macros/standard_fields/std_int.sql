{% macro std_int(expr) -%}
  safe_cast({{ expr }} as int64)
{%- endmacro %}
