# lean源码编译指南

> 参考资料：<https://github.com/coolsnowwolf/lede>

## 安装依赖

+ 首先装好Linux 系统，推荐Ubuntu LTS。

+ 安装编译依赖

```shell
sudo clear
```

```shell
sudo apt update -y
```

```shell
sudo apt full-upgrade -y
```

```shell
sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev \
libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev \
libssl-dev libtool lrzsz mkisofs msmtp ninja-build p7zip p7zip-full patch pkgconf python3 \
python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig texinfo \
uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
```

## 下载源代码

```shell
git clone --depth=1 https://github.com/coolsnowwolf/lede
cd lede
```

## 添加额外源

+ [kenzok8整合版](https://github.com/kenzok8/openwrt-packages)

```shell
cat <<- EOF >> feeds.conf.default
src-git kenzo https://github.com/kenzok8/openwrt-packages
src-git small https://github.com/kenzok8/small
EOF
```

+ [ssrp](https://github.com/fw876/helloworld)

```shell
cat <<- EOF >> feeds.conf.default
src-git helloworld https://github.com/fw876/helloworld.git
EOF
```

+ [passwall](https://github.com/xiaorouji/openwrt-passwall)

```shell
cat <<- EOF >> feeds.conf.default
src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall.git;packages
src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall.git;luci
EOF
```

+ [openclash](https://github.com/vernesong/OpenClash/tree/dev)

```shell
cat <<- EOF >> feeds.conf.default
src-git openclash https://github.com/vernesong/OpenClash.git;dev
EOF
```

+ [自用源](https://github.com/Lujiang0111/openwrt-packages)

```shell
sed -i '1 i src-git lujiang0111 https://github.com/Lujiang0111/openwrt-packages.git' feeds.conf.default
```

## 更新feeds

```shell
./scripts/feeds update -a
./scripts/feeds install -a
```

## 添加自定义包

+ [mosdns](https://github.com/sbwml/luci-app-mosdns)

```shell
# drop mosdns and v2ray-geodata packages that come with the source
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f

git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
```

+ [smartdns](https://github.com/pymumu/luci-app-smartdns)

```shell
WORKINGDIR="`pwd`/feeds/packages/net/smartdns"
mkdir $WORKINGDIR -p
rm $WORKINGDIR/* -fr
wget https://github.com/pymumu/openwrt-smartdns/archive/master.zip -O $WORKINGDIR/master.zip
unzip $WORKINGDIR/master.zip -d $WORKINGDIR
mv $WORKINGDIR/openwrt-smartdns-master/* $WORKINGDIR/
rmdir $WORKINGDIR/openwrt-smartdns-master
rm $WORKINGDIR/master.zip

LUCIBRANCH="lede"
WORKINGDIR="`pwd`/feeds/luci/applications/luci-app-smartdns"
mkdir $WORKINGDIR -p
rm $WORKINGDIR/* -fr
wget https://github.com/pymumu/luci-app-smartdns/archive/${LUCIBRANCH}.zip -O $WORKINGDIR/${LUCIBRANCH}.zip
unzip $WORKINGDIR/${LUCIBRANCH}.zip -d $WORKINGDIR
mv $WORKINGDIR/luci-app-smartdns-${LUCIBRANCH}/* $WORKINGDIR/
rmdir $WORKINGDIR/luci-app-smartdns-${LUCIBRANCH}
rm $WORKINGDIR/${LUCIBRANCH}.zip
```

+ [luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon/tree/18.06)

```shell
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b 18.06 --depth=1 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
```

+ [luci-app-argon-config](https://github.com/jerrykuku/luci-app-argon-config/tree/18.06)

```shell
rm -rf feeds/luci/applications/luci-app-argon-config
git clone -b 18.06 --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git feeds/luci/applications/luci-app-argon-config
```

## 修改具体配置

### 修改内核版本

```shell
vim target/linux/x86/Makefile
```

修改`KERNEL_PATCHVER:`为自己所需要的内核版本：

```makefile
# 修改为5.4内核
KERNEL_PATCHVER:=5.4
```

### 修改LAN口IP设置

```shell
vim package/base-files/files/bin/config_generate
```

修改LAN口ip`192.168.1.1`为自己所需要的：

```shell
lan) ipad=${ipaddr:-"192.168.1.1"} ;;
```

### 开启ssr-plus的insecure选项

```shell
vim feeds/helloworld/luci-app-ssr-plus/root/usr/share/shadowsocksr/subscribe.lua
```

修改processData函数Trojan分支的**result.insecure**选项为`1`

```lua
-- 将下方result.insecure的值修改为1

-- 按照官方的建议 默认验证ssl证书
result.insecure = "0"
```

### 修改passwall的启动延时

```shell
vim feeds/passwall_luci/luci-app-passwall/root/usr/share/passwall/0_default_config
```

将`option start_delay`的值从60修改为`5`

```lua
option start_delay '5'
```

## 修改编译文件

+ 去除所有预装application

```shell
# delete automount autosamba
sed -i 's/automount \|autosamba //g' target/linux/x86/Makefile

# delete luci-app-* block-mount ddns-
sed -i 's/\<luci-app-[^ ]* \|block-mount \|\<ddns-[^ ]* //g' include/target.mk

# add wget-ssl openssl-util
sed -i '/curl/ s/curl/curl wget-ssl openssl-util/' include/target.mk
```

## 编译选项

```shell
./scripts/feeds install -a
make menuconfig
```

### Target Images

+ 勾选(y)`Build PVE/KVM image files`
+ **Kernel partition size**改为`32`(依实际情况修改)。
+ **Root filesystem partition size**改为`8000`(依实际情况修改)。

### LuCI -> Applications

+ 勾选(y)`luci-app-argon-config`、`luci-app-aria2`、`luci-app-openclash`、`luci-app-smartdns`、`luci-app-uugamebooster`、`luci-app-vlmcsd`、`luci-app-vsftpd`、`luci-app-wireguard`等插件。

+ 编译ssrp时，如果需要IPv6解析，需要取消勾选(n)`ChinaDNS-NG`。

### Network -> SSH

+ 勾选(y)`openssh-sftp-server`。

## 无线网卡相关配置

### Kernel modules -> Wireless Drivers

+ 勾选(y)`kmod-mt76x2u` *(NETGEAR A6210)*
+ 勾选(y)`kmod-rtl8821cu` *(COMFAST CF-811AC)*

### Network -> WirelessAPD

+ 勾选(y)`hostapd`

## 开始编译

+ 下载dl库

```shell
make -j$(nproc) download V=s
```

+ 编译固件

```shell
nohup make -j$(nproc) V=s &
```
