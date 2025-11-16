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
+ nameserver-policy：

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

+ fallback:

    ```yaml
    dns:
      enable: true
      ipv6: true
      enhanced-mode: redir-host
      listen: 0.0.0.0:7874
      respect-rules: true
      proxy-server-nameserver:
        - 114.114.114.114
        - 119.29.29.29
        - 223.5.5.5
      nameserver:
        - 123.123.123.123
        - 123.123.123.124
      fallback:
        - https://8.8.8.8/dns-query#disable-ipv6=true
        - https://1.1.1.1/dns-query#disable-ipv6=true
      default-nameserver:
        - 114.114.114.114
        - 119.29.29.29
        - 223.5.5.5
      fallback-filter:
        geoip: true
        geoip-code: CN
        ipcidr:
          - ::/128
          - ::1/128
          - 2001::/32
          - 0.0.0.0/8
          - 10.0.0.0/8
          - 100.64.0.0/10
          - 127.0.0.0/8
          - 169.254.0.0/16
          - 172.16.0.0/12
          - 192.0.0.0/24
          - 192.0.2.0/24
          - 192.88.99.0/24
          - 192.168.0.0/16
          - 198.18.0.0/15
          - 198.51.100.0/24
          - 203.0.113.0/24
          - 224.0.0.0/4
          - 240.0.0.0/4
          - 255.255.255.255/32
        domain:
          - "+.google.com"
          - "+.facebook.com"
          - "+.youtube.com"
          - "+.githubusercontent.com"
          - "+.googlevideo.com"
          - "+.msftconnecttest.com"
          - "+.msftncsi.com"
    ```
