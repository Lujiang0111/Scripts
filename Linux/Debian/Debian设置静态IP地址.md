# debian设置静态IP地址

## 禁止系统自动获取IPv6

```shell
vim /etc/sysctl.conf
```

在文件末尾加入(将`enp6s18`改为实际网口名）

```ini
# disable ipv6 autoconf
net.ipv6.conf.enp6s18.autoconf=0
net.ipv6.conf.enp6s18.accept_ra=0
net.ipv6.conf.enp6s18.use_tempaddr=0
```

重启系统或执行

```shell
sysctl -p
```

生效

## 编辑网络配置文件

以管理员权限编辑网络配置文件。

```shell
vim /etc/network/interfaces
```

在文件中添加类似以下的配置（替换成你的实际网络配置）：

```plaintext
allow-hotplug enp6s18
iface enp6s18 inet static
	address 172.28.8.23/24
	gateway 172.28.8.1
	dns-nameservers 172.28.8.1

iface enp6s18 inet6 static
	address fd08::23/64
	gateway fd08::1
	dns-nameservers fd08::1
```

## 重新启动网络服务

完成更改后，重新启动网络服务以应用新的配置。

```shell
systemctl restart networking
```
