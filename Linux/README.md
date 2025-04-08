# Linux tips

## nohup不打印日志的方法

```shell
nohup sh run.sh > /dev/null 2>&1 &
```

## nohup运行python脚本

+ python添加```-u```参数，不启用输出缓冲

```shell
nohup python3 -u record_pid_top_stats.py 5524 1 &
```

## 临时添加/删除默认网关

```shell
route add default gw 192.168.1.1
route del default gw 192.168.1.1
```

## 配置http、ftp代理

```shell
export http_proxy=http://username:password@ip:port
export ftp_proxy=http://username:password@ip:port
```

## 配置DNS服务器

```shell
vim /etc/resolv.conf
```

添加相应DNS服务器

```conf
nameserver 192.168.1.12
```
