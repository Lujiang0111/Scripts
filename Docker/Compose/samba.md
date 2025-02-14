# Docker配置samba服务器

> 参考资料：<https://github.com/ServerContainers/samba/tree/master>

## 创建需要共享的目录

```shell
# data dir
mkdir -p /mnt/ssd/fastshare
chmod 777 /mnt/ssd/fastshare
mkdir -p /mnt/ssd/download
chmod 777 /mnt/ssd/download
mkdir -p /mnt/ssd/storage
chmod 777 /mnt/ssd/storage
```

## 配置docker容器

+ `docker_compose.yml`

```yml
services:
  samba:
    restart: unless-stopped
    image: ghcr.io/servercontainers/samba:latest
    container_name: samba
    cap_add:
      - CAP_NET_ADMIN
    environment:
      ACCOUNT_lujiang: your_password # set your_password
      UID_lujiang: 1000
      SAMBA_VOLUME_CONFIG_fastshare: >
        [fastshare]; path=/shares/fastshare;
        guest ok = no; read only = no; browseable = yes;
        create mask = 0664; directory mask = 0775
      SAMBA_VOLUME_CONFIG_download: >
        [download]; path=/shares/download;
        guest ok = no; read only = no; browseable = yes;
        create mask = 0664; directory mask = 0775
      SAMBA_VOLUME_CONFIG_storage: >
        [storage]; path=/shares/storage;
        guest ok = no; read only = no; browseable = yes;
        create mask = 0664; directory mask = 0775
    volumes:
      - /mnt/ssd/fastshare:/shares/fastshare
      - /mnt/ssd/download:/shares/download
      - /mnt/ssd/storage:/shares/storage
    ports:
      - 445:445
```
