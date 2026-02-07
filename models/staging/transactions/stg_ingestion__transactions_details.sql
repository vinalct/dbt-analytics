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

    select * from {{ source('raw_ingestion__tables', 'transactions_details') }}

),

standardized as (
    select
        
        {{ generate_surrogate_key(["transaction_id"]) }} as id,
        {{ natural_key_as_string("transaction_id") }} as nk,

        {{ std_string("transaction_type") }} as type,

        {{ std_numeric("qtty") }} as quantity,
        {{ std_numeric("price") }} as price_usd,

        {{ std_string("__source_file") }} as _source_file_name,

        {{ generate_surrogate_key(["__ingestion_id"]) }} as _ingestion_id,
        {{ natural_key_as_string("__ingestion_id") }} as _ingestion_nk,

        {{ std_timestamp("__ingested_at", convert_to_brt=true) }} as _ingested_at_brt

    from source
),

dedup as (
    {{ latest_version('standardized', 'id', '_ingested_at_brt') }}
)

select * from dedup
