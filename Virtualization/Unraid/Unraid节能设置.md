# Unraid节能设置

## 设置Power Mode

+ 进入unraid页面，点击`SETTINGS`->`Power Mode`，选择`Best power efficiency`

## 使用powertop

> 参考资料：<https://forums.unraid.net/topic/98070-reduce-power-consumption-with-powertop/>

1. 安装powertop

    ```shell
    mkdir /boot/extra
    cd /boot/extra
    wget https://github.com/mgutt/unraid-packages/raw/main/6.11.0/powertop-2.15-x86_64-1.txz
    ```

    `重启`raid完成安装。

1. 手动运行powertop调整

    ```shell
    powertop --auto-tune &>/dev/null
    ```

1. 设置开机自动运行

    + 编辑系统启动文件

    ```shell
    nano /boot/config/go
    ```

    + 在`/usr/local/sbin/emhttp`后添加自定义启动项目：

    ```shell
    powertop --auto-tune &>/dev/null
    ```
