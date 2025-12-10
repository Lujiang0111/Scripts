# Openlist

> 参考资料：<https://doc.oplist.org/guide/installation/docker>

## 创建目录

```shell
# config dir
rm -rf /opt/docker/openlist/config
mkdir -p /opt/docker/openlist/config
chmod 777 /opt/docker/openlist/config

# data dir
mkdir -p /mnt/ssd/download/openlist
chmod 777 /mnt/ssd/download/openlist
```

## Docker compose

```yml
services:
  openlist:
    container_name: openlist
    image: openlistteam/openlist:latest
    user: "1000:1000"
    environment:
      - TZ=Asia/Shanghai
      - UMASK=022
    volumes:
      - /opt/docker/openlist/config:/opt/openlist/data
      - /mnt/ssd/download/openlist:/downloads
    networks:
      macvlan_enp6s18:
        ipv4_address: 172.28.8.46
    restart: unless-stopped
networks:
  macvlan_enp6s18:
    external: true
```

## webui地址

<http://172.28.8.46:5244>
