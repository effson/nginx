local redis = require "resty.redis"

local rdb = redis:new()

local ok, err = rdb:connect("127.0.0.1", 6379)

if not ok then
    return ngx.exit(301)
end

local ip = ngx.var.remote_addr

local exists, err = rdb:sismember("black_list", ip)
if exists == 1 then
    ngx.log(ngx.ERR, "IP " .. ip .. " is blacklisted")
    return ngx.exit(403)
end