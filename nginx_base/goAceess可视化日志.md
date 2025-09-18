```
goaccess /var/log/nginx/access.log \
  --log-format='%h %^[%d:%t %^] "%r" %s %b "%R" "%u"' \
  --date-format=%d/%b/%Y \
  --time-format=%T \
  -o /usr/share/nginx/html/report.html
```
