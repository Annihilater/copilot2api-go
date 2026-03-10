#!/usr/bin/env bash
# logs.sh - 查看 Vite dev server 实时日志
#
# 用法:
#   bash scripts/frontend/logs.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

LOG_FILE="${ROOT_DIR}/logs/vite.log"

if [ ! -f "$LOG_FILE" ]; then
  echo "日志文件不存在: $LOG_FILE"
  echo "请先通过 start.sh 后台启动服务"
  exit 1
fi

echo "=== 查看日志: $LOG_FILE (Ctrl+C 退出) ==="
tail -f "$LOG_FILE"
