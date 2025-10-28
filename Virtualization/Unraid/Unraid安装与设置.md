# Unraid安装与设置

## 制作Unraid启动U盘

1. 准备一个2G以上有唯一GUID的U盘，建议用闪迪酷豆。

2. 将U盘格式化为FAT32格式。

### 方式1：使用官方工具制作启动U盘

1. 下载 [Unraid USB Creator](https://unraid.net/download)，选择对应版本，设置主机名，选择```Static IP```，设置IP地址、子网掩码、默认网关与首选DNS服务器，勾选**Allow UEFI Boot**。

2. 点击Write下载镜像并制作Unraid启动U盘（建议全局连接外网）。

### 方式2：手动制作启动U盘

> 参考资料：<https://docs.unraid.net/unraid-os/manual/getting-started#manual-install-method>

1. 进入Unraid下载官网<https://unraid.net/download>，下载对应版本的完整包(zip格式)。

2. 将U盘卷标改为```UNRAID```。

3. 将zip包解压到U盘根目录。

4. 进入U盘根目录，重命名```EFI-```文件夹为```EFI```。

5. 进入config文件夹，编辑```.cfg```文件进行相应设置。

    + **ident.cfg**参考配置：

        ```ini
        # Generated names
        NAME="Square"
        COMMENT="Media server"
        WORKGROUP="WORKGROUP"
        localMaster="yes"
        timeZone="Asia/Shanghai"
        USE_NTP="yes"
        NTP_SERVER1="cn.ntp.org.cn"
        NTP_SERVER2="cn.pool.ntp.org"
        NTP_SERVER3="ntp.aliyun.com"
        NTP_SERVER4="ntp.tencent.com"
        ```

    + **network.cfg**参考配置：

        ```ini
        # Generated network settings
        USE_DHCP="no"
        IPADDR="172.28.8.2"
        NETMASK="255.255.255.0"
        GATEWAY="172.28.8.1"
        BONDING="yes"
        BRIDGING="yes"
        DNS_SERVER1="172.28.8.1"
        ```

6. 返回U盘根目录，右键点击```make_bootable.bat```文件，选择**以管理员身份运行**。

## NAS准备工作

1. 使用另一个含PE的U盘进入PE系统，删除NAS上所有硬盘分区。

2. 插入Unraid启动U盘，进入BIOS设置启动U盘为第一启动项，重启进入Unraid系统，至此启动U盘不再拔出。

## Unraid初始设置

### 设置系统时间

> 参考资料：<https://wiki.unraid.net/%E5%85%A5%E9%97%A8%E6%8C%87%E5%8D%97_-_Chinese_Getting_Started_Guide>

1. 设置时区：选择**SETTING**选项卡，点击**Date and time**，选择Time zone为```UTC+08:00```

2. 手动将 NTP 服务器调整为以下一项或多项。

    + ntp.ntsc.ac.cn
    + cn.ntp.org.cn
    + cn.pool.ntp.org
    + pool.ntp.org

3. 点击```APPLY```，观察**New date and time**是否改变。

### 激活Unraid

1. 选择**TOOLS**选项卡，点击**Registration**，购买或恢复Unraid Key。

### 设置IPV6与直通网卡

1. 选择**SETTINGS**选项卡，点击**Network Settings**，在**Interface Rules**子选项卡下，将需要要直通的网卡设置为靠后的eth序号，重启系统。

2. 选择**SETTINGS**选项卡，点击**Network Settings**，将需要直通的网卡从Bonding members of bond0列表中移除。

3. 选择**TOOLS**选项卡，点击**System Devices**，勾选需要直通的网卡，点击```BIND SELECTED TO VFIO AT BOOT```，重启系统。

4. 选择**SETTINGS**选项卡，点击**Network Settings**，修改网络协议为```IPv4+IPv6```，IPv6地址分配选择```Static```，IPv6 address填写```fd08::2/64```，IPv6 default gateway填写```fd08::1```，IPv6 DNS server填写```fd08::1```，点击应用，观察页面下方路由表是否已经获取到IPv6地址，重启系统。

### 建立子账户

1. 选择**USERS**选项卡，点击**ADD USER**，设置User name和password，建立新账户。

### 设置samba选项

1. 选择**SETTINGS**选项卡，点击**SMB**，在**Samba extra configuration**添加`map to guest = Never`。

### 设置磁盘阵列

1. 选择**MAIN**选项卡，在**Array Device**子选项卡下，添加奇偶校验磁盘到Parity中，（缓存盘外的）储存磁盘到Disk中。

2. 在**Pool Device**子选项卡下，点击```ADD POOL```，添加缓存盘。

3. 点击```START```开启磁盘阵列。

4. 点击奇偶校验的```STOP```停止奇偶校验。

5. 勾选Format右边的```Yes, I want to do this```选框，点击```FORMAT```格式化磁盘，等待格式化完成。

### 安装插件及中文化

1. 选择**APPS**选项卡，点击```INSTALL```安装插件中心。

2. 搜索```chinese```安装中文语言包，点击**更多操作**->**切换到此语言**应用中文语言包。

3. 安装常用插件，如：```Dynamix File Manager```，```aria2-pro```，```Unassigned Devices```等。

### 其他设置

1. 选择**设置**选项卡，点击**管理权限**，修改起始页。
2. 选择**设置**选项卡，点击**计划程序**，添加计划程序。

### 开始奇偶校验

+ 时间较长，尽量选凌晨进行。
