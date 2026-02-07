{{ config(
    materialized = "table",
    partition_by = {
        "field": "_ingested_at_brt",
        "data_type": "timestamp"
    },
    cluster_by = ["id", "_ingestion_id"],
    tags = ["bi"]
) }}


select 
    *
from 
    {{ ref('stg_ingestion__customers') }}
