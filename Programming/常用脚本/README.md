# 常用脚本

## 通过头文件生成.def文件

+ `generate_def.py`
+ 使用方式：
  + `python3 generate_def.py project include_dir`

```shell
python3 generate_def.py libsvts ../../../../include/
```

## 循环发送http post请求

+ `request_cyclically.py`
+ 使用方式：
  + `python3 request_cyclically.py uri request_body sleep_sec`

```shell
python3 request_cyclically.py http://192.165.153.207:5656/v0.0/combination '{"2":"3","4":"5"}'
```

## 补丁升级脚本

+ `patch.sh`
+ 使用方式：
  + `bash patch.sh [update|rollback]`
  + update : 备份并升级
  + rollback : 回滚

## 删除文件的第x-y个字节

+ `trim_file.py`
  + 使用方式：见脚本说明
