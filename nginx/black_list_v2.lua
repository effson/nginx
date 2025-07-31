local bklist = ngx.shared.blk_list
local ip = ngx.var.remote_addr

if bklist:get(ip) then
    return ngx.exit(403)
end