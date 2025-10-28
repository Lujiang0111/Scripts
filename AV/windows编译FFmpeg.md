# windows编译FFmpeg

+ 参考文档：<https://www.ffmpeg.org/platform.html#Windows>

## 1. 准备工作

### 1.1. visual studio环境搭建

1. 安装vs2015以上的版本：<https://visualstudio.microsoft.com/zh-hans/downloads/>

### 1.2. msys2环境搭建

1. 下载msys2：<https://www.msys2.org/>
1. 更新msys2：

    ```shell
    pacman -Syu
    ```

    ```shell
    pacman -Su
    ```

1. 下载FFmpeg的依赖库：

    ```shell
    # normal msys2 packages
    pacman -S make pkgconf diffutils
    ```

1. 在msys2根目录下创建一个`msys_visualstudio.bat`的文件，具体内容：

    ```powershell
    set MSYS2_PATH_TYPE=inherit
    ::vs2017
    ::call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
    ::vs2022
    call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
    msys2_shell.cmd -mingw64
    ```

1. 将msys2根目录`\usr\bin\link.exe`改名为`link_msys2.exe`，因为会和vs的`link.exe`重名。

## 2. msys环境下FFmpeg编译

1. 直接运行`msys_visualstudio.bat`（不要右键用管理员运行，有可能无法正确弹框）。

### 2.1. FFmpeg 4.0以上版本

+ 下载地址：<https://www.ffmpeg.org/download.html>

+ 修改优化参数：
  + 修改`configure`文件，在`_type=msvc`分支指定`_cflags_noopt`的优化等级：

  ```configure
      elif $_cc -nologo- 2>&1 | grep -q Microsoft || { $_cc -v 2>&1 | grep -q clang && $_cc -? > /dev/null 2>&1; }; then
        _type=msvc
        
        ......

        _cflags_speed="-O2"
        _cflags_size="-O1"
        _cflags_noopt="-Og" # 从-O1改为-Og
  ```

  + `-Og`会在将来的版本被删除，暂时先用着。

+ 编译命令：

    ```shell
    ./configure --prefix=/home/Install/FFmpeg --toolchain=msvc --arch=x86_64 \
    --enable-shared --disable-static --disable-doc \
    --enable-debug --disable-optimizations --disable-asm --disable-stripping \
    --enable-avresample --disable-autodetect

    make clean && make V=1 -j$(nproc) && make install
    ```

### 2.2. FFmpeg 4.0以下版本编译

+ 下载地址：<https://www.ffmpeg.org/olddownload.html>

+ 编译命令：

    ```shell
    ./configure --prefix=/home/Install/FFmpeg --toolchain=msvc --arch=x86_64 \
    --enable-shared --disable-static --disable-programs --disable-doc \
    --enable-debug --disable-asm --disable-stripping \
    --enable-avresample

    make clean && make V=1 -j$(nproc) && make install
    ```

## 3. 常见问题

### 3.1. FFmpeg4.0以下版本常见编译错误

1. C2001：常量中有换行符
    + 文件中不能出现中文，一般是config.h的`#define CC_IDENT`行，将中文改为纯英文即可。
    + 使用sed修改文件某一行：`sed -i '9c #define CC_IDENT "Microsoft C/C++"' config.h`

1. C4005：“vsnprintf”: 宏重定义
    + vs2013及以上版本自带vsnprintf，不需要用avpriv_snprintf了，所以需要将相关地方注释掉。
    + 修改configure文件，将

    ```shell
    case $libc_type in
    bionic)
        add_compat strtod.o strtod=avpriv_strtod
        ;;
    msvcrt)
        add_compat strtod.o strtod=avpriv_strtod
        add_compat msvcrt/snprintf.o snprintf=avpriv_snprintf   \
                                     _snprintf=avpriv_snprintf  \
                                     vsnprintf=avpriv_vsnprintf
        ;;
    esac
    ```

    修改为

    ```shell
    case $libc_type in
    bionic)
        add_compat strtod.o strtod=avpriv_strtod
        ;;
    msvcrt)
    # modify by sumavision
    #        add_compat strtod.o strtod=avpriv_strtod
    #        add_compat msvcrt/snprintf.o snprintf=avpriv_snprintf   \
    #                                     _snprintf=avpriv_snprintf  \
    #                                     vsnprintf=avpriv_vsnprintf
            ;;
    esac
    ```

1. LNK2001：avpriv_snprintf相关错误
    + 将libavutil/internal.h的这几行注释掉即可。

    ```c
    #if defined(_MSC_VER)
    #pragma comment(linker, "/include:"EXTERN_PREFIX"avpriv_strtod")
    #pragma comment(linker, "/include:"EXTERN_PREFIX"avpriv_snprintf")
    #endif
    ```

1. LNK2019：unresolved external symbol ff_get_cpu_flags_aarch64 referenced in function av_get_cpu_flags
    + 将configure命令中的--disable-optimizations选项去掉即可。
