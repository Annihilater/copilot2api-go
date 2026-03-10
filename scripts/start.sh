#!/usr/bin/env bash
# start.sh - 后台启动（生产/常驻运行）
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

WEB_PORT="${WEB_PORT:-3000}"
PROXY_PORT="${PROXY_PORT:-4141}"
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
mkdir -p "$(dirname "$PID_FILE")"
mkdir -p "$(dirname "$LOG_FILE")"

# 构建（如果没有二进制或源码更新）
if [ ! -f "$ROOT_DIR/copilot-go" ] || [ "$ROOT_DIR/main.go" -nt "$ROOT_DIR/copilot-go" ]; then
  echo "构建 copilot-go..."
  go build -o copilot-go .
fi

# 后台启动
nohup ./copilot-go \
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
echo "查看日志: bash scripts/logs.sh"
echo "停止服务: bash scripts/stop.sh"
