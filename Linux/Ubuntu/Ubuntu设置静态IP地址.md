# Ubuntu设置静态IP地址

## 通过Netplan设置

### 编辑Netplan配置文件

在`/etc/netplan/`目录中寻找或创建`.yaml` 格式的文件，比如 `00-installer-config.yaml`，使用你喜欢的文本编辑器进行编辑。

```shell
vim /etc/netplan/00-installer-config.yaml
```

编辑文件以包含类似以下内容的配置（替换成你的实际网络配置）：

```yaml
network:
  version: 2
  ethernets:
    enp1s0:
      dhcp4: no
      dhcp6: no
      accept-ra: no
      addresses:
        - 172.28.8.23/24
        - "fd08::23/64"
      routes:
        - to: 0.0.0.0/0
          via: 172.28.8.21
          on-link: true
        - to: ::/0
          via: fd08::21
          on-link: true
      nameservers:
        addresses: [172.28.8.21, fd08::21]
        search: []
```

- 实现操作：
  - 关闭DHCPv4
  - 关闭DHVPv6
  - 关闭RA

#### 4. 应用配置

保存文件后，使用以下命令应用配置：

```shell
netplan apply
```
