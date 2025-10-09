# 1. 事件模块的基本代码框架

## 1.1 ngx_module_t
基本的模块接口设计范式，见nginx基础架构源码那部分

## 1.2 ngx_event_module_t
<mark>**事件模块的ctx(也就是ngx_module_t结构体的ctx部分),每个模块都有属于自己的*ctx**</mark>
```c
typedef struct {
    ngx_str_t              *name;

    void                 *(*create_conf)(ngx_cycle_t *cycle);
    char                 *(*init_conf)(ngx_cycle_t *cycle, void *conf);

    ngx_event_actions_t     actions;
} ngx_event_module_t;
```
