import os

BOM = b"\xef\xbb\xbf"
EXTENSIONS = (".c", ".cc", ".cpp", ".h", ".hpp")


def has_bom(file_path):
    """检查文件是否已有BOM"""
    with open(file_path, "rb") as f:
        start = f.read(3)
        return start == BOM


def add_bom(file_path):
    """给文件添加BOM"""
    with open(file_path, "rb") as f:
        content = f.read()

    with open(file_path, "wb") as f:
        f.write(BOM + content)


def process_file(file_path):
    """处理单个文件"""
    if not has_bom(file_path):
        add_bom(file_path)
        print(f"[修改] 已添加BOM: {file_path}")


def scan_directory(root_dir):
    """递归扫描目录"""
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith(EXTENSIONS):
                file_path = os.path.join(root, file)
                try:
                    process_file(file_path)
                except Exception as e:
                    print(f"[错误] {file_path}: {e}")


if __name__ == "__main__":
    target_dir = os.getcwd()

    if not os.path.isdir(target_dir):
        print("目录不存在！")
        exit

    scan_directory(target_dir)
    print("处理完成！")
