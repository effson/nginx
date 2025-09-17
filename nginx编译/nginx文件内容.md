# 目录结构

<img width="489" height="255" alt="image" src="https://github.com/user-attachments/assets/1e4533d6-574e-45c2-a7c7-5b7f8aaa976f" />

## auto
存放 configure 使用的 自动化脚本，负责检测编译器特性、系统库、模块依赖

<img width="449" height="383" alt="image" src="https://github.com/user-attachments/assets/10d98d9f-fca4-4110-a26d-767d314882a2" />

## conf

默认的配置文件目录，包含 nginx.conf、fastcgi.conf、mime.types 等，一般在源码安装后会被拷贝到 /usr/local/nginx/conf/

<img width="413" height="188" alt="image" src="https://github.com/user-attachments/assets/cdcc979d-3490-4eed-9722-2e541fdfe4dc" />

## contrib
一些额外的工具、脚本和示例配置， 比如 vim 的语法高亮文件、systemd 服务脚本

## html
默认的网页目录，里面通常有 index.html 和 50x.html（错误页）， 编译安装后会拷贝到 /usr/local/nginx/html/

<img width="391" height="89" alt="image" src="https://github.com/user-attachments/assets/3174d406-fb57-4930-a4b9-f033d2fc8e27" />

## man
Nginx 的手册页（man pages），安装时会复制到系统 /usr/share/man/man8/nginx.8

<img width="377" height="73" alt="image" src="https://github.com/user-attachments/assets/2306bef0-e32e-4d23-a5e1-128d351b4673" />

## src
Nginx 的核心源码目录

<img width="383" height="157" alt="image" src="https://github.com/user-attachments/assets/3b0f6f59-8146-453a-b2e3-6a28708c3aeb" />


