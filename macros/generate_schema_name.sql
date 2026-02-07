{% macro generate_schema_name(custom_schema_name, node) -%}

    {#
        Override the default generate_schema_name macro so that models
        are always created in the exact dataset (schema) specified in
        dbt_project.yml via +schema, instead of being prefixed with the
        target schema (e.g. "dev_staging").

        - If a custom schema is provided  → use it as-is  (e.g. "staging", "analytics").
        - If no custom schema is provided → fall back to the target schema from profiles.yml.
    #}

    {%- if custom_schema_name is not none and custom_schema_name | trim != '' -%}

        {{ custom_schema_name | trim }}

    {%- else -%}

        {{ target.schema }}

    {%- endif -%}

{%- endmacro %}
