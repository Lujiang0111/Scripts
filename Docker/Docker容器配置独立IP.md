# Docker容器配置独立IP

## 创建macvlan网络

1. 查看网络接口

    ```shell
    ip a
    ```

    这里假设是`ens18`。

1. 创建IPv4和IPv6双栈的macvlan网络

    假设创建的macvlan接口为`macvlan_ens18`

    ```shell
    docker network create -d macvlan \
        --subnet=172.28.8.0/24 \
        --gateway=172.28.8.1 \
        --ipv6 \
        --subnet=fd08::/64 \
        --gateway=fd08::1 \
        -o parent=ens18 \
        macvlan_ens18
    ```

    + **注意：使用macvlan时端口映射无效！**

## docker run形式指定IP地址

```shell
docker run -d \
    --name=subconverter \
    --restart=unless-stopped \
    --net=macvlan_ens18 \
    --ip=172.28.8.42 \
    --ip6=fd08::42
    tindy2013/subconverter:latest
```

## docker compose形式指定IP地址

```yml
version: "3.8"
services:
  subconverter:
    restart: unless-stopped
    image: tindy2013/subconverter:latest
    container_name: subconverter
    networks:
      macvlan_ens18:
        ipv4_address: 172.28.8.42
        ipv6_address: fd08::42
networks:
  macvlan_ens18:
    external: true
```
