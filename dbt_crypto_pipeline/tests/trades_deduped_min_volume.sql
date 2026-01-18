-- =====================================================
-- Test: trades_deduped_min_volume
-- Purpose:
--   Detect silent data loss using volume thresholds
--   Behavior differs by environment
--
-- DEV  : Very relaxed (allow pauses)
-- PROD : Strict (detect ingestion issues)
-- =====================================================

with recent_trades as (

    select count(*) as trade_count
    from {{ ref('trades_deduped') }}
    where indian_loaded_time >= dateadd(minute, -15, current_timestamp())

)

select *
from recent_trades
where trade_count <
    case
        when '{{ target.name }}' = 'dev' then 0
        else 5
    end
