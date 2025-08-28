#!/usr/bin/env bash
set -e
MODEL="/Users/tianli/Downloads/piper/voices/zh_CN-huayan-medium.onnx"
OUT="out.wav"
# 从参数或标准输入取文本
if [ -n "$1" ]; then
  TEXT="$*"
else
  TEXT="$(cat)"
fi
[ -z "$TEXT" ] && echo "用法: echo '文本' | ./read_zh.sh  或  ./read_zh.sh 文本" && exit 1

# Piper 合成
echo "$TEXT" | piper -m "$MODEL" -f "$OUT"

# 2倍速播放（只变速，可能变调；若想保留音调请用下方 ffmpeg 方案）
afplay -r 2.0 "$OUT"

# 若想保留音调，请改用：
# ffmpeg -y -i "$OUT" -filter:a "atempo=2.0" out_2x.wav && afplay out_2x.wav

