# Pve编译黑群晖

## 目标环境

+ 黑群晖版本：SA6400
+ VM ID：123
+ CPU数量32，需要使用custom内核
+ SN640直通，纯固态NAS
+ SRIOV直通核显

## 新建虚拟机

+ 常规

    | 名称 | 设置值 |
    | - | - |
    | 名称 | dsm |
    | 开机自启动 | ✔ |

+ 操作系统

    | 名称 | 设置值 |
    | - | - |
    | 操作系统 | 不使用任何介质 |
    | 客户机操作系统 | Linux 6.x-2.6 Kernel |

+ 系统

    | 名称 | 设置值 |
    | - | - |
    | 机型 | q35 |
    | BIOS | OVMF |
    | 预注册密钥 | ❌ |

+ 磁盘
  + 删除原有磁盘，显示`没有磁盘`

+ CPU

    | 名称 | 设置值 |
    | - | - |
    | 插槽 | 1 |
    | 类别 | host |
    | 核心 | 32 |

+ 内存

    | 名称 | 设置值 |
    | - | - |
    | 内存 | 32768 |

+ 网络

    | 名称 | 设置值 |
    | - | - |
    | 桥接 | vmbr0 |
    | 模型 | VirtIO |

## 导入rr引导镜像

1. 下载[rr引导镜像](https://github.com/RROrg/rr/releases)，解压出img镜像，上传至Pve。

1. 运行如下命令，将img镜像导入虚拟机

```shell
qm importdisk 123 rr.img local-lvm
```

1. 点击**对应虚拟机** -> **硬件**，双击`未使用的磁盘0`，总线改为`SATA`，点击添加。

1. 点击**对应虚拟机** -> **选项**，修改引导顺序为`SATA0`。

## 直通设备

点击**对应虚拟机** -> **硬件**，添加需要直通的设备。

+ SN640：勾选`PCI-Express`。
+ 核显：**不要直通.0设备**，勾选`主GPU`、`PCI-Express`。

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
