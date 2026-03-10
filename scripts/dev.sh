#!/usr/bin/env bash
# dev.sh - 开发模式前台启动 Go 后端
#
# 用法:
#   bash scripts/dev.sh
#
# 访问:
#   Web Console → http://localhost:37000
#   Proxy       → http://localhost:34141
#
# 前端开发服务器请单独运行: bash scripts/dev-frontend.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

WEB_PORT="${WEB_PORT:-37000}"
PROXY_PORT="${PROXY_PORT:-34141}"

echo "▶ 启动 Go 后端（前台，verbose 模式）"
echo "  Web Console → http://localhost:${WEB_PORT}"
echo "  Proxy       → http://localhost:${PROXY_PORT}"
echo "  按 Ctrl+C 停止"
echo ""

cd "$ROOT_DIR"
go run . \
  --web-port="${WEB_PORT}" \
  --proxy-port="${PROXY_PORT}" \
  --verbose
