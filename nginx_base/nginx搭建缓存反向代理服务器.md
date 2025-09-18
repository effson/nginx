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
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for

        proxy_pass http://local
    }
  }
```
