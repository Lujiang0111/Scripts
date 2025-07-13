# Ros配置端口映射(不带回流)

## IPv4

```shell
/ip/firewall/nat add chain=dstnat protocol=tcp dst-port=56888 in-interface-list=WAN action=dst-nat to-addresses=172.28.8.43 to-ports=56888 comment="forward aria2"
/ip/firewall/nat add chain=dstnat protocol=udp dst-port=56888 in-interface-list=WAN action=dst-nat to-addresses=172.28.8.43 to-ports=56888 comment="forward aria2"
```

## IPv6

```shell
/ipv6/firewall/filter/add chain=forward protocol=tcp dst-port=56881 action=accept comment="forward qbittorrent"
/ipv6/firewall/filter/add chain=forward protocol=udp dst-port=56881 action=accept comment="forward qbittorrent"
```

**注意**：添加规则后需要手动将规则移动至对应drop规则前面！
