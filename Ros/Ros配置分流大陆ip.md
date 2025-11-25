# ros配置分流大陆ip

> 参考资料：<https://www.willnet.net/index.php/archives/369/>

## 生成ros大陆ip列表脚本文件

+ 使用[geolite2](https://github.com/firehol/blocklist-ipsets/tree/master/geolite2_country)生成

```shell
curl -s https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/geolite2_country/country_cn.netset \
| sed -e '/^#/d'\
| sed -e 's/^/add address=/g' -e 's/$/ list=CNIP/g' \
| sed -e '1i/ip firewall address-list' -e '1iremove [/ip firewall address-list find list=CNIP]' -e '1iadd address=10.0.0.0/8 list=CNIP comment=private-network' -e '1iadd address=172.16.0.0/12 list=CNIP comment=private-network' -e '1iadd address=192.168.0.0/16 list=CNIP comment=private-network' -e '1iadd address=224.0.0.0/4 list=CNIP comment=private-network' \
> cnip.rsc
```

+ 使用[chnroutes2](https://github.com/misakaio/chnroutes2)生成（更小巧，推荐）

```shell
curl -s https://raw.githubusercontent.com/misakaio/chnroutes2/master/chnroutes.txt \
| sed -e '/^#/d'\
| sed -e 's/^/add address=/g' -e 's/$/ list=CNIP/g' \
| sed -e '1i/ip firewall address-list' -e '1iremove [/ip firewall address-list find list=CNIP]' -e '1iadd address=10.0.0.0/8 list=CNIP comment=private-network' -e '1iadd address=172.16.0.0/12 list=CNIP comment=private-network' -e '1iadd address=192.168.0.0/16 list=CNIP comment=private-network' -e '1iadd address=224.0.0.0/4 list=CNIP comment=private-network' \
> cnip.rsc
```

## ros配置

假设**172.28.8.1**是ros的IP，**172.28.8.21**是旁路由的IP，其余IP是需要翻墙的内网ip。

### 导入大陆IP列表

winbox中点击**Files**->**Upload**上传`cnip.rsc`脚本文件。点击**New Terminal**打开控制台，在terminal中输入

```shell
import cnip.rsc
```

导入脚本，此脚本会添加名称为`CNIP`的Address List。

### 配置需要翻墙的内网地址列表

点击**Ip**->**Firewall**，选择**Address Lists**标签，新建名称为`FQIP`的Address List，地址为需要翻墙的内网IP，可用脚本批量添加）。

#### 命令行方式

```shell
/ip firewall address-list
remove [/ip firewall address-list find list=FQIP]
add address=172.28.8.2 list=FQIP
add address=172.28.8.3 list=FQIP
add address=172.28.8.4 list=FQIP
add address=172.28.8.5 list=FQIP
......
```

#### 脚本方式

+ Linux下编写名称为`generate_fqip.sh`的脚本文件

```shell
#!/bin/bash
fqip_file=fqip.rsc

cat <<- EOF > ${fqip_file}
/ip firewall address-list
remove [/ip firewall address-list find list=FQIP]
EOF

for ((i=2; i<=20; i++))
do
    echo -e "add address=172.28.8.${i} list=FQIP" >> ${fqip_file}
done

# skip 172.28.8.21

for ((i=22; i<=239; i++))
do
    echo -e "add address=172.28.8.${i} list=FQIP" >> ${fqip_file}
done
```

+ Linux下运行`generate_fqip.sh`，生成`fqip.rsc`

```shell
bash generate_fqip.sh
```

+ ros下导入`fqip.rsc`

```shell
import fqip.rsc
```

### 配置分流路由表

点击**Routing**->**Tables**，新建一个Routing Table，名称为`rtab-fq`，勾选`FIB`。

```shell
/routing/table/add name="rtab-fq" fib
```

### 添加IP分流策略路由

点击**Ip**->**Routes**，新建一个Route，Dst. Address填写`0.0.0.0/0`，Gateway填写`172.28.8.21`，Routing Table选择`rtab-fq`。

```shell
/ip/route/add dst-address=0.0.0.0/0 routing-table="rtab-fq" gateway=172.28.8.21 comment="routing to openwrt"
```

### 给需要翻墙的内网ip添加标记

+ 点击**Ip**->**Firewall**，选择**Mangle**标签，新建一个Mangle Rule。

+ 选择Gereral标签，Chain选择`prerouting`，Src. Address List选择`FQIP`，Dst. Address List选择`CNIP`，勾选`CNIP`前面的感叹号（取反）。

+ 选择Extra标签，Dst. Address Type选择`local`，勾选`local`前面的感叹号（取反）。

+ 选择Action标签，Action选择`mark routing`，取消勾选Log，New Routing Make选择`rtab-fq`，**取消**勾选`Passthrough`。

```shell
/ip/firewall/mangle/add chain=prerouting src-address-list=FQIP dst-address-list=!CNIP dst-address-type=!local action=mark-routing new-routing-mark=rtab-fq passthrough=no comment="mark routing !CNIP"
```

### 路由器本机代理

+ 点击**Ip**->**Firewall**，选择**Mangle**标签，新建一个Mangle Rule。

+ 选择Gereral标签，Chain选择`output`，Dst. Address List选择`CNIP`，勾选`CNIP`前面的感叹号（取反）。

+ 选择Extra标签，Dst. Address Type选择`local`，勾选`local`前面的感叹号（取反）。

+ 选择Action标签，Action选择`mark routing`，取消勾选Log，New Routing Make选择`rtab-fq`，**取消**勾选`Passthrough`。

```shell
/ip/firewall/mangle/add chain=output dst-address-list=!CNIP dst-address-type=!local action=mark-routing new-routing-mark=rtab-fq passthrough=no comment="self mark routing !CNIP"
```

### 设置Netwatch，根据旁路由启停状况自动切换配置

+ 点击**Tools**->**Netwatch**，点击+号，添加一个新的Netwatch Host。
  + 选择**Host**选项卡。Host填写`172.28.8.21`，Type选择`icmp`。
  + 选择**Up**选项卡，设定IP上线时的操作(On Up)：

    ```shell
    /log/info message="172.28.8.21 up! delay start"
    delay 30
    /ip/route/enable [find where comment="routing to openwrt"]
    /ip/firewall/mangle/enable [find where comment="mark routing !CNIP"]
    /ip/dns/set servers=172.28.8.21
    /ip/dns/cache/flush
    ```

  + 选择**Down**选项卡，设定IP下线时的操作(On Down)：

    ```shell
    /log/info message="172.28.8.21 down!"
    /ip/route/disable [find where comment="routing to openwrt"]
    /ip/firewall/mangle/disable [find where comment="mark routing !CNIP"]
    /ip/dns/set servers=123.123.123.123,123.123.123.124
    /ip/dns/cache/flush
    ```

### 修改Ros默认防火墙（ROS初始配置已包含）

+ 打开 **IP** > **Firewall** > **Filter Rules**，找到 `action=drop chain=forward comment="drop invalid" connection-state=invalid` 这一条，将**General**下的**In. Interface List**改为`!LAN`防止防火墙将加密过后的流量标记为invalid而造成TCP流量握手缓慢。

+ 打开 **IP** > **Firewall** > **Filter Rules**，找到`defconf: fasttrack`这一条, 将**General**下的**In. Interface List**设置为`WAN`，防止Fasttrack与Mangle冲突。
