-- =====================================================
-- Macro: normalize_price
-- Purpose:
--   Convert price into integer by removing decimal
--   Example:
--     98999.99 -> 9899999
-- =====================================================
{% macro normalize_price(price, scale=2) %}
    cast({{ price }} * power(10, {{ scale }}) as integer)
{% endmacro %}
