# QT在线安装更换国内源

> 参考资料：<https://blog.csdn.net/yanchenyu365/article/details/124499087>

## 选择安装源

+ 进入[qt mirror list](https://download.qt.io/static/mirrorlist/)页面，选择离自己最近的安装源，本教程选择nju源：<https://mirrors.nju.edu.cn/qt/>

## 下载qt在线安装工具

+ 进入<https://mirrors.nju.edu.cn/qt/official_releases/online_installers/>页面，下载```qt-unified-windows-x64-online.exe```在线安装工具。

## 执行在线安装

+ 进入存放```qt-unified-windows-x64-online.exe```的目录，同时按```shift```+```鼠标右键```，选择```在此处打开powershell窗口```

+ 执行命令并指定源：

    ```powershell
    .\qt-unified-windows-x64-online.exe --mirror https://mirrors.nju.edu.cn/qt/
    ```

+ 如果有任何错误提示，请关闭打开的安装窗口，检查命令并重试。

+ 如无错误提示，则正常在线安装即可。
