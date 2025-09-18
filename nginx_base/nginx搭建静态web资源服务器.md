# 1. 资源准备
index.html

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>欢迎访问我的 Nginx 静态站点</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <h1>Hello, 游客!</h1>
    <p>这是一个通过 Nginx 搭建的静态 Web 服务器。</p>
    <p><a href="about.html">关于本站</a></p>
    <img src="images/logo.png" alt="Logo" width="200">
</body>
</html>

```

about.html

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>关于本站</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <h1>关于本站</h1>
    <p>本网站由 <strong>Nginx</strong> 提供服务。</p>
    <p><a href="index.html">返回首页</a></p>
</body>
</html>

```
css/style.css

```css
body {
    font-family: Arial, sans-serif;
    background-color: #f4f6f8;
    color: #333;
    margin: 40px;
}

h1 {
    color: #0066cc;
}
a {
    color: #ff6600;
    text-decoration: none;
}
a:hover {
    text-decoration: underline;
}
```
images/logo.png

<img width="408" height="385" alt="屏幕截图 2025-09-17 230851" src="https://github.com/user-attachments/assets/c1608d43-65e9-42e0-bb94-b3fb1a6ef2ef" />

# 2. 配置文件
```conf
...
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
    }
...
```
<img width="464" height="221" alt="image" src="https://github.com/user-attachments/assets/6f193ce7-c31b-43cd-9130-4a4b17aec06a" />

<img width="388" height="131" alt="image" src="https://github.com/user-attachments/assets/734859db-5bcb-4013-8896-9b476f927e4e" />

# 3. 实现效果

访问 http://192.168.23.173:8080/index.html

<img width="383" height="359" alt="image" src="https://github.com/user-attachments/assets/99aefe43-80f8-4865-89d0-5d692b3b4cd7" />

访问 http://192.168.23.173:8080/about.html

<img width="355" height="191" alt="image" src="https://github.com/user-attachments/assets/908fdd79-d850-4172-a3e3-e7b86da61305" />


# 4. 改造为https

```conf
...
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
    }
...
```
## 4.1 下载certbot
```bash
apt get certbot python2-certbot-nginx

## 4.2 改造nginx配置
certbot --nginx --nginx-server-root=/home/jeff/nginx/conf/ -d www.example.com
```
