#!/bin/bash

# 定义模型路径和输入文件
MODEL_PATH=~/Github/whisper.cpp/models/ggml-large-v3.bin
INPUT_FILE=$1
WAV_FILE="${INPUT_FILE%.*}.wav"

# 提供用法说明
if [ -z "$1" ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

# 检查输入文件是否为 WAV 格式，如果不是则转换为 WAV 格式
if [[ $INPUT_FILE != *.wav ]]; then
  echo "Converting $INPUT_FILE to WAV format..."
  ffmpeg -i "$INPUT_FILE" -ar 16000 "$WAV_FILE"
  if [ $? -ne 0 ]; then
    echo "Failed to convert $INPUT_FILE to WAV format"
    exit 1
  fi
  INPUT_FILE=$WAV_FILE
fi

# 执行 Whisper 命令
/Users/tianli/Github/whisper.cpp/main -m $MODEL_PATH -f $INPUT_FILE

