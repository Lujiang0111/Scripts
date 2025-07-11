# 常用脚本

## 循环运行停止进程

+ 文件名 : `cycle_run_stop.sh`
+ 使用方式：
  + `sh cycle_run_stop.sh exe_file run_duration(s) stop_duration(s)`

```shell
bash cycle_run_stop.sh smartd 60 60
```

## ssh保活

+ 文件名 : `ssh_keep_alive.sh`
+ 使用方式：
  + `sh ssh_keep_alive.sh [sleep_duration(s)]`

```shell
bash ssh_keep_alive.sh 30
```

## 循环记录进程top状态

+ 文件名 : `record_pid_top_stats.py`
+ 使用方式：
  + `python3 record_pid_top_stats.py pid [interval(s)]`

```shell
python3 record_pid_top_stats.py 5515 5
```

## 隔离特定CPU核

+ 文件名 : `iisolate_core.sh`
+ 使用方式：
  + 隔离核：
    + `bash isolate_core.sh install isolate_cores`
      + isolate_cores：隔离哪些核，用逗号分隔
  + 卸载隔离核：
    + `bash isolate_core.sh uninstall`

```shell
bash isolate_core.sh install 14,15
```
