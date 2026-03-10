#!/usr/bin/env bash
# restart.sh - 重启服务
#
# 用法:
#   bash scripts/backend/restart.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "重启 copilot-go..."
bash "$SCRIPT_DIR/stop.sh"
echo ""
bash "$SCRIPT_DIR/start.sh"
