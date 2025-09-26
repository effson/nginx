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
