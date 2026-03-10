#!/usr/bin/env bash
# status.sh - 查看服务状态
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PID_FILE="${ROOT_DIR}/tmp/copilot-go.pid"
WEB_PORT="${WEB_PORT:-3000}"
PROXY_PORT="${PROXY_PORT:-4141}"

echo "=== copilot-go 服务状态 ==="

if [ -f "$PID_FILE" ]; then
  PID=$(cat "$PID_FILE")
  if kill -0 "$PID" 2>/dev/null; then
    echo "状态    : ✓ 运行中"
    echo "PID     : $PID"
    echo "Web Console : http://localhost:${WEB_PORT}"
    echo "Proxy       : http://localhost:${PROXY_PORT}"
  else
    echo "状态    : ✗ 已停止（PID 文件残留，进程不存在）"
  fi
else
  echo "状态    : ✗ 未运行"
fi
