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
```conf
set_real_ip_from address | CIDR | unix:;
```
用来控制:哪些代理的 IP 才允许修改<mark>**$remote_addr**</mark>（即真实客户端 IP）
```conf
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
```
X-Forwarded-For: 203.0.113.5
```
**Nginx 配置：**
```
set_real_ip_from 192.168.1.0/24;
real_ip_header X-Forwarded-For;
```
**结果：**
```
remote_addr = 203.0.113.5   （来自可信代理）
```
#### 2.1.3.2 real_ip_header
```conf
real_ip_header field X-Real-IP | X-Forwarded-For | proxy_protocal;
```
<mark>**应该从哪个 HTTP 头部字段里取出真正的客户端 IP**</mark>
#### 2.1.3.2 real_ip_recursive
```conf
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
