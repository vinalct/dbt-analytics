{% macro generate_surrogate_key(cols) -%}
  {# cols must be a list: ['col_a', 'col_b', ...] #}

  {%- if cols is not iterable or (cols | length) == 0 -%}
    {{ exceptions.raise_compiler_error("generate_surrogate_key(cols) requires a non-empty list of columns") }}
  {%- endif -%}

  to_hex(md5(
    concat(
      {%- for c in cols -%}
        coalesce(cast({{ c }} as string), '__dbt_null__')
        {%- if not loop.last -%}, '||', {%- endif -%}
      {%- endfor -%}
    )
  ))
{%- endmacro %}
