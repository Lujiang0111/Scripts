# Esxi强制直通usb口到虚拟机

> 参考资料：<https://www.vediotalk.com/archives/13671>
> 设备：NUC8i5BEK

## 1. 记录下设备的供应商ID、设备ID以及类ID

1. 依次点击Esxi主页->管理->硬件->PCI设备，找到对应设备（如果有多个usb口，则需要逐个尝试），这里是```Intel Corporation Cannon Point-LP USB 3.1 xHCI Controller```。
2. 在下方页面记录下设备的供应商ID、设备ID以及类ID。
    + 供应商id：0x8086
    + 设备id：0x9ded
    + 类id：0xc03

## 2. 开启Esxi的SSH功能

1. 依次点击Esxi主页->主机->操作->服务->启用Secure Shell(SSH)，临时开启Esxi的ssh登录功能。

## 3. 查询确认ID（这一步不是必须的，只是验证一下）

1. 使用xshell等软件登录Esxi，密码方式选择Keyboard Interactive。
2. 查询对应类ID是否存在。

    ```shell
    lspci -v | grep "Class 0c03"
    ```

## 4. 添加直通代码

1. 使用xshell等软件登录Esxi，密码方式选择Keyboard Interactive。

2. 修改```passthru.map```文件

    ```shell
    vi /etc/vmware/passthru.map
    ```

    在文件最后添加

    ```shell
    # Cannon Point-LP USB 3.1 xHCI Controller
    8086  9ded  d3d0     default
    ```

3. 保存退出,并重启启动Esxi。

## 5. 设置直通

1. 依次点击Esxi主页->管理->硬件->PCI设备，找到对应设备，此时直通状态为禁用，表示已经可以设置直通了。
