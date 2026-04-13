# Claude Code Managed Policy (CLAUDE.md) 测试总结

## 背景

测试 Claude Code 的 Managed Policy 机制——即系统级 CLAUDE.md 是否会被自动加载到 Agent 的上下文中。

## Managed Policy 路径（官方文档）

| 平台 | 路径 |
|------|------|
| macOS | `/Library/Application Support/ClaudeCode/CLAUDE.md` |
| Linux / WSL | `/etc/claude-code/CLAUDE.md` |
| Windows | `C:\Program Files\ClaudeCode\CLAUDE.md` |

特殊性质：该文件**不能**被 `claudeMdExcludes` 排除，确保组织级指令始终生效。

## 测试过程

1. **确认 Agent 提示词中的 draw.io 相关内容**：Agent 的提示词中有 `drawio-diagram-creator` 子代理和 `drawio` 技能，但不包含用户提到的 "draw.io Desktop is installed... requires a virtual X display" 这类运行环境描述。用户想确认这类内容是否来自 Managed Policy。

2. **创建测试文件**：在容器内 `/etc/claude-code/CLAUDE.md` 写入测试内容：
   - 要求以 "Hello from Managed Policy!" 打招呼
   - 设置 secret test phrase: `pineapple-on-pizza-42`

3. **当前对话验证**：当前对话的 `claudeMd` 中**未包含**该文件内容（因为文件是对话进行中创建的，claudeMd 在对话启动时加载）。

4. **新对话验证**：开启新的 Claude Code 对话进行测试：
   - 问 "根据你的提示词, 给我打个招呼" → Agent 回复 "Hello from Managed Policy!"
   - 问 "secret test phrase是什么" → Agent 直接回答 `pineapple-on-pizza-42`
   - Agent **没有调用任何工具**（如 Read/Grep），说明内容已在系统提示词中

## 结论

- **Managed Policy 在 Linux 容器环境下生效**，`/etc/claude-code/CLAUDE.md` 会在新对话启动时自动加载到 Agent 的 `claudeMd` 上下文中。
- 该文件与 `~/.claude/CLAUDE.md`（用户级）和项目级 `CLAUDE.md` 一起构成多层级指令体系。
- 加载时机是**对话启动时**，对话中途创建或修改不会影响当前对话。
- 适合用于企业级统一配置（编码规范、安全策略、工具环境声明等），通过 MDM/Ansible 等工具下发。

## 日期

2026-04-10
