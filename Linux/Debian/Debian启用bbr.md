# Debian启用bbr

## 查看当前算法

```shell
sysctl net.ipv4.tcp_congestion_control
```

如果现在是`CUBIC`，通常会看到：

```shell
net.ipv4.tcp_congestion_control = cubic
```

## 加载BBR模块

```shell
modprobe tcp_bbr
```

确认是否可用：

```shell
cat /proc/sys/net/ipv4/tcp_available_congestion_control
```

如果看到`bbr`，例如：

```shell
reno cubic bbr
```

说明可以启用。

## 永久启用BBR

```shell
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >>/etc/sysctl.conf
echo "net.core.default_qdisc = fq" >>/etc/sysctl.conf
sysctl -p &>/dev/null
```
