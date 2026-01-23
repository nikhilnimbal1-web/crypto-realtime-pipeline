-- =====================================================
-- Macro: build_time_key
-- Purpose:
--   Create a readable time-based key from timestamp
--   Format:
--     YYYYMMDD + H(12hr) + AM/PM + MM + SS
--
-- Example:
--   2026-01-19 16:23:45 ->
--   202601194PM2345
-- =====================================================
{% macro build_time_key(ts) %}
    (
        year({{ ts }})::string ||
        lpad(month({{ ts }})::string, 2, '0') ||
        lpad(day({{ ts }})::string, 2, '0') ||

        (
            case
                when hour({{ ts }}) = 0 then '12'
                when hour({{ ts }}) > 12 then (hour({{ ts }}) - 12)::string
                else hour({{ ts }})::string
            end
        ) ||

        case
            when hour({{ ts }}) < 12 then 'AM'
            else 'PM'
        end ||

        lpad(minute({{ ts }})::string, 2, '0') ||
        lpad(second({{ ts }})::string, 2, '0')
    )
{% endmacro %}
