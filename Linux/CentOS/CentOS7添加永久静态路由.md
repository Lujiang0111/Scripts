# CentOS7添加永久静态路由

1. 在`/etc/sysconfig/network-scripts/`目录下创建一个路由配置文件，通常以 `route-<interface>`命名。例如接口是`eth0`，则创建`route-eth0`文件：

    ```shell
    vim /etc/sysconfig/network-scripts/route-eth0
    ```

1. 在文件中添加永久路由:

    ```shell
    10.0.0.0/8 via 192.165.52.1 dev eth0
    192.160.0.0/12 via 192.165.52.1 dev eth0
    ```

1. 重启网络服务：

    ```shell
    systemctl restart network
    ```

    或重启

    ```shell
    reboot
    ```
