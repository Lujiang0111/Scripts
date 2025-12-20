# Unraid Docker设置

## 拉取指定版本的docker

**Repository**项填写的仓库加```:版本```，例如：

```plain
lscr.io/linuxserver/qbittorrent:4.5.5
```

## docker模板存放位置

```shell
/boot/config/plugins/dockerMan/templates-user
```

## Docker镜像自定义DNS

+ 选择docker，编辑设置，切换到Advanced View
+ 在```Extra Parameters```选项中添加自定义dns

    ```plain
    --dns 123.123.123.123 --dns 123.123.123.124
    ```
