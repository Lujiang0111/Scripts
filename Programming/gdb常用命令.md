# gdb常用命令

## gdb在断点触发时自动打印变量

假设你在调试一个函数`foo(int x)`，你想在函数进入时打印参数`x`。

```bash
(gdb) break foo
(gdb) commands
> print x
> continue
> end
```

+ `break foo`：在函数`foo`的入口处设置断点。
+ `commands`：开始为该断点定义触发时要执行的命令序列。
+ `print x`：当断点触发时打印变量`x`的值。
+ `continue`：打印后继续程序运行（可选，如果不写就会停在断点处等待）。
+ `end`：结束命令序列定义。
