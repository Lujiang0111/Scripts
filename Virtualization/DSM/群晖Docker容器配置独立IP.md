# 群晖Docker容器配置独立IP

## 创建macvlan

1. **控制面板** -> **网络** -> **网络界面** -> **管理** -> **Open vSwitch设置**，勾选`启用Open vSwitch`。
1. 通过ssh连接群晖，查看Open vSwitch的接口名，一般为`ovs_eth0`。

    ```shell
    ifconfig
    ```

1. 查看docker是否安装。

    ```shell
    sudo docker --version
    ```

1. 为docker添加macvlan网络

    + ipv4子网和ipv6子网按实际情况修改

    ```shell
    sudo docker network create -d macvlan \
        --subnet=172.28.8.0/24 \
        --gateway=172.28.8.1 \
        --ipv6 \
        --subnet=fd08::/64 \
        --gateway=fd08::1 \
        -o parent=ovs_eth0 \
        macvlan_ovs_eth0
    ```

## 创建容器，并指定独立IP和IPv6

+ `docker run`格式

```shell
sudo docker run -d \
    --name=subconverter \
    --restart=unless-stopped \
    --net=macvlan_ovs_eth0 \
    --ip=172.28.8.42 \
    --ip6=fd08::42 \
    tindy2013/subconverter:latest
```

+ `docker compose`格式

```yml
version: "3.8"
services:
  subconverter:
    restart: unless-stopped
    image: tindy2013/subconverter:latest
    container_name: subconverter
    networks:
      macvlan_ovs_eth0:
        ipv4_address: 172.28.8.42
        ipv6_address: fd08::42
networks:
  macvlan_ovs_eth0:
    external: true
```
