with source as (

    select * from {{ source('sample_system', 'customers') }}

),

standardized as (

    select
        {{ natural_key_as_string("customer_id") }}      as customer_id,
        {{ std_string("customer_name") }}                as customer_name,
        {{ std_string("email", lower=true) }}            as email,
        {{ std_bool("is_active") }}                      as is_active,
        {{ std_timestamp("created_at") }}                as created_at,
        {{ std_timestamp("updated_at") }}                as updated_at
    from source

)

select * from standardized
