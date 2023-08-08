#!/bin/bash

# video source
# https://h265.webmfiles.org/
# https://media.xiph.org/video/derf/
# https://www.elecard.com/videos
# https://aomedia.org/

BITRATE_H264=8M
BITRATE_HEVC=5M
BITRATE_AV1=4M


# image_logo="/home/xilinx/Documents/minx/lvs/amd_logo.png"
INPUT_STREAM="/home/xilinx/Documents/minx/lvs/Videos/bbb_sunflower_2160p_60fps.mp4"
SERVER=http://127.0.0.1:8080 # local loopback

HLS_DIR="/tmp/hls"
HLS_DIR_AV1="/tmp/hls/AV1"
HLS_DIR_HEVC="/tmp/hls/HEVC"
HLS_DIR_H264="/tmp/hls/H264"

FFMPEG_DIR="/opt/amd/ma35/bin"
export FIRMWARE_DIR=/opt/amd/ma35/firmware
#export LD_LIBRARY_PATH=/opt/amd/ma35/lib

DISP_W=1600
DISP_H=900

# #get the inpute stream  resolution
# RESOLUTION=${ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 ${INPUT_STREAM}}
# echo "#######${RESOLUTION}##########"

# #get the input stream bitrate
# BITRATE=${ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 ${INPUT_STREAM}}
# echo "#######${BITRATE}##########"


function clean_up {
    echo "Killing PID_LIST $PID_LIST"
    kill -9 $PID_LIST
    sleep 1
    echo "Killing HTTP_SERVER_PID $HTTP_SERVER_PID"
    kill -9 $HTTP_SERVER_PID
    if [ -d "$HLS_DIR" ]; then rm -Rf $HLS_DIR; fi
}

trap "trap - SIGTERM && kill -9 -- -$$" SIGINT SIGTERM EXIT ERR # will kill the whole process group!

echo "Change directory to /tmp/hls"
#if [[ ! -e $HLS_DIR ]]; then mkdir -p $HLS_DIR; fi
if [ -d "$HLS_DIR" ]; then rm -Rf $HLS_DIR; fi
mkdir -p $HLS_DIR
cd ${HLS_DIR}

echo "Starting basic web-server..."
python3 -m http.server 8080 2>&1 > /dev/null &
HTTP_SERVER_PID="$!"

sleep 1

echo "Starting HLS streamer..."

# ${FFMPEG_DIR}/ffmpeg -stream_loop -1 -y -init_hw_device ama=dev0:/dev/ama_transcoder0 -vsync 0 -c:v h264_ama -out_fmt nv12-ma \
# 	     -re -i ${INPUT_STREAM} \
#      	 -map 0:v -c:v:0 h264_ama -b:v:0 ${BITRATE_H264} -expert_options rdoqEnableMask=0x0F,vceVertSearchRangeP=64,vceVertSearchRangeBr=64,vceVertSearchRangeBd=64 \
# 	     -map 0:v -c:v:1 hevc_ama -b:v:1 ${BITRATE_HEVC} -expert_options rdoqEnableMask=0x0F,vceVertSearchRangeP=64,vceVertSearchRangeBr=64,vceVertSearchRangeBd=64 \
#      	 -map 0:v -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1} \
#    	  -f hls \
# 	     -var_stream_map "v:0 v:1 v:2" \
# 	     -hls_time 6 \
# 	     -hls_segment_type mpegts \
# 	     -hls_flags delete_segments+append_list+split_by_time \
# 	     -hls_list_size 10 \
# 	     -hls_segment_filename "${HLS_DIR}/stream_%v-%d.ts" \
# 	     "${HLS_DIR}/stream_%v.m3u8" &

# ${FFMPEG_DIR}/ffmpeg -stream_loop -1 -y -init_hw_device ama=dev0:/dev/ama_transcoder0 -vsync 0 -c:v h264_ama -out_fmt nv12-ma \
# 	     -re -i ${INPUT_STREAM} \
#      	 -map 0:v -c:v:0 h264_ama -b:v:0 ${BITRATE_H264} -expert_options rdoqEnableMask=0x0F,vceVertSearchRangeP=64,vceVertSearchRangeBr=64,vceVertSearchRangeBd=64 \
# 	     -map 0:v -c:v:1 hevc_ama -b:v:1 ${BITRATE_HEVC} -expert_options rdoqEnableMask=0x0F,vceVertSearchRangeP=64,vceVertSearchRangeBr=64,vceVertSearchRangeBd=64 \
#      	 -map 0:v -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1} \
#    	  	-f rtp rtp://localhost:5004



