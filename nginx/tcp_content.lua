local sock, err = ngx.req.socket()

if err then
    return
end
local upsock = ngx.socket.tcp()

local ok, err

ok, err = upsock:connect("127.0.0.1", 8888)
if not ok then
    return
end

upsock:send(ngx.var.remote_addr .. "\n")
local function handler_upstream()
    local data
    for i = 1, 1000 do
        local reader = upsock:receiveuntil("\n", {inclusive = true})
        data, err = reader()
        if err then
            sock.close()
            upsock.close()
            return
        end
        sock:send(data)
    end
    return handler_upstream
end
ngx.thread.spawn(handler_upstream)
local data