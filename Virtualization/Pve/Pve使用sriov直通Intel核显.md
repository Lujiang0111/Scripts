# Pve使用sriov直通Intel核显

> 参考资料：<https://www.derekseaman.com/2024/07/proxmox-ve-8-2-windows-11-vgpu-vt-d-passthrough-with-intel-alder-lake.html>

## 工作配置

+ Intel Core i9-13900T ES Q0PV
+ Proxmox VE 8.2（内核版本6.8.12-1）
+ **注意**：Pve主机必须在BIOS中启用`Intel VT-d`，如果有`SR-IOV`的选项，也必须启用。

## Pve内核设置

+ 下载最新的`i915-sriov-dkms`源码，或直接下[压缩包](https://github.com/strongtz/i915-sriov-dkms/archive/refs/heads/master.zip)解压。

```shell
cd ~
git clone https://github.com/strongtz/i915-sriov-dkms.git
cd i915-sriov-dkms
```

+ 使用`dkms`安装`i915-sriov-dkms`

```shell
apt install -y sysfsutils pve-headers mokutil build-* dkms
dkms add .
dkms install -m i915-sriov-dkms -v $(cat VERSION) --force
dkms status
```

### 修改grub文件

+ 编辑`/etc/default/grub`文件
+ 修改`GRUB_CMDLINE_LINUX_DEFAULT`所在行行为`GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt i915.enable_guc=3 i915.max_vfs=7"`

```shell
sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/c\GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt i915.enable_guc=3 i915.max_vfs=7"' /etc/default/grub
update-grub
update-initramfs -u -k all
reboot
```

### 设置拆分数量

+ 现在我们需要找到VGA卡位于哪个PCIe总线上，通常为`00:02.0`

```shell
lspci | grep VGA
```

```plain
00:02.0 VGA compatible controller: Intel Corporation Raptor Lake-S GT1 [UHD Graphics 770] (rev 0c)
```

+ 设置需要拆分的VF数量，最大为`max_vfs`（本例为7）
+ **注意：拆分数量越多，性能越差，按需拆分**

```shell
echo "devices/pci0000:00/0000:00:02.0/sriov_numvfs = 7" >> /etc/sysfs.conf
cat /etc/sysfs.conf
```

+ 重启以应用修改

```shell
reboot
```

## 防止内核更新

+ 内核版本更新后，`i915-sriov-dkms`需要重新适配，所以使用如下命令固定当前内核。

```shell
proxmox-boot-tool kernel pin $(uname -r)
```

+ 如果确认内核可以更新，请运行如下命令，更新完内核后需要重新固定新内核。

```shell
proxmox-boot-tool kernel unpin
```

## 检查配置是否生效

+ 如果一切成功，最后您应该会看到次要PCIe ID 1-7以及最终启用的 7 个 VF

```shell
lspci | grep VGA
dmesg | grep i915
```

## 设置PCIE直通

```shell
lspci | grep VGA
```

```plain
00:02.0 VGA compatible controller: Intel Corporation Raptor Lake-S GT1 [UHD Graphics 770] (rev 0c)
00:02.1 VGA compatible controller: Intel Corporation Raptor Lake-S GT1 [UHD Graphics 770] (rev 0c)
00:02.2 VGA compatible controller: Intel Corporation Raptor Lake-S GT1 [UHD Graphics 770] (rev 0c)
00:02.3 VGA compatible controller: Intel Corporation Raptor Lake-S GT1 [UHD Graphics 770] (rev 0c)
00:02.4 VGA compatible controller: Intel Corporation Raptor Lake-S GT1 [UHD Graphics 770] (rev 0c)
00:02.5 VGA compatible controller: Intel Corporation Raptor Lake-S GT1 [UHD Graphics 770] (rev 0c)
00:02.6 VGA compatible controller: Intel Corporation Raptor Lake-S GT1 [UHD Graphics 770] (rev 0c)
00:02.7 VGA compatible controller: Intel Corporation Raptor Lake-S GT1 [UHD Graphics 770] (rev 0c)
```

+ 可以选择将`00:02.1`至`00:02.7`用于直通，添加PCI设备时勾选`主要GPU`。
+ **注意:00:02.0不可用于直通**
+ **注意：直通时不可以勾选所有功能**
