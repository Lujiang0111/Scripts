# smartdns在IPv6环境下分流设置

## smartdns页面设置

### 添加上游服务器

+ 服务器组分为**default**和**overseas**两组，修改dns所属分组的方法是点击每个dns右端的**修改**按钮，修改**服务器组**为`default`与`overseas`即可。

    | 名称 | IP | 端口 | 协议类型 | 服务器组 | 从默认服务器组排除 |
    | - | - | - | - | - | - |
    | LocalMajor | 123.123.123.123 | 53 | udp | | |
    | LocalMinor | 123.123.123.124 | 53 | udp | | |
    | Google | 8.8.8.8 | 853 | tls | overseas | ✔ |
    | Cloudflare | 1.1.1.1 | 853 | tls | overseas | ✔ |

+ 或者直接修改smartdns配置文件：

    ```shell
    vim /etc/config/smartdns
    ```

  + 添加内容

    ```config
    config server
    	option enabled '1'
    	option name 'LocalMajor'
    	option ip '123.123.123.123'
    	option port '53'
    	option type 'udp'

    config server
    	option enabled '1'
    	option name 'LocalMinor'
    	option ip '123.123.123.124'
    	option port '53'
    	option type 'udp'

    config server
    	option enabled '1'
    	option name 'Google'
    	option ip '8.8.8.8'
    	option port '853'
    	option type 'tls'
    	option server_group 'overseas'
    	option exclude_default_group '1'

    config server
    	option enabled '1'
    	option name 'Cloudflare'
    	option ip '1.1.1.1'
    	option port '853'
    	option type 'tls'
    	option server_group 'overseas'
    	option exclude_default_group '1'
    ```

  + 重启系统生效。

### 配置主DNS服务器

+ 点击**常规设置**选项卡，按下表所示配置。

    | 名称 | 设置值 |
    | - | - |
    | 启用 | ✔ |
    | 服务器名称 | smartdns |
    | 本地端口 | 5337 |
    | 自动设置Dnsmasq | 按需 |

+ 点击**高级设置**选项卡，按下表所示配置。

    | 名称 | 设置值 |
    | - | - |
    | 测速模式 | 无 |
    | 响应模式 | 默认 |
    | IPv6服务器 | ✔ |
    | 双栈IP优选 | ❌ |
    | 缓存过期服务 | ✔ |
    | 缓存大小 | 0 |
    | 持久化缓存 | ❌ |
    | 停用IPv6地址解析 | ❌ |
    | 停用Https地址解析 | ✔ |

+ 如果需要让dnsmasq转发dns，则需要勾选`自动设置dnsmasq`，保存设置。点击luci界面左侧**网络**->**DHCP/DNS**，检查**DNS 转发**项是否被设置为`127.0.0.1#5337`。

### 配置第二DNS服务器

+ 点击**第二DNS服务器**选项卡，按下表所示配置，点击**保存并应用**启用第二DNS服务器。

    | 名称 | 设置值 |
    | - | - |
    | 启用 | ✔ |
    | 本地端口 | 5339 |
    | 服务器组 | overseas |
    | 跳过XX | ✔ |
    | 停用IPV6地址解析 | ✔ |
    | 停用HTTPS记录解析 | ✔ |

## 代理软件设置

### ssrp

+ SmartDNS设置页面，勾选`自动设置dnsmasq`。

+ ssrp设置页面，按下表所示配置。

    | 名称 | 设置值 |
    | - | - |
    | DNS解析方式 | 使用DNS2TCP查询 |
    | 访问国外域名DNS服务器 | 127.0.0.1:5339 |

### Passwall

+ SmartDNS设置页面，勾选`自动设置dnsmasq`。

+ Passwall设置页面，点击**DNS**选项卡，按下表所示配置。

    | 名称 | 设置值 |
    | - | - |
    | 过滤代理域名 IPv6 | ❌ |
    | 过滤模式 | 通过UDP请求DNS |
    | 远程DNS | 127.0.0.1:5339 |
    | ChinaDNS-NG | ❌ |
    | 当使用中国列表外时的默认DNS | 远程DNS |

### OpenClash

+ SmartDNS设置页面，**不**勾选`自动设置dnsmasq`。

+ OpenClash设置页面，点击**插件设置**->**DNS设置**选项卡，按下表所示配置。

    | 名称 | 设置值 |
    | - | - |
    | 本地DNS劫持 | 使用Dnsmasq转发 |
    | 禁止Dnsmasq缓存DNS | ✔ |
    | 启用第二NDS服务器 | ❌ |

+ OpenClash设置页面，点击**插件设置**->**IPv6**选项卡，按下表所示配置。

    | 名称 | 设置值 |
    | - | - |
    | IPv6 流量代理 | 按需 |
    | 允许 IPv6 类型 DNS 解析 | ✔ |

+ OpenClash设置页面，点击**覆写设置**，设置自定义上游DNS服务器

  + 选择**NameServer**选项卡，添加并**只启用**如下服务器

    | 启用 | 服务器分组 | 服务器地址 | 服务器端口 | 服务器类型 | 节点域名解析 |
    | - | - | - | - | - | - |
    | ✔ | NameServer | 127.0.0.1 | 5337 | UDP | ❌ |

  + 选择**FallBack**选项卡，添加并**只启用**如下服务器

    | 启用 | 服务器分组 | 服务器地址 | 服务器端口 | 服务器类型 | 节点域名解析 |
    | - | - | - | - | - | - |
    | ✔ | FallBack | 127.0.0.1 | 5339 | UDP | ❌ |

  + 选择**Default-NameServer**选项卡，添加并**只启用**如下服务器

    | 启用 | 服务器分组 | 服务器地址 | 服务器端口 | 服务器类型 | 节点域名解析 |
    | - | - | - | - | - | - |
    | ✔ | Default-NameServer | 127.0.0.1 | 5337 | UDP | ❌ |

+ OpenClash设置页面，点击**覆写设置**->**DNS设置**选项卡，按下表所示配置。

    | 名称 | 设置值 |
    | - | - |
    | 自定义上游 DNS 服务器 | ✔ |
    | 追加上游DNS | ❌ |
    | 追加默认DNS | ❌ |
    | Fallback-Filter | ✔ |

## 订阅地址配置定时任务，防止拉取订阅超时

1. 在`/etc/scripts/`下创建一个名为`proxy_predownload.sh`的脚本。

    ```shell
    mkdir -p /etc/scripts
    cd /etc/scripts
    ```

1. 编辑`proxy_predownload.sh`文件

    ```shell
    vim /etc/scripts/proxy_predownload.sh
    ```

    添加以下内容，修改`urls`为自己的url：

    ```shell
    #!/bin/bash

    urls=(
        "https://172.28.0.100/file1.txt"
        "https://172.28.0.100/file2.pdf"
        "https://172.28.0.100/file3.jpg"
    )

    for url in "${urls[@]}"; do
        curl -sL -m 60 "${url}" -o /dev/null
        sleep 1
    done
    ```

1. 保存脚本并给它执行权限。

    ```shell
    chmod +x /etc/scripts/proxy_predownload.sh
    ```

1. luci界面配置定时任务

    ```shell
    50 3 * * 5 /bin/bash /etc/scripts/proxy_predownload.sh
    ```

    完成后，系统会在每周五的3:50自动运行该脚本。
