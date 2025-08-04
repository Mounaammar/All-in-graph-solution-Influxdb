bucket = "bike_sharing"
t      = 2025-08-04T13:20:00Z
t2 = 2025-08-04T09:20:00Z
threshold = 4.4


 snapshot= from(bucket: bucket)
    |> range(start: t2, stop: t)
    |> filter(fn: (r) =>
        r._measurement == "metric" and
        r._field == "available_bikes" 
    )
    |> group(columns: ["id"])
    |> mean()
    |> rename(columns: {id: "dst", _value: "avail"})


  neighbors=  from(bucket: bucket)
    |> range(start: t2, stop: t)
    |> filter(fn: (r) => r._measurement == "edge")
    |> keep(columns: ["src","dst","_time"])
    
// 3) Join to get each neighbor’s availability at t, then keep sources with ≥1 low neighbor
  join(tables: {e: neighbors, s: snapshot}, on: ["dst"], method: "inner")
  |> filter(fn: (r) => float(v: r.avail) < threshold)
  |> keep(columns: ["src"]) |> distinct(column: "src")
