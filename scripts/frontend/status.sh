#!/usr/bin/env bash
# status.sh - 查看 Vite dev server 运行状态
#
# 用法:
#   bash scripts/frontend/status.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

PID_FILE="${ROOT_DIR}/tmp/vite.pid"

echo "=== Vite dev server 状态 ==="

if [ -f "$PID_FILE" ]; then
  PID=$(cat "$PID_FILE")
  if kill -0 "$PID" 2>/dev/null; then
    echo "状态      : ✓ 运行中"
    echo "PID       : $PID"
    echo "前端热更新 → http://localhost:35173"
    echo "API 代理   → http://localhost:37000"
  else
    echo "状态    : ✗ 已停止（PID 文件残留，进程不存在）"
  fi
else
  echo "状态    : ✗ 未运行"
fi
