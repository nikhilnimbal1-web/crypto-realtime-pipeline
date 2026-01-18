🚀 Crypto Near Real-Time Data Engineering Pipeline
📌 Overview

This project implements a near real-time data engineering pipeline that ingests live cryptocurrency trade data from Binance, handles system downtime, and automatically backfills missing data to ensure data completeness and reliability.

The project is designed to simulate real-world data engineering challenges commonly faced in production systems using free, cloud-friendly, and scalable tools.

⚡ This is not just streaming ingestion — it demonstrates fault tolerance, recovery, and production-grade design decisions.

🎯 Problem Statement

In real-world data platforms:

Data arrives continuously

Systems can crash, restart, or lose connectivity

Missing data can lead to incorrect analytics

Pipelines must self-heal without manual intervention

This project solves:

✅ Near real-time ingestion of streaming data

✅ Safe recovery of missed data after downtime

✅ Reliable cloud storage for downstream analytics

✅ Clear separation of ingestion and transformation layers

🏗️ Architecture Overview
Binance WebSocket (Live Trades)
        |
        v
Python Ingestion Service
        |
        |-- Micro-batch every N seconds
        |        |
        |        v
        |    Amazon S3 (Streaming Files)
        |
        |-- On Restart / Downtime Detected
                 |
                 v
        Binance REST API (Backfill)
                 |
                 v
            Amazon S3 (Backfill Files)

✨ Key Features

Near real-time ingestion using Binance WebSocket

Micro-batch uploads to Amazon S3

Automatic backfill using Binance REST API after downtime

Checkpointing using a persisted state file

Clear file naming with time-window metadata

Idempotent & fault-tolerant design

Free-tier friendly cloud architecture

Production-style project structure

🧱 Project Structure
crypto_realtime_pipeline/
│
├── Ingestion/                     # Data ingestion layer
│   ├── src/
│   │   └── ingest/
│   │       └── binance_trade_listener.py
│   ├── requirements.txt
│   ├── state.json                 # Checkpoint for recovery
│   └── README.md
│
├── dbt_crypto_pipeline/           # Transformation layer (Silver / Gold)
│   ├── models/
│   ├── tests/
│   └── dbt_project.yml
│
├── .gitignore
└── README.md


🔑 Design decision:
Ingestion and transformation are intentionally decoupled to allow:

independent scaling

easier debugging

production-style deployment

🧠 How the Pipeline Works (Step-by-Step)
1️⃣ Live Streaming

Python service connects to Binance WebSocket

Receives live trade events in near real-time

2️⃣ In-Memory Buffering

Incoming events are buffered temporarily

Prevents excessive small writes to S3

3️⃣ Micro-Batch Upload

Every configured interval (e.g. 60 seconds):

Buffered data is written to Amazon S3

File includes timestamp-based naming

4️⃣ Checkpointing

Last successful ingestion timestamp is stored locally

Enables precise recovery after crashes

5️⃣ Automatic Backfill (Critical Feature)

On service restart:

Time gap is detected

Missing data is fetched via Binance REST API

Backfilled data is uploaded to S3

Live streaming then resumes automatically

🛡️ Failure Handling & Recovery
Failure Scenario	How It’s Handled
Process crash	Checkpoint ensures no data loss
Network failure	Retry logic + backfill
Application restart	Automatic gap detection
Partial uploads	S3 object-level durability

✅ Guarantee: No silent data loss, even during downtime.

🧪 How to Run the Project
# Activate virtual environment
venv\Scripts\activate

# Start ingestion service
python src\ingest\binance_trade_listener.py

🧰 Tech Stack

Python

Binance WebSocket & REST API

Amazon S3

boto3

websocket-client

dbt (for transformations)

📈 What I Learned

Designing near real-time ingestion pipelines

Handling system crashes using backfill logic

Working with WebSocket + REST hybrid architectures

Cloud storage best practices with Amazon S3

Importance of fault tolerance & idempotency

Structuring projects like real production data platforms

🚀 Future Improvements

🔄 Introduce Kafka for durable buffering

❄ Load data from S3 into Snowflake

🧹 Add deduplication logic

⏱ Orchestration using Airflow

📊 Add data quality checks in dbt

🪵 Centralized logging & monitoring

🏆 Why This Project Matters

This project demonstrates:

Real-world data engineering problem solving

Production-aware design decisions

Cloud-native & scalable architecture

Strong understanding of failure handling

Clear separation of concerns (Ingestion vs Transformation)

📌 This is how real data platforms are built — not toy pipelines.