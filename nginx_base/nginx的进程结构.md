
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

<img width="617" height="199" alt="image" src="https://github.com/user-attachments/assets/ae54279d-6dcf-45b6-9f3d-f655ec54e505" />



# 3. Nginx进程关系带来的惊群问题

## 3.1 描述
- 多个 worker 进程通过 epoll 监听相同的监听套接字（listen fd），等待新连接到来
- 如果操作系统内核实现不当，一个新连接到来时，所有 worker 都会被唤醒，但最后只有一个 worker 能成功 accept()，其他 worker 执行 accept() 会返回 EAGAIN（资源不可用）
- 大量进程被无谓唤醒，CPU 资源浪费
- 激烈的竞争导致 性能下降（锁竞争、上下文切换增多）

## 3.2 解决方法
### 3.2.1 accept_mutex（accept 锁）
```
events {
    worker_connections 10240;
    use epoll;
    accept_mutex on;    # 默认就是 on
}
```

### 3.2.2 accept_mutex（accept 锁）
