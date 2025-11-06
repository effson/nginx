# 1. HTTP反向代理流程
<img width="988" height="526" alt="image" src="https://github.com/user-attachments/assets/1506fe66-3c32-462b-ae8e-7ed613415b0c" />


# 2. proxy模块
**ngx_http_proxy_module** 是 <mark>**HTTP 反向代理模块**</mark>，它在 Nginx 的 CONTENT 阶段 执行，是最常用的 upstream 模块之一。

## 2.1 proxy_pass

### 2.1.1 指令的使用
```nginx
proxy_pass URL;
```
URL:
- **必须是http://或https://开头**
- 直接上游地址：http://127.0.0.1:8080
- upstream 名称：http://backend
- 动态变量：http://$host$request_uri
- 可选的 URI 部分（注意斜杠！）

### 2.1.2 URL参数是否携带URI

#### 携带URI
```nginx
location /api/ {
    proxy_pass http://backend/u1;
}
```
结果：
```
/api/abc ---> http://backend/u1/abc
/api/v1/user?id=1 ---> http://backend/u1/v1/user?id=1
```
