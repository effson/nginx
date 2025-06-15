# 0 rewrite概述
在 Nginx 的请求处理流程中，**rewrite 阶段（重写阶段）**是非常重要的一环。它主要用于：<br>

修改请求的 URI（统一资源标识符）<br>

进行内部重定向<br>
<br>
控制访问流程（比如结合 return、break、rewrite 指令）<br>
# 1.rewrite 阶段做什么<br>
## 1.1 修改 URI<br>
<br>
location /old {<br>
&nbsp;&nbsp;&nbsp;&nbsp;    rewrite ^/old/(.*)$ /new/$1 break;<br>
}<br>
这个规则将 /old/foo 改写为 /new/foo。<br>
<br>

## 1.2 内部跳转（internal redirect）<br>
使用 rewrite 后可以跳转到新的 URI，重新走一次 location 匹配。<br>
<br>
rewrite ^/foo$ /bar;<br>
这会让请求 /foo 变为 /bar，重新匹配 location。<br>
<br>
## 1.3 结合 ```break/last/redirect/permanent```<br>
### ```break```：停止 rewrite 阶段，继续在当前 location 内执行后续处理。<br>
### ```last```：重新走一次 location 匹配。<br>
### ```redirect```：返回 302。<br>
### ```permanent```：返回 301。<br>
<br>

# 2.rewrite 指令生效位置<br>
<br>

## ```server``` 块中<br>

## ```location``` 块中<br>

## ```if``` 块中<br>

## 不能出现在 http 块中。<br>
<br>

# 3.示例说明<br>
```
server {
    listen 80;
    server_name example.com;

    location / {
        rewrite ^/foo/(.*)$ /bar/$1 break;
        proxy_pass http://backend;
    }

    location /bar {
       return 200 'Hello from /bar!';
    }
}
```
访问 ```http://example.com/foo/test``` 时：<br>
<br>
URI 被 rewrite 改成``` /bar/test```<br>
<br>
rewrite 使用 break，不重新匹配 location<br>
<br>
最终仍在 / 匹配中，转发给后端<br>
<br>
# 4.rewrite模块和阶段的关系<br>
Nginx 的 ngx_http_rewrite_module 模块是在 rewrite 阶段工作的，它注册了``` NGX_HTTP_REWRITE_PHASE ```的 handler。<br>
这个阶段执行顺序早于 access 阶段，也早于 content 阶段，因此非常适合做前置处理。<br>
<br>

