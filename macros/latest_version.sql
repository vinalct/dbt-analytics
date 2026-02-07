{% macro latest_version(cte_name, key_column, timestamp_column, handle_nulls=true) -%}
(
    select * 
    from (
        select *,
            row_number() over (
                partition by {{ key_column }} 
                order by 
                    {% if handle_nulls %}
                    {{ timestamp_column }} desc nulls last
                    {% else %}
                    {{ timestamp_column }} desc
                    {% endif %}
            ) as rn
        from {{ cte_name }}
    ) 
    where rn = 1
)
{%- endmacro %}