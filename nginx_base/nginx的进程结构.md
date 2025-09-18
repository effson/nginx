
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

部署Nginx时都是使用一个master进程来管理多个worker进程，一般情况下，worker进程的数量与服务器上的CPU核心数相等。每一个worker进程都是繁忙的，它们在真正地提供互联网服务，master进程则很“清闲”，只负责监控管理worker进程。worker进程之间通过共享内存、原子操作等一些进程间通信机制来实现负载均衡等功能

# 2. 进程结构实例演示
```bash
ps -ef | grep nginx
```
