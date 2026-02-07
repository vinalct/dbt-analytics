{% macro std_timestamp(expr, convert_to_brt=false) -%}
  {% if convert_to_brt %}
    datetime(timestamp(safe_cast({{ expr }} as timestamp)), "America/Sao_Paulo")
  {% else %}
    safe_cast({{ expr }} as timestamp)
  {% endif %}
{%- endmacro %}
