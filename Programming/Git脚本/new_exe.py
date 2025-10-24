import os
from pathlib import Path

env_dir = Path(__file__).resolve().parent
os.chdir(env_dir)

Path("3rd").mkdir(parents=True, exist_ok=True)
Path("conf").mkdir(parents=True, exist_ok=True)
Path("doc").mkdir(parents=True, exist_ok=True)
Path("include").mkdir(parents=True, exist_ok=True)
Path("src").mkdir(parents=True, exist_ok=True)

main_cpp_context = r"""
#include <csignal>
#include <iostream>
#include <memory>
#include <string>

struct Param
{
    std::string input_file;
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
        std::cerr << "\nerror:" << detail << "\n";
    }

    std::string app_name = argv[0];
    size_t pos = app_name.find_last_of("/\\");
    if (std::string::npos != pos)
    {
        app_name = app_name.substr(pos + 1);
    }

    std::cerr << "\nUsage: " << app_name << " -i input_file\n";
    exit(0);
}

std::shared_ptr<Param> ParseParam(int argc, char **argv)
{
    std::shared_ptr<Param> param = std::make_shared<Param>();
    for (int index = 1; index < argc; ++index)
    {
        std::string curr_arg = argv[index];

        if ("--help" == curr_arg)
        {
            ShowUsage(argv, "");
        }

        if ("-i" == curr_arg)
        {
            if (index + 1 >= argc)
            {
                ShowUsage(argv, "Please specify input file");
            }

            param->input_file = argv[index + 1];
            ++index;
        }
    }

    if (param->input_file.empty())
    {
        return nullptr;
    }
    return param;
}

int main(int argc, char **argv)
{
    signal(SIGINT, SigIntHandler);

    std::shared_ptr<Param> param = ParseParam(argc, argv);
    if (!param)
    {
        ShowUsage(argv, "");
    }

    return 0;
}
"""

with open("src/main.cpp", "w", encoding="utf-8") as file:
    file.write(main_cpp_context)
