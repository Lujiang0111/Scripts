# cupsd打印服务

> 参考资料：<https://hub.docker.com/r/olbat/cupsd>

## Docker compose

```yml
services:
  cupsd:
    container_name: cupsd
    image: olbat/cupsd:stable
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

+ <https://172.28.8.45:631/>
  + 默认用户名/密码：`print`/`print`。
  + ipp打印机地址一般为`ipp://ip/ipp/print`
  + ipp地址的打印机可以选择驱动为`Generic`->`IPP Everywhere(tm)`

## 打印测试页

```shell
docker exec cupsd lp -d L6279 /usr/share/cups/data/testprint
```

将`L6279`改为cpus中设置的打印机名称。

## 添加自动打印任务

编辑`crontab`

```shell
sudo crontab -e
```

添加下面这一行

```shell
0 0 * * 2 /usr/bin/docker exec cupsd lp -d L6279 /usr/share/cups/data/testprint >/dev/null 2>&1
```

这代表`每周二 00:00`执行一次打印任务。

## Unraid 模板

+ `my-cupsd.xml`

```xml
<?xml version="1.0"?>
<Container version="2">
  <Name>cupsd</Name>
  <Repository>olbat/cupsd:stable</Repository>
  <Registry>https://hub.docker.com/r/olbat/cupsd</Registry>
  <Network>br0</Network>
  <MyIP>172.28.8.45,fd08::45</MyIP>
  <Shell>sh</Shell>
  <Privileged>false</Privileged>
  <Support/>
  <Project/>
  <Overview/>
  <Category/>
  <WebUI>http://[IP]:[PORT:631]</WebUI>
  <TemplateURL/>
  <Icon>https://raw.githubusercontent.com/Lujiang0111/Scripts/refs/heads/main/Resource/Icon/cupsd.png</Icon>
  <ExtraParams/>
  <PostArgs/>
  <CPUset/>
  <DateInstalled>1766244489</DateInstalled>
  <DonateText/>
  <DonateLink/>
  <Requires/>
  <TailscaleStateDir/>
</Container>
```

## Unraid计划任务

使用`User Scripts`插件完成
