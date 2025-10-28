# Exsi开启核显直通

> 参考资料：<https://www.bilibili.com/read/cv13866041>
> 设备：NUC8i5BEK

## 1. 关闭Esxi显卡调用（否则每次重启后直通状态会变回“启用/需重启”）

1. 开启Esxi的SSH功能。
    + 依次点击Esxi主页->主机->操作->服务->启用Secure Shell(SSH)，临时开启Esxi的ssh登录功能。

2. 使用xshell等软件登录Esxi，密码方式选择Keyboard Interactive。

3. 终端输入以下命令关闭显卡调用：

    ```shell
    esxcli system settings kernel set -s vga -v FALSE
    ```

    *关闭后重启不再显示黄底的Esxi控制台界面，如果需要重新启用显卡调用，输入*

    ```shell
    esxcli system settings kernel set -s vga -v TRUE
    ```

4. 重启Esxi设备。

## 2. 切换显卡直通

1. 依次点击Esxi主页->管理->硬件->PCI设备，查看核显直通状态。

2. 如果默认核显可选，则直接切换为直通，否则参照**Esxi强制直通usb口到虚拟机**文章方法强制直通。

## 3. 为虚拟机添加PCIE设备

1. 编辑虚拟机设置，**CPU**选项下，**取消勾选**硬件虚拟化，IOMMU，性能计数器，否则开启虚拟机会报错。

2. 添加PCIE设备，内存勾选“预留所有客户机内存（全部锁定）”选项。

3. 配置虚拟机自定义参数：
    + 进入“虚拟机选项→高级→配置参数→编辑配置”添加以下参数：
        + **键**：```hypervisor.cpuid.v0```，**值**：```FALSE```
