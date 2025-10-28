# 解决automake编译问题

> 参考资料：<https://blog.csdn.net/whatday/article/details/102473565>

## automake下载地址

<https://ftp.gnu.org/gnu/automake>

## 错误信息

**automake**在CentOS环境下编译时会提示`help2man: can't get '--help' info from automake`，导致编译失败。

## 解决方案

```shell
./configure
vim Makefile
```

在`doc/automake-$(APIVERSION).1: $(automake_script) lib/Automake/Config.pm`对应行，添加`--no-discard-stderr`编译选项

```makefile
doc/automake-$(APIVERSION).1: $(automake_script) lib/Automake/Config.pm
    $(AM_V_GEN):; HELP2MAN_NAME="Generate Makefile.in files for configure from Makefile.am"; export HELP2MAN_NAME; $(update_mans) $(automake_script) --no-discard-stderr
```

vim查找内容为

```plain
doc\/automake-\$(APIVERSION
```

修改后便可正常编译

```shell
make -j8
make install
```
