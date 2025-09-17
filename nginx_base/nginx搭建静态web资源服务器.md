# 资源准备
index.html

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>欢迎访问我的 Nginx 静态站点</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <h1>Hello, Nginx!</h1>
    <p>这是一个通过 Nginx 搭建的静态 Web 服务器。</p>
    <p><a href="about.html">关于本站</a></p>
    <img src="images/logo.png" alt="Logo" width="200">
</body>
</html>

```

about.html

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>关于本站</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <h1>关于本站</h1>
    <p>本网站由 <strong>Nginx</strong> 提供服务。</p>
    <p><a href="index.html">返回首页</a></p>
</body>
</html>

```
css/style.css

```css
body {
    font-family: Arial, sans-serif;
    background-color: #f4f6f8;
    color: #333;
    margin: 40px;
}

h1 {
    color: #0066cc;
}
a {
    color: #ff6600;
    text-decoration: none;
}
a:hover {
    text-decoration: underline;
}
```
images/logo.png
