# CentOS tips

## tab自动补全

+ 方式1：使用**bash-completion**

    ```shell
    yum install -y bash-completion
    source /usr/share/bash-completion/bash_completion
    ```

+ 方式2：手动补全

    ```shell
    cat << EOF >> ~/.bashrc

    # Complete cd command
    complete -d cd
    EOF
    ```

## 清理系统缓存

```shell
sync
echo 3 > /proc/sys/vm/drop_caches
```

## 解决ssh连接慢的问题

1. 打开ssh配置文件

    ```shell
    vim /etc/ssh/sshd_config
    ```

2. 修改```#UseDNS yes```为```UseDNS no```

## 最小化安装后网络设置

1. 输入```nmcli d```命令快速查看网卡列表以及连接情况。
2. 输入```nmtui```命令进入图形化网络设置界面，选择对应网卡，设置Ip（x.x.x.x/xx格式），网关，dns，dhcp。
3. 输入```service network restart```重启网络。

## 安装C/C++帮助手册

```shell
yum install -y man-pages libstdc++-docs
```
