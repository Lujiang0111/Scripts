# Openclash配置指南

## 配置目录

+ `clash_meta`：`/etc/openclash/core`，需要运行权限
+ `GeoIP.dat` : `/etc/openclash`
+ `GeoSite.dat` : `/etc/openclash`

## geox地址配置

+ GeoIP Dat 数据库:

    ```shell
    https://testingcf.jsdelivr.net/gh/Loyalsoldier/geoip@release/geoip.dat
    ```

+ GeoSite 数据库:

    ```shell
    https://testingcf.jsdelivr.net/gh/Loyalsoldier/domain-list-custom@release/geosite.dat
    ```

## 配置选项

| 名称 | 设置值 |
| - | - |
| 启用进程规则 | `strict` |
| Geodata 数据加载方式 | 标准模式 |
| 启用 GeoIP Dat 版数据库 | ✔ |

### dns

+ SmartDns：见smartdns在IPv6环境下分流设置
+ 内部dns：

  ```yaml
  dns:
    enable: true
    ipv6: true
    enhanced-mode: redir-host
    listen: 0.0.0.0:7874
    respect-rules: true
    nameserver-policy:
      geosite:cn,private:
        - 123.123.123.123
        - 123.123.123.124
    proxy-server-nameserver:
      - 114.114.114.114
      - 119.29.29.29
      - 223.5.5.5
    nameserver:
      - https://8.8.8.8/dns-query#disable-ipv6=true
      - https://1.1.1.1/dns-query#disable-ipv6=true
    default-nameserver:
      - 114.114.114.114
      - 119.29.29.29
      - 223.5.5.5
  ```
