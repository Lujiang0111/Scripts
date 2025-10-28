# Openwrt镜像扩容

> 参考资料：<https://dickies.myds.me:56789/st/routeos/1024/>

1. 首先下载好镜像包，如果镜像包是压缩文件，如gz结尾，那么需要先解压出镜像包，一般是img后缀的文件就是镜像包。解压命令一般如下：

    ```shell
    gzip -d openwrt-x86-64-generic-squashfs-combined-efi.img.gz
    ```

1. 在这个img镜像文件后面增加空数据，如我这里增加20GB的空数据：

    ```shell
    dd if=/dev/zero bs=1G count=20 >> openwrt-x86-64-generic-squashfs-combined-efi.img status=progress
    ```

1. 这时候我们会发现img文件体积已经变大了20GB，但只是因为空数据撑大了文件，下面我们执行分区命令`parted`：

    ```shell
    parted openwrt-x86-64-generic-squashfs-combined-efi.img
    ```

1. 使用print命令查看当前镜像包的分区情况：

    ```shell
    print
    ```

    ```shell
    (parted) print
    Error: The backup GPT table is corrupt, but the primary appears OK, so that will be used.
    OK/Cancel? OK
    Warning: Not all of the space available to /opt/openwrt-x86-64-generic-squashfs-combined-efi.img appears to be used, you can
    fix the GPT to use all of the space (an extra 41943070 blocks) or continue with the current setting? 
    Fix/Ignore? Fix
    Model:  (file)
    Disk /opt/openwrt-x86-64-generic-squashfs-combined-efi.img: 21.9GB
    Sector size (logical/physical): 512B/512B
    Partition Table: gpt
    Disk Flags: 

    Number  Start   End     Size    File system  Name  Flags
    128     17.4kB  262kB   245kB                      bios_grub
    1      262kB   17.0MB  16.8MB  fat16              legacy_boot
    2      17.0MB  436MB   419MB
    ```

1. 可以看到分区2是镜像包默认的分区空间，只有419MB，下面我们使用命令将刚才增加的20GB空数据整合进这个分区：

    ```shell
    resizepart 2 100%
    ```

    ```shell
    (parted) print                                                            
    Model:  (file)
    Disk /opt/openwrt-x86-64-generic-squashfs-combined-efi.img: 21.9GB
    Sector size (logical/physical): 512B/512B
    Partition Table: gpt
    Disk Flags: 

    Number  Start   End     Size    File system  Name  Flags
    128     17.4kB  262kB   245kB                      bios_grub
    1      262kB   17.0MB  16.8MB  fat16              legacy_boot
    2      17.0MB  21.9GB  21.9GB
    ```

1. 执行`quit`退出，这时候就已经把分区2扩容了20GB：

    ```shell
    quit
    ```