# ${FFMPEG_DIR}/ffmpeg -stream_loop -1 -y -init_hw_device ama=dev0:/dev/ama_transcoder0 -vsync 0 -c:v h264_ama -out_fmt yuv420p \
# 	     -re -i ${INPUT_STREAM} -filter_complex "split=3[a][b][c]" \
#        -map "[a]" -vsync 0 -c:v:0 h264_ama -b:v:0 ${BITRATE_H264} \
# 	     -map "[b]" -vsync 0 -c:v:1 hevc_ama -b:v:1 ${BITRATE_HEVC} \
#        -map "[c]" -vsync 0 -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1} \
#     	 -f hls \
# 	     -var_stream_map "v:0 v:1 v:2" \
# 	     -hls_time 6 \
# 	     -hls_segment_type mpegts \
# 	     -hls_flags delete_segments+append_list+split_by_time \
# 	     -hls_list_size 10 \
# 	     -hls_segment_filename "${HLS_DIR}/stream_%v-%d.ts" \
# 	     "${HLS_DIR}/stream_%v.m3u8" &

# ${FFMPEG_DIR}/ffmpeg -stream_loop -1 -y -init_hw_device ama=dev0:/dev/ama_transcoder0 -vsync 0 -c:v h264_ama -out_fmt yuv420p \
# 	     -re -i ${INPUT_STREAM} \
# 		 -filter_complex "split=3[a][b][c]" \
#       	 -map "[a]" -vsync 0 -c:v:0 h264_ama -b:v:0 ${BITRATE_H264} \
# 	     -map "[b]" -vsync 0 -c:v:1 hevc_ama -tag:v hvc1 -b:v:1 ${BITRATE_HEVC} \
#       	 -map "[c]" -vsync 0 -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1} \
#          -f hls \
# 	     -var_stream_map "v:0 v:1 v:2" \
# 	     -hls_time 6 \
# 	     -hls_segment_type fmp4 \
# 	     -hls_flags delete_segments+append_list+split_by_time \
# 	     -hls_list_size 10 \
# 	     -hls_segment_filename "${HLS_DIR}/stream_%v-%d.ts" \
# 	     "${HLS_DIR}/stream_%v.m3u8" 


# taskset -c 0 ${FFMPEG_DIR}/ffmpeg -stream_loop -1 -y -hwaccel ama -hwaccel_device /dev/ama_transcoder1 -vsync 0 -c:v h264_ama -out_fmt yuv420p \
# 	     -re \
# 		 -i ${INPUT_STREAM} \
# 		 -filter_complex "split=3[a][b][c]" \
#       	 -map "[a]" -vsync 0 -c:v:0 h264_ama -b:v:0 ${BITRATE_H264} \
# 	     -map "[b]" -vsync 0 -c:v:1 hevc_ama -tag:v hvc1 -b:v:1 ${BITRATE_HEVC} \
#       	 -map "[c]" -vsync 0 -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1}  \
#          -f hls \
# 	     -var_stream_map "v:0 v:1 v:2" \
# 	     -hls_time 10 \
# 	     -hls_segment_type mpegts \
# 	     -hls_flags delete_segments+append_list+split_by_time \
# 	     -hls_list_size 10 \
# 	     -hls_segment_filename "${HLS_DIR}/stream_%v-%d.ts" \
# 	     "${HLS_DIR}/stream_%v.m3u8" 


# ffmpeg 4.x
# ${FFMPEG_DIR}/ffmpeg -stream_loop -1 -y -init_hw_device ama=dev0:/dev/ama_transcoder0 -vsync 0 -c:v h264_ama -out_fmt yuv420p \
# 	     -re \
# 		 -i ${INPUT_STREAM}  \
# 		 -filter_complex "split=3[a][b][c]" \
#        -map "[a]" -vsync 0 -c:v:0 h264_ama -b:v:0 ${BITRATE_H264}  \
# 	     -map "[b]" -vsync 0 -c:v:1 hevc_ama -b:v:1 ${BITRATE_HEVC} -tag:v hvc1 \
#        -map "[c]" -vsync 0 -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1}  \
#        -f hls \
# 	     -var_stream_map "v:0 v:1 v:2" \
# 	     -hls_time 10 \
# 	     -hls_segment_type fmp4 \
# 	     -hls_flags delete_segments+append_list+split_by_time \
# 	     -hls_list_size 10 \
# 	     -hls_segment_filename "${HLS_DIR}/stream_%v-%d.ts" \
# 	     "${HLS_DIR}/stream_%v.m3u8" 


