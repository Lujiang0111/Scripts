# Pve导入硬盘镜像到虚拟机

## 上传镜像文件

+ `img`镜像：
  + pve页面选择：数据中心 -> pve -> local(pve) -> ISO镜像 -> 上传，选择img镜像上传。

+ `qcow2`镜像：
  + 使用ssh将镜像直接放到`/root/`目录下

## 将镜像导入虚拟机中

+ ssh连接pve，执行下列命令将镜像导入到虚拟机中
  + `121`：虚拟机的ID, 替换为实际ID。
  + `local-lvm`：存储的名字，替换为实际储存。

+ `img`镜像：

  ```shell
  qm importdisk 121 /var/lib/vz/template/iso/openwrt-x86-64-generic-squashfs-combined-efi.img local-lvm
  ```

+ `qcow2`镜像：

  ```shell
  qm importdisk 121 /root/openwrt-x86-64-generic-squashfs-combined-efi.qcow2 local-lvm
  ```

+ 运行命令后就可以在虚拟机中看到这个未使用的磁盘。点击**编辑**->**添加**导入该磁盘。

## 修改引导顺序

+ 在虚拟机的**选项**->**引导顺序**中，勾选刚才导入的磁盘，并调整顺序到第一位。
