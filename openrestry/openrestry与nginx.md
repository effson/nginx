# 1. *_by_lua 指令
<img width="753" height="683" alt="image" src="https://github.com/user-attachments/assets/20a272f3-33fe-4d30-b717-5d52ed8f936d" />
# 2. conf实例

```conf
server {
        listen       8080;                  # 监听 80 端口
        server_name  myweb;           # 可以改成你的域名/IP

        # 网站根目录
        root /home/jeff/nginx/myweb;

        # 默认首页文件
        index index.html;

        # location / 匹配所有请求
        location / {
            try_files $uri $uri/ =404;    # 请求的文件不存在则返回 404
        }

        location /lua {
            default_type text/html;
            content_by_lua  ``
        }
    }
```