# ffmpeg 5.x  pre-alpha--succeed
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 \
# 		 -stream_loop -1 -y -re \
# 		 -c:v h264_ama \
# 		 -out_fmt yuv420p \
# 		 -i ${INPUT_STREAM}  \
# 		 -filter_complex "split=3[a][b][c]" \
#       	 -map "[a]" -c:v:0 h264_ama -b:v:0 ${BITRATE_H264} \
# 	     -map "[b]" -c:v:1 hevc_ama -b:v:1 ${BITRATE_HEVC} -tag:v hvc1 \
#       	 -map "[c]" -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1}  \
#          -f hls \
# 	     -var_stream_map "v:0 v:1 v:2" \
# 	     -hls_time 10 \
# 		 -hls_segment_type fmp4 \
# 	     -hls_flags delete_segments+append_list+independent_segments \
# 	     -hls_list_size 6 \
# 	     -hls_segment_filename "${HLS_DIR}/stream_%v-%d.ts" \
# 	     "${HLS_DIR}/stream_%v.m3u8" &



#*****************************************************************************************************
#****************************scaler_ama  bug  VPE decoder error: VPI_DEC_NO_DECODING_BUFFER Error while decoding stream #0:0: Generic error in an external library
#*****************************************************************************************************

		 
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 \
# 		 -stream_loop -1 -y -re \
# 		 -c:v h264_ama \
# 		 -out_fmt yuv420p \
# 		 -i ${INPUT_STREAM}  \
# 		 -filter_complex "scaler_ama=outputs=3:out_res=(3840x2160)(3840x2160)(3840x2160) [a][b][c]" \
#       	 -map "[a]" -c:v:0 h264_ama -b:v:0 ${BITRATE_H264} \
# 	     -map "[b]" -c:v:1 hevc_ama -b:v:1 ${BITRATE_HEVC} -tag:v hvc1 \
#       	 -map "[c]" -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1}  \
#          -f hls \
# 	     -var_stream_map "v:0 v:1 v:2" \
# 	     -hls_time 6 \
# 		 -hls_segment_type fmp4 \
# 	     -hls_flags delete_segments+append_list+independent_segments \
# 	     -hls_list_size 10 \
# 	     -hls_segment_filename "${HLS_DIR}/stream_%v-%d.ts" \
# 	     "${HLS_DIR}/stream_%v.m3u8" &


# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 \
# use hardware scaler fmp4 container
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama  \
# 		 -stream_loop -1 -y -re \
# 		 -c:v h264_ama \
# 		 -out_fmt yuv420p \
# 		 -i ${INPUT_STREAM}  \
# 		 -filter_complex "scaler_ama=outputs=3:out_res=(3840x2160)(3840x2160)(3840x2160) [a][b][c]" \
#       	 -map "[a]" -c:v:0 h264_ama -b:v:0 ${BITRATE_H264} \
# 	     -map "[b]" -c:v:1 hevc_ama -b:v:1 ${BITRATE_HEVC} -tag:v hvc1 \
#       	 -map "[c]" -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1}  \
#          -f hls \
# 	     -var_stream_map "v:0 v:1 v:2" \
# 	     -hls_time 10 \
# 		 -hls_segment_type fmp4 \
# 	     -hls_flags delete_segments+append_list+independent_segments \
# 	     -hls_list_size 10 \
# 	     -hls_segment_filename "${HLS_DIR}/stream_%v-%d.ts" \
# 	     "${HLS_DIR}/stream_%v.m3u8" &


# ${FFMPEG_DIR}/ffmpeg -hwaccel ama  \
# 		 -stream_loop -1 -y -re \
# 		 -c:v h264_ama \
# 		 -out_fmt yuv420p \
# 		 -i ${INPUT_STREAM}  \
# 		 -filter_complex "scaler_ama=outputs=3:out_res=(3840x2160)(3840x2160)(3840x2160) [a][b][c]" \
#       	 -map "[a]" -c:v:0 h264_ama -b:v:0 ${BITRATE_H264} \
# 	     -map "[b]" -c:v:1 hevc_ama -b:v:1 ${BITRATE_HEVC} -tag:v hvc1 \
#       	 -map "[c]" -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1}  \
#          -f hls \
# 	     -var_stream_map "v:0 v:1 v:2" \
# 	     -hls_time 6 \
# 		 -hls_segment_type fmp4 \
# 	     -hls_flags delete_segments+append_list+independent_segments \
# 	     -hls_list_size 10 \
# 	     -hls_segment_filename "${HLS_DIR}/stream2_%v-%d.ts" \
# 	     "${HLS_DIR}/stream_%v.m3u8" &








