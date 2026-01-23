{% macro time_to_hhmm(ts_col) %}
    LPAD(DATE_PART('hour', {{ ts_col }} )::VARCHAR, 2, '0') || 
    ':' || 
    LPAD(DATE_PART('minute', {{ ts_col }} )::VARCHAR, 2, '0')
{% endmacro %}
