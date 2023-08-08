#!/bin/bash

# video source
# https://h265.webmfiles.org/
# https://media.xiph.org/video/derf/
# https://www.elecard.com/videos
# https://aomedia.org/

# Set transcode bitrate values
# BITRATE_H264=3.0M
# BITRATE_HEVC=2.1M
BITRATE_AV1=4M

# VMAF values should match the above bitrate values (or just enter ?)
VMAF_H264=90
VMAF_HEVC=90
VMAF_AV1=90

# INPUT_STREAM="/home/xilinx/Documents/minx/lvs/Videos/tcl.mp4"
SERVER=http://127.0.0.1:8080 # local loopback

# HLS_DIR="/tmp/hls"

FFMPEG_DIR="/opt/amd/ma35/bin"
export FIRMWARE_DIR=/opt/amd/ma35/firmware

DISP_W=1600
DISP_H=900


trap "trap - SIGTERM && kill -9 -- -$$" SIGINT SIGTERM EXIT ERR # will kill the whole process group!


# FFmpeg -loglevel

# 1. quiet, -8：完全静默，不显示任何信息。
# 2. panic, 0：只显示可能导致进程崩溃的致命错误，如断言失败。目前此级别未用于任何事情。
# 3. fatal, 8：只显示致命错误。这些错误会导致进程无法继续运行。
# 4. error, 16：显示所有错误，包括可以恢复的错误。
# 5. warning, 24：显示所有警告和错误。任何可能的不正确或意外事件的消息都会被显示。
# 6. info, 32：显示处理过程中的信息性消息。这是除警告和错误之外的默认值。
# 7. verbose, 40：与info相同，但更详细。
# 8. debug, 48：显示所有内容，包括调试信息。
# 9. trace, 56：显示所有内容，包括跟踪信息。

# STREAM_H264="stream_h264.m3u8"
# STREAM_AV1"stream_av1.m3u8"
# STREAM_HEVC="stream_hevc.m3u8"

# INPUT_STREAM="/home/xilinx/Documents/minx/lvs/Videos/bbb_sunflower_2160p_60fps.mp4"
INPUT_STREAM="/home/xilinx/Documents/minx/lvs/Videos/bbb_sunflower_2160p_60fps_normal.mp4"
STREAM_H264="h264.m3u8"
STREAM_HEVC="hevc.m3u8"
STREAM_AV1="av1.m3u8"

loglev=8

MODE="bind"
# fps=30
fps=60
# MODE="free"

# Origin file 
# ${FFMPEG_DIR}/ffmpeg -stream_loop -1 -y -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0 -c:v h264_ama -out_fmt yuv420p -re -i ${INPUT_STREAM} -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
# ffplay -window_title ma35_h264 -x ${DISP_W} -y ${DISP_H} -left 200 -top 100 -vf "drawtext=text='Input\: H.264 4K60@10Mbps':font='Arial':x=(main_w-text_w-10):y=(main_h-text_h-10):fontsize=45:fontcolor=black:box=1:boxcolor=white@0.5:boxborderw=5" -f rawvideo -pixel_format yuv420p -video_size 3840x2160 -framerate 60 -i - &
if [ "$MODE" = "bind" ]; then
    # # 4K AV1
    # {FFMPEG_DIR}/ffmpeg -loglevel ${loglev} -stream_loop -1 -y -hwaccel ama  -vsync 0 -c:v av1_ama -out_fmt yuv420p -re -i ${SERVER}/$STREAM_AV1 -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
    taskset -c 1 ${FFMPEG_DIR}/ffmpeg -loglevel ${loglev} -stream_loop -1 -y -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0 -c:v av1_ama -out_fmt yuv420p -r ${fps} -i ${SERVER}/$STREAM_AV1 -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
    taskset -c 2 ffplay -window_title ma35_hls_av1 -x ${DISP_W} -y ${DISP_H} -left 2000 -top 1100 -vf "drawtext=text='MA35 Transcode AV1 4K60@3Mbps':font='Arial':x=(main_w-text_w-10):y=(main_h-text_h-10):fontsize=80:fontcolor=black:box=1:boxcolor=white@0.5:boxborderw=5" -f rawvideo -pixel_format yuv420p -video_size 3840x2160 -framerate ${fps} -i - &


    # HEVC (use fmp4 container, disblap no correct)
    {FFMPEG_DIR}/ffmpeg -loglevel ${loglev} -stream_loop -1 -y -hwaccel ama -vsync 0 -c:v hevc_ama -out_fmt yuv420p -re -i ${SERVER}/$STREAM_HEVC -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
    taskset -c 5 ${FFMPEG_DIR}/ffmpeg  -loglevel ${loglev} -stream_loop -1 -y -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0 -c:v hevc_ama -out_fmt yuv420p -r ${fps} -i ${SERVER}/${STREAM_HEVC} -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
    taskset -c 7 ffplay -window_title ma35_hls_hevc -x ${DISP_W} -y ${DISP_H} -left 200 -top 1100 -vf "drawtext=text='MA35 Transcode H.265 4K60@4.0Mbps':font='Arial':x=(main_w-text_w-10):y=(main_h-text_h-10):fontsize=80:fontcolor=black:box=1:boxcolor=white@0.5:boxborderw=5" -f rawvideo -pixel_format yuv420p -video_size 3840x2160 -framerate ${fps} -i - &


    # # H264 
    # # {FFMPEG_DIR}/ffmpeg -loglevel ${loglev} -stream_loop -1 -y -hwaccel ama  -vsync 0 -c:v av1_ama -out_fmt yuv420p -re -i ${SERVER}/$STREAM_AV1 -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
    taskset -c 3,6 ${FFMPEG_DIR}/ffmpeg -stream_loop -1 -y -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0 -c:v h264_ama -out_fmt yuv420p -r ${fps} -i ${SERVER}/$STREAM_H264 -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
    taskset -c 4,8 ffplay -window_title ma35_hls_h264 -x ${DISP_W} -y ${DISP_H} -left 2000 -top 100 -vf "drawtext=text='MA35 Transcode H.264 4K60@8Mbps':font='Arial':x=(main_w-text_w-10):y=(main_h-text_h-10):fontsize=80:fontcolor=black:box=1:boxcolor=white@0.5:boxborderw=5" -f rawvideo -pixel_format yuv420p -video_size 3840x2160 -framerate ${fps} -i - &
    # -loglevel ${loglev}

    # ffmpeg -stream_loop -1 -re -i ${SERVER}/$STREAM_HEVC -map 0:0 -codec copy -f data - | \
    # ${FFMPEG_DIR}/ffmpeg -stream_loop -1 -y -init_hw_device ama=dev1:/dev/ama_transcoder0 -vsync 0 -c:v hevc_ama -out_fmt yuv420p -re -i - -map 0:v -filter_complex "setpts=PTS-STARTPTS,hwdownload,format=yuv420p" -f rawvideo - | \
    # ffplay -window_title ma35_hls_hevc -x ${DISP_W} -y ${DISP_H} -left 200 -top 1100 -vf "drawtext=text='MA35 Transcode Input\: H.265 4Kp60@5.0Mbps':font='Arial':x=(main_w-text_w-10):y=(main_h-text_h-10):fontsize=42:fontcolor=black:box=1:boxcolor=white@0.5:boxborderw=5" -f rawvideo -pixel_format yuv420p -video_size 3840x2160 -framerate 60 -i - &
