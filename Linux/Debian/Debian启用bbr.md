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
# 1. 立即加载 BBR 模块
sudo modprobe tcp_bbr

# 2. 开机自动加载 BBR 模块
echo tcp_bbr | sudo tee /etc/modules-load.d/tcp_bbr.conf

# 3. 永久设置 BBR + FQ
sudo tee /etc/sysctl.d/99-zz-bbr.conf > /dev/null <<'EOF'
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF

# 4. 立即应用配置
sudo sysctl -p /etc/sysctl.d/99-zz-bbr.conf

# 5. 查看是否生效
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc
```

## 测试bbr是否正常运行

执行：

```shell
sudo ss -tin
```

如果有正在传输数据的 TCP 连接，会看到类似：

```shell
ESTAB 0 0 192.168.1.10:443 1.2.3.4:52316
    bbr wscale:7,7 rto:204 rtt:3.5/1.2
    cwnd:32 pacing_rate 125Mbps
    bbr:(bw:100Mbps,mrtt:3.2,pacing_gain:1,cwnd_gain:2)
```

如果TCP连接中出现`bbr`字段，就能确认这条连接确实采用了bbr。
