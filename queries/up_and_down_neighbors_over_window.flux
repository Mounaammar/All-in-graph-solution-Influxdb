bucket = "bike_sharing"
tStart = 2025-08-04T10:00:00Z
tStop  = 2025-08-04T10:20:00Z

base =
  from(bucket: bucket)
    |> range(start: tStart, stop: tStop)
    |> filter(fn: (r) => r._measurement == "metric" and r._field == "available_bikes")

firsts = base |> group(columns:["id"]) |> first() |> keep(columns:["id","_value"]) |> rename(columns:{_value:"first"})
lasts  = base |> group(columns:["id"]) |> last()  |> keep(columns:["id","_value"]) |> rename(columns:{_value:"last"})

trends =
  join(tables:{a:firsts, b:lasts}, on:["id"])
    |> map(fn:(r)=>({ r with slope: float(v:r.last) - float(v:r.first) }))
    |> keep(columns:["id","slope"])

neighbors =
  from(bucket: bucket)
    |> range(start: tStart, stop: tStop)
    |> filter(fn: (r) => r._measurement == "edge")
    |> keep(columns:["src","dst","_time"])
    |> group(columns:["src","dst"])
    |> last()
    |> keep(columns:["src","dst"])

neighborTrends =
  join(tables:{e:neighbors, t:trends |> rename(columns:{id:"dst"})}, on:["dst"])
    |> map(fn:(r)=>({ r with inc: if r.slope > 0.0 then 1 else 0,
                            dec: if r.slope < 0.0 then 1 else 0 }))

neighborTrends
  |> group(columns:["src"])
  |> reduce(identity:{src:"", anyInc:0, anyDec:0},
            fn:(r,acc)=>({src:r.src,
                          anyInc: if r.inc == 1 then 1 else acc.anyInc,
                          anyDec: if r.dec == 1 then 1 else acc.anyDec}))
  |> filter(fn:(r)=> r.anyInc == 1 and r.anyDec == 1)
  |> keep(columns:["src"])
