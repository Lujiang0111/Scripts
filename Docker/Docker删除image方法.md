# Docker删除image方法

## 查看所有image

```shell
docker images
```

输入命令后显示

```shell
root@debian:~# docker images
REPOSITORY   TAG            IMAGE ID       CREATED       SIZE
openjdk      8-jre-alpine   f7a292bbb70c   4 years ago   84.9MB
```

直接删除`openjdk:8-jre-alpine`会报错，提示信息如下

```shell
root@debian:~# docker rmi openjdk:8-jre-alpine
Error response from daemon: conflict: unable to remove repository reference "openjdk:8-jre-alpine" (must force) - container 2757625603f0 is using its referenced image f7a292bbb70c
```

## 删除image方法

### 查看所有关联容器

```shell
docker ps -a | grep openjdk:8-jre-alpine
```

显示为

```shell
root@debian:~# docker ps -a | grep openjdk:8-jre-alpine
2757625603f0   openjdk:8-jre-alpine   "ash"     12 minutes ago   Exited (0) 7 minutes ago             friendly_bell
```

### 删除所有关联容器

```shell
docker rm 2757625603f0
```

### 删除image

```shell
docker rmi openjdk:8-jre-alpine
```
