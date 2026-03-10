#!/usr/bin/env bash
# stop.sh - 停止后台运行的 Vite dev server
#
# 用法:
#   bash scripts/frontend/stop.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

PID_FILE="${ROOT_DIR}/tmp/vite.pid"

if [ ! -f "$PID_FILE" ]; then
  echo "Vite dev server 未运行（找不到 PID 文件）"
  exit 0
fi

PID=$(cat "$PID_FILE")

if kill -0 "$PID" 2>/dev/null; then
  echo "停止 Vite dev server (PID: $PID)..."
  kill "$PID"
  # 等待进程退出（最多 10 秒）
  for i in $(seq 1 10); do
    if ! kill -0 "$PID" 2>/dev/null; then
      break
    fi
    sleep 1
  done
  # 强制杀死（如果还在）
  if kill -0 "$PID" 2>/dev/null; then
    echo "强制停止 (SIGKILL)..."
    kill -9 "$PID"
  fi
  echo "Vite dev server 已停止"
else
  echo "Vite dev server 未运行（进程 $PID 不存在）"
fi

rm -f "$PID_FILE"
