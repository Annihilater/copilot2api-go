#!/usr/bin/env bash
# dev.sh - 开发模式前台启动
#
# 用法:
#   bash scripts/dev.sh          # 同时启动 Go 后端 + Vite 前端（推荐）
#   bash scripts/dev.sh backend  # 只启动 Go 后端（go run，热编译需手动重启）
#   bash scripts/dev.sh frontend # 只启动 Vite dev server
#
# 访问:
#   前端开发页面  http://localhost:5173  (Vite，带热更新 HMR)
#   Go Web Console http://localhost:3000  (直接访问已构建的静态前端)
#   Proxy          http://localhost:4141

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

WEB_PORT="${WEB_PORT:-3000}"
PROXY_PORT="${PROXY_PORT:-4141}"
MODE="${1:-all}"

# 检查依赖
check_bun_or_npm() {
  if command -v bun &>/dev/null; then
    echo "bun"
  elif command -v npm &>/dev/null; then
    echo "npm"
  else
    echo ""
  fi
}

start_backend() {
  echo "▶ 启动 Go 后端 (port: ${WEB_PORT}, proxy: ${PROXY_PORT})..."
  cd "$ROOT_DIR"
  go run . \
    --web-port="${WEB_PORT}" \
    --proxy-port="${PROXY_PORT}" \
    --verbose
}

start_frontend() {
  local pkg_mgr
  pkg_mgr=$(check_bun_or_npm)
  if [ -z "$pkg_mgr" ]; then
    echo "错误: 未找到 bun 或 npm，请先安装"
    exit 1
  fi
  echo "▶ 启动 Vite dev server (port: 5173, API 代理 → localhost:${WEB_PORT})..."
  cd "$ROOT_DIR/web"
  if [ "$pkg_mgr" = "bun" ]; then
    bun run dev
  else
    npm run dev
  fi
}

case "$MODE" in
  backend)
    start_backend
    ;;
  frontend)
    start_frontend
    ;;
  all|*)
    # 同时启动两者，任意一个退出则全部退出
    trap 'echo ""; echo "正在停止所有进程..."; kill 0' EXIT INT TERM

    start_backend &
    BACKEND_PID=$!

    # 等待后端启动再起前端（避免前端代理连接失败的初始报错）
    sleep 1

    start_frontend &
    FRONTEND_PID=$!

    echo ""
    echo "✓ 开发环境已启动"
    echo "  前端热更新  → http://localhost:5173  (推荐，HMR)"
    echo "  Go 静态页面 → http://localhost:${WEB_PORT}  (已构建的 dist)"
    echo "  Proxy       → http://localhost:${PROXY_PORT}"
    echo ""
    echo "按 Ctrl+C 停止所有进程"

    wait $BACKEND_PID $FRONTEND_PID
    ;;
esac