fi



#
# if [ $MODE -eq "free" ]; then
#     # # 4K AV1
#     # {FFMPEG_DIR}/ffmpeg -loglevel ${loglev} -stream_loop -1 -y -hwaccel ama  -vsync 0 -c:v av1_ama -out_fmt yuv420p -re -i ${SERVER}/$STREAM_AV1 -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
#     ${FFMPEG_DIR}/ffmpeg -loglevel ${loglev} -stream_loop -1 -y -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0 -c:v av1_ama -out_fmt yuv420p -re -i ${SERVER}/$STREAM_AV1 -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
#     ffplay -window_title ma35_hls_av1 -x ${DISP_W} -y ${DISP_H} -left 2000 -top 1100 -vf "drawtext=text='MA35 Transcode AV1 4K60@3Mbps':font='Arial':x=(main_w-text_w-10):y=(main_h-text_h-10):fontsize=80:fontcolor=black:box=1:boxcolor=white@0.5:boxborderw=5" -f rawvideo -pixel_format yuv420p -video_size 3840x2160 -framerate 60 -i - &

#     # # H264 
#     # # {FFMPEG_DIR}/ffmpeg -loglevel ${loglev} -stream_loop -1 -y -hwaccel ama  -vsync 0 -c:v av1_ama -out_fmt yuv420p -re -i ${SERVER}/$STREAM_AV1 -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
#     ${FFMPEG_DIR}/ffmpeg -loglevel ${loglev} -stream_loop -1 -y -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0 -c:v h264_ama -out_fmt yuv420p -re -i ${SERVER}/$STREAM_H264 -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
#     ffplay -window_title ma35_hls_h264 -x ${DISP_W} -y ${DISP_H} -left 2000 -top 100 -vf "drawtext=text='MA35 Transcode H.264 4K60@8Mbps':font='Arial':x=(main_w-text_w-10):y=(main_h-text_h-10):fontsize=80:fontcolor=black:box=1:boxcolor=white@0.5:boxborderw=5" -f rawvideo -pixel_format yuv420p -video_size 3840x2160 -framerate 60 -i - &
#     # -loglevel ${loglev}

#     # # HEVC (use fmp4 container, disblap no correct)
#     # {FFMPEG_DIR}/ffmpeg -loglevel ${loglev} -stream_loop -1 -y -hwaccel ama -vsync 0 -c:v hevc_ama -out_fmt yuv420p -re -i ${SERVER}/$STREAM_HEVC -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
#     ${FFMPEG_DIR}/ffmpeg -stream_loop -1 -y -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0 -c:v hevc_ama -out_fmt yuv420p -re -i ${SERVER}/${STREAM_HEVC} -map 0:v -filter_complex "hwdownload,format=yuv420p" -f rawvideo - | \
#     ffplay -window_title ma35_hls_hevc -x ${DISP_W} -y ${DISP_H} -left 200 -top 1100 -vf "drawtext=text='MA35 Transcode H.265 4Kp60@4.0Mbps':font='Arial':x=(main_w-text_w-10):y=(main_h-text_h-10):fontsize=80:fontcolor=black:box=1:boxcolor=white@0.5:boxborderw=5" -f rawvideo -pixel_format yuv420p -video_size 3840x2160 -framerate 60 -i - &
# fi







PID_LIST+=" $!"
# ---h264---#################################################################################################################################################
wait
