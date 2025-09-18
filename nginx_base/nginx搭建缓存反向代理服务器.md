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
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr; # Nginx 做了反向代理，后端看到的默认源 IP 是 Nginx 的 IP，不是用户的真实 IP
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_pass [http://local](http://origin_backend);
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

# 2. upstream模块
