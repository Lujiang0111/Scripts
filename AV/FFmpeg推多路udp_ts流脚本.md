# FFmpeg推多路udp_ts流脚本

## Windows

+ `ffmpeg_multi_udp.bat`

```batch
@echo off
setlocal enabledelayedexpansion

set INPUT_FILE=.\H264_420_8_AAC_CBR_37M_GHY.ts
set OUTPUT_CNT=2
set OUTPUT_IP=172.28.3.21
set OUTPUT_START_PORT=18000

for /L %%i in (1,1,!OUTPUT_CNT!) do (
    set /A OUTPUT_PORT=!OUTPUT_START_PORT! + %%i - 1
    echo Starting ffmpeg process for port !OUTPUT_PORT!
    start "" .\ffmpeg.exe -re -stream_loop -1 -i "%INPUT_FILE%" -c copy -f mpegts "udp://%OUTPUT_IP%:!OUTPUT_PORT!?pkt_size=1316"
)

echo All processes started.
pause
```
