import os
from pathlib import Path

env_dir = Path(__file__).resolve().parent
os.chdir(env_dir)

Path("3rd").mkdir(parents=True, exist_ok=True)
Path("conf").mkdir(parents=True, exist_ok=True)
Path("doc").mkdir(parents=True, exist_ok=True)
Path("include").mkdir(parents=True, exist_ok=True)
Path("src").mkdir(parents=True, exist_ok=True)

main_cpp_context = r"""#include <csignal>
#include <fstream>
#include <memory>
#include <sstream>
#include <string>
#include <thread>
#include "lccl/oss/fmt.h"
#include "lccl/oss/json.h"

struct Param
{
    std::string config_file = "config.json";
};

bool app_running = true;

static void SigIntHandler(int sig_num)
{
    signal(SIGINT, SigIntHandler);
    app_running = false;
}

static void ShowUsage(char **argv, const std::string &detail)
{
    if (!detail.empty())
    {
        fmt::println("\nError: {}", detail);
    }

    std::string app_name = argv[0];
    size_t pos = app_name.find_last_of("/\\");
    if (std::string::npos != pos)
    {
        app_name = app_name.substr(pos + 1);
    }

    fmt::println("\nUsage:\n{}\n{}\n", app_name, "\t-c config_file");
    exit(0);
}

static std::shared_ptr<Param> ParseArgs(int argc, char **argv)
{
    std::shared_ptr<Param> param = std::make_shared<Param>();
    for (int index = 1; index < argc; ++index)
    {
        std::string curr_arg = argv[index];

        if ("--help" == curr_arg)
        {
            ShowUsage(argv, "");
        }
        else if ("-c" == curr_arg)
        {
            if (index + 1 >= argc)
            {
                ShowUsage(argv, "Please specify config file");
            }

            param->config_file = argv[index + 1];
            ++index;
        }
    }

    return param;
}

int main(int argc, char **argv)
{
    signal(SIGINT, SigIntHandler);
    std::shared_ptr<Param> param = ParseArgs(argc, argv);
    if (!param)
    {
        ShowUsage(argv, "");
    }

    std::ifstream fin(param->config_file.c_str());
    if (!fin.is_open())
    {
        fmt::println("Error: Can not open file {}", param->config_file);
        return 0;
    }

    std::string config_json;
    std::stringstream buffer;
    buffer << fin.rdbuf();
    config_json = buffer.str();

    rapidjson::Document config_doc;
    if (!lccl::ParseStringToJson(config_doc, config_json))
    {
        return 0;
    }

    while (app_running)
    {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    return 0;
}
"""

with open("src/main.cpp", "w", encoding="utf-8") as file:
    file.write(main_cpp_context)

config_json_context = r"""{}"""

with open("conf/config.json", "w", encoding="utf-8") as file:
    file.write(config_json_context)
