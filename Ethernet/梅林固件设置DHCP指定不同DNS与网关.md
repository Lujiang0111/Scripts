# 梅林固件设置DHCP指定不同DNS与网关

> 参考资料：<https://blog.51fuli.info/%E5%8D%8E%E7%A1%95merlin%E8%AE%BE%E7%BD%AEdhcp%E6%8C%87%E5%AE%9A%E7%BD%91%E5%85%B3>

## 1. 开启JFFS2分区与SSH

1. **高级设置**->**系统设置**：```Enable JFFS custom scripts and configs```选项选择```是```。
2. **高级设置**->**系统设置**：```启用SSH```选项选择```LAN only```。

## 2. 修改dnsmasq配置文件

1. 使用XShell等软件登录ssh。
2. 创建或修改dnsmasq配置文件

    ```shell
    vi /jffs/configs/dnsmasq.conf.add
    ```

3. 设定一个dhcp-option的tag，用于批量设置(其中```router```代表网关，```dns-server```代表DNS服务器)

    ```dnsmasq
    dhcp-option=tag:to_op,option:router,172.28.8.5
    dhcp-option=tag:to_op,option:dns-server,172.28.8.5
    ```

4. 绑定不同设备的IP地址，网关与DNS服务器

    ```dnsmasq
    dhcp-host=xx:xx:xx:xx:xx:A1,set:to_op,172.28.8.41,IPhone
    dhcp-host=xx:xx:xx:xx:xx:B2,set:to_op,172.28.8.42,Notepad
    dhcp-host=xx:xx:xx:xx:xx:C3,set:to_op,172.28.8.43,PC
    ```

    + 注意：指定IPhone时，需要在对应WIFI设置里**取消勾选**```私有无线局域网地址```，否则每次连接路由的MAC地址是不固定的。

5. 重启dnsmasq服务

    ```shell
    service restart_dnsmasq
    ```

+ 整体配置文件展示
  + 文件路径：/jffs/configs/dnsmasq.conf.add
  + 文件内容：

    ```dnsmasq
    dhcp-option=tag:to_op,option:router,172.28.8.5
    dhcp-option=tag:to_op,option:dns-server,172.28.8.5
    dhcp-host=xx:xx:xx:xx:xx:A1,set:to_op,172.28.8.41,IPhone
    dhcp-host=xx:xx:xx:xx:xx:B2,set:to_op,172.28.8.42,Notepad
    dhcp-host=xx:xx:xx:xx:xx:C3,set:to_op,172.28.8.43,PC
    ```
