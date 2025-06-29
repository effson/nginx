# 1
```
“referer 模块”实际上指的是 ngx_http_referer_module，这是一个内建的模块，用于基于 $http_referer 请求头做防盗链控制。

🔹 referer 模块的作用
用于防止外部站点直接引用你的资源，例如图片、视频等静态文件。
核心目的是：只有来自你允许的 Referer 的请求，才能访问资源，否则返回 403 或其它自定义响应。

🔹 启用和使用方式
referer 模块默认编译进 Nginx，无需额外安装，只需在配置中使用它的指令。

✅ 关键指令
指令	作用
valid_referers	设置允许访问的引用来源（可匹配多个域名或关键字）
$invalid_referer	内置变量，用于判断当前请求是否为非法引用

🔹 示例：防盗链配置（图片防盗链）
location ~* \.(jpg|jpeg|png|gif|webp)$ {
    valid_referers none blocked *.yourdomain.com www.yourdomain.com;
    
    if ($invalid_referer) {
        return 403;  # 非法引用则拒绝访问
    }

    # 合法引用可访问图片资源
    root /var/www/html;
}
各参数解释：
none：表示没有 Referer 的请求（比如直接输入网址）也被允许。
blocked：表示 Referer 被某些代理或浏览器隐藏（Referer 被清空）也被允许。
*.yourdomain.com：允许从你自己的网站引用图片。
$invalid_referer：为 1 表示不合法（即 Referer 不在白名单中）。

🔹 更强的例子：自定义返回内容
if ($invalid_referer) {
    return 403 "Access Denied: Invalid Referer";
}

或返回一张警告图片：
if ($invalid_referer) {
    rewrite ^ /images/anti_steal.jpg;
}
🔹 日志记录非法访问者
log_format referer_log '[$time_local] $remote_addr tried to access $request_uri with referer: $http_referer';

access_log /var/log/nginx/referer.log referer_log if=$invalid_referer;
✅ 总结
功能	实现方式
防止盗链	valid_referers + $invalid_referer
白名单控制	允许自己的域名或空 Referer
日志记录非法	access_log 搭配 $invalid_referer
```
