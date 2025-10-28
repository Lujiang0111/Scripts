# Ros初始配置

## 设置网口与LAN IP

### 规划好网口与地址分配
  
+ 网口分配：
  + 1号口 - 2.5G，做`lan`口。
  + 2号口 - 做`wan`口，接光猫。
  + 8号口 - 做`debug`口，以后连接网线调试用。
  + 其余均为`lan`口。

+ 地址分配：
  + 光猫：地址`172.28.100.1`
  + IPv4：ros地址`172.28.8.1`, 自建dns地址`172.28.8.21`，DHCP地址池`172.28.8.100-172.28.8.239`。
  + IPv6：ros地址`fd08::1`，内网地址池`fd08::/64`

### 使用winbox连接至ros

+ winbox是ros官方提供的图形化管理工具，下载地址：<https://mikrotik.com/download>
+ 打开winbox，选择使用mac地址方式连接至ros。

### 修改接口名称

点击**Interfaces**，选择**Interface**选项卡，确定wan口、2.5G口、SFP口等，修改网口名称，方便记忆。

+ 1号口 - `ether1-2.5g`
+ 2号口 - `ether2-wan`
+ 8号口 - `ether8-debug`

### 设置LAN网桥

+ 点击**Bridge**，选择**Bridge**选项卡，创建一个bridge：
  + **Name** - `bridge-lan`
+ 点击**Bridge**，选择**Ports**选项卡，创建New Bridge Port：
  + **Interface** - `lan网口`
  + **Bridge** - `bridge-lan`
  依次将1、3、4、5、6...口添加至网桥。

### 添加Interface List

+ 点击**Interfaces**，选择**Interface List**选项卡，点击**list**按钮，进入**Interface Lists**页面，添加`WAN`、`LAN`和`ONU`。

```shell
/interface/list/add name=WAN
/interface/list/add name=LAN
/interface/list/add name=ONU
```

+ 点击**Interfaces**，选择**Interface List**选项卡，添加一个Interface List：

    | List | Interface |
    | - | - |
    | ONU | ether2-wan |
    | LAN | bridge-lan |

```shell
/interface/list/member/add list=ONU interface=ether2-wan
/interface/list/member/add list=LAN interface=bridge-lan
```

### 设置lan口IP

+ 点击**IP**->**Addresses**，添加一个LAN口IP：
  + **Address** - `172.28.8.1/24`
  + **Interface** - `bridge-lan`

```shell
/ip/address/add address=172.28.8.1/24 interface=bridge-lan
```

## 安全设置

### 关闭不必要的服务

+ 点击**IP**->**Services**，只留下winbox与www
+ 分别点击**winbox**与**www**：
  + **Available from** - `172.28.0.0/16`（只允许内网访问）。

### 设置时钟同步

+ 点击**System**->**NTP Client**，添加NTP Server：
  + ntp.ntsc.ac.cn
  + cn.pool.ntp.org
  + ntp.aliyun.com
  + ntp.tencent.com

```shell
/system/ntp/client/set enabled=yes servers=ntp.ntsc.ac.cn,cn.pool.ntp.org,ntp.aliyun.com,ntp.tencent.com
```

+ 点击**System**->**Clock**
  + **Time Zone Name** - `Asia/Shanghai`。

```shell
/system/clock/set time-zone-name=Asia/Shanghai
```

## 防火墙设置

+ IPv4防火墙：

```shell
/ip/firewall/filter/add chain=input action=accept connection-state=established,related,untracked comment="defconf: accept established,related,untracked"
/ip/firewall/filter/add chain=input action=drop connection-state=invalid in-interface-list=!LAN comment="defconf: drop invalid from !LAN"
/ip/firewall/filter/add chain=input action=accept dst-address=127.0.0.1 comment="defconf: accept to local loopback (for CAPsMAN)"
/ip/firewall/filter/add chain=input action=drop in-interface-list=!LAN comment="defconf: drop all coming from !LAN"
/ip/firewall/filter/add chain=forward action=accept ipsec-policy=in,ipsec comment="defconf: accept in ipsec policy"
/ip/firewall/filter/add chain=forward action=accept ipsec-policy=out,ipsec comment="defconf: accept out ipsec policy"
/ip/firewall/filter/add chain=forward action=fasttrack-connection in-interface-list=WAN connection-state=established,related comment="defconf: fasttrack from WAN"
/ip/firewall/filter/add chain=forward action=accept connection-state=established,related,untracked comment="defconf: accept established,related, untracked"
/ip/firewall/filter/add chain=forward action=drop in-interface-list=!LAN connection-state=invalid comment="defconf: drop invalid from !LAN"
/ip/firewall/filter/add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface-list=!LAN comment="defconf: drop all from !LAN not DSTNATed"
```

