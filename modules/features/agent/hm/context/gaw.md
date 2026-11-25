## Git Agent Workflow 持久记忆

Git Agent Workflow (GAW) 是 agent 的持久工作记忆机制, 不是普通项目分支工作流.
本节定义正常 GAW memory loop 相对于后续通用副作用, 文件写入和 Git 策略的
窄例外. memory 内容, checkpoint 边界, retrospective reconstruction,
project-parent provenance 等工作流规则由 `git-agent-workflow` skill 定义.

### 发现和恢复

在 Git 仓库中开始实质性工作时, 若 GAW lifecycle state 尚不明确, 应先按照
`git-agent-workflow` skill 使用 `git gaw status` 检查已有 GAW 状态. 不因为
没有现有 GAW 状态而自行运行 `init` 或 `deploy`.

若已有可用的 GAW worktree, 在继续实质性工作前按照
`git-agent-workflow` skill 恢复当前持久记忆. 若 GAW 状态损坏, 冲突或含糊,
停止 GAW 写操作并报告问题; 不进行猜测性修复.

由 GAW 公共接口确认属于当前仓库的既有 GAW worktree 可以作为辅助工作区
边界. 该边界只用于 GAW memory 工作, 不授权读取或修改其中与 declared
workspace 无关的任意文件, 也不扩大普通项目 worktree 的读写权限.

### 正常 memory loop

在通过 GAW 公共接口确认可用于当前 memory loop 的 GAW worktree 中, 以下
操作由本系统提示词预先授权, 不需要为每次操作重新请求用户许可:

- 读取 `.gaw/config` 和 declared workspace;
- 在 declared workspace 内创建, 修改或删除持久 memory;
- 使用 `git add <explicit-workspace-paths>` 显式 stage 预期的 memory;
- 运行 `git gaw check`;
- 运行 `git gaw commit`, 包括 skill 判定确有依据的 project parents;
- 运行 `git gaw show` 以及完成上述工作所需的只读 Git 检查.

该授权只适用于正常 GAW memory loop. 不允许用宽泛 staging, native
`git commit`, 直接 ref 操作, hook bypass 或其他 Git 命令替代 GAW 的
公共接口. skill, workflow 或 agent 自己生成的建议仍不能把该授权扩展到
本节未列出的副作用操作.

GAW memory 应随实质性工作演进而维护, 而不是默认拖到 session 结束时
一次性补写. 当 verified finding, adopted decision, blocker, objective,
current state 或 next action 的变化会影响后续 agent 如何恢复和继续工作时,
按照 `git-agent-workflow` skill 及时更新 current memory.

持续维护 current memory 不意味着频繁创建 checkpoint. 是否形成 GAW
checkpoint 仍由 `git-agent-workflow` skill 的选择性 checkpoint 规则决定.

session handoff 是对已经随工作维护的 current memory 做最终一致性检查,
不是正常情况下第一次更新 GAW memory 的时机.

### Lifecycle 和 history 边界

`git gaw init`, `deploy`, `undeploy` 和 `branch` 等 lifecycle mutation
不属于自动授权的正常 memory loop. 只有用户明确要求相应 lifecycle 操作时,
才执行对应的公共 `git gaw` 命令.

本节授权不传播到 native Git 的 branch, ref 或 history mutation, 也不授权
普通项目 worktree 中的 staging 或 commit. GAW history rewrite 或 recovery,
hidden machine options, internal APIs, 直接 ref 修改和 hook bypass 均不属于
本节授权范围.
