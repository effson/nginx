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

## 2.1 $request_time
请求处理耗时，请求从 接收完成（读完请求头+体） 到现在的时间<br>
常用于日志记录和性能分析：
```nginx
log_format timed '$remote_addr - $request_time "$request" $status';
```

## 2.2 $server_name
当前请求匹配到的 server {} 块中定义的 server_name 值

## 2.3 $https

表示当前**连接是否使用 SSL/TLS**,若启用了 listen 443 ssl; 并建立加密连接，**则 $https = "on"**；**否则为空字符串**

## 2.4 $request_completion

响应是否完整成功地返回，发送给客户端：
- **"OK"**：请求成功完成；
- **空字符串**：请求在发送过程中中断（客户端提前断开连接）。

## 2.5 $request_id

请求唯一标识符，Nginx 为每个请求生成的唯一 ID（UUID 格式或随机字符串），用于日志追踪


## 2.6 $limit_rate
当前请求响应数据的最大传输速率（bytes/s，字节每秒）


# 3 发送HTTP响应时相关的变量


## 3.1 $body_bytes_sent
发送给客户端的 响应体（body） 的字节数，不包含 HTTP 响应头

## 3.2 $bytes_sent
表示发送给客户端的 总字节数（包括响应头 + 响应体 + 任何附加信息）
```nginx
log_format bandwidth '$remote_addr $bytes_sent bytes total, $body_bytes_sent body';
```
输出示例：
```css
192.168.1.10 5243120 bytes total, 5242880 body
```

## 3.3 $status
表示 Nginx 发送给客户端的 HTTP 响应状态码（整数值）
```nginx
log_format main '$remote_addr "$request" $status';
```
```css
192.168.1.10 "GET /index.html HTTP/1.1" 200
192.168.1.11 "GET /noexist.html HTTP/1.1" 404
```

## 3.4 $sent_trailer
Nginx 在响应中发送的 HTTP Trailer 头部（HTTP/1.1 或 chunked 传输支持）。Trailer 是响应末尾（body 之后）发送的一组 HTTP 头字段

## 3.5 $sent_http_<header_name>
表示 Nginx 已经发送给客户端的响应头部 <header_name> 的值。

#### 3.5.1 $sent_http_content_type


#### 3.5.2 $sent_http_content_length

#### 3.5.3 $sent_http_location

#### 3.5.4 $sent_http_last_modified

#### 3.5.5 $sent_http_connection

#### 3.5.6 $sent_http_transfer_encoding

#### 3.5.7 


### 3.5.8 $sent_http_cache_control

### 3.5.9
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
