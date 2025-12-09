# aria2 pro

> 参考资料：<https://github.com/P3TERX/Aria2-Pro-Docker>

## 创建目录

```shell
# config dir
rm -rf /opt/docker/aria2-pro/config
mkdir -p /opt/docker/aria2-pro/config
chmod 777 /opt/docker/aria2-pro/config

# data dir
mkdir -p /mnt/ssd/download/aria2-pro
chmod 777 /mnt/ssd/download/aria2-pro
```

## Docker compose

```yml
services:
  aria2-pro:
    container_name: aria2-pro
    image: p3terx/aria2-pro:latest
    environment:
      - PUID=1000
      - PGID=1000
      - UMASK_SET=022
      - RPC_SECRET=your_secret # set your_secret
      - RPC_PORT=56800
      - LISTEN_PORT=56888
      - DISK_CACHE=64M
      - IPV6_MODE=true
      - UPDATE_TRACKERS=true
      - TZ=Asia/Shanghai
    volumes:
      - /opt/docker/aria2-pro/config:/config
      - /mnt/ssd/download/aria2-pro:/downloads
    networks:
      macvlan_enp6s18:
        ipv4_address: 172.28.8.43
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: 1m
  ariang:
    container_name: ariang
    image: p3terx/ariang:latest
    command: --port 6880
    ports:
      - 56880:6880
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: 1m
networks:
  macvlan_enp6s18:
    external: true
```

## ariang地址

```shell
http://IP:56880/
```

## Unraid 模板

+ `my-aria2-pro.xml`

```xml
<?xml version="1.0"?>
<Container version="2">
  <Name>aria2-pro</Name>
  <Repository>p3terx/aria2-pro:latest</Repository>
  <Registry />
  <Network>br0</Network>
  <MyIP>172.28.8.43,fd08::43</MyIP>
  <Shell>sh</Shell>
  <Privileged>false</Privileged>
  <Support />
  <Project />
  <Overview />
  <Category />
  <WebUI>http://ariang.mayswind.net/latest</WebUI>
  <TemplateURL />
  <Icon>https://raw.githubusercontent.com/Lujiang0111/Scripts/refs/heads/main/Resource/Icon/AriaNg.ico</Icon>
  <ExtraParams />
  <PostArgs />
  <CPUset />
  <DateInstalled>1743401591</DateInstalled>
  <DonateText />
  <DonateLink />
  <Requires />
  <Config Name="download dir" Target="/downloads" Default="" Mode="rw" Description="" Type="Path"
    Display="always" Required="true" Mask="false">/mnt/user/download/aria2-pro</Config>
  <Config Name="config dir" Target="/config" Default="/mnt/user/appdata/aria2-pro" Mode="rw"
    Description="" Type="Path" Display="advanced" Required="true" Mask="false">/mnt/user/appdata/aria2-pro</Config>
  <Config Name="PUID" Target="PUID" Default="1000" Mode="" Description="" Type="Variable"
    Display="advanced" Required="true" Mask="false">1000</Config>
  <Config Name="PGID" Target="PGID" Default="100" Mode="" Description="" Type="Variable"
    Display="advanced" Required="true" Mask="false">100</Config>
  <Config Name="UMASK" Target="UMASK_SET" Default="022" Mode="" Description="" Type="Variable"
    Display="advanced" Required="true" Mask="false">022</Config>
  <Config Name="rpc secret" Target="RPC_SECRET" Default="" Mode="" Description="" Type="Variable"
    Display="always" Required="true" Mask="true"></Config>
  <Config Name="rpc port" Target="RPC_PORT" Default="6800" Mode="" Description="" Type="Variable"
    Display="always" Required="true" Mask="false">56800</Config>
  <Config Name="listen port" Target="LISTEN_PORT" Default="6888" Mode="" Description=""
    Type="Variable" Display="always" Required="true" Mask="false">56888</Config>
  <Config Name="disk cache" Target="DISK_CACHE" Default="32M" Mode="" Description="" Type="Variable"
    Display="always" Required="true" Mask="false">64M</Config>
  <Config Name="IPv6" Target="IPV6_MODE" Default="false" Mode="" Description="" Type="Variable"
    Display="always" Required="false" Mask="false">true</Config>
  <Config Name="update trackers" Target="UPDATE_TRACKERS" Default="true" Mode="" Description=""
    Type="Variable" Display="always" Required="false" Mask="false">true</Config>
  <TailscaleStateDir />
</Container>
```

+ `my-ariang.xml`

```xml
<?xml version="1.0"?>
<Container version="2">
  <Name>ariang</Name>
  <Repository>p3terx/ariang:latest</Repository>
  <Registry />
  <Network>bridge</Network>
  <MyIP />
  <Shell>sh</Shell>
  <Privileged>false</Privileged>
  <Support />
  <Project />
  <Overview />
  <Category />
  <WebUI>http://[IP]:[PORT:6880]</WebUI>
  <TemplateURL />
  <Icon>https://raw.githubusercontent.com/Lujiang0111/Scripts/refs/heads/main/Resource/Icon/AriaNg.ico</Icon>
  <ExtraParams />
  <PostArgs />
  <CPUset />
  <DateInstalled>1743402080</DateInstalled>
  <DonateText />
  <DonateLink />
  <Requires />
  <Config Name="http port" Target="6880" Default="6880" Mode="tcp" Description="" Type="Port"
    Display="always" Required="true" Mask="false">56880</Config>
  <TailscaleStateDir />
</Container>
```
