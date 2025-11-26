# ROS配置IPTV

## 网络结构

```blank
光纤 -- 光猫 -- ROS -- 交换机 -- Openwrt旁路由
                        |
                        +------ Wifi
                        |
                        +------ 其他设备
```

+ 光猫网段 - `172.28.100.1/24`
+ ROS LAN 网段 - `172.28.8.1/24`
+ 旁路由
  + 没有WAN接口，LAN接口为`br-lan`
  + LAN接口IP - `172.28.8.21`

## 光猫设置

+ INTERNET
  + 封装类型 - `PPPOE`
  + WAN类型 - `桥接WAN`
  + 绑定网口 - `LAN1`

+ IPTV
  + 封装类型 - `IPoE`
  + WAN类型 - `路由WAN`
  + VLAN ID - `3964`
  + 组播VLAN - `4000`
  + 绑定网口 - `无`

+ IPv4 VLAN
  + LAN1
    + 绑定模式 - `端口绑定`
  + LAN2
    + 绑定模式 - `VLAN绑定`
    + 绑定VLAN对 - `3964/3964`
    + 出口组播VLAN动作 - `不关注`

## ROS设置

### 接入网线

+ 采用双线接入方式，即INTERNET和IPTV分别用不同网线接入
  + 光猫`LAN1`(INTERNET)接ROS`ether1`口。
  + 光猫`LAN2`(IPTV)接ROS`ether2`口。

### 接口修改

+ Bridge
  + **bridge-lan**网桥去除`ether2`网口

+ Interface
  + Interface
    + 修改**ether2**网口名为`ether2-iptv`
    + bridge-lan -> General -> **勾选**`IGMP Snooping`

### 创建VLAN

+ Interface
  + Interface
    + 添加一个**VLAN**
      + General
        + Name - `vlan-iptv`
        + VLAN ID - `3964`
        + Interface - `ether2-iptv`

+ Interface
  + Interface List
    + 添加Interface List
      + List - `LAN`
      + Interface - `vlan-iptv`

```shell
/interface/list/member/add list=LAN interface=vlan-iptv
```

### 设置组播转发

+ IP -> Address
  + 添加Address
    + Address - `172.28.101.1/24`（选一个没人用的网段，后续不需要此地址）
    + Interface - `vlan-iptv`

+ Routing -> IGMP Proxy
  + Interface
    + 添加上游Interface
      + Interface - `vlan-iptv`
      + Alternative Subnets - `0.0.0.0/0`
      + Upstream - `勾选`
    + 添加下游Interface
      + Interface - `bridge-lan`
      + Alternative Subnets - `不填`
      + Upstream - `不勾选`

## 旁路由设置

+ 网络 -> 接口 -> LAN
  + 物理设置
    + 启用IGMP嗅探 - `勾选`

+ 网络 -> 防火墙 -> 区域
  + 所有的入站数据、出站数据、转发均选择`接受`（后续可优化）

+ 服务 -> udpxy
  + 启用 - `勾选`
  + Respawn - `勾选`
  + Bind IP/Interface - `br-lan`
  + 端口 - `23234`
  + Source IP/Interface - `留空`
  + udpxy状态页面：<http://172.28.8.21:23234/status>

+ 系统 -> 计划任务
  + 添加Keep alive保活，防止组播信号丢失
  + 端口选一个其他的，防止实际下载文件

  ```shell
  */2 * * * * curl -s --max-time 3 -o /tmp/iptv-keepalive http://172.28.8.21:23234/rtp/239.3.1.241:18800
  ```

## VLC设置

+ 导入播放列表：<https://github.com/Lujiang0111/network-actions/blob/main/list/iptv/beijing_unicom.m3u>
