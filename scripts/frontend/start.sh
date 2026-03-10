#!/usr/bin/env bash
# start.sh - 后台启动 Vite 前端开发服务器
#
# 用法:
#   bash scripts/frontend/start.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

PID_FILE="${ROOT_DIR}/tmp/vite.pid"
LOG_FILE="${ROOT_DIR}/logs/vite.log"

# 检测包管理器
if command -v bun &>/dev/null; then
  PKG_MGR="bun"
elif command -v npm &>/dev/null; then
  PKG_MGR="npm"
else
  echo "错误: 未找到 bun 或 npm，请先安装"
  exit 1
fi

# 检查是否已经在运行
if [ -f "$PID_FILE" ]; then
  PID=$(cat "$PID_FILE")
  if kill -0 "$PID" 2>/dev/null; then
    echo "Vite dev server 已经在运行 (PID: $PID)"
    exit 0
  else
    echo "清理过期 PID 文件..."
    rm -f "$PID_FILE"
  fi
fi

# 确保目录存在
mkdir -p "$(dirname "$PID_FILE")"
mkdir -p "$(dirname "$LOG_FILE")"

# 后台启动
cd "$ROOT_DIR/web"
nohup ${PKG_MGR} run dev >> "$LOG_FILE" 2>&1 &

PID=$!
echo $PID > "$PID_FILE"

echo "Vite dev server 已后台启动 (PID: $PID)"
echo "  前端热更新 → http://localhost:35173"
echo "  API 代理   → http://localhost:37000"
echo "  日志文件   : $LOG_FILE"
echo ""
echo "查看日志: bash scripts/frontend/logs.sh"
echo "停止服务: bash scripts/frontend/stop.sh"
