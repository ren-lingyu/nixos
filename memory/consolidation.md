# 历史知识来源

## 保留范围与证据限制

历史知识来自 18 条经审阅的独立来源, 保留 52 个具有恢复价值的知识状态. 来源包含目标, 设计动机, 替代方案, 实现结论和验证限制, 不包含原始 rollout, archive 或完整工具日志; 属于历史归纳, 不声称逐字节原始证据保真. 模块重构来源尤其只保留可见对话摘要. 当前项目事实以 current.md 的已提交基线及实际实现为准.

来源曾按主题用于 Formal 知识整合, 通过精确来源 checkpoint 支持相应判断, 并通过完整 tips 保留其 first-parent 演化. 全部活动分支及 worktrees 已安全退役; 完整 70 个来源 commits (含初始化) 仍在 Formal ancestry 中. 原始日志因审阅成本与持久保留风险未直接关联到 Formal, 新来源以旧 memory 历史为首选材料重新归纳, 不继承旧 Auxiliary 或普通项目 ancestry. 整理与退役已经结束, 下文保留验收结果供审计, 不构成当前项目待办; 更细的过程仍在 Formal first-parent 历史.

## 来源索引

路径相对于相应来源 Git tree root. 每个 source.md 说明证据范围, 同目录 current.md 的 first-parent 历史保存选定知识演化. 下表保留知识定位用途, 不依赖已删除分支名, 本机挂载位置或持久化 checkpoint OID.

| 主题 | UUID-relative 来源路径 | 知识状态数 |
| --- | --- | ---: |
| monitor-host-x11 | `d1ecfe98-8d70-4ed0-8fe9-086bfb5721fc/memory/source.md` 与同目录 `current.md` | 3 |
| file-manager-terminal-portal | `7cc5b1b0-9ad0-47a3-8e9e-afeb342bd6e9/memory/source.md` 与同目录 `current.md` | 3 |
| metadata-claims | `bd1cbfba-87f8-40ff-8170-07cf548cca1e/memory/source.md` 与同目录 `current.md` | 3 |
| registry-nix-app | `3ae570e4-1a6f-4eb5-a587-fef91898260a/memory/source.md` 与同目录 `current.md` | 1 |
| framebuffer-kmscon | `4038629b-910a-4e71-a8da-fcb671781cfc/memory/source.md` 与同目录 `current.md` | 1 |
| module-composition | `ab0e5495-e6c7-449b-a798-4b7453eb9319/memory/source.md` 与同目录 `current.md` | 6 |
| pi-skills | `67b1954b-f1df-49fa-9d6d-90f7779239e2/memory/source.md` 与同目录 `current.md` | 3 |
| flake-parts-introduction | `556edc63-3a28-4090-9d6f-12d884625a5a/memory/source.md` 与同目录 `current.md` | 2 |
| identity-secrets-armor | `8536cd94-a761-42a6-9ebd-517e37d30423/memory/source.md` 与同目录 `current.md` | 5 |
| cfg-aliases | `cc157a3b-d374-4edf-b3f1-284a0f7a8fab/memory/source.md` 与同目录 `current.md` | 2 |
| agent-providers | `d39e1ab2-c94e-4ec6-b7b9-eb5d16a54dec/memory/source.md` 与同目录 `current.md` | 2 |
| readonly-host-packages | `01d8e08d-e649-4b6a-989b-01c1f8f3b71a/memory/source.md` 与同目录 `current.md` | 4 |
| flake-parts-module-refactor | `ddc19bb1-dbb6-463a-8201-f286531af917/memory/source.md` 与同目录 `current.md` | 4 |
| clash-geodata | `ee5ea724-542e-4a38-a6a0-d7aee9717cc0/memory/source.md` 与同目录 `current.md` | 2 |
| icewm-fallback | `2b6c7939-aeff-4f1a-adcb-2a578653020a/memory/source.md` 与同目录 `current.md` | 2 |
| wsl-removal-commit-semantics | `602000f2-8797-4731-acf7-02ac8d0ba8e1/memory/source.md` 与同目录 `current.md` | 3 |
| noctalia-lockscreen | `dacd12b8-abff-441e-a495-ccaa2e8d6c65/memory/source.md` 与同目录 `current.md` | 3 |
| wireguard-evolution | `8a007c91-445c-4409-9af8-c574fe2663a3/memory/source.md` 与同目录 `current.md` | 3 |

## 旧历史退役及本地清理结果

