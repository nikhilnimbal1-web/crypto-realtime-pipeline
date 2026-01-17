import json
import time
import requests
import websocket
import boto3
from datetime import datetime, timedelta, timezone
from pathlib import Path

# ================= CONFIG =================
SYMBOL = "BTCUSDT"

# For testing use 60, for real use 15 * 60
BATCH_INTERVAL_SECONDS = 60

S3_BUCKET = "crypto-realtime-nikhil-001"
S3_PREFIX = "binance/raw/"

STATE_FILE = Path("state.json")

BINANCE_REST_URL = "https://api.binance.com/api/v3/aggTrades"
WS_URL = "wss://stream.binance.com:9443/ws/btcusdt@trade"
# ==========================================

s3_client = boto3.client("s3")

buffer = []
batch_start_time = time.time()

# ============ STATE MANAGEMENT ============
def read_last_time():
    """
    Read last successful ingestion time from disk.
    Always return UTC-aware datetime.
    """
    if not STATE_FILE.exists():
        return None

    data = json.loads(STATE_FILE.read_text())
    ts = datetime.fromisoformat(data["last_successful_time"])

    # 🔥 FIX: normalize to UTC if naive
    if ts.tzinfo is None:
        ts = ts.replace(tzinfo=timezone.utc)

    return ts


def write_last_time(ts: datetime):
    """
    Persist last successful ingestion time to disk (UTC).
    """
    STATE_FILE.write_text(
        json.dumps({"last_successful_time": ts.isoformat()})
    )

# ============ S3 UPLOAD ============
def upload_to_s3(records, prefix="stream", start_time=None, end_time=None):
    """
    Upload records to S3.

    Streaming:
      stream_YYYY-MM-DD_HH-MM-SS.json

    Backfill:
      backfill_YYYY-MM-DD_HH-MM_to_YYYY-MM-DD_HH-MM.json
    """

    if prefix == "backfill" and start_time and end_time:
        start_str = start_time.strftime("%Y-%m-%d_%H-%M")
        end_str = end_time.strftime("%Y-%m-%d_%H-%M")
        filename = f"backfill_{start_str}_to_{end_str}.json"
    else:
        ts = datetime.now(timezone.utc).strftime("%Y-%m-%d_%H-%M-%S")
        filename = f"stream_{ts}.json"

    key = f"{S3_PREFIX}{filename}"

    s3_client.put_object(
        Bucket=S3_BUCKET,
        Key=key,
        Body=json.dumps(records, indent=2)
    )

    print(f"Uploaded {key} ({len(records)} records)")

# ============ BACKFILL ============
def backfill(start_time: datetime, end_time: datetime):
    """
    Fetch missing data using Binance REST API.
    """
    print(f"Backfilling {start_time} → {end_time}")

    params = {
        "symbol": SYMBOL,
        "startTime": int(start_time.timestamp() * 1000),
        "endTime": int(end_time.timestamp() * 1000),
        "limit": 1000
    }

    all_trades = []

    while True:
        response = requests.get(BINANCE_REST_URL, params=params)
        response.raise_for_status()
        trades = response.json()

        if not trades:
            break

        for t in trades:
            all_trades.append({
                "symbol": SYMBOL,
                "price": float(t["p"]),
                "quantity": float(t["q"]),
                "trade_time": datetime.fromtimestamp(
                    t["T"] / 1000, tz=timezone.utc
                ).isoformat()
            })

        params["startTime"] = trades[-1]["T"] + 1
        time.sleep(0.2)  # rate-limit safety

    if all_trades:
        upload_to_s3(
            all_trades,
            prefix="backfill",
            start_time=start_time,
            end_time=end_time
        )
        write_last_time(end_time)

# ============ STREAMING ============
def on_message(ws, message):
    global buffer, batch_start_time

    data = json.loads(message)

    trade = {
        "symbol": data["s"],
        "price": float(data["p"]),
        "quantity": float(data["q"]),
        "trade_time": datetime.fromtimestamp(
            data["T"] / 1000, tz=timezone.utc
        ).isoformat()
    }

    buffer.append(trade)

    if time.time() - batch_start_time >= BATCH_INTERVAL_SECONDS:
        upload_to_s3(buffer)
        write_last_time(datetime.now(timezone.utc))
        buffer.clear()
        batch_start_time = time.time()

# ============ MAIN ============
def main():
    now = datetime.now(timezone.utc)
    last_time = read_last_time()

    # 🔥 Correct backfill condition
    if last_time:
        gap_seconds = (now - last_time).total_seconds()
        if gap_seconds > BATCH_INTERVAL_SECONDS:
            backfill(last_time, now)

    print("Starting live streaming...")
    ws = websocket.WebSocketApp(WS_URL, on_message=on_message)
    ws.run_forever()

if __name__ == "__main__":
    main()
