# Openwrt旁路网关配置

## pve导入镜像

+ `img`镜像：

  + `iso`目录下：

    ```shell
    qm importdisk 121 /var/lib/vz/template/iso/openwrt-x86-64-generic-squashfs-combined-efi.img local-lvm
    ```

  + `root`目录下

    ```shell
    qm importdisk 121 /root/openwrt-x86-64-generic-squashfs-combined-efi.img local-lvm
    ```

+ `qcow2`镜像：

  ```shell
  qm importdisk 121 /root/openwrt-x86-64-generic-squashfs-combined-efi.qcow2 local-lvm
  ```

## /etc/config/network配置示例

```shell
config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '172.28.8.21'
	option netmask '255.255.255.0'
	option gateway '172.28.8.1'
	option ip6assign '64'
	list dns '123.123.123.123'
	option ip6ifaceid '::21'
```

## 网络配置

+ 系统 -> 系统
  + 设置时区
  + 设置NTP服务器地址。
+ 系统 -> 管理权 -> 路由器密码：
  + 设置密码
+ 系统 -> 管理权 -> SSH访问：
  + 密码验证 - ✔
  + 允许root用户凭密码登录 - ✔
+ 网络 -> 接口 -> LAN：
  + 基本设置
    + IPv4地址 - `172.28.8.21`
    + IPv4网关 - `172.28.8.1`
    + IPv4广播 - `172.28.8.255`
    + DNS服务器 - `123.123.123.123`，`123.123.123.124`
    + IPv6分配长度 - `64`
    + IPv6后缀 - `::21`
  + DHCP服务器：
    + 禁用v4和v6所有设置
  + 物理设置
    + 桥接接口 - ✔
    + 启用IGMP嗅探 - ✔
+ 网络 -> 接口
  + IPv6 ULA前缀 - `fd08::/64`。
+ 网络 -> 防火墙
  + 常规设置
    + 启用 SYN-flood 防御 - ❌
    + 入站数据、出站数据、转发 - `接受`
  + 区域
    + 全选择`接受`
    + lan => wan IP动态伪装 - ✔

## 配置定期重启

> 参考资料：<https://openwrt.org/zh/docs/guide-user/base-system/cron>

```shell
# 每周一上午6:30执行重启
# 注意: 为了防止循环重启的怪圈，需要推迟70秒钟执行重启
# 在/etc目录下touch修改一个文件的时间属性，并且设置
# 为上午6:31然后再执行cron的重启任务.
30 6 * * 1 sleep 70 && touch /etc/banner && reboot
```

## 订阅地址配置定时任务，防止拉取订阅超时

1. 在`/etc/scripts/`下创建一个名为`proxy_predownload.sh`的脚本。

    ```shell
    mkdir -p /etc/scripts
    cd /etc/scripts
    ```

1. 编辑`proxy_predownload.sh`文件

    ```shell
    vim /etc/scripts/proxy_predownload.sh
    ```

    添加以下内容，修改`urls`为自己的url：

    ```shell
    #!/bin/bash

    urls=(
        "https://172.28.0.100/file1.txt"
        "https://172.28.0.100/file2.pdf"
        "https://172.28.0.100/file3.jpg"
    )

    for url in "${urls[@]}"; do
        curl -sL -m 60 "${url}" -o /dev/null
        sleep 1
    done
    ```

1. 保存脚本并给它执行权限。

    ```shell
    chmod +x /etc/scripts/proxy_predownload.sh
    ```

1. luci界面配置定时任务

    ```shell
    50 3 * * 5 /bin/bash /etc/scripts/proxy_predownload.sh
    ```

    完成后，系统会在每周五的3:50自动运行该脚本。
