# 1. ngx_http_module

```c
static ngx_command_t  ngx_http_commands[] = {

    { ngx_string("http"),
      NGX_MAIN_CONF|NGX_CONF_BLOCK|NGX_CONF_NOARGS,
      ngx_http_block,
      0,
      0,
      NULL },

      ngx_null_command
};
```


```c
static ngx_core_module_t  ngx_http_module_ctx = {
    ngx_string("http"),
    NULL,
    NULL
};
```

```c
ngx_module_t  ngx_http_module = {
    NGX_MODULE_V1,
    &ngx_http_module_ctx,                  /* module context */
    ngx_http_commands,                     /* module directives */
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

- 根据nginx的基础源码架构，首先执行NGX_CORE_MODULE(核心模块)类型的ctx->create_conf函数，可以看出为NULL
- <mark>**http命令是http模块的入口，会调用 ngx_http_commands[]中的set函数：ngx_http_block()** </mark>
- <mark>**ngx_http_block()创建 HTTP 层级的配置上下文，并递归解析整个 http 块内部的所有指令** </mark>
- 最后执行NGX_CORE_MODULE(核心模块)类型的ctx->init_conf函数，可以看出为NULL


# 2. 执行流程
```css
ngx_init_cycle()
  └──> ngx_conf_parse(&conf, &cycle->conf_file);
        ├── 读取配置文件内容（逐行、逐token解析）
        ├── 识别指令名称、参数
        |
        ├──> ngx_conf_handler(cf, rc);
              ├── 查找指令定义 ngx_command_t
              ├── 验证上下文和参数数量
              |
              ├──> 调用该指令对应的 set 回调函数 
```

# 3. ngx_http_block
## 3.1 建立 HTTP 解析上下文（三套 conf 指针）

```c
typedef struct {
    void        **main_conf;
    void        **srv_conf;
    void        **loc_conf;
} ngx_http_conf_ctx_t;
```
ngx_http_block() 先为 HTTP 子系统创建一个新的上下文，ngx_http_conf_ctx_t，有三个数组指针：
- void **main_conf;（http 级）
- void **srv_conf;（server 级——每个虚拟主机一个）
- void **loc_conf;（location 级——每个 location 一个）

## 3.2 创建配置实例
**遍历所有 type == NGX_HTTP_MODULE 的模块，调用各模块在 ngx_http_module_t 里声明的 工厂函数 创建配置实例**：
- create_main_conf(cf)
- create_srv_conf(cf)
- create_loc_conf(cf)

```c
typedef struct {
    ngx_int_t   (*preconfiguration)(ngx_conf_t *cf);
    ngx_int_t   (*postconfiguration)(ngx_conf_t *cf);

    void       *(*create_main_conf)(ngx_conf_t *cf);
    char       *(*init_main_conf)(ngx_conf_t *cf, void *conf);

    void       *(*create_srv_conf)(ngx_conf_t *cf);
    char       *(*merge_srv_conf)(ngx_conf_t *cf, void *prev, void *conf);

    void       *(*create_loc_conf)(ngx_conf_t *cf);
    char       *(*merge_loc_conf)(ngx_conf_t *cf, void *prev, void *conf);
} ngx_http_module_t;
```

## 3.3 调用各 HTTP 模块的 preconfiguration（可选）
正式解析 http{} 内部指令之前，**遍历所有 HTTP 模块并调用：module->preconfiguration(cf)**

## 3.4 递归解析整个 http{} 内容
```c
ngx_conf_parse(cf, NULL);
```
