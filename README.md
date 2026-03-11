# copilot2api-go

[English](README.md) | [中文](README.zh-CN.md)

A reverse-engineered proxy for the GitHub Copilot API, rewritten in Go. Exposes Copilot as OpenAI and Anthropic compatible API services with a multi-account web console for management and load balancing.

> **Warning**: This is a reverse-engineered proxy. It is not supported by GitHub and may break unexpectedly. Use at your own risk.
>
> **GitHub Security Notice**: Excessive automated or scripted use of Copilot may trigger GitHub's abuse-detection systems. Please review [GitHub Acceptable Use Policies](https://docs.github.com/en/site-policy/acceptable-use-policies) and [GitHub Copilot Terms](https://docs.github.com/en/site-policy/github-terms/github-copilot-product-specific-terms).

## Features

- **Multi-Account Management**: Web console to add, remove, start, and stop multiple GitHub Copilot accounts
- **Pool Mode Load Balancing**: Distribute requests across accounts using Round-Robin or Priority strategies
- **OpenAI Compatible API**: `/v1/chat/completions`, `/v1/models`, `/v1/embeddings`
- **Anthropic Compatible API**: `/v1/messages`, `/v1/messages/count_tokens` — automatic protocol translation
- **Model ID Mapping**: Bidirectional mapping between Copilot internal model IDs and standard display IDs (e.g. `claude-sonnet-4-20250514`)
- **Streaming SSE**: Full support for streaming responses in both OpenAI and Anthropic formats
- **GitHub OAuth Device Flow**: Authenticate accounts directly from the web console
- **Admin Authentication**: Password-protected console with session management
- **Bilingual Web UI**: English and Chinese interface with auto-detection
- **Docker Ready**: Pre-built multi-arch images published to GHCR on every release

## Default Ports

| Service | Port | Description |
|---------|------|-------------|
| Web Console | `37000` | Management UI |
| Proxy API | `34141` | OpenAI / Anthropic compatible endpoint |

## Installation

### Homebrew (macOS recommended)

```bash
brew tap Annihilater/tap
brew install copilot2api-go

# Start as a background service (auto-restart on login)
brew services start copilot2api-go
```

Service management:

```bash
brew services start   copilot2api-go   # start & enable at login
brew services stop    copilot2api-go   # stop
brew services restart copilot2api-go   # restart after upgrade

# View logs
tail -f $(brew --prefix)/var/log/copilot2api-go.log
```

Custom ports:

```bash
brew services stop copilot2api-go
copilot2api-go --web-port=8080 --proxy-port=9090
```

---

### Docker (pre-built image — recommended for servers)

Pre-built multi-arch images (`linux/amd64`, `linux/arm64`) are published to GitHub Container Registry on every release. No build step required.

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

Pin to a specific version (recommended for production):

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

Available tags:
- `latest` — latest release
- `0.1.3` — specific version
- `0.1` — latest patch of a minor version

---

### Docker Compose (pre-built image)

Create a `docker-compose.yaml`:

```yaml
services:
  copilot2api-go:
    image: ghcr.io/annihilater/copilot2api-go:latest
    container_name: copilot2api-go
    restart: unless-stopped
    ports:
      - "37000:37000"   # Web Console
      - "34141:34141"   # Proxy API
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

# View logs
docker compose logs -f

# Upgrade to latest
docker compose pull && docker compose up -d
```

---

### Docker Compose (build from source)

A `docker-compose.yaml` is included in the project root:

```bash
docker compose up -d
```

Or customize it:

```yaml
services:
  copilot2api-go:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: copilot2api-go
    restart: unless-stopped
    ports:
      - "37000:37000"   # Web Console
      - "34141:34141"   # Proxy API
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

### From Source

```bash
# 1. Build frontend
bash web/scripts/build.sh

# 2. Build binary
go build -o build/copilot-go .

# 3. Run (from project root so web UI is found)
./build/copilot-go --web-port=37000 --proxy-port=34141
```

Background daemon (Linux/macOS):

```bash
bash internal/scripts/start.sh    # start in background
bash internal/scripts/status.sh   # check status
bash internal/scripts/logs.sh     # tail logs
bash internal/scripts/stop.sh     # stop
```

---

## Command Line Options

| Option | Default | Description |
|--------|---------|-------------|
| `--web-port` | `37000` | Web console port |
| `--proxy-port` | `34141` | Proxy API port |
| `--verbose` | `false` | Enable verbose logging |
| `--auto-start` | `true` | Auto-start enabled accounts on launch |

## Quick Setup

1. Open **http://localhost:37000** — create an admin account on first visit
2. Click **Add Account** → authenticate via GitHub OAuth device flow
3. Click **Start** on the account — wait for status to show **Running**
4. Copy the **API Key** (`sk-...`) from the account detail page
5. Point your AI client to `http://localhost:34141` with the API Key

