# Debian配置永久路由

1. 打开`/etc/network/interfaces`文件：

    ```shell
    vim /etc/network/interfaces
    ```

1. 在文件中找到你的网络接口配置（例如`eth0`），并在该接口的配置下面添加静态路由。例如，假设你的默认网关是`192.165.52.1`，目标路由是`192.166.0.0/16`，可以按以下方式配置：

    ```shell
    iface eth0 inet static
    	address 172.28.1.100
    	netmask 255.255.255.0
    	gateway 172.28.1.1
    	# 添加、删除静态路由
    	up ip route add 10.0.0.0/8 via 192.165.52.1
    	down ip route del 10.0.0.0/8 via 192.165.52.1
    	up ip route add 192.160.0.0/12 via 192.165.52.1
    	down ip route del 192.160.0.0/12 via 192.165.52.1
    ```

1. 重启网络服务以应用新配置：

    ```shell
    systemctl restart networking
    ```

    或重启

    ```shell
    reboot
    ```
