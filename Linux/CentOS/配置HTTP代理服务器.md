# CentOS7配置HTTP代理服务器

## 安装squid

```shell
yum install -y squid
```

## 修改squid配置文件

```shell
vim /etc/squid/squid.conf
```

设置允许所有IP访问，修改监听IPv4端口。

```conf
# And finally deny all other access to this proxy
# http_access deny all
http_access allow all

# Squid normally listens to port 3128
# http_port 3128
http_port 0.0.0.0:53128
```

## 检查配置文件是否有误

```shell
squid -k parse
```

## 修改squid防火墙配置文件

```shell
vim /usr/lib/firewalld/services/squid.xml
```

端口改成自己设定的

```xml
<port protocol="tcp" port="53128"/>
```

## 更新防火墙规则

```shell
firewall-cmd --permanent --add-service=squid
firewall-cmd --reload
```

## 配置squid自动启动

```shell
systemctl enable squid
```

## 启动squid服务

```shell
systemctl start squid
```
