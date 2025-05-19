# FFmpeg调用GPU转码

## 确认FFmpeg支持GPU加速

+ Nvidia显卡

    ```shell
    ffmpeg -encoders | grep nvenc
    ```

+ Amd显卡

    ```shell
    ffmpeg -encoders | grep amf
    ```

+ 如果没有支持，需下载或编译支持硬件加速的FFmpeg版本。

## 基本命令

```shell
ffmpeg -i input.mp4 -c:v hevc_nvenc -preset p7 -rc vbr -b:v 8M -c:a copy output.mp4
```

或

```shell
# Nvidia only
ffmpeg -i input.mp4 -c:v hevc_nvenc -preset p7 -rc vbr -cq 22 -c:a copy output.mp4
```

### 参数说明

+ `-i input.mp4`: 指定输入文件。
+ `-c:v hevc_nvenc`: 使用 NVIDIA NVENC 编码器将视频编码为 H.265。
+ `-preset p7`: NVENC 的预设，`p1`（快）到`p7`（高质量），`p7`提供最佳质量。
+ `-rc vbr`: 使用可变比特率（Variable Bit Rate），适合大多数场景。
+ `-b:v 8M`: 设置视频比特率（如 8Mbps），可根据需要调整。
+ `-cq 22`：CRF模式: 如果优先质量，可用`-cq 22`（NVENC，值 15-30，值越低质量越高）代替`-b:v 8M`。
+ `-c:a copy`: 保持音频流不变，直接复制到输出文件。
+ `output.mp4`:` 输出文件名。

### 其他可选参数

+ 两遍编码: 为更好质量，可使用两遍编码（NVENC 示例）：

    ```shell
    ffmpeg -i input.mp4 -c:v hevc_nvenc -preset p7 -b:v 8M -pass 1 -an -f null /dev/null
    ffmpeg -i input.mp4 -c:v hevc_nvenc -preset p7 -b:v 8M -pass 2 -c:a copy output.mp4
    ```

### 典型参数设置

+ 1080P高质量
  + `-b:v 8M`
  + `-cq 22`
