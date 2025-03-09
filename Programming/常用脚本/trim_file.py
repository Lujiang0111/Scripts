import sys


def trim_file(filename, x, y):
    try:
        with open(filename, "rb") as f:
            data_before = f.read(x)

            if y == -1:
                f.seek(0, 2)
                y = f.tell()

            if x >= y:
                print("起始字节 x 应小于结束字节 y。")
                return

            f.seek(y)
            data_after = f.read()

        modified_filename = f"{filename}.new"
        with open(modified_filename, "wb") as f:
            f.write(data_before + data_after)

        print(f"成功删除{filename}的第{x}到{y}字节，并保存为{modified_filename}")
    except Exception as e:
        print(f"操作失败: {e}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("删除文件的第x-y个字节")
        print("用法: python script.py <文件名> <起始字节x> <结束字节y>")
        print("y为-1时表示删除到文件末尾")
    else:
        filename = sys.argv[1]
        try:
            x = int(sys.argv[2])
            y = int(sys.argv[3])
            trim_file(filename, x, y)
        except ValueError:
            print("请输入有效的字节数。")
