# Openwrt

+ 官方源码：<https://github.com/openwrt/openwrt>
+ uu加速器最新版本：<http://router.uu.163.com/api/plugin?type=openwrt-x86_64>
+ clash_meta内核下载
  + <https://github.com/MetaCubeX/mihomo/releases>
  + <https://github.com/vernesong/OpenClash/tree/core/dev/meta>
  + <https://github.com/juewuy/ShellCrash/tree/master/bin/meta>

## 配置定期重启

> 参考资料：<https://openwrt.org/zh/docs/guide-user/base-system/cron>

```shell
# 每天上午4:30执行重启
# 注意: 为了防止循环重启的怪圈，需要推迟70秒钟执行重启
# 在/etc目录下touch修改一个文件的时间属性，并且设置
# 为上午4:31然后再执行cron的重启任务.
30 4 * * * sleep 70 && touch /etc/banner && reboot
```
