# cupsd打印服务

> 参考资料：<https://hub.docker.com/r/olbat/cupsd>

## 创建目录

```shell
# config dir
rm -rf /opt/docker/cupsd/config
mkdir -p /opt/docker/cupsd/config
chmod 777 /opt/docker/cupsd/config
wget https://raw.githubusercontent.com/olbat/dockerfiles/refs/heads/master/cupsd/cupsd.conf -O /opt/docker/cupsd/config/cupsd.conf
wget https://raw.githubusercontent.com/Lujiang0111/Scripts/refs/heads/main/Resource/Other/printer_test_page.pdf -O /opt/docker/cupsd/config/printer_test_page.pdf
```

## Docker compose

```yml
services:
  cupsd:
    container_name: cupsd
    image: olbat/cupsd:stable
    volumes:
      - /opt/docker/cupsd/config/cupsd.conf:/etc/cups/cupsd.conf
      - /opt/docker/cupsd/config/printer_test_page.pdf:/printer_test_page.pdf
    networks:
      macvlan_enp6s18:
        ipv4_address: 172.28.8.45
        ipv6_address: fd08::45
    restart: unless-stopped
networks:
  macvlan_enp6s18:
    external: true
```

## webui地址

<https://172.28.8.45:631/>

+ 默认用户名/密码：`print`/`print`。
