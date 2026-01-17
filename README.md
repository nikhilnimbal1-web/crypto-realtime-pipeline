# Crypto Near Real-Time Data Engineering Pipeline

This project implements a near real-time data ingestion pipeline using live cryptocurrency trade data from Binance.

The goal of this project is to simulate real-world data engineering challenges such as streaming ingestion, system downtime, and automatic data backfilling using free and cloud-friendly tools.

---

## Problem Statement

In real-time data systems:
- Data arrives continuously
- Systems can crash or go offline
- Missing data must be recovered automatically

This project solves:
- Near real-time ingestion of streaming data
- Safe recovery of missed data after downtime
- Reliable storage for analytics and downstream processing

---

## Architecture Overview

Binance WebSocket (Live Trades)
        |
        v
Python Ingestion Service
        |
        |-- every N seconds --> Amazon S3 (stream files)
        |
        |-- on restart --> REST API Backfill --> Amazon S3

---

## Key Features

- Near real-time ingestion using Binance WebSocket
- Micro-batch uploads to Amazon S3
- Automatic backfill using Binance REST API after downtime
- Checkpointing using a persisted state file
- Clear file naming for backfill time windows
- Free-tier friendly cloud design

---

## Tech Stack

- Python
- Binance WebSocket & REST API
- Amazon S3
- boto3
- websocket-client

---

## How the Pipeline Works

1. The ingestion service connects to Binance WebSocket for live trade data
2. Trade events are buffered in memory
3. Every configured interval (e.g. 60 seconds), data is uploaded to Amazon S3
4. The last successful ingestion time is saved locally
5. If the service restarts and a time gap is detected:
   - Missing data is fetched using Binance REST API
   - Backfilled data is uploaded to S3
6. Live streaming resumes automatically

---

## Failure Handling

- If the system crashes or loses network connectivity:
  - Data already uploaded to S3 remains safe
  - On restart, missing data is automatically recovered
- Network or API failures during backfill are handled gracefully

---

## Running the Project

venv\Scripts\activate  
python src\ingest\binance_trade_listener.py

---

## What I Learned

- Designing near real-time ingestion pipelines
- Handling crashes using backfill logic
- Working with WebSocket and REST APIs
- Cloud storage best practices with Amazon S3
- Importance of fault tolerance in data systems

---

## Future Improvements

- Introduce Kafka for durable buffering
- Load data from S3 into Snowflake
- Add deduplication logic
- Add orchestration using Airflow
