执行下面命令，Certbot 会自动修改你的 Nginx 配置文件，添加 HTTPS 支持:<br>
# sudo certbot --nginx <br>
它会引导你：<br>
选择你要启用 HTTPS 的域名；<br>
选择是否强制重定向 HTTP 到 HTTPS；<br>
自动修改 Nginx 配置、重新加载 Nginx。<br>

执行成功后，你可以看到：<br>
```Congratulations! Your certificate and chain have been saved at:```<br>
...
#  检查你的 HTTPS 配置是否生效<br>

## sudo nginx -t<br>
## sudo systemctl reload nginx<br>
然后访问域名 https://example.com，应该就是加密的 HTTPS 页面了！<br>
<br>
# 🔁 五、自动续期<br>
Certbot 默认生成的 Let's Encrypt 证书有效期为 90 天，推荐配置自动续期：<br>
## ```sudo crontab -e```<br>
添加以下内容（每天凌晨检查并自动续期）：<br>
```0 3 * * * certbot renew --quiet```<br>
或者直接测试续期命令：<br>
```sudo certbot renew --dry-run```<br>
# 📁 六、HTTPS 站点配置样例（自动生成）<br>
## conf<br>
```
server {
    listen 80;
    server_name example.com www.example.com;

    # certbot 会自动加这个 redirect 到 HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name example.com www.example.com;

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
```
