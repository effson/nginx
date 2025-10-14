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
