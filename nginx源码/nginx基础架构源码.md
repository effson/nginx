# 1.源码整体流程
```css
main()
 |
 |--------------> ngx_init_cycle(ngx_cycle_t *cycle)配置解析和模块初始化
 |                           |
 |                           |--> pool = ngx_create_pool() // 初始化内存池
 |                           |
 |                           |--> cycle->modules[i]->ctx->create_conf(cycle); /* cycle->modules[i]->type == NGX_CORE_MODULE
 |                           |                                                  for循环调用所有核心模块定义的create_conf函数*/
 |                           |--> ngx_conf_param(&conf); // ngx_conf_t conf
 |                           |
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
 |                           |                                      把配置文本翻译成“监听项”结构挂到当前server{}的配置里,也就是cycle中listening
 |                           |                                      结构体，供后续阶段统一创建监听 socket
 |                           |                                     */
 |                           |--> cycle->modules[i]->ctx->init_conf(cycle); // cycle->modules[i]->type == NGX_CORE_MODULE
 |                           |                                                  for循环调用所有核心模块定义的init_conf函数*/
 |                           |
 |                           |--> ngx_open_listening_sockets(cycle); // 监听、绑定 cycle中listening动态数组指定的相应端口
 |                           |
 |                           |--> ngx_configure_listening_sockets; // 根据nginx.conf中的配置项设置已经监听的句柄
 |                           
 |                           
 |--------------> ngx_single_process_cycle(cycle); // if (ngx_process == NGX_PROCESS_SINGLE)
 |                           
 |--------------> ngx_master_process_cycle(cycle); // else        master/worker 进程模型
 |                           |--> ngx_start_worker_processes(cycle, ccf->worker_processes, NGX_PROCESS_RESPAWN);
 |                           |                 |    // 根据ccf->worker_processes，也就是conf文件中的进程数开进程
 |                           |                 |--> for (i = 0; i < n; i++) :
 |                           |                 |         ngx_spawn_process(cycle, ngx_worker_process_cycle,
 |                           |                 |                    (void *) (intptr_t) i, "worker process", type);
 |                           |                 |                   |-->  pid = fork();
 |                           |                 |                   |-->  子进程执行 ngx_worker_process_cycle
 |                           |                 |                   |                  |-->  ngx_worker_process_init(cycle, worker);
 |                           |                 |                   |                  |               |--> for (i = 0; cycle->modules[i]; i++) :
 |                           |                 |                   |                  |                     |--> if (cycle->modules[i]->init_process):
 |                           |                 |                   |                  |                           |--> cycle->modules[i]->init_process(cycle)
 |                           |                 |                   |                  |                
 |                           |                 |                   |                  |-->  ngx_process_events_and_timers(cycle);
 |                           |--> ngx_start_cache_manager_processes(cycle, 0); // 文件缓存模块
```

# 2.重要结构体

<img width="926" height="870" alt="image" src="https://github.com/user-attachments/assets/83b89588-b7ac-4f9d-8e41-2b9248a86e34" />


```
ngx_conf_param(&conf); // ngx_conf_t conf
解析命令行参数 -g 传进来的配置字符串，并把它当成配置文件的一部分执行:nginx -g 'worker_processes 4; daemon off;'
```

```c
struct ngx_command_s {
    ngx_str_t             name;
    ngx_uint_t            type;
    char               *(*set)(ngx_conf_t *cf, ngx_command_t *cmd, void *conf);
    ngx_uint_t            conf;      // “偏移量常量”，用于在配置解析阶段（ngx_conf_handler()）定位当前上下文层级的配置数组。
    ngx_uint_t            offset;    // 决定“写入结构体的哪个字段” ，可用offsetof(your_module_conf_t, setoption_name),
    void                 *post;
};
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

# 3.event事件模块
## 3.1 ngx_event_module_t
```c
typedef struct {
    ngx_str_t              *name;

    void                 *(*create_conf)(ngx_cycle_t *cycle);
    char                 *(*init_conf)(ngx_cycle_t *cycle, void *conf);

    ngx_event_actions_t     actions;
} ngx_event_module_t;
```

```c
typedef struct {
    ngx_int_t  (*add)(ngx_event_t *ev, ngx_int_t event, ngx_uint_t flags);
    ngx_int_t  (*del)(ngx_event_t *ev, ngx_int_t event, ngx_uint_t flags);

    ngx_int_t  (*enable)(ngx_event_t *ev, ngx_int_t event, ngx_uint_t flags);
    ngx_int_t  (*disable)(ngx_event_t *ev, ngx_int_t event, ngx_uint_t flags);

    ngx_int_t  (*add_conn)(ngx_connection_t *c);
    ngx_int_t  (*del_conn)(ngx_connection_t *c, ngx_uint_t flags);

    ngx_int_t  (*notify)(ngx_event_handler_pt handler);

    ngx_int_t  (*process_events)(ngx_cycle_t *cycle, ngx_msec_t timer,
                                 ngx_uint_t flags);

    ngx_int_t  (*init)(ngx_cycle_t *cycle, ngx_msec_t timer);
    void       (*done)(ngx_cycle_t *cycle);
} ngx_event_actions_t;

```

## 3.2 ngx_command_t
<mark>ngx_events_module模块只对一个块配置项感兴趣，也就是nginx.conf中的events{...}</mark>

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
<mark>遇到events{...}会调用ngx_events_block函数处理</mark>

## 3.3 ngx_core_module_t
```c
static ngx_core_module_t  ngx_events_module_ctx = {
    ngx_string("events"),
    NULL,
    ngx_event_init_conf
};
```
<mark>事件核心模块，没实现create_conf函数，为NULL, 根据上面的流程，nginx启动时会调用ngx_event_init_conf函数</mark>
