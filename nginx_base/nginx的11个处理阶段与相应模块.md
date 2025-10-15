# 1. nginx的11个处理阶段
```c
typedef enum {
    NGX_HTTP_POST_READ_PHASE = 0, // 在接收到完整的HTTP头部后处理的HTTP阶段
	 /*在还没有查询到URI匹配的location前，这时rewrite重写URL也作为一个独立的	
	HTTP阶段	
	*/

    NGX_HTTP_SERVER_REWRITE_PHASE,

    NGX_HTTP_FIND_CONFIG_PHASE,
    NGX_HTTP_REWRITE_PHASE,
    NGX_HTTP_POST_REWRITE_PHASE,

    NGX_HTTP_PREACCESS_PHASE,

    NGX_HTTP_ACCESS_PHASE,
    NGX_HTTP_POST_ACCESS_PHASE,

    NGX_HTTP_PRECONTENT_PHASE,

    NGX_HTTP_CONTENT_PHASE,

    NGX_HTTP_LOG_PHASE
} ngx_http_phases;
```

# 2. 不同阶段的模块
## 2.1 POST_READ：realip
### 2.1.1 realip 模块的必要性
Nginx 实际接收到的连接来自 上游代理服务器（CDN、ELB、SLB、Cloudflare、Nginx反向代理），remote_addr 就变成了代理的 IP，导致：
- access_log 中记录的不是用户真实 IP
- 限速、黑白名单、防火墙等逻辑失效
- WAF、统计模块、地理定位不准确

### 2.1.2 realip 模块的核心作用
<mark>**从 HTTP 头部（如 X-Forwarded-For 或 X-Real-IP）中提取出真实客户端 IP**</mark>

- HTTP 头部 X-Forwarded-For 用于传递IP
- HTTP 头部 X-Real-IP 用于传递用户IP

### 2.1.3 realip 模块命令与使用
#### 2.1.3.1 set_real_ip_from
```nginx
set_real_ip_from address | CIDR | unix:;
```
用来控制:哪些代理的 IP 才允许修改<mark>**$remote_addr**</mark>（即真实客户端 IP）
```nginx
http {
    set_real_ip_from 127.0.0.1;       # 信任本机（如 nginx 反向代理）
    set_real_ip_from 10.0.0.0/8;      # 信任 10.x.x.x 段代理
    set_real_ip_from 192.168.0.0/16;  # 信任 192.168.x.x 段代理
}
```
<mark>**例子**</mark> <br>
**反向代理架构：**
```
Client(203.0.113.5) → Proxy(192.168.1.2) → Nginx
```
**Proxy 添加头：**
```nginx
X-Forwarded-For: 203.0.113.5
```
**Nginx 配置：**
```nginx
set_real_ip_from 192.168.1.0/24;
real_ip_header X-Forwarded-For;
```
**结果：**
```nginx
remote_addr = 203.0.113.5   （来自可信代理）
```
#### 2.1.3.2 real_ip_header
```nginx
real_ip_header field X-Real-IP | X-Forwarded-For | proxy_protocal;
```
<mark>**应该从哪个 HTTP 头部字段里取出真正的客户端 IP**</mark>
#### 2.1.3.2 real_ip_recursive
```nginx
real_ip_recursive on | off;
```
一个请求经过多个反向代理时，通常会形成类似这样的请求头：
```
X-Forwarded-For: 203.0.113.10, 192.168.1.1, 10.0.0.2

[最左边] = 原始客户端 IP
[最右边] = 最后一个代理（即连接 Nginx 的那个）
```
real_ip_recursive off（默认）, Nginx 只取头部中的第一个 IP（即最左边）,多层代理时可能取错 <br>
real_ip_recursive on, 从右往左递归跳过信任代理,适合复杂代理链,稍有性能开销，需正确信任配置


## 2.2 REWRITE ：Rewrite 模块

### 2.2.1 功能
<mark>**实现 rewrite、if、set、return**</mark>等指令。用于修改 URI、变量、条件跳转等

#### 2.2.1.1 return
```nginx
return code [text];
return code URL;
return URL;
```
- code：HTTP 状态码（如 200, 301, 302, 403, 404, 500...）
- text：返回内容（可选）
- URL：重定向目标（相对或绝对）

```nginx
location /old {
    return 301 https://example.com/new;
}
```
code:
- 301 永久重定向
- 302 临时重定向
- 303 临时重定向, 允许改变方法，禁止被缓存
- 307 临时重定向, 不允许改变方法，禁止被缓存
- 308 永久重定向, 不允许改变方法
#### error_page与return
```nginx
error_page code ... [=code] uri;

error_page 404 /404.html;
error_page 500 502 503 504 /50x.html;
error_page 404 =200 /empty.gif;
error_page 403 http://example.com/forbidden.html;
```

```nginx
error_page 404 /403.html

location /test {
	return 404;
}
```
返回 /403.html
```nginx
error_page 404 /403.html

location /test {
	return 404 "find nothing!";
}
```
返回find nothing!


#### 2.2.1.2 rewrite
```nginx
rewrite regex replacement [flag];
```
- regex：匹配当前请求 URI 的正则表达式（不含 query string 部分）
- replacement：匹配成功后要替换成的新 URI，可以包含变量
- flag：控制 rewrite 的行为

flag:
- last: 停止当前 location 的 rewrite，重新查找匹配的 location
- break: 停止 rewrite 指令继续执行，但仍在当前 location 内
- redirect: 发出临时重定向（302）
- permanent: 发出永久重定向（301）

```nginx
location /first {
    rewrite /first(.*)$ /second$1 last;
	return 200 'first!\n';
}

location /second {
    rewrite /second(.*)$ /third$1 break;
	return 200 'second!\n';
}

location /third {
	return 200 'third!\n';
}
```
/first下有1.txt， /second下有2.txt， /third下有3.txt，如果访问/first/3.txt，URI 会改成 /third/3.txt，返回3.txt中的内容<br>
去掉break，则会返回second!

```nginx
location /redirect1 {
    rewrite /redirect1(.*) $1 permanent;
}

location /redirect2 {
    rewrite /redirect2(.*) $1 redirect;
}

location /redirect3 {
    rewrite /redirect3(.*) http://www.google.com$1;
}

location /redirect4 {
    rewrite /redirect4(.*) http://www.google.com$1 permanent;
}

```
#### 2.2.1.3 if
变量是否为空或“0”
```nginx
if ($http_user_agent = "") { ... }      # 空字符串
if ($arg_id = 0) { ... }                # 等于 0
```

变量是否存在（非空、非 0）
```nginx
if ($http_cookie) { ... }               # 存在 cookie
```

字符串比较
```nginx
if ($request_method = POST) { ... }     # 等于 POST
if ($host != example.com) { ... }       # 不等于
```

正则匹配
```nginx
if ($uri ~* \.jpg$) { ... }             # 匹配 jpg 结尾（~* 表示不区分大小写）
if ($uri !~* \.(gif|jpg|png)$) { ... }  # 不匹配这些后缀
```

```
-f  文件存在 !-f 文件不存在
-d  目录存在 !-d 目录不存在
-e  文件或目录存在 !-e 文件或目录不存在
-x  可执行文件存在 !-x 不存在可执行文件
```
