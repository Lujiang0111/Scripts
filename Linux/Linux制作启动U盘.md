# Linux制作启动U盘

## 向U盘写入ISO镜像，制作启动U盘

1. 使用fdisk查看U盘设备

    ```shell
    fdisk -l
    ```

    ```shell
    [root@localhost ~]# fdisk -l
    WARNING: fdisk GPT support is currently new, and therefore in an experimental phase. Use at your own discretion.

    Disk /dev/sda: 128.8 GB, 128849018880 bytes, 251658240 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk label type: gpt
    Disk identifier: 692D670D-2F57-4C72-8DA1-314A93E8B9E6


    #         Start          End    Size  Type            Name
    1         2048       411647    200M  EFI System      EFI System Partition
    2       411648      2508799      1G  Microsoft basic 
    3      2508800     14831615    5.9G  Linux swap      
    4     14831616    119689215     50G  Microsoft basic 
    5    119689216    251656191   62.9G  Microsoft basic 

    Disk /dev/sdb: 15.5 GB, 15472047104 bytes, 30218842 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk label type: dos
    Disk identifier: 0x00000000

    Device Boot      Start         End      Blocks   Id  System
    /dev/sdb1               1  4294967295  2147483647+  ee  GPT
    ```

    从命令的返回结果可以看到u盘的设备为```/dev/sdb```，分区为```/dev/sdb1```。

2. 取消已挂载分区

    ```shell
    umount /mnt/sdb*
    ```

3. 删除U盘分区

    ```shell
    fdisk /dev/sdb
    ```

    1. p - 列出当前所有分区
    2. d - 删除现有分区
    3. w - 保存修改

4. 使用dd命令写入镜像

    ```shell
    dd if=xxx.iso of=/dev/sdb
    sync
    ```

    ```xxx.iso```为镜像文件名，```/dev/sdb```为U盘设备文件。
