# 1. upstream模块
```conf
  upstream origin_backend {
    server 127.0.0.1:8080;  # 只允许本机进程访问
    # keepalive 64;         # 如为 HTTP/1.1 上游，建议打开
  }
  server {    
    listen 8000;
    server_name  www.upstream.com;

    location / {
        proxy_set_header Host $host;             # 把客户端请求时使用的 Host 头 传递给后端
        proxy_set_header X-Real-IP $remote_addr; # Nginx 做了反向代理，后端看到的默认源 IP 是 Nginx 的 IP，不是用户的真实 IP
                                                 # 加了这行，后端程序（比如日志、鉴权模块）就能知道真正的客户端 IP
      
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        # 在请求头 X-Forwarded-For 里追加一条 IP 地址，用逗号隔开，在多级代理链路中，后端可以追踪到整个链路上所有经过的客户端 IP

        proxy_pass http://origin_backend;
    }
  }
```
打开文件：
```
C:\Windows\System32\drivers\etc\hosts
```
添加
```
192.168.23.173   www.upstream.com
```

# 2. proxy_cache 缓存

```conf
http {
  proxy_cache_path /var/cache/nginx/proxy_cache
  levels=1:2 # 两层子目录，避免同一目录中文件过多
  keys_zone=mycache:500m   # 元数据区（共享内存），500m 大约可存数百万条索引
  max_size=10g               # 缓存硬上限
  inactive=60m               # 60 分钟无人访问自动过期
  use_temp_path=off;

  upstream origin_backend {
    server 127.0.0.1:8080;  # 只允许本机进程访问
    # keepalive 64;         # 如为 HTTP/1.1 上游，建议打开
  }

  server {    
    listen 8000;
    server_name  www.upstream.com;

    location / {
        proxy_set_header Host $host;             # 把客户端请求时使用的 Host 头 传递给后端
        proxy_set_header X-Real-IP $remote_addr; # Nginx 做了反向代理，后端看到的默认源 IP 是 Nginx 的 IP，不是用户的真实 IP
                                                 # 加了这行，后端程序（比如日志、鉴权模块）就能知道真正的客户端 IP
      
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        # 在请求头 X-Forwarded-For 里追加一条 IP 地址，用逗号隔开，在多级代理链路中，后端可以追踪到整个链路上所有经过的客户端 IP

        proxy_cache mycache;
        proxy_cache_key $host$uri$is_args$args; # 定义缓存键（cache key） 的，决定了 Nginx 把请求缓存成哪个文件（或缓存对象）

        # 缓存有效期策略（按状态码）
        proxy_cache_valid 200 301 302 1d;
        proxy_cache_valid 404             100m;
        proxy_cache_valid any             10m;

        proxy_pass http://origin_backend;
    }
  }

}

```
