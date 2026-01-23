-- =====================================================
-- Macro: to_indian_time
-- Purpose: Convert UTC timestamp to Indian Standard Time
-- =====================================================
{% macro to_indian_time(ts) %}
    convert_timezone('UTC', 'Asia/Kolkata', {{ ts }})
{% endmacro %}
