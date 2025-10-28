# VisualStudio安装特定版本

> 参考资料：<https://stackoverflow.com/questions/72232850/how-to-install-specific-version-of-visual-studio-2022#comment139592540_78637995>

+ 注意：只有专业版和企业版才能安装特定版本

## 直接通过网页下载特定安装程序

+ <https://learn.microsoft.com/en-us/visualstudio/releases/2022/release-history#evergreen-bootstrappers>

## 通过命令行方式指定安装源

```shell
./VisualStudioSetup.exe --channelUri https://aka.ms/vs/17/release.LTSC.17.8/channel
```
