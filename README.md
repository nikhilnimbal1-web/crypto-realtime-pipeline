# 🚀 Crypto Near Real-Time Data Engineering Pipeline

An end-to-end data engineering project that ingests live cryptocurrency trades via WebSockets, processes them through a modern data stack, and visualizes market movement in a professional-grade dashboard.

[![Streamlit App](https://static.streamlit.io/badges/streamlit_badge_black_white.svg)](http://localhost:8501)

---

## 🎯 Production Features

| Feature | Status |
| :--- | :--- |
| **Candlestick Charts** | ✅ 1m, 5m, 15m, and 1d intervals |
| **Custom Styling** | ✅ Financial-grade Fill + Border/Wick colors |
| **Interactive UI** | ✅ TradingView-style Zoom, Pan, and Range Selectors |
| **Live Data** | ✅ Direct Snowflake integration with <60s latency |
| **Fault Tolerance** | ✅ Checkpointing + Auto-backfill via REST API |

---

## 🏗️ Architecture Overview

The pipeline implements a **Medallion Architecture** designed for high-throughput financial data.

```mermaid
graph TD
    A[Binance WebSocket<br/>Live Trades] --> B[Python Ingestion Service]
    B --> C[S3 Micro-batches<br/>60s Parquet files]
    B --> D[Auto Backfill<br/>REST API Support]
    C --> E[Snowflake + dbt<br/>OHLC Transformation]
    E --> F[🕯️ Streamlit Dashboard<br/>Plotly Financial UI]
📁 Project Structure
Plaintext
crypto_realtime_pipeline/
├── Ingestion/                 # WebSocket + S3 logic
│   ├── binance_trade_listener.py
│   └── state.json             # Fault tolerance checkpointing
├── dbt_crypto_pipeline/       # SQL Transformations
│   ├── models/
│   │   ├── TRADES_OHLC_1M.sql
│   │   ├── TRADES_OHLC_5M.sql
│   │   ├── TRADES_OHLC_15M.sql
│   │   └── TRADES_OHLC_1D.sql
│   ├── dashboard.py          # ✨ Streamlit UI
│   └── dbt_project.yml
├── requirements.txt
├── .gitignore
└── README.md
🔧 Tech Stack
Data Source: Binance API (WebSockets & REST)

Storage: AWS S3 (Data Lake) & Snowflake (Warehouse)

Transformation: dbt (Data Build Tool)

Pipeline: Python (Boto3, Pandas)

UI: Streamlit & Plotly (Financial Charting)

💻 Quick Start
1. Clone & Install
Bash
git clone [https://github.com/YOUR_USERNAME/crypto_realtime_pipeline](https://github.com/YOUR_USERNAME/crypto_realtime_pipeline)
cd crypto_realtime_pipeline
pip install -r requirements.txt
2. Environment Setup
Create a .env file in the root:

Code snippet
SNOWFLAKE_ACCOUNT="your_account"
SNOWFLAKE_USER="your_user"
SNOWFLAKE_PASSWORD="your_password"
AWS_ACCESS_KEY="your_aws_key"
AWS_SECRET_KEY="your_aws_secret"
3. Launch
Bash
# Start ingestion
python Ingestion/binance_trade_listener.py

# Launch Dashboard
streamlit run dbt_crypto_pipeline/dashboard.py
🎓 Skills Demonstrated
Stream Processing: Handling high-frequency WebSocket events.

Cloud-Native Ingestion: Orchestrating micro-batch uploads to S3.

Analytics Engineering: Writing idempotent dbt models for time-series aggregation.

Full-Stack Data: Bridging the gap between raw backend data and frontend financial UX.

Status: 🚀 Production Deployed

Author: NIKHIL NIMBAL
