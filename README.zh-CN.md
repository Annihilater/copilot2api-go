# copilot2api-go

[English](README.md) | [中文](README.zh-CN.md)

GitHub Copilot API 反向代理，使用 Go 重写。将 Copilot 暴露为兼容 OpenAI 和 Anthropic 的 API 服务，并提供多账号 Web 控制台用于管理和负载均衡。

> **警告**：这是一个反向工程代理，不受 GitHub 官方支持，可能会意外失效。使用风险自担。
>
> **GitHub 安全提示**：过度自动化或脚本化使用 Copilot 可能触发 GitHub 的滥用检测系统。请阅读 [GitHub 可接受使用政策](https://docs.github.com/zh/site-policy/acceptable-use-policies) 和 [GitHub Copilot 条款](https://docs.github.com/zh/site-policy/github-terms/github-copilot-product-specific-terms)。

## 功能特性

- **多账号管理**：Web 控制台支持添加、删除、启动和停止多个 GitHub Copilot 账号
- **池化模式负载均衡**：使用轮询或优先级策略在账号间分发请求
- **兼容 OpenAI API**：`/v1/chat/completions`、`/v1/models`、`/v1/embeddings`
- **兼容 Anthropic API**：`/v1/messages`、`/v1/messages/count_tokens` — 自动协议转换
- **模型 ID 映射**：Copilot 内部模型 ID 与标准展示 ID 的双向映射（如 `claude-sonnet-4-20250514`）
- **流式 SSE**：完整支持 OpenAI 和 Anthropic 格式的流式响应
- **GitHub OAuth 设备流**：直接在 Web 控制台中认证账号
- **管理员认证**：密码保护的控制台，带会话管理
- **双语 Web UI**：自动检测并展示中英文界面
- **Docker 就绪**：每次发布时自动构建多架构镜像并推送到 GHCR

## 默认端口

| 服务 | 端口 | 说明 |
|------|------|------|
| Web 控制台 | `37000` | 管理界面 |
| 代理 API | `34141` | OpenAI / Anthropic 兼容接口 |

## 安装方式

### Homebrew（macOS 推荐）

```bash
brew tap Annihilater/tap
brew install copilot2api-go

# 作为后台服务启动（登录时自动启动）
brew services start copilot2api-go
```

服务管理：

```bash
brew services start   copilot2api-go   # 启动并设置开机自启
brew services stop    copilot2api-go   # 停止
brew services restart copilot2api-go   # 升级后重启

# 查看日志
tail -f $(brew --prefix)/var/log/copilot2api-go.log
```

自定义端口：

```bash
brew services stop copilot2api-go
copilot2api-go --web-port=8080 --proxy-port=9090
```

---

### Docker（预构建镜像 — 服务器推荐）

预构建的多架构镜像（`linux/amd64`、`linux/arm64`）在每次发布时自动推送到 GitHub Container Registry，无需本地构建。

```bash
docker pull ghcr.io/annihilater/copilot2api-go:latest

docker run -d \
  --name copilot2api-go \
  --restart unless-stopped \
  -p 37000:37000 \
  -p 34141:34141 \
  -v copilot-data:/root/.local/share/copilot-api \
  -e TZ=Asia/Shanghai \
  ghcr.io/annihilater/copilot2api-go:latest
```

指定版本运行（生产环境推荐）：

```bash
docker run -d \
  --name copilot2api-go \
  --restart unless-stopped \
  -p 37000:37000 \
  -p 34141:34141 \
  -v copilot-data:/root/.local/share/copilot-api \
  -e TZ=Asia/Shanghai \
  ghcr.io/annihilater/copilot2api-go:0.1.3
```

可用标签：
- `latest` — 最新发布版
- `0.1.3` — 指定版本
- `0.1` — 指定小版本的最新补丁

---

### Docker Compose（预构建镜像）

创建 `docker-compose.yaml`：

```yaml
services:
  copilot2api-go:
    image: ghcr.io/annihilater/copilot2api-go:latest
    container_name: copilot2api-go
    restart: unless-stopped
    ports:
      - "37000:37000"   # Web 控制台
      - "34141:34141"   # 代理 API
    volumes:
      - copilot-data:/root/.local/share/copilot-api
    environment:
      - TZ=Asia/Shanghai

volumes:
  copilot-data:
    driver: local
```

```bash
docker compose up -d

# 查看日志
docker compose logs -f

# 升级到最新版
docker compose pull && docker compose up -d
```

---

### Docker Compose（源码构建）

项目根目录已包含 `docker-compose.yaml`：

```bash
docker compose up -d
```

或自定义配置：

```yaml
services:
  copilot2api-go:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: copilot2api-go
    restart: unless-stopped
    ports:
      - "37000:37000"   # Web 控制台
      - "34141:34141"   # 代理 API
    volumes:
      - copilot-data:/root/.local/share/copilot-api
    environment:
      - TZ=Asia/Shanghai
    command: ["./copilot-go", "--web-port=37000", "--proxy-port=34141"]

volumes:
  copilot-data:
    driver: local
```

---

### 源码编译

```bash
# 1. 构建前端
bash web/scripts/build.sh

# 2. 编译二进制
go build -o build/copilot-go .

# 3. 运行（在项目根目录运行以便找到 Web UI）
./build/copilot-go --web-port=37000 --proxy-port=34141
```

后台守护进程（Linux/macOS）：

```bash
bash internal/scripts/start.sh    # 后台启动
bash internal/scripts/status.sh   # 查看状态
bash internal/scripts/logs.sh     # 查看日志
bash internal/scripts/stop.sh     # 停止
```

---

## 命令行选项

| 选项 | 默认值 | 说明 |
|------|--------|------|
| `--web-port` | `37000` | Web 控制台端口 |
| `--proxy-port` | `34141` | 代理 API 端口 |
| `--verbose` | `false` | 启用详细日志 |
| `--auto-start` | `true` | 启动时自动运行已启用的账号 |

## 快速上手

1. 打开 **http://localhost:37000** — 首次访问时创建管理员账号
2. 点击 **添加账号** → 通过 GitHub OAuth 设备流完成认证
3. 点击账号的 **启动** — 等待状态变为 **运行中**
4. 从账号详情页复制 **API Key**（`sk-...`）
5. 将 AI 客户端的 Base URL 指向 `http://localhost:34141`，并填入 API Key

## API 参考

### 兼容 OpenAI 的接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/v1/chat/completions` | POST | 对话补全（支持流式） |
| `/v1/models` | GET | 获取可用模型列表 |
| `/v1/embeddings` | POST | 创建嵌入向量 |
| `/chat/completions` | POST | 无 `/v1` 前缀的别名 |
| `/models` | GET | 无 `/v1` 前缀的别名 |

### 兼容 Anthropic 的接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/v1/messages` | POST | Messages API（支持流式） |
| `/v1/messages/count_tokens` | POST | Token 计数 |

### 鉴权方式

两种请求头格式均支持：

```bash
# OpenAI 风格
Authorization: Bearer sk-your-api-key

# Anthropic 风格
x-api-key: sk-your-api-key
```

## 使用示例

### OpenAI 对话补全

```bash
curl http://localhost:34141/v1/chat/completions \
  -H "Authorization: Bearer sk-your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "你好！"}],
    "stream": true
  }'
```

### Anthropic Messages

```bash
curl http://localhost:34141/v1/messages \
  -H "x-api-key: sk-your-api-key" \
  -H "Content-Type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4",
    "max_tokens": 1024,
    "messages": [{"role": "user", "content": "你好！"}]
  }'
```

### Claude Code

```bash
ANTHROPIC_BASE_URL=http://localhost:34141 \
ANTHROPIC_API_KEY=sk-your-api-key \
claude
```

或在项目目录下创建 `.claude/settings.json`：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:34141",
    "ANTHROPIC_AUTH_TOKEN": "sk-your-api-key",
    "ANTHROPIC_MODEL": "claude-sonnet-4",
    "ANTHROPIC_SMALL_FAST_MODEL": "gpt-4.1-mini"
  }
}
```

### Python（OpenAI SDK）

```python
from openai import OpenAI

