# Debian完全禁止IPv6

+ 编辑`/etc/default/grub`文件, 修改`GRUB_CMDLINE_LINUX_DEFAULT`所在行，添加`ipv6.disable=1`

```shell
# check before
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT

sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"$/ ipv6.disable=1\"/" /etc/default/grub

#check after
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT
```

+ 更新grub

```shell
update-grub
reboot
```
