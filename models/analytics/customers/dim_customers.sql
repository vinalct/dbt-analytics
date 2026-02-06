with customers as (

    select * from {{ ref('stg_sample_system__customers') }}

),

final as (

    select
        {{ generate_surrogate_key(["customer_id"]) }}   as sk_customer,
        customer_id,
        customer_name,
        email,
        is_active,
        created_at,
        updated_at
    from customers

)

select * from final
