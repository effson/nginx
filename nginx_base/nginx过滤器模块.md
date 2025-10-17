# 1.过滤器模块的位置

<img width="625" height="651" alt="image" src="https://github.com/user-attachments/assets/0454f002-4911-4a53-94c1-928f11346f95" />

# 2.过滤器模块
## 2.1 sub 模块
ngx_http_sub_module（sub 过滤器模块），是 Nginx 自带的一个 响应内容替换模块
### 2.1.1 sub_filter
设置要在响应内容中查找并替换的字符串
```nginx
sub_filter string replacement;
```
示例：
```nginx
location / {
    proxy_pass http://backend;
    sub_filter 'http://old.example.com' 'https://new.example.com';
    sub_filter_once off;
}
```
访问 / 时如果后端返回的 HTML 含有：
```html
<a href="http://old.example.com/page1">link</a>
```
→ 客户端实际收到：
```html
<a href="https://new.example.com/page1">link</a>
```
### 2.1.2 sub_filter_once
控制每个响应体中，是否只替换第一个匹配项。
```nginx
sub_filter_once on | off; # 默认值：on
```

### 2.1.3 sub_filter_last_modified
控制在执行内容替换后，是否保留原响应头中的 Last-Modified

```nginx
sub_filter_last_modified on | off;
```
## 2.2 addition 模块
在主响应内容的前面或后面附加额外的内容
### 2.2.1 add_before_body
```nginx
add_before_body uri;
```

### 2.2.2 add_after_body
```nginx
add_after_body uri;
```

### 2.2.3 addition_types
```nginx
addition_types mime-type ...; # 默认addition_types text/html;
```

### 示例
```nginx
server {
    listen 8080;
    server_name localhost;

    location / {
        root /data/www;

        # 在 HTML 内容前后追加页眉和页脚
        add_before_body /header.html;
        add_after_body /footer.html;

        # 仅对 text/html 类型生效
        addition_types text/html;
    }

    # header.html 子请求
    location = /header.html {
        root /data/common;
    }

    # footer.html 子请求
    location = /footer.html {
        root /data/common;
    }
}
```
最终输出：
```php-template
<header.html 内容>
<index.html 内容>
<footer.html 内容>
```
