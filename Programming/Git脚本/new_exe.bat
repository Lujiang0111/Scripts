@echo off

mkdir 3rd
mkdir conf
mkdir include
mkdir src

cd src
(
echo #include ^<csignal^>
echo.
echo bool app_running = true;
echo.
echo static void SigIntHandler(int sig_num^)
echo {
echo     signal(SIGINT, SigIntHandler^);
echo     app_running = false;
echo }
echo.
echo int main(int argc, char **argv^)
echo {
echo     signal(SIGINT, SigIntHandler^);
echo.
echo     return 0;
echo }
) > main.cpp
