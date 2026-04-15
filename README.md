# claude-copilot-plugin

> GitHub Copilot CLI plugin for Claude Code — delegate tasks and adversarial reviews to GPT-5 as subagents.

## 简介

这个插件让 Claude Code 能够把任务委托给 [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli) 执行，由 GPT-5 系列模型完成分析，结果直接返回给主 agent。

**适用场景：**
- 上下文密集型任务（大量文件扫描、批量分析），需要节省 Claude 的上下文窗口
- 对抗式代码审查，利用 GPT-5 的视角发现 Claude 可能忽略的边界条件

## 前提条件

安装并登录 GitHub Copilot CLI：

```bash
npm install -g @githubnext/github-copilot-cli
copilot auth
```

验证安装：

```bash
copilot -p "hello" --model gpt-5-mini -s --allow-all
```

## 安装

### 1. 注册市场

编辑 `~/.claude/settings.json`，在 `extraKnownMarketplaces` 下添加：

```json
"extraKnownMarketplaces": {
  "copilot-cli-plugins": {
    "source": {
      "source": "url",
      "url": "https://github.com/wkin-t/claude-copilot-plugin.git"
    }
  }
}
```

### 2. 安装插件

在 Claude Code 中执行：

```
/plugins install copilot-cli@copilot-cli-plugins
```

## 组件

| 组件 | 类型 | 触发方式 | 说明 |
|------|------|----------|------|
| `copilot-task` | Agent | 主 agent 调用 | 将上下文密集型任务委托给 GPT-5 |
| `copilot-review` | Agent | 主 agent 调用 | 对抗式代码审查，GPT-5 扮演怀疑论审查员 |
| `copilot-runtime` | Skill | 自动加载（不对用户开放） | 调用模板、模型路由、超时规范 |

### copilot-task

将任务整理为自包含 prompt，调用一次 Copilot CLI，原样返回输出。适合：
- 扫描 20+ 文件的模式检查
- 边界条件分析
- 大批量探索任务

### copilot-review

对抗式审查：GPT-5 的默认立场是"找到这个变更不应该上线的理由"。适合：
- 实现完成后的安全网审查
- 支付/权限等高风险代码路径的二次确认

## 安全说明

**`--allow-all` 标志**：授予 Copilot CLI 所有工具权限以支持非交互模式。请勿在不可信环境下运行。

**CLAUDE.md 自动加载**：Copilot CLI 会自动读取工作目录下的 `CLAUDE.md` 和 `.claude/CLAUDE.md`，并将内容发送至 GitHub Copilot 后端（Microsoft/OpenAI 服务器）。如果你的 CLAUDE.md 包含内部系统提示词或敏感业务信息，请确认其内容适合发送至外部服务，或在空目录下运行插件。

## 版本历史

| 版本 | 变更 |
|------|------|
| 1.0.3 | 补全发布规范：README、LICENSE、plugin.json 完整元数据 |
| 1.0.2 | Preflight check（copilot 不可用时 fail fast）；变量式调用避免 shell injection |
| 1.0.1 | 作者信息脱敏；CLAUDE.md 隐私警告；`--allow-all` 风险说明 |
| 1.0.0 | 初始发布 |

## 许可证

MIT © [wkin-t](https://github.com/wkin-t)
