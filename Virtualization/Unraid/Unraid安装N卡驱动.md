# Unraid安装N卡驱动

## 安装N卡驱动

+ 进入unraid页面，点击`APPS`，搜索并安装`Nvidia-Driver`

## 设置N卡节能

1. 编辑系统启动文件

    ```shell
    nano /boot/config/go
    ```

1. 在`/usr/local/sbin/emhttp`后添加自定义启动项目：

    ```shell
    nvidia-persistenced
    ```
