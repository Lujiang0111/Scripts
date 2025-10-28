# Unraid安装黑群晖

## 新建虚拟机

1. 新建黑群晖镜像存储文件夹`/mnt/user/domains/DSM`。
1. 下载[引导镜像](https://github.com/RROrg/rr/releases)，解压出img镜像，上传至镜像存储文件夹。
1. Unraid中新建虚拟机，按下表所示设置

    | 名称 | 设置值 |
    | - | - |
    | OS | Linux |
    | Name | DSM |
    | CPU | 1/2/4/8个 |
    | 内存 | 4G以上 |
    | Machine | Q35 |
    | BIOS | OVMF |
    | USB Controller | 3.0(qemu XHCI) |
    | Primary vDisk Location | Manual，路径选择`/mnt/user/domains/DSM/rr.img` |
    | Primary vDisk Bus | SATA |
    | 直通 | 需要直通的设备 |

## 编译黑群晖引导文件

1. 启动虚拟机，选择`Configure Loader`。
1. 根据虚拟机shell提示，访问`http://ip:7681`进入群晖安装画面。
1. 选择`Choose a model`，选择`SA6400`。
1. 选择`Choose a version`，选择安装版本。
1. 复制pat的url，下载并保存到本地。
1. 选择`Kernel`，16核以上需要切换成`custom`。
1. 选择`Addons menu` -> `Add an addon` -> `nvmesystem`。
1. 选择`Cmdline menu` -> `Define SN/MAC`，设置SN码和MAC地址。
1. 选择`Build the loader`，开始编译黑群晖引导文件。
1. 选择`Boot the loader`，等待一段时间后web会提示编译成功。
