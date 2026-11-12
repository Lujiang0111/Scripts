#include <vector>
#include <windows.h>
#include "app/utils.h"

namespace app
{

std::string Utf16ToUtf8(const std::wstring &utf16)
{
    if (utf16.empty())
    {
        return "";
    }

    // 计算 UTF-8 所需字节数
    int size = WideCharToMultiByte(
        CP_UTF8,
        WC_ERR_INVALID_CHARS,
        utf16.data(),
        static_cast<int>(utf16.size()),
        nullptr,
        0,
        nullptr,
        nullptr);

    if (size <= 0)
    {
        return "";
    }

    // 分配空间
    std::vector<char> utf8(size + 1, 0);

    // 执行转换
    if (0 == WideCharToMultiByte(
        CP_UTF8,
        WC_ERR_INVALID_CHARS,
        utf16.data(),
        static_cast<int>(utf16.size()),
        utf8.data(),
        size,
        nullptr,
        nullptr))
    {
        return "";
    }

    return utf8.data();
}

}
