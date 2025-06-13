# python常用函数

## 判断文件或目录是否存在

```python
pathlib.Path(file_name).exists()
```

## 删除文件或目录

```python
# 删除明确文件
def rm_file(file_name: str) -> None:
    path = pathlib.Path(file_name)
    if not path.exists():
        return

    if path.is_dir():
        shutil.rmtree(file_name)
    else:
        path.unlink()

# 通配符支持
def rm_file_glob(pattern: str):
    for path in pathlib.Path().glob(pattern):
        rm_file(path)
```
