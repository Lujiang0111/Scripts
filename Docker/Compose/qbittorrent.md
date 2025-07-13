# qbittorrent

> 参考资料：<https://hub.docker.com/r/linuxserver/qbittorrent>

## 创建目录

```shell
# config dir
rm -rf /opt/docker/qbittorrent/config
mkdir -p /opt/docker/qbittorrent/config
chmod 777 /opt/docker/qbittorrent/config

# data dir
mkdir -p /mnt/ssd/download/qbittorrent
chmod 777 /mnt/ssd/download/qbittorrent
```

## Docker compose

```yml
services:
  qbittorrent:
    container_name: qbittorrent
    image: lscr.io/linuxserver/qbittorrent:4.5.5
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
      - WEBUI_PORT=58080
      - TORRENTING_PORT=56881
    volumes:
      - /opt/docker/qbittorrent/config:/config
      - /mnt/ssd/download/qbittorrent:/downloads
    networks:
      macvlan_enp6s18:
        ipv4_address: 172.28.8.41
        ipv6_address: fd08::41
    dns:
      - 123.123.123.123
      - 123.123.123.124
    restart: unless-stopped
networks:
  macvlan_enp6s18:
    external: true
```

## webui地址

```shell
http://172.28.8.41:58080
```
