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
### 3.4.1 解析到server {}
- 执行 **ngx_http_core_server()**（server 指令的 set 回调）
```c
{ ngx_string("server"),
      NGX_HTTP_MAIN_CONF|NGX_CONF_BLOCK|NGX_CONF_NOARGS,
      ngx_http_core_server,
      0,
      0,
      NULL },
```
- create_srv_conf(cf)
- create_loc_conf(cf)
- **再次进入 ngx_conf_parse() 递归解析 server {} 内部**

### 3.4.2 解析到location {}
- 执行 **ngx_http_core_location()**（location 指令的 set 回调）
```c
{ ngx_string("location"),
      NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_BLOCK|NGX_CONF_TAKE12,
      ngx_http_core_location,
      NGX_HTTP_SRV_CONF_OFFSET,
      0,
      NULL },
```
- create_loc_conf(cf)
- 若为块 location {}，继续递归解析其内部 

## 3.5 初始化与合并配置（init/merge）

http{} 里的所有指令都被读完后，ngx_http_block() 进入“收尾阶段”，遍历所有 HTTP 模块调用它们的收尾钩子函数
```c
    for (m = 0; cf->cycle->modules[m]; m++) {
        if (cf->cycle->modules[m]->type != NGX_HTTP_MODULE) {
            continue;
        }
        module = cf->cycle->modules[m]->ctx;
        mi = cf->cycle->modules[m]->ctx_index;
        /* init http{} main_conf's */
        if (module->init_main_conf) {
            rv = module->init_main_conf(cf, ctx->main_conf[mi]);
            if (rv != NGX_CONF_OK) {
                goto failed;
            }
        }
        rv = ngx_http_merge_servers(cf, cmcf, module, mi);
        if (rv != NGX_CONF_OK) {
            goto failed;
        }
    }
```
## 3.6 为每个 server{} 完成 location 结构的最终化

```c
ngx_http_core_srv_conf_t   **cscfp;
// ...

/* create location trees */

    for (s = 0; s < cmcf->servers.nelts; s++) {

        clcf = cscfp[s]->ctx->loc_conf[ngx_http_core_module.ctx_index];

        if (ngx_http_init_locations(cf, cscfp[s], clcf) != NGX_OK) {
            return NGX_CONF_ERROR;
        }

        if (ngx_http_init_static_location_trees(cf, clcf) != NGX_OK) {
            return NGX_CONF_ERROR;
        }
    }

```

## 3.7 初始化“阶段（phase）容器”与请求头哈希
```c
ngx_conf_t *cf
ngx_http_core_main_conf_t   *cmcf;
// ...


    if (ngx_http_init_phases(cf, cmcf) != NGX_OK) {
        return NGX_CONF_ERROR;
    }

    if (ngx_http_init_headers_in_hash(cf, cmcf) != NGX_OK) {
        return NGX_CONF_ERROR;
    }
```
ngx_http_core_main_conf_t:
```c
typedef struct {
    ngx_array_t                servers;         /* ngx_http_core_srv_conf_t */

    ngx_http_phase_engine_t    phase_engine;

    ngx_hash_t                 headers_in_hash;

    ngx_hash_t                 variables_hash;

    ngx_array_t                variables;         /* ngx_http_variable_t */
    ngx_array_t                prefix_variables;  /* ngx_http_variable_t */
    ngx_uint_t                 ncaptures;

    ngx_uint_t                 server_names_hash_max_size;
    ngx_uint_t                 server_names_hash_bucket_size;

    ngx_uint_t                 variables_hash_max_size;
    ngx_uint_t                 variables_hash_bucket_size;
    ngx_hash_keys_arrays_t    *variables_keys;
    ngx_array_t               *ports;

    ngx_http_phase_t           phases[NGX_HTTP_LOG_PHASE + 1];
} ngx_http_core_main_conf_t;
```
ngx_http_phase_t:
```c
typedef struct {
    ngx_array_t                handlers;
} ngx_http_phase_t;
```
### ngx_http_init_phases
<mark>**初始化HTTP各阶段handler函数的ngx_array_t**</mark>：
```c
static ngx_int_t
ngx_http_init_phases(ngx_conf_t *cf, ngx_http_core_main_conf_t *cmcf)
{
    if (ngx_array_init(&cmcf->phases[NGX_HTTP_POST_READ_PHASE].handlers,
                       cf->pool, 1, sizeof(ngx_http_handler_pt))
        != NGX_OK)
    {
        return NGX_ERROR;
    }

    // ...

    if (ngx_array_init(&cmcf->phases[NGX_HTTP_LOG_PHASE].handlers,
                       cf->pool, 1, sizeof(ngx_http_handler_pt))
        != NGX_OK)
    {
        return NGX_ERROR;
    }

    return NGX_OK;
}

```
## 3.8 注册PHASE handler与过滤器模块处理函数
### 逐模块执行 postconfiguration函数
```c
    for (m = 0; cf->cycle->modules[m]; m++) {
        if (cf->cycle->modules[m]->type != NGX_HTTP_MODULE) {
            continue;
        }

        module = cf->cycle->modules[m]->ctx;

        if (module->postconfiguration) {
            if (module->postconfiguration(cf) != NGX_OK) {
                return NGX_CONF_ERROR;
            }
        }
    }
```
 postconfiguration函数基本相似：
```c
    ngx_http_handler_pt        *h;
    ngx_http_core_main_conf_t  *cmcf;

    cmcf = ngx_http_conf_get_module_main_conf(cf, ngx_http_core_module);

    h = ngx_array_push(&cmcf->phases[NGX_xxxxx_PHASE].handlers);
    if (h == NULL) {
        return NGX_ERROR;
    }

    *h = ngx_http_xxxxx_handler;

    return NGX_OK;
```
### 过滤器模块处理函数建链
```c
static ngx_http_output_header_filter_pt  ngx_http_next_header_filter;
static ngx_http_output_body_filter_pt    ngx_http_next_body_filter;

static ngx_int_t
ngx_http_gzip_filter_init(ngx_conf_t *cf)
{
    ngx_http_next_header_filter = ngx_http_top_header_filter;
    ngx_http_top_header_filter = ngx_http_xxx_header_filter;

    ngx_http_next_body_filter = ngx_http_top_body_filter;
    ngx_http_top_body_filter = ngx_http_xxx_body_filter;  // 头插法

    return NGX_OK;
}
```
