@echo off

mkdir 3rd
mkdir conf
mkdir doc
mkdir include
mkdir src

cd src
(
echo #include ^<csignal^>
echo #include ^<iostream^>
echo #include ^<memory^>
echo #include ^<string^>
echo.
echo struct Param
echo {
echo.
echo };
echo.
echo bool app_running = true;
echo.
echo static void SigIntHandler(int sig_num^)
echo {
echo     signal(SIGINT, SigIntHandler^);
echo     app_running = false;
echo }
echo.
echo static void ShowUsage(const std::string ^&app_name^)
echo {
echo     std::cerr ^<^< "\nUsage: " ^<^< app_name ^<^< "\n";
echo     exit(0^);
echo }
echo.
echo std::shared_ptr^<Param^> ParseParam(int argc, char **argv^)
echo {
echo     std::shared_ptr^<Param^> param = std::make_shared^<Param^>(^);
echo     for (int index = 1; index ^< argc; ++index^)
echo     {
echo         std::string curr_arg = argv[index];
echo.
echo         if ("--help" == curr_arg^)
echo         {
echo             ShowUsage(argv[0]^);
echo         }
echo     }
echo.
echo     return param;
echo }
echo.
echo int main(int argc, char **argv^)
echo {
echo     signal(SIGINT, SigIntHandler^);
echo.
echo     std::shared_ptr^<Param^> param = ParseParam(argc, argv^);
echo     if ^(!param^)
echo     {
echo         ShowUsage(argv[0]^);
echo     }
echo.
echo     return 0;
echo }
) > main.cpp
