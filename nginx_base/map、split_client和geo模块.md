# 1. map 模块（ngx_http_map_module）
## 1.1 作用
按“键→值”规则把一个源变量映射为一个目标变量；可做条件开关、AB 分组标记、选择上游名、日志采样开关等。匹配支持精确、通配主机名、正则与默认值，性能好（哈希表）。
## 1.2 基本语法

```nginx
# 在 http { } 顶层定义
map $source_var $dest_var {
    default   <value>;          # 没有其他匹配时的兜底
    ""        <value>;          # 源变量为空字符串时
    <string>  <value>;          # 精确匹配
    ~<regex>  <value>;          # 正则匹配（区分大小写）
    ~*<regex> <value>;          # 正则（不区分大小写）
}

# 可选的哈希参数（调大以容纳更多键）
map_hash_bucket_size  64;
map_hash_max_size     4096;
```

## 1.3 示例
### 1.3.1 依据域名选上游（带主机名通配）
```nginx
map $host $backend {
    default                main_pool;
    .img.example.com       img_pool;     # 匹配 a.img.example.com 等
    video.example.com      video_pool;
}
upstream main_pool { ... }
upstream img_pool  { ... }
upstream video_pool{ ... }

server {
    location / { proxy_pass http://$backend; }
}
```

### 1.3.2 按 UA 标记是否移动端：

```nginx
map $http_user_agent $is_mobile {
    default   0;
    ~*"(iphone|android|ipad|mobile)" 1;
}
```

### 1.3.3 使用 hostnames 参数（用于主机名匹配）

```nginx
http {
    map $http_host $value {
        hostnames;         # 启用主机名优化匹配

        default            0;

        example.com        1;
        *.example.com      1;  # 匹配所有子域名（如 a.example.com）
        .example.net       2;  # 匹配 example.net 及其所有子域名
    }
    
    server {
        # ... 在 proxy_cache_key 中使用 $cache_key_prefix
        listen 10001;
        default_type text/plain;
        location / {
            return 200 '$value';
        }
    }
}
```

<mark>** **</mark>

# 2. split_clients模块（ngx_http_split_clients_module）
## 2.1 作用
- <mark>**A/B 测试 Split Testing**</mark>：将用户流量按比例分割成不同的组（如 A 组和 B 组），每组用户访问不同的内容、页面布局或后端服务，以评估不同版本的效果
- <mark>**渐进式发布/金丝雀发布 Canary Deployment**</mark>：将一小部分（如 1% 或 5%）的真实用户流量路由到一个新的后端服务版本上，在小范围内验证新版本的稳定性和性能
- <mark>**持续性分组**</mark>：这是其核心功能。它通过对一个输入字符串（如 $remote_addr 或自定义 Cookie）进行 哈希（MurmurHash2） 运算，确保同一个客户端（只要其输入字符串不变）每次都会被分配到同一个组中。这对于保证用户体验和测试结果的准确性至关重要

## 2.2 语法

```nginx
split_clients $key $var {
    10%    "canary";     # 前 10%
    20%    "beta";       # 接下来 20%（累计到 30%）
    *      "stable";     # 其余（必须有 * 兜底）
}
```

- $key：最常用<mark>**$remote_addr**</mark> (客户端 IP 地址),
- 百分比为累进区间；顺序重要；总和不必等于 100%，剩余由 * 接住

## 2.3 示例
```nginx
split_clients $http_test1 $var {
    10%    .ten;          # 前 10%
    20%    .twenty;       # 接下来 20%（累计到 30%）
    *      "";            # 其余（必须有 * 兜底）
}

server {
        server_name example.com;
        default_type text/plain;
        location / {
            return 200 'test1$var\n';
        }
} 
```
- 测试使用：
```curl -H 'test1: 35465467gdfgdfg' example.com/```
