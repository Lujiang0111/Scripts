# Pve

## 查看硬盘所属硬盘控制器

```shell
ls -la /sys/dev/block/|grep -v loop |grep -v dm
```
