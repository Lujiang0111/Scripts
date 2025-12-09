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

<http://172.28.8.41:58080>

## Unraid 模板

+ `my-qbittorrent.xml`

```xml
<?xml version="1.0"?>
<Container version="2">
  <Name>qbittorrent</Name>
  <Repository>lscr.io/linuxserver/qbittorrent:4.5.5</Repository>
  <Registry>https://github.com/orgs/linuxserver/packages/container/package/qbittorrent</Registry>
  <Network>br0</Network>
  <MyIP>172.28.8.41,fd08::41</MyIP>
  <Shell>bash</Shell>
  <Privileged>false</Privileged>
  <Support>https://github.com/linuxserver/docker-qbittorrent/issues/new/choose</Support>
  <Project>https://www.qbittorrent.org/</Project>
  <Overview>The Qbittorrent(https://www.qbittorrent.org/) project aims to provide an open-source software alternative to &#xB5;Torrent. qBittorrent is based on the Qt toolkit and libtorrent-rasterbar library.</Overview>
  <Category>Downloaders:</Category>
  <WebUI>http://[IP]:[PORT:58080]</WebUI>
  <TemplateURL>https://raw.githubusercontent.com/linuxserver/templates/main/unraid/qbittorrent.xml</TemplateURL>
  <Icon>https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/qbittorrent-logo.png</Icon>
  <ExtraParams>--dns 123.123.123.123 --dns 123.123.123.124</ExtraParams>
  <PostArgs/>
  <CPUset/>
  <DateInstalled>1765259888</DateInstalled>
  <DonateText>Donations</DonateText>
  <DonateLink>https://www.linuxserver.io/donate</DonateLink>
  <Requires/>
  <Config Name="Path: /downloads" Target="/downloads" Default="" Mode="rw" Description="Location of downloads on disk." Type="Path" Display="always" Required="false" Mask="false">/mnt/user/download/qbittorrent</Config>
  <Config Name="WEBUI_PORT" Target="WEBUI_PORT" Default="8080" Mode="{3}" Description="for changing the port of the web UI, see below for explanation" Type="Variable" Display="always" Required="true" Mask="false">58080</Config>
  <Config Name="TORRENTING_PORT" Target="TORRENTING_PORT" Default="6881" Mode="{3}" Description="for changing the port of tcp/udp connection, see below for explanation" Type="Variable" Display="always" Required="true" Mask="false">56881</Config>
  <Config Name="Appdata" Target="/config" Default="/mnt/user/appdata/qbittorrent" Mode="rw" Description="Contains all relevant configuration files." Type="Path" Display="advanced" Required="true" Mask="false">/mnt/user/appdata/qbittorrent</Config>
  <Config Name="PUID" Target="PUID" Default="99" Mode="{3}" Description="" Type="Variable" Display="advanced" Required="true" Mask="false">1000</Config>
  <Config Name="PGID" Target="PGID" Default="100" Mode="{3}" Description="" Type="Variable" Display="advanced" Required="true" Mask="false">100</Config>
  <Config Name="UMASK" Target="UMASK" Default="022" Mode="{3}" Description="" Type="Variable" Display="advanced" Required="false" Mask="false">022</Config>
  <TailscaleStateDir/>
</Container>
```
