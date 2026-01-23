{{ config(materialized = 'table') }}

WITH base AS (
    SELECT 
        DATE,
        TIME,
        -- Extract hour from TIME (09:15 → 9)
        CAST(SUBSTRING(TIME, 1, 2) AS INTEGER) AS candle_hour,
        -- 9:15,9:20 → 9:15 | 9:25,9:30 → 9:30
        CASE 
            WHEN CAST(SUBSTRING(TIME, 4, 2) AS INTEGER) IN (15,20) THEN 15
            WHEN CAST(SUBSTRING(TIME, 4, 2) AS INTEGER) IN (25,30) THEN 30
            WHEN CAST(SUBSTRING(TIME, 4, 2) AS INTEGER) IN (35,40) THEN 45
            WHEN CAST(SUBSTRING(TIME, 4, 2) AS INTEGER) IN (45,50,55) THEN 45
            WHEN CAST(SUBSTRING(TIME, 4, 2) AS INTEGER) IN (0,5) THEN 0
            WHEN CAST(SUBSTRING(TIME, 4, 2) AS INTEGER) IN (10) THEN 15
        END AS candle_minute_15,
        OPEN, HIGH, LOW, CLOSE, VOLUME
    FROM {{ ref('trades_ohlc_5m') }}
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY DATE, candle_hour, candle_minute_15 
            ORDER BY TIME ASC
        ) AS rn_first,
        ROW_NUMBER() OVER (
            PARTITION BY DATE, candle_hour, candle_minute_15 
            ORDER BY TIME DESC
        ) AS rn_last
    FROM base
)
SELECT 
    DATE,
    LPAD(candle_hour::VARCHAR, 2, '0') || ':' || LPAD(candle_minute_15::VARCHAR, 2, '0') AS TIME,
    
    -- 9:15 5min OPEN → 9:15 15min OPEN  
    MAX(CASE WHEN rn_first = 1 THEN OPEN END) AS OPEN,
    
    -- 9:30 5min CLOSE → 9:30 15min CLOSE
    MAX(CASE WHEN rn_last = 1 THEN CLOSE END) AS CLOSE,
    
    MAX(HIGH) AS HIGH,
    MIN(LOW) AS LOW,
    SUM(VOLUME) AS VOLUME
    
FROM ranked
WHERE candle_minute_15 IS NOT NULL
GROUP BY DATE, candle_hour, candle_minute_15
ORDER BY DATE DESC, candle_hour DESC, candle_minute_15 DESC