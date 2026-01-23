{% macro calc_vwap(
    high_col,
    low_col,
    close_col,
    volume_col,
    symbol_col,
    time_col
) %}

(
    sum(
        (({{ high_col }} + {{ low_col }} + {{ close_col }}) / 3)
        * {{ volume_col }}
    )
    over (
        partition by
            {{ symbol_col }},
            to_date({{ time_col }})
    )
    /
    nullif(
        sum({{ volume_col }})
        over (
            partition by
                {{ symbol_col }},
                to_date({{ time_col }})
        ),
        0
    )
)

{% endmacro %}
