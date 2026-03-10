#!/usr/bin/env bash
# restart.sh - 重启服务
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "重启 copilot-go..."
bash "$SCRIPT_DIR/stop.sh"
echo ""
bash "$SCRIPT_DIR/start.sh"
