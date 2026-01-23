{{ config(
    materialized = 'incremental',
    unique_key   = 'trade_business_key'
) }}

with max_loaded as (

    {% if is_incremental() %}
        select max(load_ts) as max_load_ts
        from {{ this }}
    {% else %}
        select to_timestamp_ntz('1900-01-01') as max_load_ts
    {% endif %}

),

base as (

    select
        symbol,
        price,
        quantity,

        load_ts,
        trade_time as binance_trade_time,

        {{ to_indian_time('trade_time') }} as indian_trade_time,
        {{ to_indian_time('load_ts') }}   as indian_loaded_time,

        year({{ to_indian_time('load_ts') }})    as load_year,
        month({{ to_indian_time('load_ts') }})   as load_month,
        to_date({{ to_indian_time('load_ts') }}) as load_date,
        dayname({{ to_indian_time('load_ts') }}) as load_day_name,
        hour({{ to_indian_time('load_ts') }})    as load_hour,
        minute({{ to_indian_time('load_ts') }})  as load_minute,

        row_number() over (
            partition by symbol, trade_time
            order by load_ts desc
        ) as rn

    from {{ ref('trades_clean') }}
    cross join max_loaded

    where load_ts > max_loaded.max_load_ts
)

select
    b.symbol,
    b.price,
    b.quantity,
    b.load_ts,

    b.binance_trade_time,
    b.indian_trade_time,
    b.indian_loaded_time,

    b.load_year,
    b.load_month,
    m.month_name,
    b.load_date,
    b.load_day_name,
    b.load_hour,
    h.hour_label,
    b.load_minute,

    {{ generate_trade_business_key(
        to_indian_time('b.binance_trade_time'),
        'b.price',
        'b.quantity'
    ) }} as trade_business_key

from base b
left join {{ ref('month_dim') }} m
    on b.load_month = m.month_number
left join {{ ref('hour_dim') }} h
    on b.load_hour = h.hour_24
where b.rn = 1
