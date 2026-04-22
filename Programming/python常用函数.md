# python常用函数

```python
import argparse
import os
from pathlib import Path
import shutil
import sys

file_name = ""

# 创建文件所在的目录
Path(file_name).parent.mkdir(parents=True, exist_ok=True)

# 检查是否有特定的文件或目录
Path(file_name).exists()

# 读写文件
with open(file_name, "rw", encoding="utf-8") as f:
    pass


# 检查是否有匹配通配符的文件或目录
def find_path_glob(path, pattern: str, recursion: bool) -> list:
    if not Path(path).exists():
        return

    prev_dir = os.getcwd()
    os.chdir(path)

    if recursion:
        results = [p.absolute() for p in Path(".").rglob(pattern)]
    else:
        results = [p.absolute() for p in Path(".").glob(pattern)]

    os.chdir(prev_dir)
    return results


# 删除文件或目录
def rm_path(file_name, retries=3) -> None:
    path = Path(file_name)
    if path.is_symlink() or path.is_file():
        path.unlink()
        return

    if path.is_dir():
        for i in range(retries):
            try:
                shutil.rmtree(file_name)
                return
            except OSError:
                if i == retries - 1:
                    raise
                time.sleep(1)
        return


# 删除文件或目录，支持通配符
def rm_path_glob(path_name, pattern: str) -> None:
    paths = find_path_glob(path_name, pattern, False)
    if not paths:
        return

    for path in paths:
        rm_path(path)


# 拷贝文件或目录
def copy_path(src_path, dst_path) -> None:
    src = Path(src_path)
    dst = Path(dst_path)

    if not src.exists():
        return

    dst.parent.mkdir(parents=True, exist_ok=True)

    if dst.is_dir():
        dst = dst / src.name
    rm_path(str(dst))

    if src.is_file():
        shutil.copy2(src, dst)
    elif src.is_dir():
        shutil.copytree(src, dst, copy_function=shutil.copy2)


# 获取系统名称和架构
def get_os_info() -> None:
    if "Windows" == platform.system():
        os = "windows"
    else:
        with open("/etc/os-release", "r", encoding="utf-8") as file:
            for line in file:
                line = line.strip().lower()
                if line.startswith("id="):
                    id = line

        if "centos" in id:
            os = "centos"
        elif "ubuntu" in id:
            os = "ubuntu"
        elif "kylin" in id:
            os = "Kylin"
        elif "openeuler" in id:
            os = "openeuler"
        else:
            os = "default_os"

    machine = platform.machine().lower()
    if machine in ["amd64", "x86_64"]:
        arch = "x64"
    elif machine in ["aarch64", "arm64"]:
        arch = "aarch64"
    else:
        arch = "default_arch"

    print(f"os=\033[33m{os}\033[0m")
    print(f"arch=\033[33m{arch}\033[0m")


class ExampleClass:
    __env_dir = None
    __args = None

    def main(self, args) -> None:
        # 获取脚本所在目录
        self.__env_dir = Path(__file__).resolve().parent

        # 解析参数
        self.parse_args()

        # 将当前目录切换到脚本所在目录
        os.chdir(self.__env_dir)

    def parse_args(self) -> None:
        parser = argparse.ArgumentParser(description="arg description")

        # 位置参数
        parser.add_argument("product", help="指定产品名称(如ffmpeg)")

        # 可选参数
        parser.add_argument(
            "-v", "--version", help="指定版本号(形如x.y.z)", default="1.0.0"
        )

        # 解析参数
        self.__args = parser.parse_args()

        # 处理参数
        self.__product = self.__args.product
        self.__version = self.__args.version


if __name__ == "__main__":
    h = ExampleClass()
    h.main(sys.argv)
```
