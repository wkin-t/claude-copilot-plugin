# claude-copilot-plugin

> GitHub Copilot CLI plugin for Claude Code — delegate tasks and adversarial reviews to GPT-5 as subagents.

## 简介

这个插件让 Claude Code 能够把任务委托给 [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli) 执行，由 GPT-5 系列模型完成分析，结果直接返回给主 agent。

**适用场景：**
- 上下文密集型任务（大量文件扫描、批量分析），需要节省 Claude 的上下文窗口
- 对抗式代码审查，利用 GPT-5 的视角发现 Claude 可能忽略的边界条件

## 前提条件

安装并登录 **新版** GitHub Copilot CLI（需支持 `copilot -p` 接口）：

```bash
npm install -g @github/copilot-cli
copilot auth
```

> **注意**：旧版包名 `@githubnext/github-copilot-cli`（2023 年版）**不支持** `-p`/`--model` 标志，请确认安装的是新版。

验证安装（以下输出中应包含 `-p` / `--model` 选项）：

```bash
copilot --help
```

**常见问题**：如果 `~/.bashrc` 中存在 `copilot` 同名 shell 函数（如 `copilot () { /c/Windows/System32/copilot.exe ... }`），会导致插件检测失败。需先注释或移除该函数，再重启 shell。

## 安装

```bash
# 第一步：注册市场（只需做一次）
claude plugin marketplace add https://github.com/wkin-t/claude-copilot-plugin.git

# 第二步：安装插件
claude plugin install copilot-cli
```

重启 Claude Code 后生效。

<details>
<summary>手动方式（备用）</summary>

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

然后执行 `/plugins install copilot-cli@copilot-cli-plugins`。

</details>

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

## 免责声明

**本插件按"现状"提供，不附带任何明示或暗示的保证。使用前请阅读以下内容：**

### AI 输出免责

本插件的代码审查和任务分析结果由 AI 模型（GPT-5）自动生成，**不构成专业建议**。AI 输出可能包含错误、遗漏或误判。

- 请勿将 AI 审查结论作为唯一的代码质量或安全性依据
- 涉及生产环境、安全敏感或合规要求的代码，须经人工复核
- 作者对因依赖 AI 输出而导致的任何损失不承担责任

### 费用免责

本插件会调用 **GitHub Copilot CLI**，该工具按调用次数计费，费用由你的 GitHub Copilot 订阅承担。

- 作者对你产生的任何 Copilot 使用费用不承担责任
- 建议在使用前了解 [GitHub Copilot 定价](https://github.com/features/copilot)

### 数据隐私免责

使用本插件时，以下内容会被发送至 **GitHub Copilot 后端**（由 Microsoft/OpenAI 处理）：

- 你嵌入 prompt 中的代码片段、文件内容
- 工作目录下的 `CLAUDE.md` / `.claude/CLAUDE.md`（由 Copilot CLI 自动加载）

请确认你有权将相关数据发送至上述第三方服务，并符合所在组织的数据合规要求（GDPR、企业数据安全政策等）。作者对数据传输引发的任何隐私问题不承担责任。

### 第三方软件声明

本插件是 [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli) 的包装器，与 GitHub、Microsoft 或 OpenAI 无任何关联或背书。

---

## 升级

```bash
claude plugin update copilot-cli
```

然后在 Claude Code 中运行：

```
/reload-plugins
```

`/reload-plugins` 会立即应用更新（重载 agents、skills、hooks），无需重启 Claude Code。

发布新版本（维护者）：

```bash
./release.sh 1.0.5
```

## 版本历史

| 版本 | 变更 |
|------|------|
| 1.0.5 | 三阶段 preflight check：区分 Windows 内置 copilot.exe、shell 函数覆盖、旧版 CLI；修正安装文档 |
| 1.0.4 | 添加发布脚本 release.sh；完善免责声明 |
| 1.0.3 | 补全发布规范：README、LICENSE、plugin.json 完整元数据 |
| 1.0.2 | Preflight check（copilot 不可用时 fail fast）；变量式调用避免 shell injection |
| 1.0.1 | 作者信息脱敏；CLAUDE.md 隐私警告；`--allow-all` 风险说明 |
| 1.0.0 | 初始发布 |

## 许可证

MIT © [wkin-t](https://github.com/wkin-t)

本项目遵循 [MIT License](plugins/copilot-cli/LICENSE)。核心条款：软件"按现状"提供，作者不对任何直接或间接损失承担责任。
