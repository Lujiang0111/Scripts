# rp_filter设置

## 查看当前`rp_filter`设置

```shell
cat /proc/sys/net/ipv4/conf/all/rp_filter
cat /proc/sys/net/ipv4/conf/default/rp_filter
cat /proc/sys/net/ipv4/conf/eth0/rp_filter
```

+ `0`：关闭（No source validation）
+ `1`：开启严格模式（Strict mode，默认）
+ `2`：宽松模式（Loose mode）

## 关闭rp_filter

+ 临时关闭

    ```shell
    for iface in $(ls /proc/sys/net/ipv4/conf/); do
        echo "Setting rp_filter=0 for ${iface}"
        echo 0 | sudo tee /proc/sys/net/ipv4/conf/${iface}/rp_filter > /dev/null
    done
    ```

+ 永久关闭，重启生效

    ```shell
    rm -rf /etc/sysctl.d/99-disable-rp_filter.conf
    for iface in $(ls /proc/sys/net/ipv4/conf/); do
        echo -e "net.ipv4.conf.${iface}.rp_filter = 0" >> /etc/sysctl.d/99-disable-rp_filter.conf
    done
    ```