client = OpenAI(api_key="sk-your-api-key", base_url="http://localhost:34141/v1")
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "你好！"}]
)
print(response.choices[0].message.content)
```

### Python（Anthropic SDK）

```python
import anthropic

client = anthropic.Anthropic(api_key="sk-your-api-key", base_url="http://localhost:34141")
message = client.messages.create(
    model="claude-sonnet-4",
    max_tokens=1024,
    messages=[{"role": "user", "content": "你好！"}]
)
print(message.content[0].text)
```

## Web 控制台 API

### 公开接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/config` | GET | 服务器配置（代理端口、初始化状态） |
| `/api/auth/setup` | POST | 初始管理员设置 |
| `/api/auth/login` | POST | 管理员登录 |

### 受保护接口（需要管理员 Session Token）

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/accounts` | GET | 获取所有账号及状态 |
| `/api/accounts` | POST | 添加账号 |
| `/api/accounts/:id` | PUT | 更新账号 |
| `/api/accounts/:id` | DELETE | 删除账号 |
| `/api/accounts/:id/start` | POST | 启动实例 |
| `/api/accounts/:id/stop` | POST | 停止实例 |
| `/api/accounts/:id/usage` | GET | 查看账号用量 |
| `/api/accounts/:id/regenerate-key` | POST | 重新生成 API Key |
| `/api/auth/device-code` | POST | 发起 GitHub OAuth 流程 |
| `/api/auth/poll/:sessionId` | GET | 轮询 OAuth 状态 |
| `/api/auth/complete` | POST | 完成 OAuth 并创建账号 |
| `/api/pool` | GET / PUT | 获取/更新池化配置 |
| `/api/pool/regenerate-key` | POST | 重新生成池化 API Key |
| `/api/model-map` | GET / PUT / POST | 管理模型 ID 映射 |
| `/api/model-map/:copilotId` | DELETE | 删除映射 |

## 数据存储

所有数据持久化在 `~/.local/share/copilot-api/`：

| 文件 | 内容 |
|------|------|
| `accounts.json` | 账号列表和 Token |
| `pool-config.json` | 池化模式配置 |
| `admin.json` | 管理员密码哈希 |
| `model_map.json` | 模型 ID 映射 |

## 项目结构

```
copilot2api-go/
├── main.go                      # 入口
├── go.mod / go.sum
├── Dockerfile                   # 多阶段构建
├── Dockerfile.ci                # CI 构建（复制预构建二进制）
├── docker-compose.yaml          # Docker Compose（源码构建）
├── docs/                        # 文档
├── build/                       # 本地构建输出（已 gitignore）
├── internal/
│   ├── scripts/                 # 后端管理脚本
│   ├── config/config.go
│   ├── store/                   # JSON 持久化
│   ├── auth/device_flow.go      # GitHub OAuth 设备流
│   ├── copilot/vscode_version.go
│   ├── anthropic/               # 协议转换
│   ├── instance/                # 实例生命周期 + 负载均衡
│   └── handler/                 # HTTP 路由
└── web/                         # React 前端（Vite + TypeScript）
    ├── scripts/                 # 前端管理脚本
    ├── src/
    ├── dist/                    # 构建输出（已 gitignore）
    └── vite.config.ts
```

## 致谢

基于 [ericc-ch/copilot-api](https://github.com/ericc-ch/copilot-api)（TypeScript/Bun）使用 Go 重写，并增加了多账号控制台模式。

## 许可证

MIT
