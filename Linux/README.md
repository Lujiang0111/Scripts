# Linux tips

## nohup不打印日志的方法

```shell
nohup sh run.sh > /dev/null 2>&1 &
```

## nohup运行python脚本

+ python添加```-u```参数，不启用输出缓冲

```shell
nohup python3 -u record_pid_top_stats.py 5524 1 &
```

## 使用通配符`*`时打印文件名

```shell
for file in *; do
    if [[ -f "${file}" ]]; then
        output=$(${your_command} 2>&1 | grep ${your_grep})
        if [ -n "${output}" ]; then
            echo -e "File: ${file}"
            echo -e "${output}"
            echo "----------------"
        fi
    fi
done
```

## 测试NTP服务器是否可用

```shell
ntpdate -d ${ntp_server}
```
