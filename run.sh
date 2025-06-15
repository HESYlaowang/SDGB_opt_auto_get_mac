#!/bin/bash
cd "$(dirname "$0")"

python3 ./opt.py
exit_code=$?

if [ $exit_code -eq 100 ]; then
  echo "See You Next Play"
  exit 0
fi

OPT_DIR="opt"
OPT_BIN="OPT.BIN"
FSTOOL="fstool.exe"

if [ ! -f "$OPT_BIN" ]; then
  echo "找不到 $OPT_BIN ，解密无法继续"
  exit 1
fi

if [ ! -f "$FSTOOL" ]; then
  echo "找不到 $FSTOOL ，解密无法继续"
  exit 1
fi

for optfile in "$OPT_DIR"/*.opt; do
  vhdfile="${optfile%.opt}.vhd"
  if [ -f "$vhdfile" ]; then
    echo "跳过已存在的VHD文件: $vhdfile"
  else
    echo "解密 $optfile 到 $vhdfile"
    wine fstool dec "$OPT_BIN" "$optfile" "$vhdfile"
    if [ $? -eq 0 ]; then
      echo "成功解密 $optfile"
    else
      echo "解密失败 $optfile"
    fi
  fi
done

for vhdfile in "$OPT_DIR"/*.vhd; do
  basename="$(basename "${vhdfile%.vhd}")"
  outdir="output/$basename"

  if [ -d "$outdir" ] && [ "$(ls -A "$outdir")" ]; then
    echo "已提取过 $basename ，跳过提取"
    continue
  else
    echo "挂载 $vhdfile..."
    MOUNT_OUTPUT=$(hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount "$vhdfile")
    DEVICE=$(echo "$MOUNT_OUTPUT" | grep "/dev/disk" | awk '{print $1}' | head -n1)

    if [ -z "$DEVICE" ]; then
      echo "挂载失败: $vhdfile"
      continue
    fi

    echo "尝试挂载 $DEVICE ..."
    sudo mkdir -p /Volumes/vhdmount
    if sudo mount -t exfat "$DEVICE" /Volumes/vhdmount; then
      echo "从 $DEVICE 提取文件到 $outdir ..."
      mkdir -p "$outdir"
      cp -a "/Volumes/vhdmount"/. "$outdir"/
      echo "卸载挂载点..."
      hdiutil detach "$DEVICE" >/dev/null
      echo "处理完成: $basename"
    else
      echo "$DEVICE 挂载失败，尝试卸载..."
      sudo hdiutil detach "$DEVICE"
      continue
    fi
  fi
done
