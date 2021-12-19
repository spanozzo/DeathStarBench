require "socket"
math.randomseed(socket.gettime()*1000)
math.random(); math.random(); math.random()

local function get_user()
  local id = math.random(0, 500)
  local user_name = "Cornell_" .. tostring(id)
  local pass_word = ""
  for i = 0, 9, 1 do 
    pass_word = pass_word .. tostring(id)
  end
  return user_name, pass_word
end

local function search_hotel() 
  local in_date = math.random(9, 23)
  local out_date = math.random(in_date + 1, 24)

  local in_date_str = tostring(in_date)
  if in_date <= 9 then
    in_date_str = "2015-04-0" .. in_date_str 
  else
    in_date_str = "2015-04-" .. in_date_str
  end

  local out_date_str = tostring(out_date)
  if out_date <= 9 then
    out_date_str = "2015-04-0" .. out_date_str 
  else
    out_date_str = "2015-04-" .. out_date_str
  end

  local lat = 38.0235 + (math.random(0, 481) - 240.5)/1000.0
  local lon = -122.095 + (math.random(0, 325) - 157.0)/1000.0

  local method = "GET"
  local path = "http://localhost:5000/hotels?inDate=" .. in_date_str .. 
    "&outDate=" .. out_date_str .. "&lat=" .. tostring(lat) .. "&lon=" .. tostring(lon)

  local headers = {}
  -- headers["Content-Type"] = "application/x-www-form-urlencoded"
  return wrk.format(method, path, headers, nil)
end

local function recommend()
  local coin = math.random()
  local req_param = ""
  if coin < 0.33 then
    req_param = "dis"
  elseif coin < 0.66 then
    req_param = "rate"
  else
    req_param = "price"
  end

  local lat = 38.0235 + (math.random(0, 481) - 240.5)/1000.0
  local lon = -122.095 + (math.random(0, 325) - 157.0)/1000.0

  local method = "GET"
  local path = "http://localhost:5000/recommendations?require=" .. req_param .. 
    "&lat=" .. tostring(lat) .. "&lon=" .. tostring(lon)
  local headers = {}
  -- headers["Content-Type"] = "application/x-www-form-urlencoded"
  return wrk.format(method, path, headers, nil)
end

local function reserve()
  local in_date = math.random(9, 23)
  local out_date = in_date + math.random(1, 5)

  local in_date_str = tostring(in_date)
  if in_date <= 9 then
    in_date_str = "2015-04-0" .. in_date_str 
  else
    in_date_str = "2015-04-" .. in_date_str
  end

  local out_date_str = tostring(out_date)
  if out_date <= 9 then
    out_date_str = "2015-04-0" .. out_date_str 
  else
    out_date_str = "2015-04-" .. out_date_str
  end

  local hotel_id = tostring(math.random(1, 80))
  local user_id, password = get_user()
  local cust_name = user_id

  local num_room = "1"

  local method = "POST"
  local path = "http://localhost:5000/reservation?inDate=" .. in_date_str .. 
    "&outDate=" .. out_date_str .. "&lat=" .. tostring(lat) .. "&lon=" .. tostring(lon) ..
    "&hotelId=" .. hotel_id .. "&customerName=" .. cust_name .. "&username=" .. user_id ..
    "&password=" .. password .. "&number=" .. num_room
  local headers = {}
  -- headers["Content-Type"] = "application/x-www-form-urlencoded"
  return wrk.format(method, path, headers, nil)
end

local function user_login()
  local user_name, password = get_user()
  local method = "GET"
  local path = "http://localhost:5000/user?username=" .. user_name .. "&password=" .. password
  local headers = {}
  -- headers["Content-Type"] = "application/x-www-form-urlencoded"
  return wrk.format(method, path, headers, nil)
end

request = function()
  cur_time = math.floor(socket.gettime())
  local search_ratio      = 0.6
  local recommend_ratio   = 0.39
  local user_ratio        = 0.005
  local reserve_ratio     = 0.005

  local coin = math.random()
  if coin < search_ratio then
    return search_hotel()
  elseif coin < search_ratio + recommend_ratio then
    return recommend()
  elseif coin < search_ratio + recommend_ratio + user_ratio then
    return user_login()
  else 
    return reserve()
  end
end

-- PRINT TO CSV
done = function(summary, latency, requests)
  local rps = summary["requests"]/(summary["duration"]/1000000)
  local eps = (summary["errors"]["connect"]+summary["errors"]["read"]+summary["errors"]["write"]+summary["errors"]["status"]+summary["errors"]["timeout"])/(summary["duration"]/1000000)
  local rer = ((summary["errors"]["connect"]+summary["errors"]["read"]+summary["errors"]["write"]+summary["errors"]["status"]+summary["errors"]["timeout"])*100)/summary["requests"]
  -- open output file
  f = io.open("result.csv", "w")
  f:write("TS,COMPONENT,min-latency,max-latency,mean-latency,p50,p85,p90,p95,p99,duration,requests,bytes,connect-errors,read-errors,write-errors,status-errors,timeouts, rps, eps, rer\n")
  f:write(string.format("%s,%s,%f,%f,%f,%f,%f,%f,%f,%f,%d,%d,%d,%d,%d,%d,%d,%d,%f,%f,%f\n",
    os.date("!%Y-%m-%dT%T"),
    "hotel_reservation",
    latency.min/1000,    -- minimum latency
    latency.max/1000,    -- max latency
    latency.mean/1000,   -- mean of latency

    latency:percentile(50)/1000,     -- 50percentile latency
    latency:percentile(85)/1000,     -- 85percentile latency
    latency:percentile(90)/1000,     -- 90percentile latency
    latency:percentile(95)/1000,     -- 99percentile latency
    latency:percentile(99)/1000,     -- 99.999percentile latency
      
    summary["duration"]/1000000,  -- duration of the benchmark in seconds
    summary["requests"],          -- total requests during the benchmark
    summary["bytes"],             -- total received bytes during the benchmark
     
    summary["errors"]["connect"], -- total socket connection errors
    summary["errors"]["read"],    -- total socket read errors
    summary["errors"]["write"],   -- total socket write errors
    summary["errors"]["status"],  -- total socket write errors
    summary["errors"]["timeout"], -- total request timeouts
                        
    rps,
    eps,
    rer    
    ))
  
  f:close()
end
