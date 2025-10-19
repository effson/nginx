# 1. 协议
Nginx 通过 HTTP 响应头与客户端协商 keepalive：
```makefile
Connection: keep-alive | close
Keep-Alive: timeout=65, max=1000
```

# 2. 指令
## 2.1 keepalive_disable
禁用对特定类型客户端（通常是老旧或存在兼容性问题的浏览器）使用 HTTP keep-alive（长连接）机制。
```nginx
keepalive_disable none | browser ...; # http, server, location
```
默认值：

```nginx
keepalive_disable msie6;
```
示例：
```nginx
http {
    # 禁用 IE6、Safari 在 HTTPS 下的 keepalive
    keepalive_disable msie6 safari ssl;
}
```


## 2.2 keepalive_requests
限制一个客户端长连接上可处理的 最大请求数。超过该请求数后，Nginx 主动关闭该连接
```nginx
keepalive_requests number; # http, server, location
```

默认值：
```nginx
keepalive_requests 100;
```

示例：
```nginx
http {
    # 一个 TCP 连接最多处理 1000 个请求
    keepalive_requests 1000;
}
```


## 2.3 keepalive_timeout
设置客户端空闲连接的 超时时间，即在最后一次请求完成后，连接保持多久不被关闭
```nginx
keepalive_timeout timeout [header_timeout];
```
- timeout	空闲超时时间（单位：秒，或加 ms 毫秒）。连接在该时间后关闭。
- header_timeout	（可选）写入 HTTP 响应头中的 Keep-Alive: timeout= 值，用于提示客户端

默认值：
```nginx
keepalive_timeout 75s;
```

示例：
```nginx
http {
    # 连接空闲 65 秒后关闭，并向客户端发送 Keep-Alive 头提示 60 秒
    keepalive_timeout 65s 60s;
}
```
