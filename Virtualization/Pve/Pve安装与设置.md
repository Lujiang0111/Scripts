# Pve安装与设置

## 官方资料

+ 下载地址：<https://www.proxmox.com/en/downloads>
+ 官方文档：<https://pve.proxmox.com/pve-docs/>

## 全新安装

+ 使用[rufus](https://rufus.ie)制作启动U盘进行安装，此处选择的是pve 9.0版本。
+ 默认管理网址：<https://ip:8006>
+ 默认用户名：root

## 更改语言

+ 登录界面可以直接选择语言。
+ 进入主页面后在右上角点击用户名切换语言。

## 使用ssh连接到pve

+ 关机：`poweroff`
+ 重启：`reboot`

## 设置http代理

如果pve主机本身无法联网但有联网需求，需要设置http代理

```shell
cat <<- EOF > /etc/profile.d/proxy.sh
export http_proxy="http://username:password@ip:port"
export https_proxy="http://username:password@ip:port"
export no_proxy="localhost,127.0.0.1,::1"
EOF

source /etc/profile
```

## 修改软件源

可选ustc软件源或无订阅软件源

### 屏蔽原有企业版软件源

+ pve 8

  ```shell
  sed -i 's/^/# /' /etc/apt/sources.list.d/pve-enterprise.list
  ```

+ pve 9

  ```shell
  cd /etc/apt/sources.list.d/
  mkdir -p backup
  mv pve-enterprise.sources backup/
  ```

### ustc软件源

> 参考资料：<https://mirrors.ustc.edu.cn/help/proxmox.html>

### 无订阅软件源

> 参考资料：<https://pve.proxmox.com/wiki/Package_Repositories>

### 更新软件源

```shell
apt update -y
apt full-upgrade -y
```

重启系统

```shell
reboot
```

## 安装vim

```shell
apt install -y vim
```

## 设置静态IPv6地址

+ 编辑网络配置文件

```shell
vim /etc/network/interfaces
```

+ 为网络接口配置IPv6地址 找到与你的网络接口（如`vmbr0`）相关的配置，然后添加或修改IPv6 配置。

```config
# 删除不需要的网卡

auto vmbr0
iface vmbr0 inet static
	address 172.28.8.11/24
	gateway 172.28.8.1
	bridge-ports enp8s0
	bridge-stp off
	bridge-fd 0

# IPv6 config
iface vmbr0 inet6 static
	address fd08::11/64
	gateway fd08::1
```

+ 重启网络服务

```shell
systemctl restart networking
```

## 去除未订阅提示

+ 使用ssh连接到pve
+ 编辑`proxmoxlib.js`文件

```shell
vim /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
```

+ 将`if (res === null || res === undefined || !res || res.data.status.toLowerCase() !== 'active')`判断改为`if (false)`

```js
if (false) {
    Ext.Msg.show({
        title: gettext('No valid subscription'),
        icon: Ext.Msg.WARNING,
        message: Proxmox.Utils.getNoSubKeyHtml(res.data.url),
        buttons: Ext.Msg.OK,
        callback: function(btn) {
            if (btn !== 'ok') {
                return;
            }
            orig_cmd();
        },
    });
} else {
    orig_cmd();
}
```

+ 执行

```shell
systemctl restart pveproxy
```

或重启

```shell
reboot
```

生效。

## 设置PCI直通

> 参考资料：<https://pve.proxmox.com/wiki/PCI(e)_Passthrough>

### 修改grub文件

+ 编辑`/etc/default/grub`文件
+ 修改`GRUB_CMDLINE_LINUX_DEFAULT`所在行内容为`GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"`

```shell
# check before
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT

sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/c\GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"' /etc/default/grub

#check after
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT
```

### 添加Kernel Modules

+ 修改`/etc/modules`文件

```shell
#check before
cat /etc/modules

cat <<- EOF >> /etc/modules
vfio
vfio_iommu_type1
vfio_pci

EOF

#check after
cat /etc/modules
```

### 屏蔽驱动或设备

#### 显卡驱动

> 参考资料：<https://pve.proxmox.com/wiki/PCI_Passthrough>

+ AMD GPUs

```shell
echo "blacklist amdgpu" >> /etc/modprobe.d/amd-blacklist.conf
echo "blacklist radeon" >> /etc/modprobe.d/amd-blacklist.conf
```

+ NVIDIA GPUs

```shell
echo "blacklist nouveau" >> /etc/modprobe.d/nvidia-blacklist.conf
echo "blacklist nvidia*" >> /etc/modprobe.d/nvidia-blacklist.conf
```

+ Intel GPUs(注意直通后可能导致vnc失效)

```shell
echo "blacklist i915" >> /etc/modprobe.d/intel-blacklist.conf
```

#### SATA控制器驱动

**注意**：会屏蔽掉所有ahci驱动的sata控制器

```shell
echo "blacklist ahci" >> /etc/modprobe.d/sata-blacklist.conf
```

#### 单独设备

> 参考资料：<https://forum.proxmox.com/threads/pci-passthrough-selection-with-identical-devices.63042/#post-287937>

1. 添加`vfio`module到`initramfs`

    ```shell
    echo "vfio-pci" >> /etc/initramfs-tools/modules
    ```

1. 确认设备信息

    ```shell
    lspci -nn
    ```

    例如输出

    ```shell
    18:00.0 Ethernet controller [0200]: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ [8086:1572] (rev 02)
    18:00.1 Ethernet controller [0200]: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ [8086:1572] (rev 02)
    ```

    这里：

    + `18:00.0`是设备的**PCI地址**
    + `8086:1572`是**厂商ID:设备ID**

1. 屏蔽对应设备

    ```shell
    mkdir -p /etc/initramfs-tools/scripts/init-top
    touch /etc/initramfs-tools/scripts/init-top/bind_vfio.sh
    chmod +x /etc/initramfs-tools/scripts/init-top/bind_vfio.sh
    ```

    修改`bind_vfio.sh`:

    ```shell
    vim /etc/initramfs-tools/scripts/init-top/bind_vfio.sh
    ```

    `DEVS`根据自己需要修改

    ```shell
    #!/bin/sh
    DEVS="0000:00:11.5 \
    0000:00:17.0 \
    0000:02:00.0 \
    0000:03:00.0 \
    0000:18:00.1 \
    0000:8a:00.0 \
    0000:8a:00.1 \
    0000:c3:00.0 \
    0000:c4:00.0 \
    0000:c5:00.0"
    for DEV in $DEVS; do
        echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done

    modprobe -i vfio-pci
    ```

### 应用更改

+ 更新grub

```shell
update-grub
reboot
```

+ 刷新initramfs

```shell
update-initramfs -u -k all
reboot
```

### 测试直通是否生效

```shell
dmesg | grep -e DMAR -e IOMMU -e AMD-Vi
```

如果显示`IOMMU enabled`, `Directed I/O`或`Interrupt Remapping`就代表成功了。

## 为虚拟机添加PCI设备

+ **注意：不要将控制口的网卡给直通了！！**

+ 查看网卡pci地址:

```shell
ethtool -i enp87s0
```

```shell
driver: igc
version: 6.5.11-7-pve
firmware-version: 1057:8754
expansion-rom-version: 
# bus-info即pci地址
bus-info: 0000:57:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes
```

+ 点击：虚拟机->硬件->添加->PCI设备
  + 所有功能
    + 如果该设备具有多个功能（例如显卡 01:00.0 和 01:00.1），勾选此选项会一起传递。

  + 主 GPU (x-vga=on|off)
    + 标记该设备为虚拟机主显卡，勾选后虚拟机将会忽略配置中的`显示`选项。

  + PCI-Express (pcie=on|off)
    + 告诉 Proxmox VE 使用PCIe还是PCI端口。一些设备组合需要PCIe而非PCI。PCIe只在q35机型上有效。

  + ROM-Bar (rombar=on|off)
    + 使固件ROM对客户机可见。默认已勾选，有些PCI(e)设备需要禁用。

## 设置PVE防火墙

> 参考资料：<https://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_pve_firewall>

### 设置数据中心防火墙

+ **注意**：如果启用防火墙，默认情况下会阻止到所有主机的流量。唯一的例外是本地网络中的WebGUI(8006)和 ssh(22)。

+ 数据中心 - 防火墙 - 添加
  + 添加自定义防火墙

+ 数据中心 - 防火墙 - 选项 - 启用

### 启用节点防火墙

+ 默认情况下节点防火墙是启用的。

+ 数据中心 - pve节点 - 防火墙 - 选项 - 启用

## 设置vm防火墙

+ 数据中心 - 节点 - vm - 防火墙 - 添加
  + 添加自定义防火墙

+ 数据中心 - 节点 - vm - 防火墙 - 选项 - 启用
