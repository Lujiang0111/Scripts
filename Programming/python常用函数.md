# python常用函数

## 文件操作

```python
import os
from pathlib import Path

# 获取脚本所在目录
env_dir = Path(__file__).resolve().parent

# 将当前目录切换到脚本所在目录
os.chdir(env_dir)

# 创建文件所在的目录
Path(file_name).parent.mkdir(parents=True, exist_ok=True)

# 检查是否有特定的文件或目录
pathlib.Path(file_name).exists()

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

# 读写文件
with open(save_path, "w", encoding="utf-8") as file:
    pass
```
