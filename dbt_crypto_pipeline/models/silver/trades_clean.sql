{{ config(
    schema='SILVER',
    materialized='view'
) }}


select
    raw_data:symbol::string        as symbol,
    raw_data:price::float          as price,
    raw_data:quantity::float       as quantity,
    raw_data:trade_time::timestamp as trade_time,
    load_ts
from {{ source('crypto_raw', 'BINANCE_RAW') }}