+ IPv6防火墙

```shell
/ipv6/firewall/address-list/add list=bad_ipv6 address=::/128 comment="defconf: unspecified address"
/ipv6/firewall/address-list/add list=bad_ipv6 address=::1 comment="defconf: lo"
/ipv6/firewall/address-list/add list=bad_ipv6 address=fec0::/10 comment="defconf: site-local"
/ipv6/firewall/address-list/add list=bad_ipv6 address=::ffff:0:0/96 comment="defconf: ipv4-mapped"
/ipv6/firewall/address-list/add list=bad_ipv6 address=::/96 comment="defconf: ipv4 compat"
/ipv6/firewall/address-list/add list=bad_ipv6 address=100::/64 comment="defconf: discard only "
/ipv6/firewall/address-list/add list=bad_ipv6 address=2001:db8::/32 comment="defconf: documentation"
/ipv6/firewall/address-list/add list=bad_ipv6 address=2001:10::/28 comment="defconf: ORCHID"
/ipv6/firewall/address-list/add list=bad_ipv6 address=3ffe::/16 comment="defconf: 6bone"
```

```shell
/ipv6/firewall/filter/add chain=input action=accept connection-state=established,related,untracked comment="defconf: accept established,related,untracked"
/ipv6/firewall/filter/add chain=input action=drop in-interface-list=!LAN connection-state=invalid comment="defconf: drop invalid from !LAN"
/ipv6/firewall/filter/add chain=input action=accept protocol=udp port=33434-33534 comment="defconf: accept UDP traceroute"
/ipv6/firewall/filter/add chain=input action=accept protocol=udp dst-port=546 src-address=fe80::/10 comment="defconf: accept DHCPv6-Client prefix delegation."
/ipv6/firewall/filter/add chain=input action=accept protocol=udp dst-port=500,4500 comment="defconf: accept IKE"
/ipv6/firewall/filter/add chain=input action=accept protocol=ipsec-ah comment="defconf: accept ipsec AH"
/ipv6/firewall/filter/add chain=input action=accept protocol=ipsec-esp comment="defconf: accept ipsec ESP"
/ipv6/firewall/filter/add chain=input action=accept ipsec-policy=in,ipsec comment="defconf: accept all that matches ipsec policy"
/ipv6/firewall/filter/add chain=input action=drop in-interface-list=!LAN comment="defconf: drop everything else coming from !LAN"
/ipv6/firewall/filter/add chain=forward action=accept connection-state=established,related,untracked comment="defconf: accept established,related,untracked"
/ipv6/firewall/filter/add chain=forward action=drop in-interface-list=!LAN connection-state=invalid comment="defconf: drop invalid from !LAN"
/ipv6/firewall/filter/add chain=forward action=drop src-address-list=bad_ipv6 comment="defconf: drop packets with bad src ipv6"
/ipv6/firewall/filter/add chain=forward action=drop dst-address-list=bad_ipv6 comment="defconf: drop packets with bad dst ipv6"
/ipv6/firewall/filter/add chain=forward action=drop protocol=icmpv6 hop-limit=equal:1 comment="defconf: rfc4890 drop hop-limit=1"
/ipv6/firewall/filter/add chain=forward action=accept protocol=icmpv6 comment="defconf: accept ICMPv6"
/ipv6/firewall/filter/add chain=forward action=accept protocol=139 comment="defconf: accept HIP"
/ipv6/firewall/filter/add chain=forward action=accept protocol=udp dst-port=500,4500 comment="defconf: accept IKE"
/ipv6/firewall/filter/add chain=forward action=accept protocol=ipsec-ah comment="defconf: accept ipsec AH"
/ipv6/firewall/filter/add chain=forward action=accept protocol=ipsec-esp comment="defconf: accept ipsec ESP"
/ipv6/firewall/filter/add chain=forward action=accept ipsec-policy=in,ipsec comment="defconf: accept all that matches ipsec policy"
/ipv6/firewall/filter/add chain=forward action=drop in-interface-list=!LAN comment="defconf: drop everything else coming from !LAN"
```

