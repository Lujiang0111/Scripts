# Debian安装N卡环境

## Pve直通设置

+ 选择`所有功能`，`PCI-Express`

## 安装内核头文件

```shell
apt install -y linux-headers-$(uname -r)
```

## 安装Cuda和Nvida驱动

> 参考资料1：<https://developer.nvidia.com/cuda-downloads>
>
> 参考资料2：<https://github.com/mexersus/debian-nvidia-drivers/blob/main/README.md>

debian13必须按照*参考资料2*执行，其中`wget`的网址可以通过*参考资料1*获取

+ CUDA Toolkit Installer

```shell
# Download and install the CUDA keyring
wget https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb

# Update package list and install CUDA drivers
sudo apt-get update
sudo apt install -y cuda-drivers
```

+ Driver Installer

```shell
sudo apt install -y nvidia-open
```

安装完成后重启系统

```shell
reboot
```

## 禁止内核更新

### 方法一：安装Debian时选择特定内核版本

+ 在Debian系统安装过程中，选择特定内核版本（如`linux-image-6.1.0-25-amd64`）而**不是**`linux-image-amd64`。

### 方法二：使用apt-mark hold命令

1. 查看当前内核版本

    ```shell
    uname -r
    dpkg --list | grep linux-image
    ```

    找到类似于`linux-image-X.X.X`的包名。

1. 锁定内核包

    ```shell
    apt-mark hold linux-image-X.X.X
    ```

## 验证驱动安装

```shell
nvidia-smi
```

如果正确安装，应该会显示当前的显卡信息和驱动版本。

## 安装NVIDIA Container Toolkit

> 参考资料：<https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html>

+ 先安装docker，参考资料：<https://docs.docker.com/engine/install/debian/>

+ 配置生产存储库

```shell
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

+ （可选）配置存储库以使用实验性软件包

```shell
sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

+ 更新软件源

```shell
apt update -y
```

+ 安装`NVIDIA Container Toolkit`

```shell
apt install -y nvidia-container-toolkit
```

## 配置Docker

+ 使用`nvidia-ctk`命令配置容器运行时

```shell
nvidia-ctk runtime configure --runtime=docker
```

+ 重启Docker

```shell
systemctl restart docker
```
