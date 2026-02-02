# syncthing

> 参考资料：<https://hub.docker.com/r/linuxserver/syncthing>

## 创建目录

```shell
# config dir
rm -rf /opt/docker/syncthing/config
mkdir -p /opt/docker/syncthing/config
chmod 777 /opt/docker/syncthing/config

# data dir
mkdir -p /mnt/ssd/download/syncthing
chmod 777 /mnt/ssd/download/syncthing
```

## 端口说明

+ `8384/tcp` - Web管理界面端口，建议只对内网开放
+ `22000/tcp` - 设备之间的数据同步端口（TCP方式），需要开启端口转发
+ `22000/udp` - 设备之间的数据同步端口（QUIC方式），由于QoS严重，一般直接禁用。
+ `21027/udp` - 局域网自动发现端口，建议只对内网开放

## Docker compose

```yml
services:
  syncthing:
    image: lscr.io/linuxserver/syncthing:latest
    container_name: syncthing
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
    volumes:
      - /opt/docker/syncthing/config:/config
      - /mnt/ssd/download/syncthing:/sync_data
    restart: unless-stopped
    networks:
      macvlan_ens18:
        ipv4_address: 172.28.8.44
        ipv6_address: fd08::44
networks:
  macvlan_ens18:
    external: true
```

## web管理页面地址

<http://172.28.8.44:8384>
