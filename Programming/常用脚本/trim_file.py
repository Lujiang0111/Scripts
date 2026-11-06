import argparse
import os


def delete_bytes(file_path, x, y):
    """
    删除文件第 x 到第 y 个字节（包含 x 和 y）。

    字节位置从 1 开始：
    x = 10, y = 20  删除第 10~20 字节
    x = 10, y = -1  删除第 10 字节至文件末尾
    x = 10, y = -2  删除第 10 字节至倒数第 2 字节
    """

    with open(file_path, "r+b") as f:
        f.seek(0, os.SEEK_END)
        size = f.tell()

        # 转换为从 0 开始的字节偏移量
        start = x - 1
        end = y if y > 0 else size + y + 1

        if not (0 <= start < end <= size):
            raise ValueError(f"无效范围: x={x}, y={y}, 文件大小={size}")

        # 将删除范围之后的数据向前移动
        read_pos = end
        write_pos = start
        chunk_size = 1024 * 1024  # 每次处理 1MB

        while read_pos < size:
            f.seek(read_pos)
            data = f.read(min(chunk_size, size - read_pos))

            f.seek(write_pos)
            f.write(data)

            read_pos += len(data)
            write_pos += len(data)

        # 截断多余数据
        f.truncate(write_pos)

    print(f"删除成功，删除从{start} 至 {end}， 共 {end - start} 字节")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="删除文件指定范围的字节")
    parser.add_argument("file", help="文件路径")
    parser.add_argument("x", type=int, help="起始字节位置")
    parser.add_argument("y", type=int, help="结束字节位置，支持负数")

    args = parser.parse_args()

    delete_bytes(args.file, args.x, args.y)
