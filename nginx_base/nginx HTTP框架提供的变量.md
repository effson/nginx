# 1. Nginx变量：HTTP请求相关变量

## (一)
### 1.1.1 $arg_参数名
```pgsql
http://example.com/index.html?id=10&user=jeff&debug=1
```
Nginx 会自动解析 ? 之后的查询字符串：
```ini
id=10
user=jeff
debug=1
```
生成一组变量：
```
变量名	    值
$args	    id=10&user=jeff&debug=1
$arg_id	    10
$arg_user	jeff
$arg_debug	1
```
### 1.1.1 $query_string
户端原始请求行中的查询字符串部分（不含 ?），与$args相同

### 1.1.2 $args
查询字符串部分，即 URL 中 ? 后面的参数，不包括 ? 本身

### 1.1.3 $is_args
? 或 空 , 若存在参数则为 ?，否则为空

### 1.1.4 $content_length
HTTP请求中标识包体长度的Content-Length头部的值

### 1.1.5 $content_type
标识请求包体内容类型的Content-type头部的值

## (二)

### 1.1.6 $document_uri
与 $uri 相同

### 1.1.7 $uri
当前请求的 URI 路径部分，不包含查询字符串（?后面的参数）

### 1.1.8 $request_uri
客户端原始请求 URI（包含uri和参数）

### 1.1.9 $scheme
协议，http 或 https

### 1.1.10 $request_method
请求方法（GET/POST/PUT/DELETE 等）
示例：
```nginx
if ($request_method = POST) {
    proxy_pass http://backend_post;
}
```

### 1.1.11 $request_length
请求报文总长度（包括请求行、请求头和请求体的总和，单位：字节）

### 1.1.12 $remote_user
HTTP Basic Authentication 协议传入的用户名

## (三)

### 1.1.13 $request_body_file
当前请求体被 Nginx 临时存放的文件路径.也就是说，当 Nginx 把请求体写入临时文件后，这个变量保存了文件的完整路径，方便其他模块（或上游）读取
- 如果包体非常小则不会存文件
- client_body_in_file_only会强制所有包体存入文件，可决定是否删除

### 1.1.14 $request_body

$request_body 表示 当前请求的请求体数据（字符串形式），仅当请求体在内存中缓存时才会有值。


### 1.1.15 $request
HTTP 请求报文的第一行叫做 请求行（Request Line），该变量为客户端请求行（Request Line）完整文本

```pgsql
GET /index.html?user=jeff HTTP/1.1
POST /api/login HTTP/2
```
## (四)

### 1.1.16 $host
#### 优先级顺序（从高到低）：
1️⃣ 从HTTP 请求行中获取 
```nginx
GET http://www.jeffweb.com/index.html HTTP/1.0
```
2️⃣ HTTP 请求头中的 Host 字段（若存在）

```
GET / HTTP/1.1
Host: www.jeffweb.com
```
$host = www.jeffweb.com,替换请求行中的主机名 <br>

3️⃣ 匹配该请求的 server_name<br>
请求中没有 Host 头部，或者 Host 头部值为空，Nginx 将会使用配置中与该请求匹配的 server 块的 server_name（即配置的第一个服务器名称）

## (五)

### 1.1.17 $http_头部名字
```nginx
$http_host
$http_user_agent
$http_x_forwarded_for
$http_referer
$http_cookie
$http_via
```
返回相应的头部的值
