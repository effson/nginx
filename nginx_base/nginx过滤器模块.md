# 1.过滤器模块的位置

<img width="625" height="651" alt="image" src="https://github.com/user-attachments/assets/0454f002-4911-4a53-94c1-928f11346f95" />

# 2.过滤器模块
## 2.1. sub 模块
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
