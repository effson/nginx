# 1.源码整体流程
```css
main()
 |
 |-------------------> ngx_init_cycle(ngx_cycle_t *cycle)
 |                           |
 |                           |--> module = cycle->modules[i]->ctx->create_conf(cycle); // cycle->modules[i]->type == NGX_CORE_MODULE
 |
```
