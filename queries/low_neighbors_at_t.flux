bucket = "bike_sharing"
t  = 2025-08-04T10:20:00Z
lookback = 1h
threshold = 3.0

snapshot =
  from(bucket: bucket)
    |> range(start: t - lookback, stop: t)
    |> filter(fn: (r) => r._measurement == "metric" and r._field == "available_bikes")
    |> toFloat()
    |> group(columns: ["id"])
    |> last()
    |> keep(columns: ["id","_value"])
    |> rename(columns: {id: "dst", _value: "avail"})

neighbors =
  from(bucket: bucket)
    |> range(start: t - lookback, stop: t)
    |> filter(fn: (r) => r._measurement == "edge")
    |> keep(columns: ["src","dst","_time"])
    |> group(columns: ["src","dst"])
    |> last()
    |> keep(columns: ["src","dst"])

join(tables: {e: neighbors, s: snapshot}, on: ["dst"])
  |> filter(fn: (r) => r.avail < threshold)
  |> keep(columns: ["src","dst","avail"])
