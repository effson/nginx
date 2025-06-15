# 0 概述<br>
auth_request 是 Nginx 的一个子请求认证模块，由 ```ngx_http_auth_request_module``` 提供<br>

# 1 功能
### ✅ 把认证过程“外包”给另一个内部请求（子请求），并根据子请求的结果（状态码）决定主请求是否被允许。<br>

### 🧠 一句话总结<br>
### Nginx 的 auth_request 模块 不进行认证本身，而是调用另一个 location 进行认证判断。<br>

# 2 ✅ 使用场景<br>
#### 单点登录（SSO）<br>

#### API 网关认证（JWT、Session 等）<br>

#### 基于 Token / Cookie 的认证<br>

#### 与后端认证服务配合使用（如 OpenResty、Auth0、Keycloak）<br>

# 3 📦 模块说明<br>
该模块默认在 Nginx 源码中自带，但要确保编译时包含```--with-http_auth_request_module``` <br>
<br>
🔧 配置示例：将认证交给 /auth 接口判断<br>
```
server {
    listen 80;

    location /api/ {
        auth_request /auth;
        proxy_pass http://backend;
    }

    # 认证接口，只返回 2xx 表示通过，其它表示失败<br>
    location = /auth {
        internal;
        proxy_pass http://auth-server/validate_token;
    }
}
```
🔍 工作流程<br>
用户访问 /api/foo<br>
<br>
Nginx 自动发起子请求 /auth<br>

/auth 接口向认证服务检查用户合法性（检查 Cookie、Header、Token 等）<br>
<br>
根据 /auth 返回的状态码决定是否继续主请求：<br>
<br>
/auth 返回码	效果<br>
2xx（如 200）	✅ 请求通过，继续访问 /api<br>
401/403	❌ 主请求返回错误<br>
其它	默认返回 403 Forbidden<br>
<br>
✅ 搭配 header 传递身份信息<br>
你可以让 /auth 设置 header，然后传递给后端：<br>
<br>
<br>
location /api/ {<br>
    auth_request /auth;<br>
    auth_request_set $auth_user $upstream_http_x_user;<br>
    proxy_set_header X-User $auth_user;<br>
    proxy_pass http://backend;<br>
}<br>
这样后端能拿到 X-User 头，知道是谁。<br>
<br>
🚨 注意事项<br>
项	注意<br>
/auth 必须为 internal	防止外部直接访问<br>
/auth 不能返回重定向	会被 Nginx当作失败处理<br>
不支持 body 转发	子请求不会带 body，适合只检查 header/token<br>
配合缓存使用时要小心	auth_request 会绕过缓存逻辑<br>
<br>
🧪 用 curl 模拟验证<br>
你可以这样测试：<br>
<br>
curl -v -H "Authorization: Bearer xyz" http://127.0.0.1/api/foo<br>
看是否触发了 /auth 子请求并判断成功。<br>
<br>
✅ 总结表
指令	说明
auth_request /auth;	指定认证子请求的 URI
auth_request_set	从子请求提取 header、变量
internal	防止 /auth 被直接访问
