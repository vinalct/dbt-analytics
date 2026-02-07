{% macro std_string(expr, upper=true, lower=false, empty_to_null=true) -%}
  {%- set v = "trim(cast(" ~ expr ~ " as string))" -%}
  {%- if upper -%}
    {%- set v = "upper(" ~ v ~ ")" -%}
  {%- elif lower -%}
    {%- set v = "lower(" ~ v ~ ")" -%}
  {%- endif -%}

  {%- if empty_to_null -%}
    nullif({{ v }}, '')
  {%- else -%}
    {{ v }}
  {%- endif -%}
{%- endmacro %}
