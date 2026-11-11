#include <memory>
#include "imgui.h"
#include "win32_dx11_app.h"

bool app_running = true;

struct MainParam
{
    std::wstring file_name_w;
    std::string file_name;
};

int main(int argc, char **argv)
{
    std::shared_ptr<MainParam> param = std::make_shared<MainParam>();

    std::shared_ptr<Application> app = std::make_shared<Application>();
    if (!app->Init(L"Ts Parser", 800, 600))
    {
        return 1;
    }

    while (app->ProcessMessages())
    {
        app->BeginFrame();

        // 获取 Win32 窗口对应的 ImGui 主视口
        ImGuiViewport *viewport = ImGui::GetMainViewport();

        // 让 ImGui 窗口覆盖整个客户区
        ImGui::SetNextWindowPos(viewport->WorkPos);
        ImGui::SetNextWindowSize(viewport->WorkSize);

        ImGuiWindowFlags flags =
            ImGuiWindowFlags_NoTitleBar |
            ImGuiWindowFlags_NoResize |
            ImGuiWindowFlags_NoMove |
            ImGuiWindowFlags_NoCollapse |
            ImGuiWindowFlags_NoBringToFrontOnFocus;

        // ImGui窗口定义
        ImGui::Begin("Ts parser", nullptr, flags);

        if (ImGui::Button("打开文件"))
        {
            param->file_name_w = app->OpenFileDialog();
            param->file_name = app->Utf16ToUtf8(param->file_name_w);
        }

        ImGui::SameLine();

        ImGui::Text("%s", param->file_name.c_str());

        // ImGui窗口定义结束
        ImGui::End();

        app->EndFrame();
    }

    app = nullptr;
    return 0;
}
