#!/usr/bin/env bash
# dev.sh - 前台运行（开发调试用，日志直接输出到终端）
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

WEB_PORT="${WEB_PORT:-3000}"
PROXY_PORT="${PROXY_PORT:-4141}"
VERBOSE="${VERBOSE:-true}"

echo "启动 copilot-go (前台模式)..."
echo "  Web Console : http://localhost:${WEB_PORT}"
echo "  Proxy       : http://localhost:${PROXY_PORT}"
echo "  按 Ctrl+C 停止"
echo ""

go run . \
  --web-port="${WEB_PORT}" \
  --proxy-port="${PROXY_PORT}" \
  $([ "$VERBOSE" = "true" ] && echo "--verbose")
