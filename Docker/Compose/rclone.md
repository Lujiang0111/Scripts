# rclone

## 创建目录

```shell
# config dir
rm -rf /opt/docker/rclone/config
mkdir -p /opt/docker/rclone/config
chmod 777 /opt/docker/rclone/config

# data dir
mkdir -p /mnt/ssd/download/rclone
chmod 777 /mnt/ssd/download/rclone
```

## Docker compose

```yml
services:
  rclone:
    container_name: rclone
    image: rclone/rclone:latest
    environment:
      - UID=1000
      - GID=1000
      - TZ=Asia/Shanghai
    volumes:
      - /opt/docker/rclone/config:/config/rclone
      - /mnt/ssd/download/rclone:/data
    networks:
      macvlan_enp6s18:
        ipv4_address: 172.28.8.46
    restart: unless-stopped
networks:
  macvlan_enp6s18:
    external: true
```

## webui地址

<http://172.28.8.46:8080>
