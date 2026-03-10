#!/usr/bin/env bash
# build.sh - 编译前端，产物输出到 web/dist/
#
# 用法:
#   bash scripts/frontend/build.sh
#
# 产物路径: web/dist/
# Go 后端会直接 serve 该目录下的静态文件

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 检测包管理器
if command -v bun &>/dev/null; then
  PKG_MGR="bun"
elif command -v npm &>/dev/null; then
  PKG_MGR="npm"
else
  echo "错误: 未找到 bun 或 npm，请先安装"
  exit 1
fi

echo "▶ 编译前端（使用 ${PKG_MGR}）"
cd "$ROOT_DIR/web"
${PKG_MGR} run build

echo ""
echo "✓ 编译完成，产物输出到 web/dist/"
echo "  重启 Go 后端即可生效: bash scripts/backend/restart.sh"
