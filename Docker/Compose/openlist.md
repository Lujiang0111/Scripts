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
      macvlan_ens18:
        ipv4_address: 172.28.8.46
    restart: unless-stopped
networks:
  macvlan_ens18:
    external: true
```

## webui地址

<http://172.28.8.46:5244>

## Unraid

### 创建目录

```shell
mkdir -p /mnt/user/appdata/openlist
mkdir -p /mnt/user/download/openlist
```

### 模板

+ `my-openlist.xml`

```xml
<?xml version="1.0"?>
<Container version="2">
  <Name>openlist</Name>
  <Repository>openlistteam/openlist:latest</Repository>
  <Registry>https://doc.oplist.org/guide/installation/docker</Registry>
  <Network>br0</Network>
  <MyIP>172.28.8.46</MyIP>
  <Shell>sh</Shell>
  <Privileged>false</Privileged>
  <Support/>
  <Project/>
  <Overview/>
  <Category/>
  <WebUI>http://[IP]:[PORT:5244]</WebUI>
  <TemplateURL/>
  <Icon>https://raw.githubusercontent.com/OpenListTeam/Logo/main/logo.png</Icon>
  <ExtraParams>--user 1000:100</ExtraParams>
  <PostArgs/>
  <CPUset/>
  <DateInstalled>1765374894</DateInstalled>
  <DonateText/>
  <DonateLink/>
  <Requires/>
  <Config Name="Config dir" Target="/opt/openlist/data" Default="/mnt/user/appdata/openlist" Mode="rw" Description="" Type="Path" Display="always" Required="false" Mask="false">/mnt/user/appdata/openlist</Config>
  <Config Name="Download dir" Target="/downloads" Default="/mnt/user/download/openlist" Mode="rw" Description="" Type="Path" Display="always" Required="false" Mask="false">/mnt/user/download/openlist</Config>
  <Config Name="UMASK" Target="UMASK" Default="022" Mode="" Description="" Type="Variable" Display="advanced" Required="false" Mask="false">022</Config>
  <Config Name="Timezone" Target="TZ" Default="Asia/Shanghai" Mode="" Description="" Type="Variable" Display="advanced" Required="false" Mask="false">Asia/Shanghai</Config>
  <TailscaleStateDir/>
</Container>
```
