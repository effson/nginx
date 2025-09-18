
# 1. 进程间关系

```arduino
+-------------------+
|   Master Process  |  ← 1 个，负责管理
+-------------------+
        |
        | fork
        v
+-------------------+     +-------------------+     +-------------------+
|   Worker Process  | ... |   Worker Process  | ... |   Worker Process  |
+-------------------+     +-------------------+     +-------------------+
      | epoll 事件驱动，每个 Worker 可以同时处理成千上万个连接
```
如果启用缓存：
```arduino
Master
  ├── Worker 1
  ├── Worker 2
  ├── ...
  ├── Cache Manager
  └── Cache Loader   # 为反向代理时后端发来的请求做缓存使用
```
