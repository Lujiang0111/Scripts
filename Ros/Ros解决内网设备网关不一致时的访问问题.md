# Ros解决内网设备网关不一致时的访问问题

## 问题描述

| 名称 | IP | 网关 |
| - | - | - |
| Ros bridge-lan | 192.168.8.1 | |
| 旁路网关 | 192.168.8.21 | 192.168.8.1 |
| 内网设备 | 192.168.8.32 | 192.168.8.21 |
| Ros Wireguard服务端 | 192.168.9.1 |  |
| 远程 Wireguard客户端 | 192.168.9.33 | 192.168.9.1 |

此时使用Wireguard客户端`192.168.9.33`ping内网设备`192.168.8.32`时无法ping通。

## 解决方案

## 方案1：内网设备添加静态路由

### debian系统

1. 编辑网络配置文件

    打开`/etc/network/interfaces`文件并编辑（需要root权限）

    ```shell
    vim /etc/network/interfaces
    ```

1. 添加静态路由

    在相应的网络接口配置段中添加如下配置：

    ```shell
    up ip route add 192.168.0.0/16 via 192.168.8.1
    down ip route del 192.168.0.0/16 via 192.168.8.1
    ```

## 方案2：ros添加静态路由

添加静态路由，目的地址`192.168.8.32`，网关`192.168.8.21`。

```shell
/ip/route/add dst-address=192.168.8.32 gateway=192.168.8.21 comment="routing to 192.168.8.32"
```
