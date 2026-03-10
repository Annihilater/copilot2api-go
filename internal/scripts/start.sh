#!/usr/bin/env bash
# start.sh - 后台启动（生产/常驻运行）
#
# 用法:
#   bash internal/scripts/start.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$ROOT_DIR"

WEB_PORT="${WEB_PORT:-37000}"
PROXY_PORT="${PROXY_PORT:-34141}"
BINARY="${ROOT_DIR}/build/copilot-go"
PID_FILE="${ROOT_DIR}/tmp/copilot-go.pid"
LOG_FILE="${ROOT_DIR}/logs/copilot-go.log"

# 检查是否已经在运行
if [ -f "$PID_FILE" ]; then
  PID=$(cat "$PID_FILE")
  if kill -0 "$PID" 2>/dev/null; then
    echo "copilot-go 已经在运行 (PID: $PID)"
    exit 0
  else
    echo "清理过期 PID 文件..."
    rm -f "$PID_FILE"
  fi
fi

# 确保目录存在
mkdir -p "$(dirname "$BINARY")"
mkdir -p "$(dirname "$PID_FILE")"
mkdir -p "$(dirname "$LOG_FILE")"

# 构建（如果没有二进制或 main.go 更新）
if [ ! -f "$BINARY" ] || [ "$ROOT_DIR/main.go" -nt "$BINARY" ]; then
  echo "构建 copilot-go..."
  go build -o "$BINARY" .
fi

# 后台启动
nohup "$BINARY" \
  --web-port="${WEB_PORT}" \
  --proxy-port="${PROXY_PORT}" \
  >> "$LOG_FILE" 2>&1 &

PID=$!
echo $PID > "$PID_FILE"

echo "copilot-go 已后台启动 (PID: $PID)"
echo "  Web Console : http://localhost:${WEB_PORT}"
echo "  Proxy       : http://localhost:${PROXY_PORT}"
echo "  日志文件    : $LOG_FILE"
echo ""
echo "查看日志: bash internal/scripts/logs.sh"
echo "停止服务: bash internal/scripts/stop.sh"
