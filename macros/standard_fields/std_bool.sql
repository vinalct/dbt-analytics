{% macro std_bool(expr) -%}
  case
    when {{ expr }} is null then null
    when lower(trim(cast({{ expr }} as string))) in ('true','t','1','yes','y','sim','s') then true
    when lower(trim(cast({{ expr }} as string))) in ('false','f','0','no','n','nao','não') then false
    else null
  end
{%- endmacro %}
