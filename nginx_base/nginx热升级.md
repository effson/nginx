# 替换二进制
替换 /sbin/nginx为新的可执行二进制文件

# Master 进程重新加载新二进制
```bash
kill -USR2 $(cat /home/jeff/nginx/logs/nginx.pid)
```
# 优雅关闭旧 Worker
彻底结束旧进程树
```bash
kill -QUIT $(cat /home/jeff/nginx/logs/nginx.pid.oldbin)
```
<br>
WINCH：只停掉 Worker，Master 保留（便于回滚）
```bash
kill -WINCH $(cat /home/jeff/nginx/logs/nginx.pid.oldbin)
```
