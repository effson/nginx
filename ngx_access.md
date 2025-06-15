# 0 概述 <br>
在 Nginx 的 HTTP 请求处理流程中，access 阶段（NGX_HTTP_ACCESS_PHASE）是用于权限控制的关键阶段<br>
access 阶段主要用于判断当前请求是否允许访问，常用于 IP 黑白名单、用户认证、ACL（访问控制列表）等操作。<br>


# 1 常见用法示例<br><br>
## 1.1 拒绝某个 IP 访问<br>
```
location /admin {<br>
    deny 192.168.1.1;
    allow all;
}
```
#### 所有 IP 都允许，除了 192.168.1.1 被拒绝<br>
#### deny/allow 就是 access 阶段的 handler 指令<br>

## 1.2 开启基本认证<br>
```
location /private {
    auth_basic "Restricted";
    auth_basic_user_file /root/nginxdir/.htpasswd;
}
```
#### 访问 /private 资源时，需要提供用户名和密码，这也是发生在 access 阶段<br>
#### .htpasswd文件可以用 ```htpasswd -c /root/nginxdir/.htpasswd user_name``` 生成
#### 需要先安装httpd-tools
