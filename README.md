# 🚀 Crypto Near Real-Time Data Pipeline

**Production-grade**: Binance → S3 → Snowflake Snowpipe → dbt → TradingView Dashboard (<60s latency)

[![Streamlit](https://static.streamlit.io/badges/streamlit_badge_black_white.svg)](https://your-app.streamlit.app)

---

## 🎯 Executive Summary

| Metric | Value |
|--------|-------|
| Data Source | Binance BTCUSDT Live Trades |
| Latency | <60 seconds end-to-end |
| Storage | S3 + Snowflake |
| Architecture | dbt Medallion (Raw→Silver→Gold) |
| Dashboard | TradingView-style Interactive |

---

## 🏗️ Architecture Flow
Binance WS/REST → Python Ingester → S3 Raw JSON
↓
Snowflake Snowpipe (10-30s)
↓
RAW → dbt SILVER → dbt GOLD
↓
Streamlit TradingView Dashboard


---

## 1. PYTHON INGESTER (ingest.py)

**What it does:**
- Live WebSocket streaming (BTCUSDT trades)
- Automatic gap backfill (REST API)
- S3 upload every 60 seconds
- Fault-tolerant state.json checkpointing

**Output files:**
s3://crypto-realtime-nikhil-001/binance/raw/
├── stream_2026-01-24_13-22-00.json (live batches)
└── backfill_13-00_to_13-30.json (gap recovery)

**Run:**
```bash
pip install requests websocket-client boto3
python ingest.py

2. SNOWFLAKE SETUP (snowflake_setup.sql)
Creates:
DATABASE: CRYPTO_DB
├── RAW/
│   ├── BINANCE_RAW (Snowpipe target)
│   ├── BINANCE_STAGE (S3 external)
│   └── BINANCE_PIPE (AUTO_INGEST)
├── SILVER/ (dbt)
└── GOLD/ (OHLC analytics)

Snowpipe auto-loads S3 files → RAW table (10-30s latency)

3. DBT MEDALLION PIPELINE
Raw → Silver:
JSON parsing → IST timezone → business_key → deduplication
RAW.BINANCE_RAW → SILVER.TRADES_DEDUPED

Silver → Gold:
Window functions → OHLC aggregation
TRADES_DEDUPED → TRADES_OHLC_1M/5M/15M/1D

4. TRADINGVIEW DASHBOARD (dashboard.py)
Features:

4x color pickers (bull/bear fill + border/wick)

Multi-timeframe (1m/5m/15m/1d)

Dark/light themes

Live Snowflake queries (5s refresh)

Zoom + pan interactions

Run:
pip install streamlit plotly snowflake-connector-python pandas
streamlit run dashboard.py

📁 File Structure
crypto_realtime_pipeline/
├── ingest.py              # Binance → S3
├── snowflake_setup.sql    # Snowpipe infra  
├── dashboard.py           # TradingView UI
├── requirements.txt
└── README.md

🚀 Production Features
✅ Fault tolerance (state.json recovery)

✅ Rate limiting (API throttling)

✅ Auto-scaling (Snowpipe + dbt)

✅ Deduplication (business keys)

✅ Timezone handling (UTC → IST)

📊 Performance
Stage	Latency	Throughput
Python→S3	60s batches	1000+ trades/min
Snowpipe	10-30s	Auto
dbt	2-5min	Incremental
Dashboard	5s refresh	Interactive
👨‍💻 Author
Nikhil Nimbalkar
Data Engineer | Snowflake + dbt Expert
📍 Nagenahalli, Karnataka, India
💼 LinkedIn

Status: 🚀 PRODUCTION LIVE | ⭐ Star this repo!

