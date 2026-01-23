{% snapshot trades_ohlc_1d_snapshot %}

{{ config(
    target_schema='SNAPSHOTS',
    strategy='check',
    check_cols='all',
    unique_key='DATE'
) }}

SELECT 
    DATE,
    TIME,
    OPEN,
    HIGH,
    LOW,
    CLOSE,
    VOLUME
FROM {{ ref('trades_ohlc_1d') }}
WHERE DATE = CURRENT_DATE() - 1  -- Yesterday only

{% endsnapshot %}
