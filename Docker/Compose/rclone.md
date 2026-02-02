# rclone

+ **还不完善**

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
    cap_add:
      - SYS_ADMIN
    devices:
      - /dev/fuse:/dev/fuse
    security_opt:
      - apparmor=unconfined
    volumes:
      - /opt/docker/rclone/config:/config/rclone
      - /mnt/ssd/download/rclone:/data
    command: rcd --rc-web-gui --rc-addr 0.0.0.0:5572 --rc-user #username --rc-pass #password
    networks:
      macvlan_ens18:
        ipv4_address: 172.28.8.47
    restart: unless-stopped
networks:
  macvlan_ens18:
    external: true
```

## webui地址

<http://172.28.8.47:5572>
