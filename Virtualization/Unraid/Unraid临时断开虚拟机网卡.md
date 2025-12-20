# Unraid临时断开虚拟机网卡

1. 查看虚拟机网卡列表

    假设虚拟机名称为`win10-dl`

    ```shell
    virsh domiflist win10-dl
    ```

    获取虚拟机的网卡名称（只有开机状态下才能获取）

    ```shell
    Interface
    ---------
    vnet0
    ```

1. 临时断开对应网卡

    ```shell
    virsh domif-setlink win10-dl vnet0 down
    ```

1. 连接对应网卡

    ```shell
    virsh domif-setlink win10-dl vnet0 up
    ```

**注意**：虚拟机重启后网卡默认会变为连接状态。