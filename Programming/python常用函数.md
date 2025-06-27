# python常用函数

## 获取脚本所在目录

```python
from pathlib import Path

env_dir = Path(__file__).resolve().parent
```

## 文件操作

```python
from pathlib import Path

# 检查是否有特定的文件或目录
pathlib.Path(file_name).exists()

# 检查是否有匹配通配符的文件或目录
pattern = "path/to/files/*.txt"
matches = list(Path().glob(pattern))

# 删除文件或目录
def rm_path(file_name: str) -> None:
    path = Path(file_name)
    if not path.exists():
        return

    if path.is_dir():
        shutil.rmtree(file_name)
    else:
        path.unlink()

# 删除文件或目录，支持通配符
def rm_path_glob(pattern: str) -> None:
    for path in Path().glob(pattern):
        rm_path(path)

# 拷贝文件或目录
def copy_path(src_path, dst_path) -> None:
    src = Path(src_path)
    dst = Path(dst_path)

    if not src.exists():
        return

    if src.is_file():
        if dst.is_dir():
            dst_file = dst / src.name
        else:
            dst_file = dst
        dst_file.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst_file)
    elif src.is_dir():
        if dst.exists() and dst.is_file():
            return

        dst.mkdir(parents=True, exist_ok=True)
        for item in src.iterdir():
            copy_path(item, dst / item.name)
```