## 设置拨号上网

### 添加pppoe client

+ 点击**Interfaces**，选择**Interface**选项卡，点击+号，选择**PPPOE Client**,新建一个PPPOE Client：
  + **General**
    + **Name** - `pppoe-bjlt`
    + **Interfaces** - `ether2-wan`
  + **Dial Out**
    + **User** - pppoe用户名
    + **Password** - pppoe密码
    + **Add Default Route** - ✔

### 设置Interface List

+ 点击**Interfaces**，选择**Interface List**选项卡，添加一个Interface List：

    | List | Interface |
    | - | - |
    | WAN | pppoe-bjlt |

```shell
/interface/list/member/add list=WAN interface=pppoe-bjlt
```

### 设置wan口IP伪装

```shell
/ip/firewall/nat/add action=masquerade chain=srcnat out-interface-list=!LAN comment="defconf: masquerade IPv4 form !LAN"
```

## 设置DNS地址与DNS缓存

+ 点击**IP**->**DNS**：
  + **Server** - `123.123.123.123`,`123.123.123.124`
  + **Allow Remote Requests** - ✔

```shell
/ip/dns/set servers=123.123.123.123,123.123.123.124
/ip/dns/set allow-remote-requests=yes
/ip/dns/cache/flush
```

## 设置MSS钳制

```shell
/ip/firewall/mangle/add chain=forward action=change-mss new-mss=clamp-to-pmtu protocol=tcp tcp-flags=syn out-interface=pppoe-bjlt passthrough=yes comment="IPv4 MSS clamp to PMTU"
/ipv6/firewall/mangle/add chain=forward action=change-mss new-mss=clamp-to-pmtu protocol=tcp tcp-flags=syn out-interface=pppoe-bjlt passthrough=yes comment="IPv6 MSS clamp to PMTU"
```

## 设置DHCP

### 设置DHCP IP池

+ 点击**IP**->**Pool**，选择**Pools**选项卡，创建一个IP Pool：
  + **Name** - `pool-ipv4`
  + **Addresses** - `172.28.8.100-172.28.8.239`（想要分配的地址池）

```shell
/ip/pool/add name=pool-ipv4 ranges=172.28.8.100-172.28.8.239
```

### 设置DHCP Server

+ 点击**IP**->**DHCP Server**，选择**Networks**选项卡，新建一个DHCP Network：
  + **Address** - `172.28.8.0/24`
  + **Gateway** - `172.28.8.1`
  + **DNS Servers** - `172.28.8.1`
+ 点击**IP**->**DHCP Server**，选择**DHCP**选项卡，创建一个DHCP Server：
  + **Name** - `server-ipv4`
  + **Interface** - `bridge-lan`
  + **Address Pool** - `pool-ipv4`

```shell
/ip/dhcp-server/network/add address=172.28.8.0/24 gateway=172.28.8.1 dns-server=172.28.8.1
/ip/dhcp-server/add name=server-ipv4 interface=bridge-lan address-pool=pool-ipv4
```

## 设置IPv6

+ 点击**Interfaces**，选择**Interface**选项卡，查看已创建的PPPOE Client，记录下`Actual MTU`列中的实际MTU值，本文以`1492`为例。

### 设置DHCPv6

+ 点击**IPv6**->**DHCP Client**，点击+号，添加一个DHCPv6 Client：
  + **DHCP**
    + **Interface** - `pppoe-bjlt`
    + **Request** - `prefix`
    + **Pool name** - `pool-ipv6`
    + **Pool Prefix Length** - `60`（电信：56，移动、联通：60）
    + **Use Peer DNS** - ❌
    点击**Apply**，如果Prefix正确的话会显示状态栏**Status:Bound**，如果不正确就换个**Pool Prefix Length**值再尝试。

