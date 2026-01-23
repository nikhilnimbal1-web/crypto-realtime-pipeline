🚀 Crypto Near Real-Time Data Engineering Pipeline
Overview
This project implements a near real-time data ingestion pipeline using live cryptocurrency trade data from Binance, featuring a TradingView-style interactive dashboard built with Streamlit + Plotly. It simulates real-world data engineering challenges like system downtime, recovery, backfilling, and production-ready visualization.

✨ New Features Added
text
✅ FULLY INTERACTIVE TRADINGVIEW DASHBOARD
✅ Real-time candlestick charts (15m, 5m, 1m, 1d)
✅ Customizable candle colors (Fill + Border/Wick separately)
✅ Dark/Light theme toggle
✅ Zoom/Pan TradingView controls
✅ Clean axes (Time + Price labels only)
✅ Snowflake-powered OHLC data
✅ Production-grade UI
Problem Statement
Real-time data systems face:

Continuous data arrival

System crashes or restarts

Risk of missing or incomplete data

Visualization at scale

This project addresses:

Near real-time streaming ingestion

Automatic recovery of missed data

Reliable cloud storage for analytics

Interactive TradingView dashboard

🏗️ Complete Architecture
text
Binance WebSocket (Live Trades)
        |
        v
Python Ingestion Service
        |
        |-- Micro-batch every N seconds --> Amazon S3 (stream files)
        |
        |-- On restart --> Binance REST API (Backfill) --> Amazon S3
        |
        v
Snowflake (dbt_crypto_pipeline/)
        |
        v
🕯️ TradingView Dashboard (Streamlit + Plotly)
Project Structure
text
crypto_realtime_pipeline/
├── Ingestion/
│   ├── src/ingest/binance_trade_listener.py
│   ├── requirements.txt
│   └── state.json
├── dbt_crypto_pipeline/
│   ├── models/
│   │   ├── TRADES_OHLC_1M.sql
│   │   ├── TRADES_OHLC_5M.sql
│   │   ├── TRADES_OHLC_15M.sql
│   │   └── TRADES_OHLC_1D.sql
│   ├── tests/
│   ├── dashboard.py          ← ✨ NEW!
│   └── dbt_project.yml
├── .gitignore
└── README.md
🎛️ Dashboard Features
Feature	Status
Candlestick Charts	✅ 15m/5m/1m/1d
Color Customization	✅ Fill + Border/Wick
Theme Toggle	✅ Dark/Light
TradingView Controls	✅ Zoom/Pan/Reset
Snowflake Integration	✅ Live data
Clean UI	✅ No clutter
How the Pipeline Works
text
1. Python service → Binance WebSocket (live trades)
2. Micro-batch → S3 (every 60s)
3. dbt → Snowflake (OHLC aggregation)
4. Streamlit → Interactive candlesticks
5. Restart → Auto-backfill gaps
🔧 Key Technologies
text
DATA INGESTION
├── Python + WebSocket + REST API
├── Amazon S3 (free-tier)
├── boto3 + checkpointing
└── Fault-tolerant backfill

DATA WAREHOUSE
├── Snowflake (COMPUTE_WH)
├── dbt (multi-timeframe models)
└── OHLC aggregation

VISUALIZATION
├── Streamlit (dashboard.py)
├── Plotly (candlesticks)
├── Custom colors/themes
└── TradingView UX
🚀 Production Features Delivered
text
✅ Near real-time ingestion
✅ Automatic backfill/recovery
✅ Multi-timeframe OHLC (1m/5m/15m/1d)
✅ Interactive TradingView dashboard
✅ Custom candle styling (4 colors)
✅ Theme switching
✅ Fault tolerance
✅ Cloud-native (S3 + Snowflake)
✅ Clean, recruiter-ready UI
💡 What I Learned
Near real-time pipeline design with checkpointing

Plotly candlestick customization (fill/border/wick)

Snowflake + dbt for multi-timeframe analytics

Streamlit production dashboards

TradingView UX implementation

Fault-tolerant data systems

🔮 Future Improvements
text
Phase 2: Apache Kafka (durable queue)
Phase 3: Airflow orchestration
Phase 4: Real-time alerts
Phase 5: Multi-asset support
Phase 6: Mobile responsive
🎯 Why This Project Stands Out
text
✅ End-to-end pipeline (Ingest → Warehouse → Viz)
✅ Production-grade fault tolerance
✅ TradingView-level visualization
✅ Cloud-native (free-tier friendly)
✅ Interview-ready demo
✅ Recruiter-friendly README
Live Demo: (http://localhost:8501)
Tech Stack: Python | Snowflake | dbt | S3 | Streamlit | Plotly
Status: 🚀 Production Ready