#!/usr/bin/env bash
# restart.sh - 重启 Vite dev server
#
# 用法:
#   bash scripts/frontend/restart.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "重启 Vite dev server..."
bash "$SCRIPT_DIR/stop.sh"
echo ""
bash "$SCRIPT_DIR/start.sh"
