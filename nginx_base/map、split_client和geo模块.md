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

<mark>** **</mark>
# 3. geo 模块（ngx_http_geo_module）
## 3.1 作用
<mark>**按客户端 IP（CIDR 或区间）映射到变量值**</mark>，常用于白/黑名单、按网段开关、区域路由等
## 3.2 语法
```nginx
geo $var {
    default 0;                     # 兜底值
    127.0.0.1         1;           # 单个地址
    10.0.0.0/8        1;           # CIDR
    2001:db8::/32     1;           # IPv6 CIDR
    # 开区间匹配模式（可选）
    # ranges;
    # 192.168.1.1-192.168.1.100  1;

    include conf/ip_whitelist.conf; # 可拆分外部文件
}
```
## 3.3 示例
```nginx
geo $country {
    default CN;                     # 兜底值
    127.0.0.0/24         UK;           # 单个地址
    127.0.0.1/32         RU;
    10.1.0.0/16          US;           # CIDR
    2001:db8::/32        AUS;           # IPv6 CIDR
    # 开区间匹配模式（可选）
    # ranges;
    # 192.168.1.1-192.168.1.100  1;
}

server {
        server_name example.com;
        default_type text/plain;
        location / {
            return 200 '$country\n';
        }
} 

```
- 测试使用：```curl -H 'X-Forwarded-For: 10.1.0.0, 127.0.0.1, 192.168.1.123' example.com/```


# 3. geoip 模块（ngx_http_geoip_module）
根据客户端 IP，从本地 GeoIP 数据库中查询：
- 所属国家（country）
- 省份/州（region）
- 城市（city）
- 纬度、经度、时区等信息

## 3.1 语法与配置

```nginx
http {
    geoip_country /etc/nginx/geoip/GeoIP.dat;        # 国家库
    geoip_city    /etc/nginx/geoip/GeoLiteCity.dat;  # 城市库
}
```
#### 可用变量
```
$geoip_country_code	两位国家码（CN、US 等）
$geoip_country_name	国家名（China、United States）
$geoip_region	省/州代码
$geoip_city	城市名
$geoip_latitude / $geoip_longitude	纬度 / 经度
$geoip_area_code	电话区号
$geoip_region_name	省/州名
$geoip_postal_code	邮政编码
$geoip_continent_code	洲代码
```
