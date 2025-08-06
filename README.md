# Bike Sharing — Graph + Time Series (InfluxDB) Demo

Minimal setup to test combined graph and time-series data in InfluxDB.

## Quick start
1. Start InfluxDB: `docker compose up -d`
2. Write data: `./scripts/write_data.sh`
3. Run queries from `queries/` in the InfluxDB UI.

## Schema
- **node**: tag `station_id`; fields `name` (string), `capacity` (int)
- **edge**: tags `edge_id`, `src`, `dst`; fields `member_type`, `bike_type`, `user_id`
- **metric**: tags `id`, `metric_name` (implicit by field name here); fields `available_bikes` (int)

Write with `?precision=ns`.
