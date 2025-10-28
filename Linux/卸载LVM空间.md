# 卸载LVM空间

## 为什么会被LVM占用

当一个磁盘（例如`/dev/nvme3n1`）被加入到`LVM`中时，它会成为：

+ PV (Physical Volume) : 物理卷
+ VG (Volume Group) : 卷组
+ LV (Logical Volume) : 逻辑卷

只要该磁盘是某个`VG`的一部分，系统就会持有对它的占用，因此：

```shell
wipefs -a /dev/nvme3n1p3
```

会报错：

```shell
wipefs: error: /dev/nvme3n1p3: device or resource busy
```

## 确认设备是否属于LVM

先确认

```shell
lsblk -o NAME,TYPE
```

如果看到类似

```shell
nvme3n1      disk
|─nvme3n1p1  part
|─nvme3n1p2  part
└─nvme3n1p3  part
  |─pve-swap lvm
  └─pve-root lvm
```

说明该磁盘`/dev/nvme3n1`已经是某个LVM卷组的成员。

进一步验证：

```shell
pvs
```

输出类似

```shell
PV             VG  Fmt  Attr PSize  PFree
/dev/nvme3n1p3 pve lvm2 a--  <2.91t <16.25g
```

这表示

+ /dev/nvme3n1p3是`PV`。
+ 属于卷组`pve`。
+ 已激活(`a--`)。

## 逐步释放LVM占用

1. 停用卷组

    ```shell
    vgchange -an pve
    ```

1. 删除卷组

```shell
vgremove pve
```

## 清空分区

```shell
wipefs -a /dev/nvme3n1p1
wipefs -a /dev/nvme3n1p2
wipefs -a /dev/nvme3n1p3
wipefs -a /dev/nvme3n1
```
