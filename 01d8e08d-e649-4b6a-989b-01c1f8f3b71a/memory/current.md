# Nix 风格、readOnly、严格 host getter 与 containers/packages

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### Nix 布尔风格

55 个表达式级 &&/|| 改成 builtins.all/any (x_ : x_)，保持操作数顺序、短路与混合嵌套。shell 字符串中的 22 个运算符保留。两处旧 condition_ identity lambda 收敛为 x_。

### 验证

历史 agent 执行 nix flake check Exit code 0；用户 shell 部署 nixos-server Exit code 0。copying 0 paths 只说明目标已有依赖路径，不能独立证明新旧 system closure 相同。

### 提交表达

derived options 太窄，最终草稿 refactor(modules): limit internal options to one definition，涵盖 metadata、内部输入和派生值。

### Option 语义

internal 是声明/赋值来源边界，允许最终组装层读取；不是安全访问控制。unique 的类型合并语义与 readOnly 的原始定义数量约束不同，不能直接机械替换。

### UID 修正

modules.users.<user>.uid 由 flake.nix 最终组装层赋值，不应 internal；已移除 internal，保留 unique 和 default=null。modules.hosts.<host>.users 由 metadata 内部生产，flake 只读取，故保留 internal；撤回更早认为 host.users 也误标的建议。

### readOnly 迁移

19 类直接 internal+unique 改基础类型 + internal + readOnly，配套删除被覆写默认值并整理生产端/消费者。未修改 nested/element-level unique，也不把 UID 改回 internal。

### 消费者契约

Agent provider 未定义 enable 与显式 false 均禁用；fallback 在消费视图，不向 readOnly option 自身补定义，避免多定义和自引用。SOPS defaultSopsFormat 无消费端伪默认，只消费真实定义，lingyu 明确 yaml。Niri/X11 禁用 wrapper 显式 null，thinkbook/WSL publicIpAddress 显式 null。

### Nix 风格

新增/修改表达式不用 &&、||、//、++，用现有函数形式；不修改 .gitignore。

### 严格 getter

零个和多个 enabled host 的临时 Nix 求值均先报 attribute wireguard missing。根因是旧 helper 返回 {} 后被直接读字段；assertions 不是命令式前置检查。用户采纳 getUniqueEnabledHost 非唯一时 builtins.throw，错误包括 enabled names，不增加 bool 模式参数。

### 模块不变量

保留全局 exactly-one-host assertion，因为惰性 getter 未必被调用；assertion 改用 (builtins.tryEval enabledHost_).success。host-functions 测试期待失败，module-composition 同步新通用消息。

### 验证和 staging

更新遗留 composition 消息后，用户 check 通过。随后发现 staged composition tests 与 unstaged assertion 错位，不能用完整 worktree check 证明 index snapshot。最终拆成 getter+单测的 fix(lib)，以及 assertion+composition 的第二笔草稿，分别审阅。不把草稿或检查认作实际 commit。
