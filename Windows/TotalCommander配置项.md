# TotalCommander配置项

+ 配置文件位置：`%APPDATA%\GHISLER`
+ 编码格式：`ANSI`（中文系统为`GBK`）

## default.bar

### 添加校验和计算功能

+ 软件：[my_hash](https://github.com/drag0n-app/MyHash)
+ 拷贝文件`MyHash64.exe`、`MyHash64.ini`、`MyHashExt64.dll`到`%Commander_path%\Tools`目录。

```ini
button27=%Commander_path%\Tools\MyHash64.exe
cmd27=MyHash64.exe
param27=%P%S
path27=%commander_path%\Tools\
iconic27=0
menu27=校验和计算
```

## wincmd.ini

### 关闭时最小化

+ 必须配合**同一时间只能打开一个Toal Commander**（`onlyonce=1`）使用。

```ini
[Configuration]
onlyonce=1
MinimizeOnClose=1
```
