{{ config(materialized = 'table') }}

WITH base AS (
    SELECT 
        DATE,
        TIME,
        -- Extract hour from TIME string (09:15 → 9)
        CAST(SUBSTRING(TIME, 1, 2) AS INTEGER) AS candle_hour,
        OPEN, HIGH, LOW, CLOSE, VOLUME
    FROM {{ ref('trades_ohlc_15m') }}
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY DATE 
            ORDER BY TIME ASC
        ) AS rn_first,
        ROW_NUMBER() OVER (
            PARTITION BY DATE 
            ORDER BY TIME DESC
        ) AS rn_last
    FROM base
)
SELECT 
    DATE,
    '09:30' AS TIME,  -- Fixed daily open time
    
    -- Daily OPEN: First 15min candle's OPEN (9:15 → Daily OPEN)
    MAX(CASE WHEN rn_first = 1 THEN OPEN END) AS OPEN,
    
    -- Daily CLOSE: Last 15min candle's CLOSE (last trading hour → Daily CLOSE)
    MAX(CASE WHEN rn_last = 1 THEN CLOSE END) AS CLOSE,
    
    MAX(HIGH) AS HIGH,
    MIN(LOW) AS LOW,
    SUM(VOLUME) AS VOLUME
    
FROM ranked
GROUP BY DATE
ORDER BY DATE DESC