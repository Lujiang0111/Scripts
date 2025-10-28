# Openwrt配置Wireguard客户端

## 组网环境

### Wireguard服务器

+ 设备：RouterOS
+ 内网IP：172.28.8.1/24
+ 公网IP：123.45.67.89
+ Wireguard IP：172.28.9.1
+ Wireguard端口：52321

### Wireguard客户端

+ 设备：OpenWrt
+ 内网IP: 192.165.23.45
+ Wireguard IP：172.28.9.45

## 配置Wireguard客户端

1. 进入`网络`->`接口`，点击`添加新接口...`。
1. 输入接口名称（例如`Wireguard`），协议选择`WireGuard VPN`。
1. 在新页面中，点击`常规设置`，配置以下参数：
    + `私钥`：使用wireguard windows客户端生成一个密钥对。将私钥填写在此处。
    + `监听端口`：留空，WireGuard客户端通常不需要监听端口。
    + `IP地址`：输入Wireguard IP`172.28.9.45`
    + `无主机路由`：❌
1. 在接口配置页面中，点击`防火墙配置`，将`Wireguard`接口添加到`lan`区域中。
1. 在接口配置页面中，点击`对端`，配置以下参数：
    + `公钥`：输入服务器的公钥。
    + `允许的IP`：输入你希望通过WireGuard隧道路由的IP地址范围，例如`172.28.0.0/16`。
    + `路由允许的IP`：✔。
    + `端点主机`：填写Wireguard服务器的IP地址或DDNS域名。
    + `端点端口`：填写服务器的端口号，这里填写`52321`。
    + `持续Keep-alive`：填写Keep alive包的发送间隔，这里填写`25`。
1. 点击`保存&应用`。

## 建立Wireguard连接

1. 进入`网络`->`接口`，点击`WireGuard`接口右端的`连接`。
1. 查看是否有接收和发送数据包，或者可以Ping`172.28.8.1`来判断是否连接成功。

## Wireguard服务器访问Wireguard客户端网络

1. 使用Winbox连接到Ros。
1. 进入`IP`->`Address`，点击+号，添加一个IP地址：
    + `Address` - `192.165.23.123/16`
    + `Interface` - `wireguard-lan`
1. 测试ping`192.165.23.45`，查看是否连接成功。

## 配置断线自动重连

1. 在`/etc/scripts/`下创建一个名为`wireguard_check.sh`的脚本。

    ```shell
    mkdir -p /etc/scripts
    cd /etc/scripts
    ```

1. 编辑`wireguard_check.sh`文件

    ```shell
    vim /etc/scripts/wireguard_check.sh
    ```

    添加以下内容，修改`wg_interface`和`ping_target`为自己设置的值：

    ```shell
    #!/bin/bash
    wg_interface=Wireguard
    ping_target=172.28.8.1

    fail_cnt=0
    for i in {1..3}; do
        if ! ping -c 1 -W 3 ${ping_target} >/dev/null 2>&1; then
            fail_cnt=$((fail_cnt + 1))
        fi
    done

    if [ ${fail_cnt} -ge 3 ]; then
        logger -t wireguard_check "wireGuard peer ping fail, reconnect"

        wg_state=$(ifstatus ${wg_interface} | jsonfilter -e '@.up')
        if [ "${wg_state}" = "true" ]; then
            ifdown ${wg_interface}
        fi

        sleep 10
        ifup ${wg_interface}
    fi
    ```

1. 保存脚本并给它执行权限。

    ```shell
    chmod +x /etc/scripts/wireguard_check.sh
    ```

1. luci界面配置定时任务

    ```shell
    */30 * * * * /bin/bash /etc/scripts/wireguard_check.sh
    ```

    这会让cron每30分钟执行一次脚本，检查WireGuard的连接状态，并在失效时重启接口。
