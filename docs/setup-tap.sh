#!/usr/bin/env bash
# setup-tap.sh - 一次性脚本：在 GitHub 创建 Homebrew tap 仓库并初始化 Formula
#
# 用法:
#   bash docs/setup-tap.sh
#
# 前提:
#   - 已安装 gh CLI 并已登录 (gh auth login)
#   - 已安装 git

set -e

OWNER="$(gh api user --jq .login)"
TAP_REPO="homebrew-copilot2api-go"
FORMULA_NAME="copilot-go"

echo "==> 创建 tap 仓库: ${OWNER}/${TAP_REPO}"
gh repo create "${OWNER}/${TAP_REPO}" \
  --public \
  --description "Homebrew tap for copilot2api-go" \
  --clone=false 2>/dev/null || echo "仓库已存在，跳过创建"

echo "==> 克隆 tap 仓库..."
TMP_DIR="$(mktemp -d)"
git clone "https://github.com/${OWNER}/${TAP_REPO}.git" "${TMP_DIR}/tap"
cd "${TMP_DIR}/tap"

# 初始化 Formula 目录
mkdir -p Formula

cat > Formula/${FORMULA_NAME}.rb << 'FORMULA'
class CopilotGo < Formula
  desc "GitHub Copilot token → OpenAI / Anthropic API proxy"
  homepage "https://github.com/OWNER/copilot2api-go"
  version "0.0.0"
  license "MIT"

  # This formula will be automatically updated by the release workflow.
  # Placeholder URLs — will be replaced on first release.
  url "https://github.com/OWNER/copilot2api-go/releases/download/v0.0.0/copilot-go_v0.0.0_darwin_arm64.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  def install
    libexec.install "copilot-go"
    libexec.install "web"
    (bin/"copilot-go").write <<~SH
      #!/bin/bash
      cd "#{libexec}" && exec "#{libexec}/copilot-go" "$@"
    SH
  end

  service do
    run [opt_bin/"copilot-go", "--web-port=37000", "--proxy-port=34141"]
    keep_alive true
    working_dir libexec
    log_path var/"log/copilot-go.log"
    error_log_path var/"log/copilot-go.log"
  end

  test do
    assert_predicate opt_bin/"copilot-go", :exist?
  end
end
FORMULA

# Replace OWNER placeholder
sed -i "s/OWNER/${OWNER}/g" Formula/${FORMULA_NAME}.rb

git config user.email "github-actions[bot]@users.noreply.github.com"
git config user.name "github-actions[bot]"
git add Formula/${FORMULA_NAME}.rb
git commit -m "Feature: 初始化 copilot-go Homebrew formula"
git push

echo ""
echo "✅ Tap 仓库初始化完成!"
echo ""
echo "下一步:"
echo "  1. 在主仓库创建 Secret: HOMEBREW_TAP_TOKEN"
echo "     -> GitHub 主仓库 Settings → Secrets → Actions → New repository secret"
echo "     -> 名称: HOMEBREW_TAP_TOKEN"
echo "     -> 值: 一个有 repo 权限的 Personal Access Token (PAT)"
echo "        生成地址: https://github.com/settings/tokens/new?scopes=repo"
echo ""
echo "  2. 推送 tag 触发 release 工作流:"
echo "     git tag v1.0.0 && git push origin v1.0.0"
echo ""
echo "  3. 用户安装方式:"
echo "     brew tap ${OWNER}/copilot2api-go"
echo "     brew install copilot-go"
echo "     brew services start copilot-go"
echo ""
echo "Tap 仓库地址: https://github.com/${OWNER}/${TAP_REPO}"

# Cleanup
cd /
rm -rf "${TMP_DIR}"
