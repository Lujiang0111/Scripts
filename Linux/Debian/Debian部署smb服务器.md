# debian部署smb服务器

## 安装Samba软件包

```shell
apt install samba
```

## 备份原samba配置文件

```shell
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
```

## 创建共享目录

```shell
mkdir -p /mnt/ssd/download
chmod 777 /mnt/ssd/download
mkdir -p /mnt/ssd/fastshare
chmod 777 /mnt/ssd/fastshare
mkdir -p /mnt/ssd/storage
chmod 777 /mnt/ssd/storage
mkdir -p /mnt/ssd/xvideos
chmod 777 /mnt/ssd/xvideos
```

## 添加共享目录

编辑配置文件：

```shell
vim /etc/samba/smb.conf
```

在末尾添加以下内容

```conf
[download]
    path = /mnt/ssd/download
    guest ok = no
    read only = no
    browseable = yes
    create mask = 0664
    directory mask = 0775

[fastshare]
    path = /mnt/ssd/fastshare
    guest ok = no
    read only = no
    browseable = yes
    create mask = 0664
    directory mask = 0775

[storage]
    path = /mnt/ssd/storage
    guest ok = no
    read only = no
    browseable = yes
    create mask = 0664
    directory mask = 0775

[xvideos]
    path = /mnt/ssd/xvideos
    guest ok = no
    read only = no
    browseable = yes
    create mask = 0664
    directory mask = 0775
```

## 添加samba用户

Samba使用系统的用户账户，但需要为这些用户设置Samba密码

```shell
smbpasswd -a username
```

启用该用户

```shell
smbpasswd -e username
```

## 添加个性化设置

编辑配置文件：

```shell
vim /etc/samba/smb.conf
```

在`[global]`配置下添加以下内容

```conf
[global]
    # 禁用DNS代理功能
    dns proxy = no

    # MacOS兼容性设置
    vfs objects = catia fruit streams_xattr
    fruit:aapl = yes

    # 兼容性设置
    unix charset = UTF-8
    dos charset = CP850
    mangled names = no
```

## 验证配置文件

检查`smb.conf`配置是否正确

```shell
testparm
```

## 开启samba服务

1. 启动Samba服务

    ```shell
    systemctl start smbd
    systemctl start nmbd
    ```

1. 设置开机自启

    ```shell
    systemctl enable smbd
    systemctl enable nmbd
    ```

## 完整配置文件示例

```conf
[global]
    workgroup = WORKGROUP

    log file = /var/log/samba/log.%m
    max log size = 1000
    logging = file

    panic action = /usr/share/samba/panic-action %d
    server role = standalone server
    obey pam restrictions = yes

    unix password sync = yes
    passwd program = /usr/bin/passwd %u
    passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
    pam password change = yes

    map to guest = bad user
    usershare allow guests = yes

    # Custom
    dns proxy = no
    vfs objects = catia fruit streams_xattr
    fruit:aapl = yes
    unix charset = UTF-8
    dos charset = CP850
    mangled names = no

[download]
    path = /mnt/ssd/download
    guest ok = no
    read only = no
    browseable = yes
    create mask = 0664
    directory mask = 0775

[fastshare]
    path = /mnt/ssd/fastshare
    guest ok = no
    read only = no
    browseable = yes
    create mask = 0664
    directory mask = 0775

[storage]
    path = /mnt/ssd/storage
    guest ok = no
    read only = no
    browseable = yes
    create mask = 0664
    directory mask = 0775

[xvideos]
    path = /mnt/ssd/xvideos
    guest ok = no
    read only = no
    browseable = yes
    create mask = 0664
    directory mask = 0775
```
