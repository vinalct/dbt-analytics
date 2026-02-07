{{ config(
    materialized = "table",
    partition_by = {
        "field": "transaction_date_brt",
        "data_type": "timestamp"
    },
    cluster_by = ["transaction_id", "customer_id"],
    tags = ["bi"]
) }}


with transactions as (
    select 
        * except(rn)
    from 
        {{ ref('stg_ingestion__transactions') }}
),

transactions_details as (
    select 
        * except(rn)
    from 
        {{ ref('stg_ingestion__transactions_details') }}
),

fact_table as (
    select 
        transactions.id as transaction_id,
        transactions.transaction_nk,
        transactions.customer_id,
        transactions.customer_nk,
        transactions.status,
        transactions.transaction_date_brt,
        transactions_details.type as transaction_type,
        transactions_details.quantity,
        transactions_details.price_usd,
    from 
        transactions
    left join 
        transactions_details
    on 
        transactions.id = transactions_details.id
),

dedup as (
    {{ latest_version('fact_table', 'transaction_id', 'transaction_date_brt') }}
)

select * from dedup
