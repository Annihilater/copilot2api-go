#!/usr/bin/env bash
# dev-frontend.sh - 开发模式启动 Vite 前端开发服务器
#
# 用法:
#   bash scripts/dev-frontend.sh
#
# 访问:
#   前端热更新 → http://localhost:35173  (HMR)
#   /api 请求会代理到 → http://localhost:37000 (Go 后端)
#
# 请先确保 Go 后端已启动: bash scripts/dev.sh 或 bash scripts/start.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# 检测包管理器
if command -v bun &>/dev/null; then
  PKG_MGR="bun"
elif command -v npm &>/dev/null; then
  PKG_MGR="npm"
else
  echo "错误: 未找到 bun 或 npm，请先安装"
  exit 1
fi

echo "▶ 启动 Vite dev server（使用 ${PKG_MGR}）"
echo "  前端热更新 → http://localhost:35173"
echo "  API 代理   → http://localhost:37000"
echo "  按 Ctrl+C 停止"
echo ""

cd "$ROOT_DIR/web"
${PKG_MGR} run dev
