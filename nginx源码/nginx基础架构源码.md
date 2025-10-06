# 1.源码整体流程
```css
main()
 |
 |-------------------> ngx_init_cycle(ngx_cycle_t *cycle)配置解析和模块初始化
 |                           |
 |                           |--> pool = ngx_create_pool() // 初始化内存池
 |                           |--> cycle->modules[i]->ctx->create_conf(cycle); /* cycle->modules[i]->type == NGX_CORE_MODULE
 |                           |                                                  for循环调用所有核心模块定义的create_conf函数*/
 |                           |--> ngx_conf_param(&conf); // ngx_conf_t conf
 |                           |--> ngx_conf_parse(&conf, &cycle->conf_file); // ngx_conf_t conf
 |                           |          |--> if (cf->handler) : (*cf->handler)(cf, NULL, cf->handler_conf); 
 |                           |          |--> else : ngx_conf_handler(cf, rc);
 |                           |                            |--> for (i = 0; cf->cycle->modules[i]; i++) :
 |                           |                                     cmd = cf->cycle->modules[i]->commands;
 |                           |                                     根据cmd->type,使用cf->ctx和偏移找到conf
 |                           |                                     cmd->set(cf, cmd, conf);调用该command结构体中的set函数进行设置操作
 |                           |                                     /*
 |                           |                                      以 listen 80;（作用域：server{}）为例：
 |                           |                                     cmd->conf = NGX_HTTP_SRV_CONF_OFFSET（根据偏移找到ngx_http_conf_ctx_t的srv_conf成员）
 |                           |                                     cf->ctx也就是ngx_http_conf_ctx_t*，里面有 void **main_conf;
 |                           |                                                                              void **srv_conf;
 |                           |                                                                              void **loc_conf;
 |                           |                                     static ngx_command_t  ngx_http_core_commands[] = {
 |                           |                                         ...                                                                                                              
 |                           |                                         { ngx_string("listen"),
 |                           |                                           NGX_HTTP_SRV_CONF|NGX_CONF_1MORE,
 |                           |                                           ngx_http_core_listen,
 |                           |                                           NGX_HTTP_SRV_CONF_OFFSET,
 |                           |                                           0,
 |                           |                                           NULL },
 |                           |                                         ...
 |                           |                                      }
 |                           |                                      对于listen这个命令，set函数为:
 |                           |                                      ngx_http_core_listen(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)，
 |                           |                                      把配置文本翻译成“监听项”结构挂到当前server{}的配置里，供后续阶段统一创建监听 socket
 |                           |                                     */
 |                           |--> cycle->modules[i]->ctx->init_conf(cycle); // cycle->modules[i]->type == NGX_CORE_MODULE
 |                           |                                                  for循环调用所有核心模块定义的init_conf函数*/

```

<img width="926" height="870" alt="image" src="https://github.com/user-attachments/assets/83b89588-b7ac-4f9d-8e41-2b9248a86e34" />


```
ngx_conf_param(&conf); // ngx_conf_t conf
解析命令行参数 -g 传进来的配置字符串，并把它当成配置文件的一部分执行:nginx -g 'worker_processes 4; daemon off;'
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

    ngx_module_t            **modules;        /* 指向所有已编译/动态加载的模块数组 */
    ngx_uint_t                modules_n;      /* 指向所有已编译/动态加载的模块数组 */
    ngx_uint_t                modules_used;   /* unsigned  modules_used:1; */

    ngx_queue_t               reusable_connections_queue;
    ngx_uint_t                reusable_connections_n;
    time_t                    connections_reuse_time;

    ngx_array_t               listening;    /* 监听套接字数组（每个元素是 ngx_listening_t，对应一个 listen 指令） */
    ngx_array_t               paths;        /* 配置文件里定义的各种路径（如 client_body_temp），会在启动时被创建 */

    ngx_array_t               config_dump;
    ngx_rbtree_t              config_dump_rbtree;
    ngx_rbtree_node_t         config_dump_sentinel;

    ngx_list_t                open_files;    /* 需要统一管理的已打开文件列表（如 access_log） */
    ngx_list_t                shared_memory; /* 共享内存段列表（如 limit_req_zone 等模块使用的 shm） */

    ngx_uint_t                connection_n;
    ngx_uint_t                files_n;

    ngx_connection_t         *connections;
    ngx_event_t              *read_events;
    ngx_event_t              *write_events;

    ngx_cycle_t              *old_cycle;     /* 旧的 cycle 指针，在热加载（reload）时用于资源继承（日志/共享内存/监听端口）*/

    ngx_str_t                 conf_file;    /* 配置文件路径（默认是 conf/nginx.conf）*/
    ngx_str_t                 conf_param;   /* 命令行参数里传入的配置（-g 指定的参数）*/
    ngx_str_t                 conf_prefix;  /* 配置文件路径的前缀（一般是 conf/）*/
    ngx_str_t                 prefix;       /* 安装目录的前缀路径（一般是 nginx 的根目录）*/
    ngx_str_t                 error_log;
    ngx_str_t                 lock_file;    /* 全局锁文件路径（有些平台上用于守护进程互斥）*/
    ngx_str_t                 hostname;
};
```


