# 0 概述<br>
limit_conn 是 Nginx 中用于限制并发连接数的指令，它配合 limit_conn_zone 使用，属于 ngx_http_limit_conn_module。<br>
limit_conn 用于限制某个“key”（如 IP）对应的活动连接数，例如限制每个客户端 IP 最多同时建立 1 个连接。<br>

# 1 基本语法limit_conn_zone<br>
## 1.1 简介
#### Nginx中用于连接数限制（concurrent connections）的配置指令，
#### 属于 ngx_http_limit_conn_module 模块<br>
#### 限制单个客户端 IP 的连接数（防止慢连接攻击）<br>
#### 限制某类用户、域名、接口的并发连接数<br>
## 1.2 基本语法<br>
 ```limit_conn_zone key zone=name:size;``` <br>
 key：限制的单位，如 ```$binary_remote_addr```（客户端 IP）<br>
 ```zone=name:size```：共享内存区的名字和大小，例如 ```zone=addr:10m``` <br>
#### ⚠️ 注意：这个指令 只能放在 http 块中<br>
## 1.3 示例：限制每个 IP 同时最多 1 个连接<br>
```
http {<br>
    # 创建一个共享内存区域 addr，每个 IP 限制连接数
    limit_conn_zone $binary_remote_addr zone=addr:10m;

   server {
        listen 80;

        location / {
        # 应用上面的区域，每个 IP 最多 1 个连接
            limit_conn addr 1;
        }
    }
}
```
#### 1.3.1 ```$binary_remote_addr```<br>
是二进制格式的 IP 地址，比 $remote_addr 更紧凑、内存占用更少，推荐使用<br>
#### 1.3.2 ```zone=addr:10m```<br>
创建一个名为 addr 的共享内存区，大小为 10MB，可大约容纳 16 万条连接状态记录<br>
#### 1.3.3 ```limit_conn addr 1```<br>
在某个 location 或 server 中，使用 limit_conn 应用前面定义的区域<br>
限制每个 key（这里是 IP）最多 1 个活动连接<br>
# 总结表<br>
## ```limit_conn_status 429;```  <br>         
### 限制时返回 ```429``` 状态码（可选）<br>
