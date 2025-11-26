# Ros配置Bond

## 需求

+ 原来`sfp-sfpplus1`-`sfp-sfpplus8`都在`bridge-lan`。
+ 现在要把`sfp-sfpplus2`和`sfp-sfpplus2`聚合成`bond4`，`transmit-hash-policy`为`layer-3-and-4`。

## ros侧配置

1. 移除物理接口出bridge。

    ```shell
    /interface/bridge/port/remove [find interface=sfp-sfpplus2]
    /interface/bridge/port/remove [find interface=sfp-sfpplus3]
    ```

1. 创建bond接口。

    ```shell
    /interface/bonding/add name=bonding1 slaves=sfp-sfpplus2,sfp-sf
    pplus3 mode=802.3ad transmit-hash-policy=layer-3-and-4 lacp-rate=30secs
    ```

1. 把bond接口加入bridge。

    ```shell
    /interface/bridge/port/add bridge=bridge-lan interface=bonding1
    ```

1. 检查bond状态

    ```shell
    /interface/bonding/monitor bonding1
    ```

## 对端配置

### pve

+ 编辑网络配置文件

```shell
vim /etc/network/interfaces
```

假设为`ens5f0np0`和`ens5f1np1`配置bond：

```config
auto ens5f0np0
iface ens5f0np0 inet manual

auto ens5f1np1
iface ens5f1np1 inet manual

auto bond0
iface bond0 inet manual
	bond-slaves ens5f0np0 ens5f1np1
	bond-miimon 100
	bond-mode 802.3ad
	bond-xmit-hash-policy layer3+4

auto vmbr0
iface vmbr0 inet static
	address 172.28.8.11/24
	gateway 172.28.8.1
	bridge-ports bond0
	bridge-stp off
	bridge-fd 0

iface vmbr0 inet6 static
	address fd08::11/64
	gateway fd08::1
```