## API Reference

### OpenAI Compatible Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/chat/completions` | POST | Chat completions (streaming supported) |
| `/v1/models` | GET | List available models |
| `/v1/embeddings` | POST | Create embeddings |
| `/chat/completions` | POST | Alias without `/v1` prefix |
| `/models` | GET | Alias without `/v1` prefix |

### Anthropic Compatible Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/messages` | POST | Messages API (streaming supported) |
| `/v1/messages/count_tokens` | POST | Token counting |

### Authentication

Both header styles are supported:

```bash
# OpenAI style
Authorization: Bearer sk-your-api-key

# Anthropic style
x-api-key: sk-your-api-key
```

## Usage Examples

### OpenAI Chat Completions

```bash
curl http://localhost:34141/v1/chat/completions \
  -H "Authorization: Bearer sk-your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello!"}],
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
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Claude Code

```bash
ANTHROPIC_BASE_URL=http://localhost:34141 \
ANTHROPIC_API_KEY=sk-your-api-key \
claude
```

Or create `.claude/settings.json` in your project:

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

### Python (OpenAI SDK)

```python
from openai import OpenAI

client = OpenAI(api_key="sk-your-api-key", base_url="http://localhost:34141/v1")
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

### Python (Anthropic SDK)

```python
import anthropic

client = anthropic.Anthropic(api_key="sk-your-api-key", base_url="http://localhost:34141")
message = client.messages.create(
    model="claude-sonnet-4",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello!"}]
)
print(message.content[0].text)
```

## Web Console API

### Public Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/config` | GET | Server config (proxy port, setup status) |
| `/api/auth/setup` | POST | Initial admin setup |
| `/api/auth/login` | POST | Admin login |

### Protected Endpoints (require admin session token)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/accounts` | GET | List all accounts with status |
| `/api/accounts` | POST | Add account |
| `/api/accounts/:id` | PUT | Update account |
| `/api/accounts/:id` | DELETE | Delete account |
| `/api/accounts/:id/start` | POST | Start instance |
| `/api/accounts/:id/stop` | POST | Stop instance |
| `/api/accounts/:id/usage` | GET | Get account usage |
| `/api/accounts/:id/regenerate-key` | POST | Regenerate API key |
| `/api/auth/device-code` | POST | Start GitHub OAuth flow |
| `/api/auth/poll/:sessionId` | GET | Poll OAuth status |
| `/api/auth/complete` | POST | Complete OAuth and create account |
| `/api/pool` | GET / PUT | Get/update pool config |
| `/api/pool/regenerate-key` | POST | Regenerate pool API key |
| `/api/model-map` | GET / PUT / POST | Manage model ID mappings |
| `/api/model-map/:copilotId` | DELETE | Delete mapping |

## Data Storage

All data is persisted in `~/.local/share/copilot-api/`:

| File | Content |
|------|---------|
| `accounts.json` | Account list and tokens |
| `pool-config.json` | Pool mode settings |
| `admin.json` | Admin password hash |
| `model_map.json` | Model ID mappings |

## Project Structure

```
copilot2api-go/
├── main.go                      # Entry point
├── go.mod / go.sum
├── Dockerfile                   # Multi-stage build
├── Dockerfile.ci                # CI build (copies pre-built binary)
├── docker-compose.yaml          # Docker Compose (build from source)
├── docs/                        # Documentation
├── build/                       # Local build output (gitignored)
├── internal/
│   ├── scripts/                 # Backend management scripts
│   ├── config/config.go
│   ├── store/                   # JSON persistence
│   ├── auth/device_flow.go      # GitHub OAuth device flow
│   ├── copilot/vscode_version.go
│   ├── anthropic/               # Protocol translation
│   ├── instance/                # Instance lifecycle + load balancer
│   └── handler/                 # HTTP routing
└── web/                         # React frontend (Vite + TypeScript)
    ├── scripts/                 # Frontend management scripts
    ├── src/
    ├── dist/                    # Build output (gitignored)
    └── vite.config.ts
```

## Credits

Based on [ericc-ch/copilot-api](https://github.com/ericc-ch/copilot-api) (TypeScript/Bun), rewritten in Go with multi-account console mode.

## License

MIT
