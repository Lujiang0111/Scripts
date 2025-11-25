# Nikki配置指南

## 安装前准备

+ 阅读[官方FAQ](https://github.com/nikkinikki-org/OpenWrt-nikki/wiki/FAQ)。
+ 在[meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat)提前下载好`GeoIP.dat`和`GeoSite.dat`，放入`/etc/nikki/run`中。

## 插件配置

| 名称 | 设置值 |
| - | - |
| 定时重启 | ✔ |
| Cron表达式 | `0 4 * * 5`（每周五4:00点重启，更新订阅） |
| 检查配置文件 | ✔ |
| 仅核心 | ❌ |

## 混入配置 -> 全局配置

| 名称 | 设置值 |
| - | - |
| 进程匹配 | strict |
| IPv6 | 启用 |
| TCP Keep Alive 空闲 | 600 |
| TCP Keep Alive 间隔 | 15 |

+ TCP相关设置是为了解决苹果手机耗电问题

## 混入配置 -> DNS配置

| 名称 | 设置值 |
| - | - |
| IPv6 | 启用 |
| DNS模式 | Redir-Host |
| 遵循分流规则 | 启用 |
| 覆盖 DNS 服务器 | ✔ |
| 覆盖 DNS 服务器查询策略 | ✔ |

最终配置成如下所示

```yaml
dns:
  enable: true
  listen: "[::]:1053"
  ipv6: true
  enhanced-mode: redir-host
  respect-rules: true
  proxy-server-nameserver:
    - 223.5.5.5
    - 114.114.114.114
    - 119.29.29.29
  nameserver:
    - https://8.8.8.8/dns-query#disable-ipv6=true
    - https://1.1.1.1/dns-query#disable-ipv6=true
  nameserver-policy:
    geosite:private,cn:
      - 123.123.123.123
      - 123.123.123.124
```

## 混入配置 -> 嗅探器配置

| 名称 | 设置值 |
| - | - |
| 启用 | 启用 |
| 嗅探 Redir-Host 流量 | ✔ |
| 嗅探纯 IP 连接 | ✔ |

## 混入配置 -> GEOX配置

| 名称 | 设置值 |
| - | - |
| GeoIP 格式 | DAT |
| 定时更新GeoX文件 | 启用 |

## 代理配置 -> 代理配置

| 名称 | 设置值 |
| - | - |
| 启用 | ✔ |
| TCP 模式 | Redirect 模式 |
| UDP 模式 | TUN 模式 |
| IPv4 DNS 劫持 | ✔ |
| IPv6 DNS 劫持 | ✔ |
| IPv4 代理 | ✔ |
| IPv6 代理 | ✔ |

## 代理配置 -> 路由器代理

| 名称 | 设置值 |
| - | - |
| 启用 | ❌ |

## 代理配置 -> 绕过

| 名称 | 设置值 |
| - | - |
| 绕过中国大陆 IP | ❌ |
| 绕过中国大陆 IP6 | ❌ |
| 要代理的 TCP 目标端口 | 常用端口 |
| 要代理的 UDP 目标端口 | 常用端口 |
