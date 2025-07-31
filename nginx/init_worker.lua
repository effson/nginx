if ngx.worker.id() ~= 0 then
    return
end 

local redis = require "resty.redis"
local bklist = ngx.shared.blk_list

local function update_blacklist()
    local rdb = redis:new()
    local ok, err = rdb:connect("127.0.0.1", 6379)
    if not ok then
        return
    end
    local black_list, err = rdb:smembers("black_list")
    bklist:flush_all()
    for _, v in ipairs(black_list) do
        bklist:set(v, true)
    end
    ngx.timer_at(5, update_blacklist)  -- Schedule next update in 60 seconds
end

ngx.timer_at(5, update_blacklist)