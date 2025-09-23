# 1. 模块化设计
## 1.1 ngx_module_t
所有的模块都遵循着同样的<mark>ngx_module_t</mark>的接口设计规范，接口足够简单，只涉及模块的初始化、退出以及对配置项的处理

```c
struct ngx_module_s {
    ngx_uint_t            ctx_index;
    ngx_uint_t            index;
    char                 *name;

    ngx_uint_t            spare0;
    ngx_uint_t            spare1;

    ngx_uint_t            version;
    const char           *signature;

    void                 *ctx;  /* 每种模块将具体化ctx上下文*/
    ngx_command_t        *commands;
    ngx_uint_t            type;

    /* 模块初始化、退出以及对配置项处理*/
    ngx_int_t           (*init_master)(ngx_log_t *log);
    ngx_int_t           (*init_module)(ngx_cycle_t *cycle);
    ngx_int_t           (*init_process)(ngx_cycle_t *cycle);
    ngx_int_t           (*init_thread)(ngx_cycle_t *cycle);
    void                (*exit_thread)(ngx_cycle_t *cycle);
    void                (*exit_process)(ngx_cycle_t *cycle);
    void                (*exit_master)(ngx_cycle_t *cycle);

    uintptr_t             spare_hook0;
    uintptr_t             spare_hook1;
    uintptr_t             spare_hook2;
    uintptr_t             spare_hook3;
    uintptr_t             spare_hook4;
    uintptr_t             spare_hook5;
    uintptr_t             spare_hook6;
    uintptr_t             spare_hook7;
};
```

ngx_module_t结构体作为所有模块的通用接口，它只定义了<mark>**init_master、init_module、init_process、init_thread、exit_thread、exit_process、exit_master**</mark>这7个回调方法。<br>
可以看出系统的核心结构体为<mark>**ngx_cycle_t**</mark>

### 1.1.1 ngx_uint_t type
标识了该模块的 类型（Type）

```c
#define NGX_CORE_MODULE           0x45524F43  /* "CORE" */
#define NGX_CONF_MODULE           0x464E4F43  /* "CONF" */
#define NGX_HTTP_MODULE           0x50545448  /* "HTTP" */
#define NGX_EVENT_MODULE          0x544E5645  /* "EVNT" */
#define NGX_MAIL_MODULE           0x4C49414D  /* "MAIL" */
#define NGX_STREAM_MODULE         0x4d525453  /* "STRM" */
```

### 1.1.2 void *ctx

<mark>ctx 是 “模块上下文”，不同类型的模块会用不同的结构体去解释它。相当于一个 桥梁把 Nginx 框架核心和具体模块实现联系起来</mark>

### 1.1.3 ngx_command_t *commands
<mark>ngx_command_t *commands 是 Nginx 模块与配置文件（nginx.conf）交互的关键，ngx_command_t类型的commands数组指定了模块处理配置项的方法</mark>

```c
struct ngx_command_s {
    ngx_str_t             name;
    ngx_uint_t            type;
    char               *(*set)(ngx_conf_t *cf, ngx_command_t *cmd, void *conf);
    ngx_uint_t            conf;
    ngx_uint_t            offset;
    void                 *post;
};

```
每个模块可以通过一个 ngx_command_t commands[] 数组来描述自己支持的配置指令

#### ngx_str_t name
指令名称。例如 "listen"、"location"、"proxy_pass"。
解析配置文件时，读到对应指令名就会查找模块的 commands 表

#### ngx_uint_t type
指令出现的位置（上下文），以及参数个数限制

```c
NGX_HTTP_MAIN_CONF   // http{} 内的 main 级别
NGX_HTTP_SRV_CONF    // server{} 块
NGX_HTTP_LOC_CONF    // location{} 块
NGX_CONF_TAKE1       // 接受 1 个参数
NGX_CONF_TAKE2       // 接受 2 个参数
NGX_CONF_FLAG        // on/off
```


```c
typedef struct {
    ngx_str_t             name;
    void               *(*create_conf)(ngx_cycle_t *cycle);
    char               *(*init_conf)(ngx_cycle_t *cycle, void *conf);
} ngx_core_module_t;
```
