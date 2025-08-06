# Bike Sharing — Graph + Time Series (InfluxDB) Demo

Minimal setup to test combined graph and time-series data in InfluxDB.

## Quick start
1. Copy `.env.example` to `.env` (adjust if needed).
2. Start InfluxDB: `docker compose up -d`
3. Write data: `./scripts/write_data.sh`
4. Run queries from `queries/` in the InfluxDB UI.

## Schema
- **node**: tag `station_id`; fields `name` (string), `capacity` (int)
- **edge**: tags `edge_id`, `src`, `dst`; fields `member_type`, `bike_type`, `user_id`
- **metric**: tags `id`, `metric_name` (implicit by field name here); fields `available_bikes` (int)

Data timestamps are 2025-08-04 (UTC). Write with `?precision=ns`.
