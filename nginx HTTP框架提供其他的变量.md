# 1 TCP连接相关变量
```
$remote_addr: 客户端的 IP 地址。
$binary_remote_addr: 
$remote_port: 客户端的端口号。
$server_addr: 服务器的 IP 地址（通常是服务器监听的地址）。
$server_port: 服务器的端口号。
$proxy_protocol_addr:
$proxy_protocol_port:
$connection: 当前连接的唯一标识符。
$connection_requests: 当前连接的请求数量。
$TCP_INFO:
$server_protocol:
```

# 2 Nginx处理请求过程中产生的变量
```
$request_time:
$request_completion:
$request_id:
$server_name:
$https:
$request_filename:
$document_root:
$realpath_root:
$limit_rate:
```

# 3 发送HTTP响应时相关的变量
```
$body_bytes_sent:
$bytes_sent:
$status:
$sent_trailer:
```

# 4 Nginx系统变量
```
$time_local:
$pid:
$pipe:
$hostname:
$msee:
```
