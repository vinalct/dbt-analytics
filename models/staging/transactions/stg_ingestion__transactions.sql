{{ config(
    materialized = "table",
    partition_by = {
        "field": "_ingested_at_brt",
        "data_type": "timestamp"
    },
    cluster_by = ["id", "_ingestion_id"],
    tags = ["bi"]
) }}

with source as (

    select * from {{ source('raw_ingestion__tables', 'transactions') }}

),

standardized as (
    select
        {{ generate_surrogate_key(["transaction_id", "customer_id", "transaction_date", "transaction_status"]) }} as id,
        {{ generate_surrogate_key(["transaction_id"]) }} as transaction_id,
        {{ generate_surrogate_key(["customer_id"]) }} as customer_id,
        
        {{ natural_key_as_string("transaction_id") }} as transaction_nk,
        {{ natural_key_as_string("customer_id") }} as customer_nk,

        {{ std_string("transaction_status") }} as status,

        {{ std_timestamp("transaction_date") }} as transaction_date_brt,
        
        {{ std_string("__source_file") }} as _source_file_name,

        {{ generate_surrogate_key(["__ingestion_id"]) }} as _ingestion_id,
        {{ natural_key_as_string("__ingestion_id") }} as _ingestion_nk,

        {{ std_timestamp("__ingested_at", convert_to_brt=true) }} as _ingested_at_brt

    from source
),

dedup as (
    {{ latest_version('standardized', 'id', 'transaction_date_brt') }}
)

select * from dedup
