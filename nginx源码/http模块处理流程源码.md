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
```scss
ngx_init_cycle()
  └── ngx_conf_parse(&conf, &cycle->conf_file)
        ├── 读取配置文件内容（逐行、逐token解析）
        ├── 识别指令名称、参数
        ├── 调用 ngx_conf_handler(cf, rc)
              ├── 查找指令定义 ngx_command_t
              ├── 验证上下文和参数数量
              ├── 调用该指令对应的 set 回调函数 
```
