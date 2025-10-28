# CentOS7更换Vault源

+ CentOS7已经在2024年6月30日结束生命周期，官方不再进行支持维护,如果使用官方yum源下载会报404。
+ 可以使用以下脚本(`centos7-change-vault.sh`)将默认源改为Vault源实现环境的安装。

```shell
#!/bin/bash

repo_file="/etc/yum.repos.d/CentOS-Base.repo"

if [ "$(id -u)" != "0" ]; then
  echo "Error: This script needs to be run with root privileges" 1>&2
  exit 1
fi

echo -e "Backup old CentOS-Base.repo file..."
cp ${repo_file} "${repo_file}.bak"

# ustc mirror
sed -i.bak \
  -e 's|^mirrorlist=|#mirrorlist=|g' \
  -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.ustc.edu.cn/centos-vault/centos|g' \
  ${repo_file}

echo "updating yum cache..."
yum clean all
yum makecache
echo -e "Successfully replaced with CentOS Vault repository source"
```
