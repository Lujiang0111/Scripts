# MosDNS配置指南

## MosDNS选项

### 基本设置

+ **基本选项**

| 名称 | 设置值 |
| - | - |
| 启动 | ✔ |
| 配置文件 | 内置预设 |
| 监听端口 | 5337 |
| DNS转发 | ❌ |
| 本地DNS | ✔ |
| 上游DNS服务器 | 123.123.123.123、123.123.123.124 |

+ **高级选项**

| 名称 | 设置值 |
| - | - |
| TCP/DoT连接复用 | ✔ |

## PassWall选项

### 基本设置->DNS

| 名称 | 设置值 |
| - | - |
| 过滤代理域名 IPv6 | ❌(MosDNS默认过滤远程DNS的IPv6) |
| 过滤模式 | 通过UDP请求DNS |
| 远程DNS | 127.0.0.1:5337 |
| ChinaDNS-NG | ❌ |
| 当使用中国列表外时的默认DNS | 远程DNS |

### 规则列表->直连列表

+ 将上游DNS服务器（123.123.123.123、123.123.123.124）添加到直连列表。
+ 将机场节点域名添加到直连列表（出现连接不上远程DNS服务器时需要添加）。

### 规则列表->代理列表

+ 将远程DNS服务器添加到代理列表。

## Openclash选项

### 插件设置->DNS设置

| 名称 | 设置值 |
| - | - |
| 本地DNS劫持 | 使用Dnsmasq转发 |
| 禁止Dnsmasq缓存DNS | ✔ |
| 启用第二NDS服务器 | ❌ |

### 插件设置->IPv6

| 名称 | 设置值 |
| - | - |
| IPv6 流量代理 | 按需 |
| 允许 IPv6 类型 DNS 解析 | ✔ |

### 覆写设置

+ 选择**NameServer**选项卡，添加并**只启用**如下服务器

    | 启用 | 服务器分组 | 服务器地址 | 服务器端口 | 服务器类型 |
    | - | - | - | - | - |
    | ✔ | NameServer | 127.0.0.1 | 5337 | UDP |

+ 选择**FallBack**选项卡，添加并**只启用**如下服务器

    | 启用 | 服务器分组 | 服务器地址 | 服务器端口 | 服务器类型 |
    | - | - | - | - | - |
    | ✔ | FallBack | 127.0.0.1 | 5337 | UDP |

### 覆写设置->DNS设置

| 名称 | 设置值 |
| - | - |
| 自定义上游 DNS 服务器 | ✔ |
| 追加上游DNS | ❌ |
| 追加默认DNS | ❌ |
| Fallback-Filter | ❌ |