#*****************************************************************************************************
#******************************************Split process *********************************************
#*****************************************************************************************************
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama  \
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder1 \
# 		 -stream_loop -1 -y -re \
# 		 -c:v h264_ama \
# 		 -out_fmt yuv420p \
# 		 -i ${INPUT_STREAM}  \
# 		 -filter_complex "split=3[a][b][c]" \
#       	 -map "[a]" -c:v:0 h264_ama -b:v:0 ${BITRATE_H264} \
# 	     -map "[b]" -c:v:1 hevc_ama -b:v:1 ${BITRATE_HEVC} -tag:v hvc1 \
#       	 -map "[c]" -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1}  \
#          -f hls \
# 	     -var_stream_map "v:0 v:1 v:2" \
# 	     -hls_time 6 \
# 		 -hls_segment_type fmp4 \
# 	     -hls_flags delete_segments+append_list+independent_segments  \
# 	     -hls_list_size 10 \
# 	     -hls_segment_filename "${HLS_DIR}/stream_%v-%d.ts" \
# 	     "${HLS_DIR}/stream_%v.m3u8" &



# taskset -c  0 ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 \
# 		 -stream_loop -1 -y -re \
# 		 -c:v h264_ama \
# 		 -out_fmt yuv420p \
# 		 -i ${INPUT_STREAM}  \
# 		 -filter_complex "split=3[a][b][c]" \
#       	 -map "[a]" -c:v h264_ama -b:v ${BITRATE_H264} -f hls  -hls_time 6  -hls_segment_type mpegts -hls_flags delete_segments+append_list+independent_segments  -hls_list_size 10   -hls_segment_filename   "${HLS_DIR}/h264-%d.mp4"  "${HLS_DIR}/h264.m3u8" \
# 	     -map "[b]" -c:v hevc_ama -b:v ${BITRATE_HEVC} -f hls  -hls_time 6  -hls_segment_type mpegts -hls_flags delete_segments+append_list+independent_segments  -hls_list_size 10   -hls_segment_filename   "${HLS_DIR}/hevc-%d.mp4"  "${HLS_DIR}/hevc.m3u8"  \
#       	 -map "[c]" -c:v av1_ama  -b:v ${BITRATE_AV1}  -f hls  -hls_time 6  -hls_segment_type fmp4   -hls_flags delete_segments+append_list+independent_segments  -hls_list_size 10   -hls_segment_filename   "${HLS_DIR}/av1-%d.mp4"  "${HLS_DIR}/av1.m3u8" \

		#   -stream_loop -1 -y -re \
		# -loglevel 0 \

taskset -c  0 ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 \
		 -stream_loop -1 -y -re \
		 -c:v h264_ama \
		 -out_fmt yuv420p \
		 -i ${INPUT_STREAM}  \
		 -filter_complex "split=4[a][b][c][d]" \
      	 -map "[a]" -c:v h264_ama -b:v 8M -f hls  -hls_time 6  -hls_segment_type mpegts -hls_flags delete_segments+append_list+independent_segments  -hls_list_size 10   -hls_segment_filename   "${HLS_DIR}/h264-%d.mp4"  "${HLS_DIR}/h264.m3u8" \
	     -map "[b]" -c:v hevc_ama -b:v 4M -f hls  -hls_time 6  -hls_segment_type mpegts -hls_flags delete_segments+append_list+independent_segments  -hls_list_size 10   -hls_segment_filename   "${HLS_DIR}/hevc-%d.mp4"  "${HLS_DIR}/hevc.m3u8"  \
      	 -map "[c]" -c:v av1_ama -type 1 -b:v 3M -f hls -hls_time 6 -hls_segment_type fmp4 -hls_flags delete_segments+append_list+independent_segments -hls_list_size 10  -hls_segment_filename   "${HLS_DIR}/av1-%d.mp4"  "${HLS_DIR}/av1.m3u8" \
		 -map "[d]" -c:v av1_ama -type 1 -b:v 2M -r 30 -f hls -hls_time 6  -hls_segment_type fmp4 -hls_flags delete_segments+append_list+independent_segments -hls_list_size 10 -hls_segment_filename "${HLS_DIR}/30fpsav1-%d.mp4"  "${HLS_DIR}/30fpsav1.m3u8" &

