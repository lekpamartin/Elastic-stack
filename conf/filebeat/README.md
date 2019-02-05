## filebeat.yml

### filebeat.prospectors

#### PHP 
```bash
- type: log
  paths:
    - /var/log/php_errors.log
  fields:
    type: php_errors
  fields_under_root: true
  multiline.pattern: '^\['
  multiline.negate: true
  multiline.match: after
```
