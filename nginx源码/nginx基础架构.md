# 1. 模块化设计
## 1.1 ngx_module_t
所有的模块都遵循着同样的<mark>ngx_module_t</mark>的接口设计规范，接口足够简单，只涉及模块的初始化、退出以及对配置项的处理


```c
typedef struct {
    ngx_str_t             name;
    void               *(*create_conf)(ngx_cycle_t *cycle);
    char               *(*init_conf)(ngx_cycle_t *cycle, void *conf);
} ngx_core_module_t;
```
