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
#### set回调函数
Nginx 解析到该指令时调用，用来写入配置

```c
char *set(ngx_conf_t *cf, ngx_command_t *cmd, void *conf);
```

返回 NGX_CONF_OK 表示解析成功，返回错误字符串表示失败

#### conf 和 offset
conf 表示在哪一级配置（main/srv/loc），offset 表示该配置在配置结构体中的偏移量，框架会根据这两个值，把参数写到对应模块的配置结构体里

## 1.2 ngx_core_module_t
<mark>Nginx定义了一种基础类型的模块：核心模块，它的模块类型叫做NGX_CORE_MODULE</mark> <br>
定义核心模块,可以简化Nginx的设计，使得非模块化的框架代码只关注于如何调用6个核心模块（大部分Nginx模块都是非核心模块）,它们虽然功能不同，但都需要：
- 提供一个函数来 创建配置结构体（存放配置项）
- 提供一个函数来 初始化配置（默认值/合法性检查）

### struct ngx_core_module_t
```c
typedef struct {
    ngx_str_t             name;
    void               *(*create_conf)(ngx_cycle_t *cycle);
    char               *(*init_conf)(ngx_cycle_t *cycle, void *conf);
} ngx_core_module_t;
```

#### ngx_str_t name
模块名称，比如<mark> "core", "events", "http", "mail"</mark>。用来标识和查找配置块

#### create_conf

用来分配、初始化该模块的配置结构体。例如在解析 events {} 配置块时，会调用 events 模块的 create_conf 来准备存储配置的内存

#### init_conf
在解析完配置文件后，对配置进行进一步的初始化或检查。比如：如果用户没写某些参数，就填充默认值；检查配置项是否合法

### 以事件event模块为例

<mark>**event模块**</mark>

####  1. ngx_module_t  ngx_events_module
```c
ngx_module_t  ngx_events_module = {
    NGX_MODULE_V1,
    &ngx_events_module_ctx,                /* module context */
    ngx_events_commands,                   /* module directives */
    NGX_CORE_MODULE,                       /* module type */
    NULL,                                  /* init master */
    NULL,                                  /* init module */
    NULL,                                  /* init process */
    NULL,                                  /* init thread */
    NULL,                                  /* exit thread */
    NULL,                                  /* exit process */
    NULL,                                  /* exit master */
    NGX_MODULE_V1_PADDING
};
```

####  2. ngx_command_t ngx_events_commands[]

```c
static ngx_command_t  ngx_events_commands[] = {

    { ngx_string("events"),
      NGX_MAIN_CONF|NGX_CONF_BLOCK|NGX_CONF_NOARGS,
      ngx_events_block,
      0,
      0,
      NULL },

      ngx_null_command
};
```

####  3. ngx_core_module_t ngx_events_module_ctx

```c
static ngx_core_module_t  ngx_events_module_ctx = {
    ngx_string("events"),
    NULL,
    ngx_event_init_conf
};
```

<mark>**event核心 core 模块**</mark>

#### 1. ngx_module_t ngx_event_core_module

```c
ngx_module_t  ngx_event_core_module = {
    NGX_MODULE_V1,
    &ngx_event_core_module_ctx,            /* module context */
    ngx_event_core_commands,               /* module directives */
    NGX_EVENT_MODULE,                      /* module type */
    NULL,                                  /* init master */
    ngx_event_module_init,                 /* init module */
    ngx_event_process_init,                /* init process */
    NULL,                                  /* init thread */
    NULL,                                  /* exit thread */
    NULL,                                  /* exit process */
    NULL,                                  /* exit master */
    NGX_MODULE_V1_PADDING
};
```

####  2. ngx_command_t  ngx_event_core_commands[]

```c
static ngx_command_t  ngx_event_core_commands[] = {

    { ngx_string("worker_connections"),
      NGX_EVENT_CONF|NGX_CONF_TAKE1,
      ngx_event_connections,
      0,
      0,
      NULL },

    { ngx_string("use"),
      NGX_EVENT_CONF|NGX_CONF_TAKE1,
      ngx_event_use,
      0,
      0,
      NULL },

    { ngx_string("multi_accept"),
      NGX_EVENT_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      0,
      offsetof(ngx_event_conf_t, multi_accept),
      NULL },

    { ngx_string("accept_mutex"),
      NGX_EVENT_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      0,
      offsetof(ngx_event_conf_t, accept_mutex),
      NULL },

    { ngx_string("accept_mutex_delay"),
      NGX_EVENT_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      0,
      offsetof(ngx_event_conf_t, accept_mutex_delay),
      NULL },

    { ngx_string("debug_connection"),
      NGX_EVENT_CONF|NGX_CONF_TAKE1,
      ngx_event_debug_connection,
      0,
      0,
      NULL },

      ngx_null_command
};
```

####  3. ngx_event_module_t  ngx_event_core_module_ctx

```c
static ngx_event_module_t  ngx_event_core_module_ctx = {
    &event_core_name,
    ngx_event_core_create_conf,            /* create configuration */
    ngx_event_core_init_conf,              /* init configuration */

    { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL }
};
```

## Nginx模块总结
配置模块和核心模块这两种模块类型是由Nginx的框架代码所定义的，这里的配置模块是所有模块的基础，它实现了最基本的配置项解析功能（就是解析nginx.conf文件）<br>

<mark>事件模块、HTTP模块、mail模块都有相应的核心core模块作为核心业务与管理功能</mark>
- 事件模块是由它的“代言人”——ngx_events_module核心模块定义，所有事件模块的加载操作不是由Nginx框架完成的，而是由ngx_event_core_module模块负责的。
- HTTP模块是由它的“代言人”——ngx_http_module核心模块定义的，核心模块会负责加载所有的HTTP模块，决定业务的核心逻辑以及对于具体的请求该选用哪一个HTTP模块处理
- 至于mail模块，因与HTTP模块基本相似，不再赘述。
