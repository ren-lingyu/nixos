# Nix 风格、readOnly、严格 host getter 与 containers/packages

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### Nix 布尔风格

55 个表达式级 &&/|| 改成 builtins.all/any (x_ : x_)，保持操作数顺序、短路与混合嵌套。shell 字符串中的 22 个运算符保留。两处旧 condition_ identity lambda 收敛为 x_。

### 验证

定向搜索与 git diff --check 通过，未运行 Nix check。该阶段还存在其他此前变更，不能把此验证当整个工作区构建证明。

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

### Containers

旧 caddy/WBO staged 代码引用已删除 interconnect namespace，不能只改排版。用户要求完整接入：modules/default.nix 导入 containers，自动发现 container，统一 enable/extra-options/existModule。每个 container 根只导入 os 并声明 os=true/hm=false；真实配置在 os/default.nix。

### 显式网络输入

caddy 暴露 ip、port、networkInterface；WBO 再加 allowedSourceIp。port 默认18000，其他需要明确设置。enable 不自动从 host 推导，防火墙限制目标/source IP 与 TCP port，caddy UID 从 config.ids.uids.caddy 派生，不写死 wg0。extra-options 完整参数签名与仓库一致。

### genAttrs

五处按名称生成 attrset 改为 lib.genAttrs，分布在四个文件，保留括号换行。涉及通用 module option generator、HM interfaces 两层、host metadata 和 Thunderbird fromList。SOPS UID→username 需要同时派生键值，保留 listToAttrs+map。用户示例 getAttrs 是笔误，实际采用 genAttrs。

### Package helper

lib/packageFunctions.nix 同时收集 localOverlays 与 namespaceOverlays，避免目录两种 overlay 并存时漏掉更深层。审查发现 derivation 也是 attrs，单用 isAttrs 会把同名 package 当 namespace；历史记录 加 lib.isDerivation 保护，明确拒绝冲突。两处 // 改 mergeAttrsList，保持后 overlay 覆盖顺序。

### pkgs 风格

统一参数/回调/括号；禁止 Nix indented multiline strings，phase 用 concatStringsSep，固定 argv 用 escapeShellArgs。需要 runtime 展开的变量保留正确引用；不误用面向 option attrset 的 GNU CLI helper 生成有序完整命令。

### 最终验证

git diff --check 与禁用运算符搜索通过，未 Nix build/check。packageFunctions 是 MM，最终修复在 unstaged；需要重新 stage 才进入未来提交。此前八月初段 check 不覆盖九月后续 containers/package 改动。
