# FFmpeg常用命令

## 一键编译ffmpeg

> 参考资料：<https://github.com/BtbN/FFmpeg-Builds>

+ 编译环境：Ubuntu
+ 目标环境：win64, win32, linux64, linuxarm64
+ 编译需求：bash，docker

1. 安装docker

    > 参考资料：<https://docs.docker.com/engine/install/ubuntu/>

2. 切换为root用户

    ```shell
    sudo su
    ```

3. clone源码

    ```shell
    git clone https://github.com/BtbN/FFmpeg-Builds.git
    cd FFmpeg-Builds
    ```

4. 制作对应平台的docker镜像

    ```shell
    ./makeimage.sh win64 nonfree
    ```

5. 编译ffmpeg

    ```shell
    ./build.sh win64 nonfree
    ```

## 转封装

+ 输出udp-ts流

```shell
ffmpeg -re -i input_file -c copy -f mpegts udp://ip:port?pkt_size=1316
```

+ 推送rtmp

```shell
ffmpeg -re -i input_file -c copy -f flv rtmp://your-rtmp-server/live/stream_key
```

## 只接收不输出

```shell
ffmpeg -i rtp://239.3.1.241:8000 -f null -
```

## 编码H.264 CBR码流（libx264）

> 参考资料：<https://trac.ffmpeg.org/wiki/Encode/H.264>

```shell
ffmpeg -i input.mp4 -c:v libx264 -x264-params "nal-hrd=cbr" -b:v 1M -minrate 1M -maxrate 1M -bufsize 2M -pix_fmt yuv420p output.ts
```

## 编码AAC CBR码流（需要libfdk_aac，否则用FFmpeg自带的aac encoder只能编vbr）

> 参考资料：<https://trac.ffmpeg.org/wiki/Encode/AAC>

+ fdk_aac需要ffmpeg带nonfree参数才能编译

```shell
ffmpeg -i input.wav -c:a libfdk_aac -b:a 256k output.m4a
```

## 编码MP3 CBR码流（libmp3lame）

> 参考资料：<https://trac.ffmpeg.org/wiki/Encode/MP3>

```shell
ffmpeg -i input.wav -codec:a libmp3lame -b:a 256k output.mp3
```

## 输出解复用后的es数据

```shell
ffmpeg -f s337m -i s337m.dat -c copy -map 0:a:0 -f data dolby_e.es
```