```shell
/ipv6/dhcp-client/add interface=pppoe-bjlt request=prefix pool-name=pool-ipv6 pool-prefix-length=60 use-peer-dns=no
```

### 给网桥接口分配公网IPv6地址

+ 点击**IPv6**->**Address**,点击+号，添加一个Ipv6 Address：
  + **Address** - `::/64`，
  + **From Pool** - `pool-ipv6`
  + **Interface** - `bridge-lan`
  + `EUI64` - ✔
  + `Advertise` - ✔

```shell
/ipv6/address/add address=::/64 from-pool=pool-ipv6 interface=bridge-lan eui-64=yes advertise=yes
```

### 给网桥接口分配私有IPv6地址

+ 点击**IPv6**->**Address**,点击+号，添加一个Ipv6 Address：
  + **Address** - `fd08::1/64`，
  + **Interface** - `bridge-lan`
  + `Advertise` - ✔

```shell
/ipv6/address/add address=fd08::1/64 interface=bridge-lan advertise=yes
```

### 设置IPv6伪装

```shell
/ipv6/firewall/nat/add action=masquerade chain=srcnat out-interface-list=!LAN comment="defconf: masquerade IPv6 from !LAN"
```

### 设置IPv6 ND

+ 点击**IPv6**->**ND**，选择**Interface**选项卡，选择默认的all规则，点击**Disable**禁用。

```shell
/ipv6/nd/disable numbers=0
```

+ 点击**IPv6**->**ND**，选择**Interface**选项卡，点击+号，添加新的ND：
  + **Interface** - `bridge-lan`
  + **DNS Servers** - `fd08::1`

```shell
/ipv6/nd/add interface=bridge-lan dns=fd08::1
```

+ 点击**IPv6**->**ND**，选择**Prefixes**选项卡，点击**Default**：
  + **Valid Lifetime** - `2d 00:00:00`
  + **Preferred Lifetime** - `1d 00:00:00`

```shell
/ipv6/nd/prefix/default/set preferred-lifetime=24:00:00 valid-lifetime=48:00:00
```

## 设置访问光猫网段

### 设置wan口IP

+ 点击**IP**->**Address**，添加一个wan口IP（注意wab口IP和光猫需在同一网段,例如`172.28.100.2`）：
  + **Address** - `172.28.100.2/24`
  + **Interface** - `ether2-wan`

```shell
/ip/address/add address=172.28.100.2/24 interface=ether2-wan
```

### 添加防火墙规则

```shell
/ip/firewall/mangle/add action=accept chain=prerouting comment="access to ONU" src-address=172.28.8.0/24 dst-address=172.28.100.0/24
```

## 设置 Endpoint-Independent NAT(仅对UDP生效)

```shell
/ip/firewall/nat/add action=endpoint-independent-nat chain=srcnat out-interface-list=WAN protocol=udp place-before=0 comment="udp endpoint-independent nat"
/ip/firewall/nat/add action=endpoint-independent-nat chain=dstnat in-interface-list=WAN protocol=udp place-before=0 comment="udp endpoint-independent nat"
```

## 屏蔽QUIC（可选）

+ 由于运营商对UDP的QoS限制，QUIC目前在国内体验不好，可以通过阻止UDP443端口的方式来屏蔽QUIC

```shell
/ip/firewall/filter/add action=drop chain=forward protocol=udp dst-port=443 comment="disable quic"
```

**注意**：将该规则移至forward的第一条

## 开启UPnP（不建议）

+ 点击**IP**->**UPnp**，勾选`Enabled`、`Allow To Disable External Interface`、`Show Dummy Rule`。

+ 点击Interfaces，创建一个Upnp，Interface选择wan口(`ether2-wan`)，type选择`external`。

+ 点击Interfaces，创建一个Upnp，Interface选择`bridge-lan`，type选择`internal`。

## 可选配置

+ ip neighbor

```shell
/ip/neighbor/discovery-settings/set discover-interface-list=LAN
```

+ mac-server

```shell
/tool/mac-server/set allowed-interface-list=LAN
/tool/mac-server/mac-winbox/set allowed-interface-list=LAN
```

+ 升级固件
  + 点击**System**->**Packages**，点击**Check For Updates**查找更新，一般选择stable通道。
