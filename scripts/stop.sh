#!/usr/bin/env bash
# stop.sh - 停止后台运行的服务
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PID_FILE="${ROOT_DIR}/tmp/copilot-go.pid"

if [ ! -f "$PID_FILE" ]; then
  echo "copilot-go 未运行（找不到 PID 文件）"
  exit 0
fi

PID=$(cat "$PID_FILE")

if kill -0 "$PID" 2>/dev/null; then
  echo "停止 copilot-go (PID: $PID)..."
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
  echo "copilot-go 已停止"
else
  echo "copilot-go 未运行（进程 $PID 不存在）"
fi

rm -f "$PID_FILE"
