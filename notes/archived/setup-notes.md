# Claude Container Setup Notes

> 下次重建容器时需要的安装与配置记录

## 1. 环境信息

- **容器类型**: Ubuntu Linux Docker container (Docker Desktop on Mac, linuxkit kernel)
- **宿主机挂载**: `/Users/yangyixuan/` 挂载进容器
- **容器用户**: `agent` (home: `/home/agent/`)

## 2. GPU Server SSH 配置

### 2.1 创建专用用户

在 A40 GPU 服务器 (`172.20.65.32`) 上为容器创建了专用 SSH 用户：

- **用户名**: `claude-ssh-user`
- **密码**: `cotIxtRVoSw1tauyiBGzUQ==`
- **Boltzgen 环境**: `/home/claude-ssh-user/boltzgen`（从 `/home/nano/miniconda3/envs/boltzgen` 复制）

### 2.2 SSH Key 免密登录

在项目目录 `scholarclaw_nanobody/.ssh/` 下生成了 ed25519 密钥对，公钥已部署到服务器。

连接命令：
```bash
ssh -i /Users/yangyixuan/workspaces/AIM/scholarclaw_nanobody/.ssh/id_ed25519 -o StrictHostKeyChecking=no claude-ssh-user@172.20.65.32 '<REMOTE_COMMAND>'
```

**注意**: 密钥对存放在项目目录而非 `~/.ssh/`，重建容器时无需重新生成（挂载自宿主机）。

### 2.3 容器内缺失的工具

以下工具在容器内不可用，如需使用需额外安装：

- `sshpass` — 非交互式 SSH 密码传递（已通过 SSH Key 免密方案替代）
- `expect` — 交互式自动化
- `tmux` — 终端复用（持久化 SSH 会话必需，需 `sudo apt-get install -y tmux`）

## 3. tmux 安装与持久化 SSH 会话

### 3.1 安装 tmux

```bash
sudo apt-get update && sudo apt-get install -y tmux
```

### 3.2 持久化交互式 SSH 会话

通过 tmux + SSH Key 实现跨命令保持状态的远程会话：

```bash
# 创建持久化 SSH 会话
tmux new-session -d -s gpu-ssh "ssh -i /Users/yangyixuan/workspaces/AIM/scholarclaw_nanobody/.ssh/id_ed25519 -o StrictHostKeyChecking=no claude-ssh-user@172.20.65.32"

# 发送命令
tmux send-keys -t gpu-ssh '命令' Enter

# 读取输出
tmux capture-pane -t gpu-ssh -p
```

### 3.3 tmux-mcp（已配置，工具暂不可用）

项目 `.mcp.json` 中已配置 tmux-mcp，MCP server 可连接但工具未暴露到 Claude Code 工具列表。当前使用上述 Bash + tmux 方案替代。

```json
{
  "mcpServers": {
    "tmux": {
      "command": "npx",
      "args": ["-y", "tmux-mcp"]
    }
  }
}
```

## 4. 项目级配置文件清单

| 文件 | 用途 |
|------|------|
| `scholarclaw_nanobody/CLAUDE.md` | 项目指令，含 SSH 连接信息 |
| `scholarclaw_nanobody/.mcp.json` | MCP server 配置 |
| `scholarclaw_nanobody/.ssh/id_ed25519` | SSH 私钥（免密登录） |
| `scholarclaw_nanobody/.ssh/id_ed25519.pub` | SSH 公钥 |
