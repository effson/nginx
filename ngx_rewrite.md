# 0 rewrite阶段
在 Nginx 的请求处理流程中，**rewrite 阶段（重写阶段）**是非常重要的一环。它主要用于：<br>

修改请求的 URI（统一资源标识符）<br>

进行内部重定向<br>
<br>
控制访问流程（比如结合 return、break、rewrite 指令）<br>
