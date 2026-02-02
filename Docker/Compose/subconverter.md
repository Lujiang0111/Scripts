# subconverter

> 参考资料：<https://github.com/tindy2013/subconverter/blob/master/README-docker.md>
>
> 参考资料：<https://github.com/asdlokj1qpi233/subconverter/blob/master/README-docker.md>

## Docker compose

```yml
services:
  subconverter:
    restart: unless-stopped
    image: asdlokj1qpi23/subconverter:latest
    container_name: subconverter
    networks:
      macvlan_ens18:
        ipv4_address: 172.28.8.42
        ipv6_address: fd08::42
networks:
  macvlan_ens18:
    external: true
```

## 测试服务器

<http://172.28.8.42:25500/version>

## 清空缓存

<http://172.28.8.42:25500/flushcache?token=password>

## 订阅模板

```html
http://172.28.8.42:25500/sub?target=clash&url=%URL%&config=https%3A%2F%2Fraw.githubusercontent.com%2FLujiang0111%2FScripts%2Frefs%2Fheads%2Fmain%2FOpenwrt%2FClash%2Frules_mini.ini&filename=%FILE_NAME%&emoji=true&udp=true
```

## Unraid 模板

+ `my-subconverter.xml`

```xml
<?xml version="1.0"?>
<Container version="2">
  <Name>subconverter</Name>
  <Repository>asdlokj1qpi23/subconverter:latest</Repository>
  <Registry />
  <Network>br0</Network>
  <MyIP>172.28.8.42,fd08::42</MyIP>
  <Shell>sh</Shell>
  <Privileged>false</Privileged>
  <Support />
  <Project />
  <Overview />
  <Category />
  <WebUI>http://[IP]:[PORT:25500]/flushcache?token=password</WebUI>
  <TemplateURL />
  <Icon>https://raw.githubusercontent.com/Lujiang0111/Scripts/main/Resource/Icon/subconverter-icon.png</Icon>
  <ExtraParams />
  <PostArgs />
  <CPUset />
  <DateInstalled>1743399523</DateInstalled>
  <DonateText />
  <DonateLink />
  <Requires />
  <TailscaleStateDir />
</Container>
```
