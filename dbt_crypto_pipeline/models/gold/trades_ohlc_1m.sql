{{ config(materialized = 'table') }}

WITH base AS (
    SELECT 
        DATE(INDIAN_TRADE_TIME) AS candle_date,
        DATE_PART('hour', INDIAN_TRADE_TIME) AS candle_hour,
        DATE_PART('minute', INDIAN_TRADE_TIME) AS candle_minute,
        SYMBOL,
        price,
        quantity,
        INDIAN_TRADE_TIME,
        ROW_NUMBER() OVER (
            PARTITION BY DATE(INDIAN_TRADE_TIME), 
                         DATE_PART('hour', INDIAN_TRADE_TIME), 
                         DATE_PART('minute', INDIAN_TRADE_TIME), 
                         SYMBOL 
            ORDER BY INDIAN_TRADE_TIME ASC
        ) AS rn_first,
        ROW_NUMBER() OVER (
            PARTITION BY DATE(INDIAN_TRADE_TIME), 
                         DATE_PART('hour', INDIAN_TRADE_TIME), 
                         DATE_PART('minute', INDIAN_TRADE_TIME), 
                         SYMBOL 
            ORDER BY INDIAN_TRADE_TIME DESC
        ) AS rn_last
    FROM {{ ref('trades_deduped') }}
)

SELECT 
    candle_date AS DATE,
    LPAD(candle_hour::VARCHAR, 2, '0') || ':' || LPAD(candle_minute::VARCHAR, 2, '0') AS TIME,
    
    -- OPEN: First trade price
    MAX(CASE WHEN rn_first = 1 THEN price END) AS OPEN,
    
    -- CLOSE: Last trade price  
    MAX(CASE WHEN rn_last = 1 THEN price END) AS CLOSE,
    
    MAX(price) AS HIGH,
    MIN(price) AS LOW,
    SUM(quantity) AS VOLUME
    
FROM base
GROUP BY candle_date, candle_hour, candle_minute, SYMBOL
ORDER BY candle_date DESC, candle_hour DESC, candle_minute DESC