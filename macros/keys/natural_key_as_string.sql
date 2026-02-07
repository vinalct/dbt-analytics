{% macro natural_key_as_string(expr, empty_to_null=true) -%}
  {%- set v = "trim(cast(" ~ expr ~ " as string))" -%}
  {%- if empty_to_null -%}
    nullif({{ v }}, '')
  {%- else -%}
    {{ v }}
  {%- endif -%}
{%- endmacro %}