知识与来源验收后, 用户单独授权清理, 并分别确认全部不可达 commits 与独立 blob/tree 均可不备份删除. 原始 18 条和弃用试建 18 条共 36 个 branches/worktrees 已退役. 移除前重新检查 tips, worktrees, 完整 index, untracked 和进行中的操作; 未用强制 worktree 删除丢弃改动. 分支通过公共 `git gaw branch -D` 显式放弃, 未手动修改 refs.

重新核对保留关系后, 仅过期不可达 reflog 条目, 保留可达 reflog 历史, 并执行 `git gc --prune=now`; GC 本身禁止额外过期 reflog. 未制作恢复包. 清理前不可达集合为 276 commits, 702 trees, 681 blobs, 包括 187 个指定退役 commits 和用户允许丢弃的 89 个其他不可达 commits. 原预检中不归属这些 commits 闭包的 469 blobs 与 22 trees 亦获得明确丢弃授权.

清理后逐个检查 187 个旧/试建 commits, 17 个原始 rollout blobs 及原预检的 936 个非目标对象, 全部已无法读取. 完整不可达对象检查为空. 上轮清理后, 36 个指定 refs/worktrees 不存在, 当时保留 18 个清洁 Auxiliary 和共 20 个 worktrees; 所有清洁 tips 仍可从 Formal ancestry 到达. 普通项目分支保持不变, 未 push 或改写普通项目历史.

已有 commit-graph 派生缓存引用四个失效条目; 通过公开 `git commit-graph write --reachable --split=replace` 重建后, 默认完整对象检查及 GC 后检查通过. 共享且仍由合法历史引用的对象继续保留, 不将其误报为清理失败.

上述结果仅针对目标本地仓库中的 Git 对象和指定 worktrees. 不保证外部副本或物理存储残留清除. 仓库外原始 Codex 会话与隔离审阅副本未删除, 忽略目录内临时材料也未自动清空; 它们不是 Formal 的长期恢复依赖.

## 已整合清洁来源的安全退役

在上述旧历史 GC 完成后, 用户明确接受来源中保留的个人配置背景, 并授权退役全部 18 条清洁 Auxiliary 的活动分支. 退役前重新确认完整 tips 已进入 Formal ancestry, 所有 worktrees/index/untracked 干净且无进行中的操作. 顺序为移除对应 worktree, 复查 `git gaw aux check`, 再使用公共 `git gaw branch -d` 安全删除; 不使用 `-D`.

验收结果: Auxiliary branches 为零, worktrees 只剩普通项目与 Formal 两个. 18 条清洁来源的全部 70 个 commits 仍从 Formal 可达, 包括 52 个知识 checkpoints 与 18 个初始化 roots. UUID-relative 来源表及 Formal 整合 parents 保留, 删除活动分支不删除这些历史. 可从相关 Formal 整合 checkpoint 的 parents 检查对应 UUID tree, 再按表中路径读取 source.md/current.md 及其 first-parent 演化; 不依赖已删除分支名或本机 worktree 路径. 本轮未执行 GC 或 push, 普通项目 refs 保持, 完整 fsck 通过.

敏感性复查覆盖当时 Formal 可达的 80 个 commits 和 93 个文件内容版本, 未发现凭据值或原始日志. 部分来源包含用户名及个人配置背景, 用户明确接受保留; 这不等于绝对排除所有未识别风险.

## 按需恢复

先用 `git log --first-parent refs/gaw/HEAD -- memory/architecture.md memory/consolidation.md` 定位相关主题的 Formal 整合记录, 用 `git gaw show --no-patch --format=raw <integration>` 检查 parents, 再检查候选来源 tree 中的表列 UUID 与路径. 用 `git show <source-parent>:<uuid>/memory/current.md` 读取归纳, 用 `git log --first-parent <source-parent>` 查看该来源演化. 不根据 parent 位置赋予固定业务角色, 不需要重新创建 Auxiliary 才能查阅.

来源可达只说明历史保留, 不证明每条知识均经独立验证或已经采纳. 历史检查, 用户运行报告, 本轮静态核对与当前执行验证必须分开. 当前实现取代的提议不恢复成当前 API; 旧工作区, 截断结果及未复现行为的证据缺口不由摘要一致性填补. 原始材料未随新来源保留, 无法依靠本索引复原完整日志.

重要纠错已落实在 architecture.md: Noctalia 最终天气设置为关闭, 不采用早期试开状态; 内部接口与 UID 约束按现行实现解释. 历史维护的长期经验是先审阅拟持久保存的材料, 再建立来源历史, 并在提交前检查最终内容及新增事件; 不以事后删除分支替代敏感性审阅. 个人配置背景经用户确认可保留, 凭据值不属于这一许可.
