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



