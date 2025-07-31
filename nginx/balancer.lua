local balancer = require "ngx.balancer"
local shm = ngx.shared.tcp_content

local id = shm:incr("rr", 1, 0)

local urls_shm = ngx.shared.urls
local urls_in_shm = urls_shm:get_keys()

if #_urls_in_shm == 0 then
    return ngx.exit(500)
end

local url = _urls[(id % #_urls_in_shm) + 1]
local host, port = url:match("(.*)(.*)")

ngx.log(ngx.INFO, "id --> ", id, " urls --> ", _urls, " port --> ", port)

local ok, err = balancer.set_current_peer(host, tonumber(port))
if not ok then
    return ngx.exit(500)
end