# Pve配置ups

## 安装apcupsd

```shell
apt install -y apcupsd
```

## 配置apcupsd

```shell
vim /etc/apcupsd/apcupsd.conf
```

+ 注意要注释掉配置文件中的`DEVICE`

```conf
# UPSCABLE：指定ups连接类型，可选择simple, smart, ether, usb
UPSCABLE usb

# 注释掉DEVICE
UPSTYPE usb
# DEVICE /dev/ttyS0

# ONBATTERYDELAY：UPS设备切换到电池供电模式后的延迟时间
ONBATTERYDELAY 6

# BATTERYLEVEL：UPS电池电量的阈值，当UPS电池电量低于阈值时关机（百分比值）
BATTERYLEVEL 50

# MINUTES：UPS设备内部计算的剩余电池宫殿时间（分钟）低于MINUTES时关机
MINUTES 5

# TIMEOUT：UPS在电池供电模式下超过了TIMEOUT（秒）时关机。
TIMEOUT 120
```

## 控制apcupsd

+ 查看apcupsd状态

```shell
systemctl status apcupsd
```

+ 启动/停止/重启apcupsd

```shell
systemctl start apcupsd
systemctl stop apcupsd
systemctl restart apcupsd
```

+ 设置/取消开机启动

```shell
systemctl enable apcupsd
systemctl disable apcupsd
```

+ 查看ups状态

```shell
apcaccess
```

## PS

网上有小伙伴说使用`BK650M2-CH`配合apcupsd时，满电时候`STATUS`为`ONBATT`，导致异常关机。我这里显示的是`STATUS:ONLINE`，暂时没有出现这个情况。
