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

## 2.3 FIND_CONFIG阶段
### 2.3.1 location
```nginx
server {
    location = /exact          { ... }   # 精确匹配优先
    location /prefix/          { ... }   # 普通前缀匹配
    location ~ \.php$          { ... }   # 正则匹配  ~大小写敏感
    location /                 { ... }   # 通配（默认）
}

location [=|~|~*|^~] pattern {
    # 指令...
}
```
#### 2.3.1.1 location的匹配规则
```
（无符号）   普通前缀匹配   			请求 URI 以 pattern 开头即可匹配
=           精确匹配请求    			URI 必须完全等于 pattern
^~			优先前缀匹配	   			请求 URI 以 pattern 开头，则不再检查正则匹配
~			正则匹配（区分大小写）	pattern 被当作正则表达式匹配 URI
~*			正则匹配（不区分大小写）	同上，忽略大小写
```
```
请求 URI → 检查：
   │
   ├─ 是否有 “=” 精确匹配？
   │     └─ 有 → 立即使用
   │
   ├─ 否则，查找所有前缀匹配（/api, /static, /）
   │     ├─ 若匹配 ^~，立即使用（不再匹配正则）
   │     └─ 若仅普通前缀，暂时记录最长匹配
   │
   ├─ 检查是否有正则匹配（~、~*）
   │     ├─ 若匹配，使用第一个命中的正则 location
   │     └─ 若无正则命中，使用上一步最长前缀匹配
   │
   └─ 匹配结束
```
## 2.4 PREACCESS阶段
### 2.4.1 ngx_http_limit_conn_module
用于限制客户端并发连接数，<mark>**在access 阶段之前**</mark>，用于防止连接过多的并发请求
#### 2.4.1.1 limit_conn_zone
定义共享内存区域，用来保存连接状态（必须先定义）
```nginx
limit_conn_zone key zone=name:size; # http
# key: 决定 “Nginx 按什么维度统计并发连接数”
```

#### 2.4.1.2 limit_conn
指定每个 key 的最大连接数
```nginx
limit_conn zone_name number; # http server location
```

#### 2.4.1.3 limit_conn_log_level
控制超出限制时的日志级别
```nginx
limit_conn_log_level info | notice | warn | error;  # 默认值：error
```

#### 2.4.1.4 limit_conn_status
控制超限时返回的 HTTP 状态码（默认 503）

```nginx
http {
    # 定义共享内存区域
    limit_conn_zone $binary_remote_addr zone=addr_limit:10m;

    server {
        listen 80;
        server_name example.com;

        # 每个 IP 同时最多允许 2 个连接
        limit_conn addr_limit 2;

        # 记录日志级别
        limit_conn_log_level warn;

        # 超限时返回 429 而不是 503
        limit_conn_status 429;

        location / {
            root /var/www/html;
        }
    }
}
```
### 2.4.2 ngx_http_limit_req_module

#### 2.4.2.1 limit_req_zone
定义限速共享内存区域及统计 key

```nginx
limit_req_zone key zone=name:size rate=rate; # http
```
- key: 统计限速的分组依据（如 $binary_remote_addr、$server_name）
- zone=name: size 定义共享内存区域名称和大小
- rate=rate: 允许的平均速率（格式：r/s 或 r/m）

#### 2.4.2.2 limit_req
```nginx
limit_req zone=name [burst=number] [nodelay];
```
- burst=number: 允许的请求突发数（缓冲）
- nodelay : 不延迟请求；超出 rate + burst 的请求立即拒绝,立即返回错误（默认 503）

#### 2.4.2.3 limit_req_log_level
设置日志级别
```nginx
limit_req_log_level info | notice | warn | error; # 默认值：error
```
#### 2.4.2.4 limit_req_status
设置超限返回状态码
```nginx
limit_req_status code; # 默认值 503
```

limit_req 先执行，limit_conn 后执行

## 2.5 ACCESS阶段
### 2.5.1 ACCESS：ngx_http_access_module模块
基于 IP 地址控制访问
#### 2.5.1.1 allow
```nginx
allow address | CIDR | unix: | all;
```

#### 2.5.1.1 deny
```nginx
deny  address | CIDR | unix: | all;
```

### 2.5.2 ACCESS：ngx_http_auth_basic_module模块
基于用户名/密码认证
#### 2.5.2.1 auth_basic
auth_basic：定义认证提示文字；
```nginx
auth_basic string; # string为显示给用户的信息
```
#### 2.5.2.2 auth_basic_user_file
定义用户名/密码文件（Apache htpasswd 格式）
```nginx
auth_basic_user_file file;
```
生成htpasswd文件:
```bash
apt install apache2-utils -y
htpasswd -c /home/jeff/nginx/.htpasswd jeff
```
### 2.5.3 ACCESS：ngx_http_auth_request_module模块
与 auth_basic 不同，不直接校验用户名密码，通过子请求机制（subrequest），把认证逻辑交给上游服务来完成
#### 2.5.3.1 auth_request

```nginx
auth_request uri | off;
```
- uri ：指定用于认证的内部子请求路径（内部 location）

#### 2.5.3.2 auth_request_set
用于从子请求的响应中提取变量（header 或 body 值），以便在主请求中使用（例如传给后端）。
```nginx
auth_request_set $variable value;
```

```nginx
# 定义认证子请求
location = /auth {
    proxy_pass http://auth_backend/verify;       # 请求认证服务
    proxy_pass_request_body off;                 # 不转发请求体
    proxy_set_header Content-Length "";          # 清空 Content-Length
    proxy_set_header X-Original-URI $request_uri; # 传递原始URI
}

# 主服务 location
location /api/ {
    auth_request /auth;                          # 认证检查
    auth_request_set $auth_user $upstream_http_x_user;
    proxy_set_header X-User $auth_user;          # 向后端传递用户信息
    proxy_pass http://backend_app;
}
```
### 2.5.4 satisfy指令
决定了多种访问限制之间是 AND（必须全部满足），还是 OR（任意满足一个即可）
```nginx
satisfy all | any;
```
- all ：所有访问控制条件都必须通过（默认）
- any ：只要任意一个条件通过就放行

## 2.6 PRECONTENT阶段
### 2.6.1 PRECONTENT：try_files 模块
按顺序检测一组“候选文件/目录”是否存在；一旦命中，就内部重定向到相应 URI（或直接返回状态码）。常用于“静态优先、失败再走后端”的路由策略。
```nginx
try_files file1 file2 ... final;
```
- fileN：按顺序测试是否存在（相对当前 root/alias 的物理路径；可以用变量，如 $uri、$uri/
- final：以 = 开头的状态码：找不到任何候选时，直接返回该码（如 =404、=403）
```nginx
location / {
    try_files $uri $uri/ =404;
}
```
### 2.6.2 PRECONTENT：mirror 模块
在不影响主请求正常处理的前提下，异步“复制”一份请求发送到其他服务器（或 location）去执行
#### 2.6.2.1 mirror
指定要镜像的目标 URI（可多个）
```nginx
mirror uri | off;
```
#### 2.6.2.2 mirror_request_body
控制是否将主请求的请求体（body）转发到镜像请求
```nginx
mirror_request_body on | off;
```

```nginx
location /api/ {
    mirror /mirror;                    # 将请求复制到 /mirror
    mirror_request_body on;            # 同步发送请求体
    proxy_pass http://main_backend;    # 主请求照常处理
}

location = /mirror {
    internal;                          # 只允许内部请求
    proxy_pass http://mirror_backend;  # 镜像目标服务
}
```
