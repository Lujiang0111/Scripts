# Pve虚拟机UEFI引导关闭安全启动

## 方法一：创建虚拟机时取消预注册密钥

+ 创建虚拟机时，取消勾选**系统** - **预注册密钥**

## 方法二：在BIOS取消

+ 在Proxmox VE7.1-8.x版本中，引入了TPM 2.0，在默认创建OVMF虚拟时，会启用安全启动，导致无法识别到OC、Clover等引导,无法安装Linux系统等等问题。
+ 关闭方法如下：
  + 启动虚拟机，出现Proxmox画面时。按ESC，进入BIOS。
  + 依次选择【Device Manager】——【Secure Boot Configuration】
  + 取消勾选【Attempt Secure Boot】
