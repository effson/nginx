# 1.源码整体流程
```css
main()
 |
 |-------------------> ngx_init_cycle(ngx_cycle_t *cycle)
 |                           |
 |                           |--> cycle->modules[i]->ctx->create_conf(cycle); // cycle->modules[i]->type == NGX_CORE_MODULE
 |                           |--> ngx_conf_param(&conf); // ngx_conf_t conf
 |                           |--> ngx_conf_parse(&conf, &cycle->conf_file); // ngx_conf_t conf
 |                           |--> cycle->modules[i]->ctx->init_conf(cycle); // cycle->modules[i]->type == NGX_CORE_MODULE


```

```c
struct ngx_cycle_s {
    void                  ****conf_ctx;
    ngx_pool_t               *pool;

    ngx_log_t                *log;
    ngx_log_t                 new_log;

    ngx_uint_t                log_use_stderr;  /* unsigned  log_use_stderr:1; */

    ngx_connection_t        **files;
    ngx_connection_t         *free_connections;
    ngx_uint_t                free_connection_n;

    ngx_module_t            **modules;  /* 指向所有已编译/动态加载的模块数组 */
    ngx_uint_t                modules_n;     /* 指向所有已编译/动态加载的模块数组 */
    ngx_uint_t                modules_used;    /* unsigned  modules_used:1; */

    ngx_queue_t               reusable_connections_queue;
    ngx_uint_t                reusable_connections_n;
    time_t                    connections_reuse_time;

    ngx_array_t               listening;
    ngx_array_t               paths;

    ngx_array_t               config_dump;
    ngx_rbtree_t              config_dump_rbtree;
    ngx_rbtree_node_t         config_dump_sentinel;

    ngx_list_t                open_files;
    ngx_list_t                shared_memory;

    ngx_uint_t                connection_n;
    ngx_uint_t                files_n;

    ngx_connection_t         *connections;
    ngx_event_t              *read_events;
    ngx_event_t              *write_events;

    ngx_cycle_t              *old_cycle;

    ngx_str_t                 conf_file;    /* 配置文件路径（默认是 conf/nginx.conf）*/
    ngx_str_t                 conf_param;   /* 命令行参数里传入的配置（-g 指定的参数）*/
    ngx_str_t                 conf_prefix;  /* 配置文件路径的前缀（一般是 conf/）*/
    ngx_str_t                 prefix;       /* 安装目录的前缀路径（一般是 nginx 的根目录）*/
    ngx_str_t                 error_log;
    ngx_str_t                 lock_file;
    ngx_str_t                 hostname;
};
```


