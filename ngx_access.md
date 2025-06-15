在 Nginx 的 HTTP 请求处理流程中，access 阶段（NGX_HTTP_ACCESS_PHASE）是用于权限控制的关键阶段
# access 阶段主要用于判断当前请求是否允许访问，常用于 IP 黑白名单、用户认证、ACL（访问控制列表）等操作。
