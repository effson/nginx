# 1. TCP连接相关变量

## 1.1 $binary_remote_addr
客户端地址的二进制形式
- IPv4 4字节
- IPv6 16字节

## 1.2 $connection
当前 TCP 连接的序号（ngx_connection_t->number）
- 不断递增

## 1.3 $connection_requests
当前 TCP 连接上已处理的请求数（复用场景），对keepalive连接有意义，判断是否复用 Keep-Alive 连接

## 1.4 $remote_addr

客户端 IP 地址（来自 ngx_connection_t->sockaddr）
- 记录访问者 IP、限速、黑名单匹配

## 1.5 $remote_port
客户端源端口

## 1.6 $proxy_protocol_addr

当使用 PROXY protocol 时，返回代理客户端真实 IP 地址,获取真实客户端 IP（在四层代理后）

## 1.7 $proxy_protocol_port
当使用 PROXY protocol 时，返回代理客户端端口

## 1.8 $server_addr
服务器本地 IP 地址（Nginx 监听端口的 IP）

## 1.9 $server_port

服务器监听端口号

## 1.10 $server_protocol
请求协议版本，如 
- HTTP/1.1
- HTTP/2.0

## 1.11 $TCP_INFO

<mark>$tcpinfo_*（或 $TCP_INFO）变量</mark>, tcp内核层参数

### 1.11.1 $tcpinfo_rtt
平滑往返时延（RTT），毫秒

### 1.11.2 $tcpinfo_rttvar
RTT 方差（RTT 的波动程度）

### 1.11.3 $tcpinfo_rcv_space
当前接收缓冲区可用空间，字节

### 1.11.4 $tcpinfo_snd_cwnd

当前发送拥塞窗口大小（以 MSS 为单位），包数



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
