# Ros配置WireGuard

> 参考资料：<https://www.truenasscale.com/2022/04/30/1032.html>

+ Host内网网段：`172.28.8.0/24`
+ Peer内网网段：`192.165.0.0/16`
+ WireGuard网段：`172.28.9.0/24`

## 生成Peer公钥

+ 我们需要借助别的客户端生成Peer的秘钥，使用的Windows的WireGuard的软件，点击**新建空隧道**，然后它就会自动的生成私钥和公钥，这里假设公钥为`public-key-peer`。

## Ros设置

### 设置ddns

+ 点击**IP**->**Cloud**，选择**Cloud**选项卡。
  + DDNS Enabled - `✔`
  + Update Time - `✔`

+ 点击`apply`确认后，DNS Name区域会生成一段网址`xxx.sn.mynetname.net`，使用nslookup命令查看网址即可查询对应的公网IP。

### 设置WireGuard

+ 点击**WireGuard**，选择**WireGuard**选项卡，点击+号。
  + Name - `wireguard-lan`
  + MTU - `1200`
  + Listen Port - `52321`

+ 添加完成后，可以看到**wireguard-lan**自动生成了一串**Public Key**，这里假设为`public-key-lan`。

### 防火墙放行wireguard-lan

+ ROS默认规则有一条`defconf: drop all not coming from LAN`，需要在此规则前加一条对**wireguard-lan**的**Listen Port**的放行规则。

```shell
/ip/firewall/filter/add chain=input protocol=udp dst-port=52321 action=accept comment="accept wireguard listen port"
```

**注意**：添加规则后需要手动将规则移动至最前面！

+ 将**wireguard-lan**添加到**LAN**中

```shell
/interface/list/member/add list=LAN interface=wireguard-lan
```

### 为WireGuard设置IP

+ 点击**IP**->**Addresses**，点击+号。
  + Address - `172.28.9.1/24`
  + Interface - `wireguard-lan`

### 设置Peer

+ 点击**WireGuard**，选择**Peers**选项卡，点击+号。
  + Name - `wireguard-peer`
  + Interface - `wireguard-lan`
  + Public Key - `public-key-peer`
  + Allowed Address - `172.28.9.43/32`、`192.165.0.0/16`
  + Persistent Keepalive - **不设置，否则断连后会打很多日志**

+ 如果要设置多个peer，必须要保证`Allowed Address`不重复。

+ 如果要访问peer的内网网段，需要添加对应静态路由（平常可以disable）

```shell
/ip/route/add dst-address=192.165.0.0/16 gateway=wireguard-lan comment="Routing to wireguard-peer"
```

### 配置访问peer网段

+ 添加address-list

```shell
/ip/firewall/address-list/remove [/ip/firewall/address-list/find list=WGIP]
/ip/firewall/address-list/add address=192.165.0.0/16 list=WGIP comment="wireguard peer ip"
```

+ 添加routing-table及mangle规则
  + 注意mangle规则的顺序，不想用时禁用mangle规则即可

```shell
/routing/table/add name="rtab-wireguard-lan" fib
/ip/route/add dst-address=0.0.0.0/0 routing-table="rtab-wireguard-lan" gateway=wireguard-lan comment="routing to wireguard-lan"
/ip/firewall/mangle/add chain=prerouting dst-address-list=WGIP dst-address-type=!local action=mark-routing new-routing-mark=rtab-wireguard-lan passthrough=no comment="mark routing wireguard peer ip"
```

## 客户端配置

+ 不同的客户端配置方法是大同小异的，我就以刚刚Windows生成的继续往下配置了，名称填写`wireguard-peer`。
  + **PrivateKey** - Windows自动生成的私钥
  + **Address** - Ros设置中为Peer设置的IP
  + **PublicKey** - wireguard-lan的公钥
  + **Endpoint** - 填写OS的公网IP：监听端口
  + **AllowedIPs** - 填写需要通过WireGuard代理的地址段
  + **PersistentKeepalive** - 心跳间隔

```ini
[Interface]
PrivateKey = private-key-peer
Address = 172.28.9.43/32
[peer]
PublicKey = public-key-lan
Endpoint = 123.45.67.89:52321
AllowedIPs = 172.28.0.0/16
PersistentKeepalive = 25
```