taskset -c 0 ${FFMPEG_DIR}/ffmpeg -y -hwaccel ama -hwaccel_device /dev/ama_transcoder1 \
		-stream_loop -1 -y -re \
		-c:v h264_ama \
		-out_fmt yuv420p \
		-i ${INPUT_STREAM}   \
		-filter_complex "scaler_ama=outputs=3:out_res=(1920x1080)(1280x720)(720x480)(360x240) [a][b][c]" \
		-map '[a]' -c:v hevc_ama -b:v 2.0M -r 30 -f hls  -hls_time 6  -hls_segment_type mpegts -hls_flags delete_segments+append_list+independent_segments  -hls_list_size 10   -hls_segment_filename   "${HLS_DIR}/hd265-%d.mp4"    "${HLS_DIR}/hd265.m3u8"  \
		-map '[b]' -c:v av1_ama  -b:v 1.5M -r 30 -f hls  -hls_time 6  -hls_segment_type fmp4   -hls_flags delete_segments+append_list+independent_segments  -hls_list_size 10   -hls_segment_filename   "${HLS_DIR}/720pav1-%d.mp4"  "${HLS_DIR}/720pav1.m3u8" \
		-map '[c]' -c:v h264_ama -b:v 0.2M -r 30 -f hls  -hls_time 6  -hls_segment_type mpegts -hls_flags delete_segments+append_list+independent_segments  -hls_list_size 10   -hls_segment_filename   "${HLS_DIR}/480h264-%d.mp4"  "${HLS_DIR}/480p264.m3u8" &

# ffmpeg 5.x different
#use split mpegts containere
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder1 \
# 		 -stream_loop -1 -y -re \
# 		 -c:v h264_ama \
# 		 -out_fmt yuv420p \
# 		 -i ${INPUT_STREAM}  \
# 		 -filter_complex "split=3[a][b][c]" \
#       	 -map "[a]" -c:v:0 h264_ama -b:v:0 ${BITRATE_H264} \
# 	     -map "[b]" -c:v:1 hevc_ama -b:v:1 ${BITRATE_HEVC} -tag:v hvc1 \
#       	 -map "[c]" -c:v:2 av1_ama  -b:v:2 ${BITRATE_AV1}  \
#          -f hls \
# 	     -var_stream_map "v:0 v:1 v:2" \
# 	     -hls_time 6 \
# 		 -hls_segment_type mpegts \
# 	     -hls_flags delete_segments+append_list+independent_segments  \
# 	     -hls_list_size 10 \
# 	     -hls_segment_filename "${HLS_DIR}/stream2_%v-%d.ts" \
# 	     "${HLS_DIR}/stream2_%v.m3u8" &


#*****************************************************************************************************
#****************************************Single process **********************************************
#*****************************************************************************************************

# AV1 
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder1 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
#                   -an \
# 					-c:v av1_ama \
# 					-b:v ${BITRATE_AV1} \
# 					-f hls \
# 					-hls_time 10 \
# 					-hls_segment_type fmp4 \
# 					-hls_flags delete_segments+append_list+split_by_time \
# 					-hls_list_size 10 \
# 					-hls_segment_filename "${HLS_DIR}/stream_av1-%d.mp4" \
# 					"${HLS_DIR}/stream_av1.m3u8" & 

###  RTP not support AV1 ####
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
# 					-c:v av1_ama \
# 					-b:v ${BITRATE_AV1} \
# 					-f rtp rtp://127.0.0.1:4321 -sdp_file ma35_av1.sdp &

# # HEVC
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
# 					-f hls \
# 					-c:v hevc_ama \
# 					-tag:v hvc1 \
# 					-b:v ${BITRATE_HEVC} \
# 					 -hls_time 10 \
# 					-hls_segment_type mpegts \
# 					-hls_flags delete_segments+append_list+split_by_time \
# 					-hls_list_size 10 \
# 					-hls_segment_filename "${HLS_DIR}/stream_hevc-%d.ts" \
# 					"${HLS_DIR}/stream_hevc.m3u8" & 

# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
# 					-c:v hevc_ama \
# 					-b:v ${BITRATE_HEVC} \
# 					-f rtp rtp://127.0.0.1:4321 -sdp_file ma35_hevc.sdp &

# # h264 to H264
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
# 					-f hls \
# 					-c:v h264_ama \
# 					-b:v ${BITRATE_H264} \
# 					-hls_time 10 \
# 					-hls_segment_type fmp4 \
# 					-hls_flags delete_segments+append_list+split_by_time \
# 					-hls_list_size 10 \
# 					-hls_segment_filename "${HLS_DIR}/stream_h264-%d.mp4" \
# 					"${HLS_DIR}/stream_h264.m3u8" & 

# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
# 					-b:v ${BITRATE_H264} \
# 					-c:v h264_ama \
# 					-f rtp rtp://127.0.0.1:1234 -sdp_file ma35_h264.sdp &




# # AV1 
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
# 					-f hls \
# 					-c:v av1_ama \
# 					-b:v ${BITRATE_AV1} \
# 					 -hls_time 10 \
# 					-hls_segment_type fmp4 \
# 					-hls_flags delete_segments+append_list+split_by_time \
# 					-hls_list_size 10 \
# 					-hls_segment_filename "${HLS_DIR}/stream_av1_2-%d.mp4" \
# 					"${HLS_DIR}/stream_av1_2.m3u8" & 

# # HEVC
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
# 					-f hls \
# 					-c:v hevc_ama \
# 					-tag:v hvc1 \
# 					-b:v ${BITRATE_HEVC} \
# 					 -hls_time 10 \
# 					-hls_segment_type mpegts \
# 					-hls_flags delete_segments+append_list+split_by_time \
# 					-hls_list_size 10 \
# 					-hls_segment_filename "${HLS_DIR}/stream_hevc_2-%d.ts" \
# 					"${HLS_DIR}/stream_hevc_2.m3u8" & 

# # h264 to H264
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
# 					-f hls \
# 					-c:v h264_ama \
# 					-b:v ${BITRATE_H264} \
# 					 -hls_time 10 \
# 					-hls_segment_type fmp4 \
# 					-hls_flags delete_segments+append_list+split_by_time \
# 					-hls_list_size 10 \
# 					-hls_segment_filename "${HLS_DIR}/stream_h264_2-%d.mp4" \
# 					"${HLS_DIR}/stream_h264_2.m3u8" & 



# # AV1 
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
# 					-f hls \
# 					-c:v av1_ama \
# 					-b:v ${BITRATE_AV1} \
# 					 -hls_time 10 \
# 					-hls_segment_type fmp4 \
# 					-hls_flags delete_segments+append_list+split_by_time \
# 					-hls_list_size 10 \
# 					-hls_segment_filename "${HLS_DIR}/stream_av1_3-%d.mp4" \
# 					"${HLS_DIR}/stream_av1_3.m3u8" & 

# # HEVC
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
# 					-f hls \
# 					-c:v hevc_ama \
# 					-tag:v hvc1 \
# 					-b:v ${BITRATE_HEVC} \
# 					 -hls_time 10 \
# 					-hls_segment_type mpegts \
# 					-hls_flags delete_segments+append_list+split_by_time \
# 					-hls_list_size 10 \
# 					-hls_segment_filename "${HLS_DIR}/stream_hevc_2-%d.ts" \
# 					"${HLS_DIR}/stream_hevc_3.m3u8" & 

# # h264 to H264
# ${FFMPEG_DIR}/ffmpeg -hwaccel ama -hwaccel_device /dev/ama_transcoder0 -vsync 0  \
# 					-stream_loop -1 -y -re \
#                     -c:v h264_ama \
# 					-i ${INPUT_STREAM} \
# 					-f hls \
# 					-c:v h264_ama \
# 					-b:v ${BITRATE_H264} \
# 					 -hls_time 10 \
# 					-hls_segment_type fmp4 \
# 					-hls_flags delete_segments+append_list+split_by_time \
# 					-hls_list_size 10 \
# 					-hls_segment_filename "${HLS_DIR}/stream_h264_2-%d.mp4" \
# 					"${HLS_DIR}/stream_h264_3.m3u8" & 


#*****************************************************************************************************
#****************************************Single process **********************************************
#*****************************************************************************************************



PID_LIST="$!"



wait

