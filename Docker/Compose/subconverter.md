# Docker配置subconverter

> 参考资料：<https://github.com/tindy2013/subconverter/blob/master/README-docker.md>

## 配置docker容器

+ `docker_compose.yml`

```yml
services:
  subconverter:
    restart: unless-stopped
    image: tindy2013/subconverter:latest
    container_name: subconverter
    networks:
      macvlan_enp6s18:
        ipv4_address: 192.168.8.42
        ipv6_address: fd08::42
networks:
  macvlan_enp6s18:
    external: true
```

## 测试服务器

<http://192.168.8.42:25500/version>

## 清空缓存

<http://192.168.8.42:25500/flushcache?token=password>

## Unraid 模板

+ `my-subconverter.xml`

```xml
<?xml version="1.0"?>
<Container version="2">
  <Name>subconverter</Name>
  <Repository>tindy2013/subconverter:latest</Repository>
  <Registry />
  <Network>br0</Network>
  <MyIP>192.168.8.42,fd08::42</MyIP>
  <Shell>sh</Shell>
  <Privileged>false</Privileged>
  <Support />
  <Project />
  <Overview />
  <Category />
  <WebUI>http://[IP]:[PORT:25500]/flushcache?token=password</WebUI>
  <TemplateURL />
  <Icon>
    https://raw.githubusercontent.com/Lujiang0111/Scripts/35ce7b8e2ba4f850b8a61195acf83aafcc368686/Resource/Icon/subconverter-icon.png</Icon>
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
