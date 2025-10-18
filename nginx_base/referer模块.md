# 1.referer模块
## 1.1 模块功能概述
Nginx 的 referer 模块（全称：ngx_http_referer_module），**主要用于 防止“盗链”（Hotlinking），即禁止外部网站直接引用服务器上的图片、视频、下载资源等内容**。<br>
外部网站通过url引用页面，用户在浏览器点击url时，http请求的头部会通过**referer头部**，将该网站当前页面的url带上，告诉服务器本次请求是由这个浏览器页面发起的。<br>

<mark>**核心功能：根据请求头中的 Referer 字段来判断请求来源，允许或拒绝来自特定站点的访问**。</mark>




## 1.2模块加载
- 模块名：<mark>**ngx_http_referer_module**</mark>
- 类型：HTTP访问控制模块
- 默认已内置，无需 --with- 参数
- 所属阶段：<mark>**ACCESS**</mark>


## 1.3 主要指令

### 1.3.1 valid_referers
指定允许访问的 Referer 来源规则。告诉 Nginx 哪些来源的请求被认为是“合法”的。

#### 语法

```nginx
valid_referers none | blocked | server_names | string ...;
```
- none：没有 Referer 头的请求视为合法（直接访问）
- blocked：Referer 存在但被防火墙或代理隐藏（不是以 http/https 开头）
- server_names：允许本服务器配置的所有 server_name 域名
- string：明确列出允许的域名（可带通配符）

#### $invalid_referer 变量
判断当前请求的 Referer 是否非法：
- **1 → 非法 Referer**
- **空字符串 → 合法 Referer**

```nginx
location / {
    valid_referers none blocked server_names *.mydomain.com mycdn.net;

    if ($invalid_referer) {
        return 403;
    }

    return 200 'valid\n';
}
```
#### 示例
```nginx
valid_referers none blocked server_names *.mydomain.com mycdn.net;
```
表示：
- 无 Referer：允许；
- Referer 被代理隐藏：允许；
- Referer 是本域名（如 www.mydomain.com）：允许；
- Referer 是 mycdn.net 或其子域：允许；
- 其他来源：视为非法。




### 1.3.2 referer_hash_bucket_size & referer_hash_max_size
用于控制该模块内部用于匹配合法 Referer 域名的哈希表（hash table）的大小和内存分配行为
```nginx
referer_hash_bucket_size size; # 单位：字节
referer_hash_max_size size;
```


# 2. secure_link 模块
Nginx 内置的一个 **安全防盗链和防篡改访问控制模块**。

## 2.1 模块功能概述
secure_link 模块通过对 URL 或参数中的签名字段进行校验（验证URL中的哈希值），确认该链接是由服务器合法生成的，而不是外部伪造。若校验失败，则拒绝访问（返回 403）。

- 防止 URL 被恶意分享（防盗链）
- 控制下载链接的有效期（限时访问）
- 校验文件访问权限（防篡改）
- 提供安全的 CDN 文件分发

## 2.2 模块原理
Nginx 在收到请求时：
- 1️⃣ 从请求中提取特定参数（例如 $arg_md5, $arg_expires, $uri 等）
- 2️⃣ 根据配置计算一个 本地哈希值（通过 MD5 或 HMAC-MD5）
