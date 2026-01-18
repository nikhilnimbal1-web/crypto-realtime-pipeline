{{ config(
    materialized='incremental',
    unique_key='trade_business_key'
) }}

-- =====================================================
-- Base CTE
-- Responsibilities:
-- 1. Convert timestamps to Indian time using macro
-- 2. Derive date and time dimensions
-- 3. Deduplicate trades using latest load timestamp
-- 4. Support incremental loading
-- =====================================================
with base as (

    select
        symbol,
        price,
        quantity,

        -- Binance trade time as received (UTC)
        trade_time as binance_trade_time,

        -- Binance trade time converted to IST
        {{ to_indian_time('trade_time') }} as indian_trade_time,

        -- Snowflake load time converted to IST
        {{ to_indian_time('load_ts') }} as indian_loaded_time,

        -- Time dimensions based on Indian load time
        year({{ to_indian_time('load_ts') }})     as load_year,
        month({{ to_indian_time('load_ts') }})    as load_month,
        day({{ to_indian_time('load_ts') }})      as load_date,
        dayname({{ to_indian_time('load_ts') }})  as load_day_name,
        hour({{ to_indian_time('load_ts') }})     as load_hour,
        minute({{ to_indian_time('load_ts') }})   as load_minute,

        -- Deduplication logic
        row_number() over (
            partition by symbol, trade_time
            order by load_ts desc
        ) as rn

    from {{ ref('trades_clean') }}

    {% if is_incremental() %}
        -- Only process new records in incremental runs
        where load_ts >
            (
                select max(indian_loaded_time)
                from {{ this }}
            )
    {% endif %}
)

-- =====================================================
-- Final SELECT
-- =====================================================
select
    b.symbol,
    b.price,
    b.quantity,

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

    -- Business-readable trade key
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
