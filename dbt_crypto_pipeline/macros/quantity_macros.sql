-- =====================================================
-- Macro: normalize_quantity
-- Purpose:
--   Convert quantity into fixed-width integer string
--   Example:
--     0.0001 -> 00001
-- =====================================================
{% macro normalize_quantity(quantity, scale=4, width=5) %}
    lpad(
        cast({{ quantity }} * power(10, {{ scale }}) as integer)::string,
        {{ width }},
        '0'
    )
{% endmacro %}
