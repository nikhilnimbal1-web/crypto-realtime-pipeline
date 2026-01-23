-- =====================================================
-- Macro: generate_trade_business_key
-- Purpose:
--   Generate business-readable trade key by combining:
--   - Time key
--   - Normalized price
--   - Normalized quantity
--
-- Final format:
--   TIMEKEY-PRICE-QUANTITY
--
-- Example:
--   202601194PM2345-9899999-00001
-- =====================================================
{% macro generate_trade_business_key(trade_time_ist, price, quantity) %}
    {{ build_time_key(trade_time_ist) }} || '-' ||
    {{ normalize_price(price) }} || '-' ||
    {{ normalize_quantity(quantity) }}
{% endmacro %}
