# Docker配置subconverter

> 参考资料：<https://github.com/tindy2013/subconverter/blob/master/README-docker.md>

## 配置docker容器

+ `docker_compose.yml`

```yml
services:
  subconverter:
    restart: unless-stopped
    image: tindy2013/subconverter:latest
    container_name: subconverter
    networks:
      macvlan_enp6s18:
        ipv4_address: 192.168.8.42
        ipv6_address: fd08::42
networks:
  macvlan_enp6s18:
    external: true
```

## 测试服务器

<http://192.168.8.42:25500/version>

## 清空缓存

<http://192.168.8.42:25500/flushcache?token=password>

## Unraid WebUI配置

```shell
http://[IP]:[PORT:25500]/version
```
